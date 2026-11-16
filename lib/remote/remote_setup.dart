import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../data/database/database.dart' show Connection;
import '../data/database/tables/connections.dart';
import '../data/repositories/connection_repo.dart';
import '../features/onboarding/demo_service.dart' show isDemoConnection;
import '../features/pro/pro.dart';
import '../mqtt/endpoint.dart';
import '../mqtt/mqtt_manager.dart';
import '../mqtt/mqtt_status.dart';
import '../mqtt/providers/mqtt_manager_provider.dart';
import 'founder.dart';
import 'remote_home.dart';
import 'remote_seal.dart';

/// The relay's API (`relay/verifier`). A test build points elsewhere with
/// `--dart-define=ZIGDASH_RELAY_API=http://<host>:8787`.
const relayApi = String.fromEnvironment('ZIGDASH_RELAY_API', defaultValue: 'https://relay.zigdash.app');

/// A test relay (not the production one) accepts "test-pro-…" tokens.
bool get relayIsTest => relayApi != 'https://relay.zigdash.app';

/// Topic ZigDash Engine takes its relay login from (never retained).
const engineRemoteTopic = 'zigdash/remote/set';

enum RemoteSetupResult { ready, noPro, notAtHome, refused, unreachable }

/// What the relay said to a founder's code (founders-pass.md, the wire
/// contract): `POST /v1/homes` with `store: "founder"`.
enum FounderRedeemResult {
  ready,

  /// 402 `no_pass`: no such code.
  wrongCode,

  /// 409 `code_used`: entered before (and not this phone's lost answer).
  used,

  /// 402 `deadline`: not entered by its date.
  deadline,

  /// 402 `revoked`: withdrawn.
  revoked,

  /// 429: too many tries from this network.
  tooMany,
  notAtHome,
  unreachable,
  refused,
}

/// What the relay said to moving a founder's Home to a Pro purchase
/// (`POST /v1/homes/<id>/upgrade`).
enum FounderUpgradeResult {
  done,

  /// No Pro purchase on this phone, or 402 `no_purchase`.
  noPurchase,

  /// 409 `purchase_has_home`: that purchase already has a Home.
  taken,

  /// 401: the relay doesn't take this phone's login.
  login,

  /// 404: the relay doesn't know the Home.
  notFound,

  /// 410 `deleted`.
  deleted,

  /// No answer: the only one tried again.
  unreachable,
  refused,
}

/// One phone with remote access to a Home.
class RemotePhone {
  const RemotePhone({required this.username, required this.created, required this.thisPhone});
  final String username;
  final DateTime created;
  final bool thisPhone;
}

/// Sets remote control up for a Home, and turns it off (zigdash-3.0.md §5).
class RemoteSetup {
  RemoteSetup(
    this._store,
    this._managerOf, {
    HttpClient? http,
    Future<String?> Function()? purchaseToken,
    String api = relayApi,
    String Function()? nonce,
    DateTime Function()? now,
  })  : _http = http ?? HttpClient(),
        _purchaseToken = purchaseToken ?? proPurchaseToken,
        _api = api,
        _nonce = nonce ?? newRedeemNonce,
        _now = now ?? DateTime.now;

  final RemoteHomeStore _store;
  final Future<MqttManager> Function(String connectionId) _managerOf;
  final HttpClient _http;
  final Future<String?> Function() _purchaseToken;
  final String _api;
  final String Function() _nonce;
  final DateTime Function() _now;

  Future<(int, Map<String, Object?>?)> _call(String method, String path,
      {Map<String, Object?>? body, RemoteHome? auth}) async {
    try {
      final req = await _http.openUrl(method, Uri.parse('$_api$path')).timeout(const Duration(seconds: 15));
      req.headers.contentType = ContentType.json;
      if (auth != null) {
        req.headers.set('Authorization', 'Basic ${base64.encode(utf8.encode('${auth.username}:${auth.password}'))}');
      }
      if (body != null) req.write(jsonEncode(body));
      final res = await req.close().timeout(const Duration(seconds: 15));
      final text = await res.transform(utf8.decoder).join();
      Map<String, Object?>? json;
      try {
        final d = jsonDecode(text);
        json = d is Map<String, Object?> ? d : {'list': d};
      } catch (_) {}
      return (res.statusCode, json);
    } catch (_) {
      return (0, null);
    }
  }

