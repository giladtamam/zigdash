import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../features/pro/pro.dart' show proPurchaseToken, proStore;
import '../mqtt/endpoint.dart';
import '../mqtt/mqtt_manager.dart';
import '../mqtt/providers/mqtt_manager_provider.dart';
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

/// One phone with remote access to a Home.
class RemotePhone {
  const RemotePhone({required this.username, required this.created, required this.thisPhone});
  final String username;
  final DateTime created;
  final bool thisPhone;
}

/// Sets remote control up for a Home, and turns it off (zigdash-3.0.md §5).
class RemoteSetup {
  RemoteSetup(this._store, this._managerOf, {HttpClient? http, Future<String?> Function()? purchaseToken})
      : _http = http ?? HttpClient(),
        _purchaseToken = purchaseToken ?? proPurchaseToken;

  final RemoteHomeStore _store;
  final Future<MqttManager> Function(String connectionId) _managerOf;
  final HttpClient _http;
  final Future<String?> Function() _purchaseToken;

  Future<(int, Map<String, Object?>?)> _call(String method, String path,
      {Map<String, Object?>? body, RemoteHome? auth}) async {
    try {
      final req = await _http.openUrl(method, Uri.parse('$relayApi$path')).timeout(const Duration(seconds: 15));
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
    final (status, body) = await _call('POST', '/v1/homes', body: {'purchaseToken': token, 'store': proStore});
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

  /// The Home's phones on the relay, as this phone sees them; null when the
  /// relay can't be asked.
  Future<List<RemotePhone>?> phones(String connectionId) async {
    final home = await _store.read(connectionId);
    if (home == null) return null;
    final (status, body) = await _call('GET', '/v1/homes/${home.homeId}/phones', auth: home);
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
    if (status == 0) return RemoteSetupResult.unreachable;
    final hub = body?['hub'] as Map?;
    if (status != 200 || hub == null) return RemoteSetupResult.refused;
    mgr.publish(engineRemoteTopic, jsonEncode({
      'url': hub['url'], 'homeId': home.homeId, 'username': hub['username'], 'password': hub['password'],
      'key': base64.encode(home.key),
    }), '', qos: mc.MqttQos.atLeastOnce);
    return RemoteSetupResult.ready;
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
