import 'dart:convert';
import 'dart:typed_data';

import 'package:zigdash/features/chat/chat_api.dart';
import 'package:zigdash/features/chat/chat_hub.dart';
import 'package:zigdash/remote/remote_home.dart';

final relayLogin = RemoteHome(
  homeId: 'h0me1d',
  url: 'wss://relay.example/mqtt',
  username: 'phone-h0me1d-ff',
  password: 'x',
  key: Uint8List(32),
);

/// The relay's ticket route and the chat service, in memory. [log] is
/// shared with [FakeChatHub] so tests can check the order of steps.
class FakeChatApi implements ChatApi {
  FakeChatApi(this.log);
  final List<String> log;

  ChatFail? ticketFails;
  ChatFail? linkFails;
  ChatFail? unlinkFails;
  String goodCode = '4821';
  Uri? linkUrl;

  /// Answers to the next confirm calls, before the code is checked.
  final confirmFails = <ChatException>[];
  var listed = <ChatLinkInfo>[];
  final linked = <String, Map<String, String>>{};
  final tickets = <Map<String, String?>>[];
  var _n = 0;

  @override
  Future<String> ticket(String connectionId, {String? clientId, String? requestTopic, String? answerTopic}) async {
    log.add('ticket${clientId == null ? '' : ' $clientId'}');
    if (ticketFails != null) throw ChatException(ticketFails!);
    tickets.add({'client_id': clientId, 'request_topic': requestTopic, 'answer_topic': answerTopic});
    return 'ticket-${++_n}${clientId == null ? '' : ':$clientId'}';
  }

  @override
  Future<ChatLinkCode> link({required String ticket, required String token, required String key, required String scope}) async {
    log.add('link $scope');
    if (linkFails != null) throw ChatException(linkFails!);
    linked[ticket] = {'token': token, 'key': key, 'scope': scope};
    return (code: 'LK7Q2F9', url: linkUrl);
  }

  @override
  Future<ChatLinkInfo?> confirm({required String ticket, required String codeBack}) async {
    log.add('confirm $codeBack');
    if (confirmFails.isNotEmpty) throw confirmFails.removeAt(0);
    if (codeBack != goodCode) throw const ChatException(ChatFail.wrongCode, triesLeft: 2);
    final id = ticket.split(':').last;
    final scope = linked.entries.firstWhere((e) => e.key.endsWith(':$id')).value['scope']!;
    final info = ChatLinkInfo(clientId: id, telegramName: 'Dana', scope: scope);
    listed = [...listed, info];
    return info;
  }

  @override
  Future<void> unlink({required String ticket, required String clientId}) async {
    log.add('service unlink $clientId');
    if (unlinkFails != null) throw ChatException(unlinkFails!);
    listed = [for (final l in listed) if (l.clientId != clientId) l];
  }

  @override
  Future<List<ChatLinkInfo>> links({required String ticket}) async {
    log.add('links');
    return listed;
  }
}

/// The hub's broker, in memory: at home or not.
class FakeChatHub implements ChatHub {
  FakeChatHub(this.log);
  final List<String> log;
  bool atHome = true;
  final configs = <String, Map<String, Object?>>{};
  List<ChatAuditEntry>? audits;

  @override
  Future<void> createClient(String connectionId, String clientId, String config) async {
    if (!atHome) throw const ChatException(ChatFail.notAtHome);
    log.add('hub create $clientId');
    configs[clientId] = jsonDecode(config) as Map<String, Object?>;
  }

  @override
  Future<bool> revokeClient(String connectionId, String clientId) async {
    if (!atHome) return false;
    log.add('hub revoke $clientId');
    configs.remove(clientId);
    return true;
  }

  @override
  Future<List<ChatAuditEntry>?> audit(String connectionId,
      {required String clientId, required String token, required Uint8List key, RemoteHome? relay}) async {
    log.add('audit $clientId');
    return audits;
  }
}