  /// At home, with Pro: the relay admits the Home, ZigDash Engine on the hub
  /// gets its login and a new key over the home network, this phone keeps
  /// its own login and the key.
  Future<RemoteSetupResult> setUp(String connectionId) async {
    final mgr = await _managerOf(connectionId);
    if (!mgr.isConnected || mgr.activeEndpoint == MqttEndpoint.relay) return RemoteSetupResult.notAtHome;
    final token = await _purchaseToken() ?? (relayIsTest && kDebugMode ? 'test-pro-$connectionId' : null);
    if (token == null) return RemoteSetupResult.noPro;
    final (status, body) = await _call('POST', '/v1/homes', body: {'purchaseToken': token});
    if (status == 0) return RemoteSetupResult.unreachable;
    if (status == 402) return RemoteSetupResult.noPro;
    if (status != 200 || body == null) return RemoteSetupResult.refused;
    final hub = body['hub'] as Map?;
    final phone = body['phone'] as Map?;
    final homeId = body['homeId'] as String?;
    if (hub == null || phone == null || homeId == null) return RemoteSetupResult.refused;
    final key = RemoteSeal.newKey();
    mgr.publish(engineRemoteTopic, jsonEncode({
      'url': hub['url'], 'homeId': homeId, 'username': hub['username'], 'password': hub['password'],
      'key': base64.encode(key),
    }), '', qos: mc.MqttQos.atLeastOnce);
    await _store.write(connectionId, RemoteHome(
      homeId: homeId, url: '${phone['url']}', username: '${phone['username']}', password: '${phone['password']}', key: key,
    ));
    return RemoteSetupResult.ready;
  }

  /// At home: a founder's code instead of a Pro purchase. The relay admits
  /// the Home for the pass, and the rest is [setUp]'s. The `redeem_nonce`
  /// is kept until the relay says yes, so a retry after a lost answer gets
  /// fresh logins for the same Home instead of "code already used".
  Future<FounderRedeemResult> redeem(String connectionId, String code) async {
    final mgr = await _managerOf(connectionId);
    if (!mgr.isConnected || mgr.activeEndpoint != MqttEndpoint.local) return FounderRedeemResult.notAtHome;
    var nonce = await _store.readRedeemNonce(connectionId);
    if (nonce == null) {
      nonce = _nonce();
      await _store.writeRedeemNonce(connectionId, nonce);
    }
    final (status, body) = await _call('POST', '/v1/homes', body: {
      'store': 'founder',
      'purchaseToken': normaliseFounderCode(code),
      'redeem_nonce': nonce,
    });
    final error = body?['error'];
    switch (status) {
      case 0:
        return FounderRedeemResult.unreachable;
      case 402:
        return switch (error) {
          'deadline' => FounderRedeemResult.deadline,
          'revoked' => FounderRedeemResult.revoked,
          _ => FounderRedeemResult.wrongCode,
        };
      case 409:
        return FounderRedeemResult.used;
      case 429:
        return FounderRedeemResult.tooMany;
    }
    final hub = body?['hub'] as Map?;
    final phone = body?['phone'] as Map?;
    final homeId = body?['homeId'] as String?;
    if (status != 200 || hub == null || phone == null || homeId == null) return FounderRedeemResult.refused;
    final key = RemoteSeal.newKey();
    mgr.publish(engineRemoteTopic, jsonEncode({
      'url': hub['url'], 'homeId': homeId, 'username': hub['username'], 'password': hub['password'],
      'key': base64.encode(key),
    }), '', qos: mc.MqttQos.atLeastOnce);
    await _store.write(connectionId, RemoteHome(
      homeId: homeId, url: '${phone['url']}', username: '${phone['username']}', password: '${phone['password']}', key: key,
    ));
    await _store.writeFounder(connectionId, FounderStatus.fromRelay({...body!, 'kind': 'founder'}, _now()));
    await _store.deleteRedeemNonce(connectionId);
    return FounderRedeemResult.ready;
  }

  /// Asks the relay what the Home is (`GET /v1/homes/<id>`) and keeps the
  /// answer with the login. 410 is a deleted Home. Null without a login or
  /// an answer; a stored status then stands.
  Future<FounderStatus?> founderStatus(String connectionId) async {
    final home = await _store.read(connectionId);
    if (home == null) return null;
    final (status, body) = await _call('GET', '/v1/homes/${home.homeId}', auth: home);
    if (status == 410) return _noteEnd(connectionId, deleted: true);
    if (status != 200 || body == null) return null;
    final s = FounderStatus.fromRelay(body, _now());
    await _store.writeFounder(connectionId, s);
    return s;
  }

  /// A 402 `pass_ended` or a 410 from a phone route: kept, so the Remote
  /// and Chat screens say so before asking again.
  Future<FounderStatus?> _noteEnd(String connectionId, {bool deleted = false}) async {
    final old = await _store.readFounder(connectionId);
    final s = old == null
        ? FounderStatus(kind: deleted ? null : 'founder', ended: !deleted, deleted: deleted, fetchedAt: _now())
        : old.copyWith(ended: deleted ? old.ended : true, deleted: deleted ? true : old.deleted, fetchedAt: _now());
    await _store.writeFounder(connectionId, s);
    return s;
  }

