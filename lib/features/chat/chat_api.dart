import 'dart:convert';
import 'dart:io';

import '../../remote/remote_setup.dart';

/// The chat service (tool/zigdash-chat). A test build points elsewhere with
/// `--dart-define=ZIGDASH_CHAT_API=http://<host>:8790`.
const chatApiBase = String.fromEnvironment('ZIGDASH_CHAT_API', defaultValue: 'https://chat.zigdash.app');

/// The Telegram bot a link code is sent to.
const chatBotName = String.fromEnvironment('ZIGDASH_CHAT_BOT', defaultValue: 'ZigDashHomeBot');

/// Why a Chat step didn't work, as the screen explains it and `chat_link
/// failed` counts it.
enum ChatFail {
  /// Linking writes to the hub over the home network.
  notAtHome('not_home'),

  /// ZigDash Engine on the hub is older than the one with Chat.
  engineOld('engine_old'),

  /// The relay or the chat service can't be reached.
  unreachable('unreachable'),

  /// The relay doesn't accept this phone's login (401).
  login('login'),

  /// Google Play says the purchase isn't valid, or isn't this Home's (402).
  purchase('purchase'),

  /// Too many tries this hour.
  tooMany('too_many'),

  /// The code ran out (10 minutes) or was cancelled after 3 wrong back-codes.
  expired('expired'),

  /// The 4-digit code from Telegram was wrong.
  wrongCode('wrong_code'),

  /// Anything else the service refused.
  refused('refused');

  const ChatFail(this.wire);
  final String wire;
}

class ChatException implements Exception {
  const ChatException(this.why);
  final ChatFail why;

  @override
  String toString() => 'ChatException(${why.wire})';
}

/// One linked Telegram account, as the chat service lists it.
class ChatLinkInfo {
  const ChatLinkInfo({required this.clientId, required this.telegramName, required this.scope, this.lastUsed});

  final String clientId;
  final String telegramName;

  /// `read` or `control`.
  final String scope;
  final DateTime? lastUsed;

  static ChatLinkInfo? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = j['client_id'];
    if (id is! String || id.isEmpty) return null;
    final used = j['last_used'];
    return ChatLinkInfo(
      clientId: id,
      telegramName: '${j['telegram_name'] ?? ''}',
      scope: j['scope'] == 'control' ? 'control' : 'read',
      lastUsed: used is num
          ? DateTime.fromMillisecondsSinceEpoch(used.toInt())
          : used is String
              ? DateTime.tryParse(used)
              : null,
    );
  }
}

/// The relay's ticket route and the chat service's link routes
/// (chat-linking.md §2). Every method throws [ChatException].
abstract class ChatApi {
  /// A ticket for this Home; for a link, [clientId] and its relay topics.
  Future<String> ticket(String connectionId, {String? clientId, String? requestTopic, String? answerTopic});

  /// Hands the client's token and key to the service; returns the link code.
  Future<String> link({required String ticket, required String token, required String key, required String scope});

  /// Finishes the claim with the 4-digit code Telegram showed.
  Future<void> confirm({required String ticket, required String codeBack});

  Future<void> unlink({required String ticket, required String clientId});

  Future<List<ChatLinkInfo>> links({required String ticket});
}

ChatFail _failOf(int status, Object? body, {ChatFail other = ChatFail.refused}) {
  final error = body is Map ? body['error'] : null;
  switch (error) {
    case 'wrong_code':
      return ChatFail.wrongCode;
    case 'expired' || 'cancelled' || 'unknown_code':
      return ChatFail.expired;
    case 'too_many':
      return ChatFail.tooMany;
  }
  return switch (status) {
    0 => ChatFail.unreachable,
    401 => ChatFail.login,
    402 => ChatFail.purchase,
    404 || 410 => ChatFail.expired,
    429 => ChatFail.tooMany,
    _ => other,
  };
}

class HttpChatApi implements ChatApi {
  HttpChatApi(this._remote, {HttpClient? http}) : _http = http ?? HttpClient();

  final RemoteSetup _remote;
  final HttpClient _http;

  Future<(int, Object?)> _call(String method, String path, {Map<String, Object?>? body, String? ticket}) async {
    try {
      final req = await _http.openUrl(method, Uri.parse('$chatApiBase$path')).timeout(const Duration(seconds: 15));
      req.headers.contentType = ContentType.json;
      if (ticket != null) req.headers.set('X-Chat-Ticket', ticket);
      if (body != null) req.write(jsonEncode(body));
      final res = await req.close().timeout(const Duration(seconds: 15));
      final text = await res.transform(utf8.decoder).join();
      Object? json;
      try {
        json = jsonDecode(text);
      } catch (_) {}
      return (res.statusCode, json);
    } catch (_) {
      return (0, null);
    }
  }

  @override
  Future<String> ticket(String connectionId, {String? clientId, String? requestTopic, String? answerTopic}) async {
    final (status, ticket) = await _remote.chatTicket(connectionId, extra: {
      'client_id': ?clientId,
      'request_topic': ?requestTopic,
      'answer_topic': ?answerTopic,
    });
    if (ticket == null) throw ChatException(_failOf(status, null));
    return ticket;
  }

  @override
  Future<String> link({required String ticket, required String token, required String key, required String scope}) async {
    final (status, body) =
        await _call('POST', '/v1/link', body: {'ticket': ticket, 'token': token, 'key': key, 'scope': scope});
    final code = body is Map ? body['code'] : null;
    if (status == 200 && code is String && code.isNotEmpty) return code;
    // A refused ticket here means it ran out, not a wrong login.
    throw ChatException(status == 401 ? ChatFail.expired : _failOf(status, body));
  }

  @override
  Future<void> confirm({required String ticket, required String codeBack}) async {
    final (status, body) = await _call('POST', '/v1/link/confirm', body: {'ticket': ticket, 'code_back': codeBack});
    if (status == 200) return;
    throw ChatException(_failOf(status, body, other: ChatFail.wrongCode));
  }

  @override
  Future<void> unlink({required String ticket, required String clientId}) async {
    final (status, body) = await _call('DELETE', '/v1/link/${Uri.encodeComponent(clientId)}', ticket: ticket);
    // Already gone counts as removed.
    if (status == 200 || status == 204 || status == 404) return;
    throw ChatException(_failOf(status, body));
  }

  @override
  Future<List<ChatLinkInfo>> links({required String ticket}) async {
    final (status, body) = await _call('GET', '/v1/links', ticket: ticket);
    final list = body is List ? body : (body is Map ? body['links'] : null);
    if (status != 200 || list is! List) throw ChatException(_failOf(status, body));
    return [for (final j in list) ?ChatLinkInfo.fromJson(j)];
  }
}
