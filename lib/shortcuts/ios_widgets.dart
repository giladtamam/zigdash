import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage/secure_storage.dart';
import '../data/database/daos/device_registry_dao.dart';
import '../data/database/database.dart';
import '../data/database/tables/connections.dart';
import '../data/database/tables/panels.dart';
import '../features/devices/device_profile.dart';
import '../features/devices/device_state.dart';
import '../features/panels/models/panel_config.dart';
import '../l10n/app_localizations.dart';
import '../features/panels/providers/panel_value_provider.dart' show composeTopic;
import 'shortcut_service.dart' show appChannel;
import 'shortcut_store.dart';

/// What the iOS widgets read (docs/design/ios.md, iOS 3). A widget runs in
/// its own process with no Flutter, so everything it needs is worked out
/// here: each dashboard device's topics and the exact payloads a tap sends,
/// each Home's broker, the words to show, and the last state the app saw.
/// The Swift side only connects, publishes and waits for the state.
Map<String, Object?> iosWidgetDevice({
  required String connectionId,
  required String home,
  required String ieee,
  required String name,
  required String publishTopic,
  required String subscribeTopic,
  required DeviceProfile profile,
}) {
  final cover = profile.deviceClass == DeviceClass.cover;
  final sw = profile.switches.firstOrNull;
  return {
    ...encodeControl(
        connectionId: connectionId, home: home, ieee: ieee, name: name, profile: profile),
    'pub': publishTopic,
    'sub': subscribeTopic,
    if (cover) ...{
      'open': DeviceCommand.cover('OPEN'),
      'close': DeviceCommand.cover('CLOSE'),
      'stop': DeviceCommand.cover('STOP'),
      if (profile.position != null) 'positionProperty': profile.position!.property,
    } else if (sw != null) ...{
      'property': sw.property,
      'on': {sw.property: sw.valueOn ?? true},
      'off': {sw.property: sw.valueOff ?? false},
      'toggle': DeviceCommand.toggle(sw, null),
      'onValue': sw.valueOn ?? true,
    },
  };
}

/// A Home as a widget reaches it: straight to the broker over MQTT (TCP or
/// TLS), or not at all ([direct] false: Home Assistant, WebSocket and relay
/// Homes open the app instead).
Map<String, Object?> iosWidgetHome(Connection c) {
  final direct = transportOf(c.transport) == ConnectionTransport.mqtt &&
      (c.protocol == MqttProtocol.tcp || c.protocol == MqttProtocol.tcpSsl);
  return {
    'name': c.name,
    'direct': direct,
    if (direct) ...{
      'host': c.host,
      'port': c.port,
      'tls': c.protocol == MqttProtocol.tcpSsl,
      if (c.remoteHost != null && c.remoteHost!.isNotEmpty) 'remoteHost': c.remoteHost,
      if (c.username != null && c.username!.isNotEmpty) 'username': c.username,
    },
  };
}

Map<String, String> iosWidgetStrings(AppLocalizations l10n) => {
      'on': l10n.deviceOn,
      'off': l10n.deviceOff,
      'opened': l10n.deviceOpen,
      'closed': l10n.deviceClosed,
      'open': l10n.panelCoverOpen,
      'stop': l10n.panelCoverStop,
      'close': l10n.panelCoverClose,
      'working': l10n.shortcutWorking,
      'cantReach': l10n.shortcutCantReach,
      'notConfirmed': l10n.shortcutNotConfirmed,
      'removed': l10n.shortcutRemoved,
      'chooseDevice': l10n.shortcutChooseDevice,
    };

/// Hands the widgets' data to iOS (AppChannel.swift `shareWidgets`), with
/// the direct Homes' passwords for the shared Keychain. Nothing elsewhere.
Future<void> shareIosWidgets(
    AppDatabase db, SharedPreferences prefs, AppLocalizations l10n) async {
  if (defaultTargetPlatform != TargetPlatform.iOS) return;
  final homes = <String, Object?>{};
  final devices = <Map<String, Object?>>[];
  final states = <String, Object?>{};
  final passwords = <String, String>{};
  final store = createSecureStore();
  for (final conn in await db.select(db.connections).get()) {
    final home = iosWidgetHome(conn);
    homes[conn.id] = home;
    if (home['direct'] == true && conn.username != null) {
      final pw = await store.readPassword(conn.id);
      if (pw != null && pw.isNotEmpty) passwords[conn.id] = pw;
    }
    final seen = <String>{};
    for (final (panel, prefix) in await DeviceRegistryDao(db).tilesOfHome(conn.id)) {
      final ieee = panel.deviceIeee;
      if (panel.type != PanelType.device || ieee == null || !seen.add(ieee)) continue;
      final config = PanelConfig.decode(panel.type, panel.config);
      if (config is! DeviceTileConfig) continue;
      final effective = panel.topicPrefixOverride ?? prefix;
      devices.add(iosWidgetDevice(
        connectionId: conn.id,
        home: conn.name,
        ieee: ieee,
        name: panel.name,
        publishTopic: composeTopic(effective, panel.topic),
        subscribeTopic: composeTopic(effective, panel.subscribeTopic ?? panel.topic),
        profile: config.profile,
      ));
      final kept = prefs.getString(shortcutStateKey(conn.id, ieee));
      if (kept != null) states['${conn.id}/$ieee'] = jsonDecode(kept);
    }
  }
  try {
    await appChannel.invokeMethod('shareWidgets', {
      'data': jsonEncode({
        'homes': homes,
        'devices': devices,
        'states': states,
        'strings': iosWidgetStrings(l10n),
      }),
      'passwords': passwords,
    });
  } on MissingPluginException {
    // An iOS build without the widgets.
  }
}
