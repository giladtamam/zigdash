import 'dart:async';
import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/database/tables/connections.dart';
import '../../data/repositories/connection_repo.dart';
import '../../mqtt/endpoint.dart';
import '../../mqtt/mqtt_manager.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import '../devices/devices_providers.dart' show homeBaseTopicProvider;
import '../discovery/models/z2m_device.dart';
import 'support_details.dart';
import 'support_log.dart';

/// App and phone facts for Support details.
typedef PlatformFacts = ({
  String appVersion,
  String build,
  String? android,
  String? phone,
});

final platformFactsProvider = FutureProvider<PlatformFacts>((ref) async {
  var version = '?', build = '?';
  String? android, phone;
  try {
    final info = await PackageInfo.fromPlatform();
    version = info.version;
    build = info.buildNumber;
  } catch (_) {}
  if (defaultTargetPlatform == TargetPlatform.android) {
    try {
      final a = await DeviceInfoPlugin().androidInfo;
      android = a.version.release;
      phone =
          '${a.manufacturer[0].toUpperCase()}${a.manufacturer.substring(1)} '
          '${a.model}';
    } catch (_) {}
  }
  return (appVersion: version, build: build, android: android, phone: phone);
});

/// Zigbee2MQTT's version from a `bridge/info` payload, read by name: the
/// payload also carries the whole config (broker URL, username, device
/// names), so nothing else is taken from it.
String? z2mVersionOf(String payload) {
  try {
    final j = jsonDecode(payload);
    final v = j is Map ? j['version'] : null;
    return v is String && v.length <= 32 ? v : null;
  } catch (_) {
    return null;
  }
}

/// Whether `bridge/state` says online; it is plain text before Zigbee2MQTT
/// 1.29 and `{"state":"online"}` after.
bool? bridgeOnlineOf(String payload) {
  final t = payload.trim();
  if (t == 'online') return true;
  if (t == 'offline') return false;
  try {
    final j = jsonDecode(t);
    final s = j is Map ? j['state'] : null;
    return s == 'online' ? true : (s == 'offline' ? false : null);
  } catch (_) {
    return null;
  }
}

/// Reads Zigbee2MQTT's version, bridge state and device count from their
/// retained topics, waiting at most [wait]. Null when nothing arrives.
Future<Z2mFacts?> z2mFactsOf(
  MqttManager mgr,
  String base, {
  Duration wait = const Duration(seconds: 2),
}) async {
  if (!mgr.isConnected) return null;
  String? version;
  bool? online;
  int? devices;
  final topics = {
    '$base/bridge/info': (String p) => version = z2mVersionOf(p),
    '$base/bridge/state': (String p) => online = bridgeOnlineOf(p),
    '$base/bridge/devices': (String p) => devices = p.trim().startsWith('[')
        ? parseBridgeDevices(p).length
        : null,
  };
  final done = Completer<void>();
  final subs = <StreamSubscription<MqttRxMessage>>[];
  // A topic can deliver twice (the cached value, then the retained one), so
  // wait for each topic, not for a number of messages.
  final arrived = <String>{};
  for (final MapEntry(key: topic, value: take) in topics.entries) {
    subs.add(
      mgr.subscribe(topic).listen((m) {
        take(m.payload);
        if (arrived.add(topic) &&
            arrived.length == topics.length &&
            !done.isCompleted) {
          done.complete();
        }
      }),
    );
  }
  await done.future.timeout(wait, onTimeout: () {});
  for (final s in subs) {
    await s.cancel();
  }
  for (final t in topics.keys) {
    mgr.unsubscribe(t);
  }
  if (version == null && online == null && devices == null) return null;
  return Z2mFacts(version: version, online: online, devices: devices);
}

String _protocolLabel(MqttProtocol p) => switch (p) {
  MqttProtocol.tcp => 'TCP',
  MqttProtocol.tcpSsl => 'TLS',
  MqttProtocol.ws => 'WebSocket',
  MqttProtocol.wss => 'WebSocket TLS',
};

typedef SupportQuery = ({String openedFrom, String? connectionId});

/// Support details for Get help, assembled when it opens.
final supportDetailsProvider = FutureProvider.autoDispose
    .family<SupportDetails, SupportQuery>((ref, q) async {
      final platform = await ref.watch(platformFactsProvider.future);
      final log = ref.read(supportLogProvider);
      await log.load();

      ConnectionFacts? connection;
      Z2mFacts? z2m;
      final id = q.connectionId;
      // A failure here only drops the home's lines: support must stay reachable.
      if (id != null) {
        try {
          final conn = await ref.read(connectionRepoProvider).getById(id);
          if (conn != null) {
            MqttManager? mgr;
            try {
              mgr = await ref
                  .read(mqttManagerProvider(id).future)
                  .timeout(const Duration(seconds: 2));
            } catch (_) {}
            final remote = mgr?.activeEndpoint == MqttEndpoint.remote;
            final host = remote ? (conn.remoteHost ?? conn.host) : conn.host;
            connection = ConnectionFacts(
              remote: remote,
              protocol: _protocolLabel(conn.protocol),
              port: conn.port,
              shape: addressShape(host),
            );
            final base = ref.read(homeBaseTopicProvider(id)) ?? 'zigbee2mqtt';
            if (mgr != null) z2m = await z2mFactsOf(mgr, base);
          }
        } catch (_) {}
      }

      return SupportDetails(
        appVersion: platform.appVersion,
        build: platform.build,
        android: platform.android,
        phone: platform.phone,
        openedFrom: q.openedFrom,
        connection: connection,
        z2m: z2m,
        lastFailure: log.lastFailure,
        lastScan: log.lastScan,
      );
    });