  Future<void> _noteRefusal(String connectionId, int status, Map<String, Object?>? body) async {
    if (status == 402 && body?['error'] == 'pass_ended') await _noteEnd(connectionId);
    if (status == 410) await _noteEnd(connectionId, deleted: true);
  }

  /// Moves a founder's Home to this phone's Pro purchase: same Home, phones
  /// and Chat links. Only ever called after the person said so.
  Future<FounderUpgradeResult> upgrade(String connectionId) async {
    final home = await _store.read(connectionId);
    if (home == null) return FounderUpgradeResult.notFound;
    final token = await _purchaseToken() ?? (relayIsTest && kDebugMode ? 'test-pro-$connectionId' : null);
    if (token == null) return FounderUpgradeResult.noPurchase;
    final (status, body) = await _call('POST', '/v1/homes/${home.homeId}/upgrade',
        body: {'purchaseToken': token, 'store': 'play'}, auth: home);
    switch (status) {
      case 200:
        await _store.writeFounder(connectionId, FounderStatus(fetchedAt: _now()));
        return FounderUpgradeResult.done;
      case 0:
        return FounderUpgradeResult.unreachable;
      case 401:
        return FounderUpgradeResult.login;
      case 402:
        return FounderUpgradeResult.noPurchase;
      case 404:
        return FounderUpgradeResult.notFound;
      case 409:
        return FounderUpgradeResult.taken;
      case 410:
        await _noteEnd(connectionId, deleted: true);
        return FounderUpgradeResult.deleted;
    }
    return status >= 500 ? FounderUpgradeResult.unreachable : FounderUpgradeResult.refused;
  }

  /// The Home's phones on the relay, as this phone sees them; null when the
  /// relay can't be asked.
  Future<List<RemotePhone>?> phones(String connectionId) async {
    final home = await _store.read(connectionId);
    if (home == null) return null;
    final (status, body) = await _call('GET', '/v1/homes/${home.homeId}/phones', auth: home);
    await _noteRefusal(connectionId, status, body);
    if (status != 200 || body == null) return null;
    return [
      for (final p in (body['list'] as List? ?? const []))
        if (p is Map) RemotePhone(username: '${p['username']}', created: DateTime.fromMillisecondsSinceEpoch((p['created'] as num).toInt()), thisPhone: p['username'] == home.username),
    ]..sort((a, b) => a.created.compareTo(b.created));
  }

  /// A login for another phone of this Home, with the Home's key, for the
  /// QR code. Null when the relay refused (limit reached) or can't be asked.
  Future<RemoteHome?> newPhone(String connectionId) async {
    final home = await _store.read(connectionId);
    if (home == null) return null;
    final (status, body) = await _call('POST', '/v1/homes/${home.homeId}/phones', auth: home);
    await _noteRefusal(connectionId, status, body);
    final phone = body?['phone'] as Map?;
    if (status != 200 || phone == null) return null;
    return RemoteHome(homeId: home.homeId, url: '${phone['url']}', username: '${phone['username']}', password: '${phone['password']}', key: home.key);
  }

  /// Removes another phone from the relay (a lost or sold phone).
  Future<bool> removePhone(String connectionId, String username) async {
    final home = await _store.read(connectionId);
    if (home == null) return false;
    final (status, _) = await _call('DELETE', '/v1/homes/${home.homeId}/phones/$username', auth: home);
    return status == 200;
  }

  /// At home: a fresh hub login from the relay, handed to ZigDash Engine with
  /// the Home's existing key, so every paired phone keeps working.
  Future<RemoteSetupResult> reconnectHub(String connectionId) async {
    final home = await _store.read(connectionId);
    if (home == null) return RemoteSetupResult.refused;
    final mgr = await _managerOf(connectionId);
    if (!mgr.isConnected || mgr.activeEndpoint != MqttEndpoint.local) return RemoteSetupResult.notAtHome;
    final (status, body) = await _call('POST', '/v1/homes/${home.homeId}/hub', auth: home);
    await _noteRefusal(connectionId, status, body);
    if (status == 0) return RemoteSetupResult.unreachable;
    final hub = body?['hub'] as Map?;
    if (status != 200 || hub == null) return RemoteSetupResult.refused;
    mgr.publish(engineRemoteTopic, jsonEncode({
      'url': hub['url'], 'homeId': home.homeId, 'username': hub['username'], 'password': hub['password'],
      'key': base64.encode(home.key),
    }), '', qos: mc.MqttQos.atLeastOnce);
    return RemoteSetupResult.ready;
  }

