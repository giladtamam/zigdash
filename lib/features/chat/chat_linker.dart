import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/daos/device_registry_dao.dart';
import '../../data/database/database.dart';
import '../../engine/engine_providers.dart';
import '../../engine/engine_status.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import '../../remote/remote_home.dart';
import '../../remote/remote_setup.dart';
import '../pro/pro.dart';
import '../settings/providers/settings_controller.dart' show sharedPreferencesProvider;
import 'chat_api.dart';
import 'chat_hub.dart';
import 'chat_store.dart';
import 'chat_wire.dart';

/// The first ZigDash Engine with Chat in it (chat-linking.md §1).
const chatMinEngine = '3.7.0';

/// Whether [report]'s Engine takes Chat clients: an older one would leave
/// the client's key retained on the broker.
bool engineHasChat(EngineReport? report) {
  final have = parseVersion(report?.version ?? '');
  final want = parseVersion(chatMinEngine);
  return have != null && want != null && compareVersions(have, want) >= 0;
}

/// A link waiting for the 4-digit code Telegram shows.
class PendingChatLink {
  PendingChatLink({required this.client, required this.code, required this.ticket, required this.ticketAt, required this.topics});

  final LocalChatClient client;

  /// `L` and six characters, for `t.me/<bot>?start=<code>`.
  final String code;
  String ticket;
  DateTime ticketAt;
  final ({String req, String res}) topics;

  Uri get telegram => Uri.parse('https://t.me/$chatBotName?start=$code');
}

/// Links, lists and removes Chat accounts for a Home (chat-linking.md §3):
/// the hub over the home network, the relay's ticket, the chat service.
class ChatLinker {
  ChatLinker(this._api, this._hub, this._store, this._relayOf, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final ChatApi _api;
  final ChatHub _hub;
  final ChatStore _store;
  final Future<RemoteHome?> Function(String connectionId) _relayOf;
  final DateTime Function() _now;

  /// Tickets last 10 minutes; a fresh one is asked for after 8.
  static const ticketFor = Duration(minutes: 8);

  /// An unconfirmed link older than this is dropped from the hub.
  static const abandonedAfter = Duration(minutes: 15);

  Future<void> _save(String connectionId, ChatHomeRecord Function(ChatHomeRecord) change) async =>
      _store.write(connectionId, change(await _store.read(connectionId)));

  /// Steps 1-3 of linking: a client on the hub, a ticket, a link code.
  /// At home only. On any failure the hub client is taken back.
  Future<PendingChatLink> start(
    String connectionId, {
    required String scope,
    required List<String> controls,
    required bool atHome,
    required bool engineReady,
  }) async {
    if (!atHome) throw const ChatException(ChatFail.notAtHome);
    if (!engineReady) throw const ChatException(ChatFail.engineOld);
    final relay = await _relayOf(connectionId);
    if (relay == null) throw const ChatException(ChatFail.login);
    final client = LocalChatClient(
      clientId: ChatWire.newClientId(),
      token: ChatWire.newToken(),
      key: ChatWire.newKey(),
      scope: scope == 'control' ? 'control' : 'read',
      created: _now(),
    );
    final topics = ChatWire.relayTopics(relay.homeId, client.clientId, client.key);
    // The ticket first: a refused purchase leaves nothing on the hub.
    final ticket = await _api.ticket(connectionId,
        clientId: client.clientId, requestTopic: topics.req, answerTopic: topics.res);
    // Keys before the hub, as cli.mjs: a hub client whose key is lost could
    // never be read or tidied.
    await _save(connectionId, (r) => ChatHomeRecord(clients: [...r.clients, client], revokeOnHub: r.revokeOnHub));
    try {
      await _hub.createClient(
        connectionId,
        client.clientId,
        ChatWire.clientConfig(
          name: 'Telegram',
          token: client.token,
          key: client.key,
          scope: client.scope,
          controls: client.scope == 'control' ? controls : const [],
        ),
      );
      final code = await _api.link(ticket: ticket, token: client.token, key: base64.encode(client.key), scope: client.scope);
      return PendingChatLink(client: client, code: code, ticket: ticket, ticketAt: _now(), topics: topics);
    } catch (_) {
      await _dropClient(connectionId, client.clientId);
      rethrow;
    }
  }

  /// Step 4: the code Telegram showed. Throws [ChatException]
  /// (`wrongCode`, or `expired` after 3 wrong ones or 10 minutes).
  Future<void> confirm(String connectionId, PendingChatLink link, String codeBack) async {
    if (_now().difference(link.ticketAt) > ticketFor) {
      link.ticket = await _api.ticket(connectionId,
          clientId: link.client.clientId, requestTopic: link.topics.req, answerTopic: link.topics.res);
      link.ticketAt = _now();
    }
    await _api.confirm(ticket: link.ticket, codeBack: codeBack.trim());
    await _save(connectionId, (r) => ChatHomeRecord(
          clients: [for (final c in r.clients) c.clientId == link.client.clientId ? c.confirm() : c],
          revokeOnHub: r.revokeOnHub,
        ));
  }

  /// A link left before it was confirmed: the service lets the code run
  /// out; the hub client goes now, or at home.
  Future<void> abandon(String connectionId, PendingChatLink link) => _dropClient(connectionId, link.client.clientId);

  Future<void> _dropClient(String connectionId, String clientId) async {
    var onHub = false;
    try {
      onHub = await _hub.revokeClient(connectionId, clientId);
    } catch (_) {}
    await _save(connectionId, (r) => ChatHomeRecord(
          clients: [for (final c in r.clients) if (c.clientId != clientId) c],
          revokeOnHub: onHub ? r.revokeOnHub : {...r.revokeOnHub, clientId},
        ));
  }

  /// The Home's linked accounts, from the service.
  Future<List<ChatLinkInfo>> links(String connectionId) async =>
      _api.links(ticket: await _api.ticket(connectionId));

  /// Removes one account: the service first (that alone ends access, since
  /// it no longer has the key), then the hub, now or when the phone is next
  /// at home. Returns whether the hub was reached.
  Future<bool> remove(String connectionId, String clientId) async {
    final ticket = await _api.ticket(connectionId, clientId: clientId);
    await _api.unlink(ticket: ticket, clientId: clientId);
    await _dropClient(connectionId, clientId);
    return !(await _store.read(connectionId)).revokeOnHub.contains(clientId);
  }

  /// At home: the hub deletions owed, and links never confirmed (the code
  /// ran out, the app was closed) that the service doesn't list.
  Future<void> tidy(String connectionId, {required List<ChatLinkInfo>? listed}) async {
    final record = await _store.read(connectionId);
    final owed = {...record.revokeOnHub};
    final listedIds = listed?.map((l) => l.clientId).toSet();
    final keep = <LocalChatClient>[];
    for (final c in record.clients) {
      final abandoned = !c.confirmed &&
          listedIds != null &&
          !listedIds.contains(c.clientId) &&
          _now().difference(c.created) > abandonedAfter;
      if (abandoned) {
        owed.add(c.clientId);
      } else {
        keep.add(c);
      }
    }
    final left = <String>{};
    for (final id in owed) {
      var done = false;
      try {
        done = await _hub.revokeClient(connectionId, id);
      } catch (_) {}
      if (!done) left.add(id);
    }
    if (keep.length != record.clients.length || left.length != record.revokeOnHub.length || !left.containsAll(record.revokeOnHub)) {
      await _store.write(connectionId, ChatHomeRecord(clients: keep, revokeOnHub: left));
    }
  }

  /// What Chat did, for the linked clients this phone holds the keys of,
  /// newest first; null when the hub didn't answer for any of them.
  Future<List<ChatAuditEntry>?> audit(String connectionId) async {
    final record = await _store.read(connectionId);
    final relay = await _relayOf(connectionId);
    List<ChatAuditEntry>? all;
    for (final c in record.clients.where((c) => c.confirmed)) {
      final entries = await _hub.audit(connectionId, clientId: c.clientId, token: c.token, key: c.key, relay: relay);
      if (entries != null) (all ??= []).addAll(entries);
    }
    all?.sort((a, b) => b.at.compareTo(a.at));
    return all;
  }
}

final chatApiProvider = Provider<ChatApi>((ref) => HttpChatApi(ref.watch(remoteSetupProvider)));

final chatHubProvider = Provider<ChatHub>((ref) => MqttChatHub((id) => ref.read(mqttManagerProvider(id).future)));

final chatStoreProvider = Provider<ChatStore>((ref) => SecureChatStore());

final chatLinkerProvider = Provider<ChatLinker>((ref) => ChatLinker(
      ref.watch(chatApiProvider),
      ref.watch(chatHubProvider),
      ref.watch(chatStoreProvider),
      (id) => ref.read(remoteHomeStoreProvider).read(id),
    ));

/// Whether this build offers Chat: the Google Play build. Not the GitHub or
/// F-Droid builds (no Pro to check), nor the App Store's (the ticket route
/// checks Play purchases; chat-linking.md §3).
final chatOfferedProvider = Provider<bool>((ref) => proFlavor == 'play');

/// What Home settings › Chat shows.
enum ChatRowState {
  /// Not in this build, Pro isn't sold here, or a Home the relay can't serve.
  hidden,