  /// A ticket for ZigDash Chat (chat-linking.md §2): the relay checks this
  /// phone's login and asks Google Play about the Pro purchase again (for a
  /// founder's Home, the pass: no purchase is sent), and signs what the
  /// chat service may do for this Home for 10 minutes. [extra] names the
  /// Chat client being linked, when there is one. The status is the
  /// relay's (401 a wrong login, 402 the purchase isn't valid or isn't this
  /// Home's, or `pass_ended`, 0 unreachable) with its `error`; the ticket is
  /// null unless 200.
  Future<(int, String?, String?)> chatTicket(String connectionId, {Map<String, Object?> extra = const {}}) async {
    final home = await _store.read(connectionId);
    if (home == null) return (401, null, null);
    FounderStatus? founder;
    try {
      founder = await _store.readFounder(connectionId);
    } catch (_) {}
    String? token;
    if (founder?.founder != true) {
      token = await _purchaseToken() ?? (relayIsTest && kDebugMode ? 'test-pro-$connectionId' : null);
      if (token == null) return (402, null, null);
    }
    final (status, body) = await _call('POST', '/v1/homes/${home.homeId}/chat-ticket',
        body: {'purchase_token': ?token, ...extra}, auth: home);
    await _noteRefusal(connectionId, status, body);
    final ticket = body?['ticket'];
    final error = body?['error'];
    return (
      status,
      status == 200 && ticket is String && ticket.isNotEmpty ? ticket : null,
      error is String ? error : null,
    );
  }

  /// Keeps a login brought from another phone (QR code or backup file).
  Future<void> adopt(String connectionId, RemoteHome home) => _store.write(connectionId, home);

  /// Removes this phone from the relay and forgets the Home's login here;
  /// with [everywhere], also tells ZigDash Engine on the hub to disconnect.
  Future<void> turnOff(String connectionId, {bool everywhere = true}) async {
    final home = await _store.read(connectionId);
    if (home != null) {
      await _call('DELETE', '/v1/homes/${home.homeId}/phones/${home.username}', auth: home);
    }
    if (everywhere) {
      final mgr = await _managerOf(connectionId);
      if (mgr.isConnected) mgr.publish(engineRemoteTopic, jsonEncode({'off': true}), '', qos: mc.MqttQos.atLeastOnce);
    }
    await _store.delete(connectionId);
  }
}

final remoteSetupProvider = Provider<RemoteSetup>((ref) => RemoteSetup(
      ref.watch(remoteHomeStoreProvider),
      (id) => ref.read(mqttManagerProvider(id).future),
    ));

/// This phone's relay login for a Home, or null.
final remoteHomeProvider = FutureProvider.autoDispose.family<RemoteHome?, String>(
    (ref, connectionId) => ref.watch(remoteHomeStoreProvider).read(connectionId));

/// Whether this build sells Pro, and so remote control: the Play build
/// where Play offers Pro. Before Play answers, its last answer stands, so
/// the door to remote control doesn't pop in a moment after every start.
final remoteSoldProvider = Provider.autoDispose<bool>(
  (ref) =>
      proFlavor == 'play' &&
      (ref.watch(proStatusProvider) != ProStatus.unavailable ||
          ref.watch(proOfferedProvider)),
);

/// Whether remote control can work for [home] at all (3.4.4): a real home
/// connected to its own broker. A home carried by Home Assistant or by
/// Zigbee2MQTT's page never uses the relay (`endpointCandidates`), so
/// offering it remote control would sell something that can't work.
bool remoteFits(Connection home) =>
    !isDemoConnection(home.host) &&
    transportOf(home.transport) == ConnectionTransport.mqtt;

/// [remoteFits] for a stored home; false while it loads or when it's gone.
final remoteFitsProvider = Provider.autoDispose.family<bool, String>((
  ref,
  connectionId,
) {
  final home = ref.watch(connectionByIdProvider(connectionId)).valueOrNull;
  return home != null && remoteFits(home);
});

/// Whether this phone is at [connectionId]'s home right now: connected
/// straight to the broker on the home network, where remote control can be
/// turned on (not through the relay, nor the home's own remote address).
final atHomeProvider = Provider.autoDispose.family<bool, String>((
  ref,
  connectionId,
) {
  final status = ref.watch(connectionStatusProvider(connectionId)).valueOrNull;
  final mgr = ref.watch(mqttManagerProvider(connectionId)).valueOrNull;
  return status == MqttStatus.connected &&
      mgr?.activeEndpoint == MqttEndpoint.local;
});