  /// Pro isn't owned (the trial doesn't count).
  noPro,

  /// Remote control is off for this Home.
  noRemote,

  /// ZigDash Engine was never seen on the hub.
  noEngine,
  ready,
}

ChatRowState chatRowStateOf({
  required bool offered,
  required bool fits,
  required ProStatus pro,
  required bool remoteOn,
  required bool engineInstalled,
}) {
  if (!offered || !fits || pro == ProStatus.unavailable) return ChatRowState.hidden;
  if (pro != ProStatus.unlocked) return ChatRowState.noPro;
  if (!remoteOn) return ChatRowState.noRemote;
  if (!engineInstalled) return ChatRowState.noEngine;
  return ChatRowState.ready;
}

final chatRowStateProvider = Provider.autoDispose.family<ChatRowState, String>((ref, connectionId) {
  return chatRowStateOf(
    offered: ref.watch(chatOfferedProvider),
    fits: ref.watch(remoteFitsProvider(connectionId)),
    pro: ref.watch(proStatusProvider),
    remoteOn: ref.watch(remoteHomeProvider(connectionId)).valueOrNull != null,
    engineInstalled: engineKnownInstalled(ref.watch(sharedPreferencesProvider), connectionId),
  );
});

/// Per IEEE address, the names of the tiles, sections and dashboards a
/// device is on in a Home: what the gate words are checked against.
final chatTileTagsProvider = StreamProvider.autoDispose.family<Map<String, List<String>>, String>(
    (ref, connectionId) => DeviceRegistryDao(ref.watch(appDatabaseProvider)).watchDeviceTags(connectionId));
