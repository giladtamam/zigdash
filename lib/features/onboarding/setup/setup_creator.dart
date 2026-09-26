import '../../../data/database/tables/connections.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../data/repositories/dashboard_repo.dart';
import 'package:flutter/widgets.dart' show Locale;

import '../../../data/database/tables/panels.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../../data/repositories/section_repo.dart';
import '../../../l10n/app_localizations.dart';
import '../../devices/device_profile.dart';
import '../../discovery/models/device_panel_suggestion.dart';
import '../../panels/models/panel_config.dart';
import '../demo_service.dart' show isDemoConnection;
import 'recommendation_policy.dart';

/// The outcome of the idempotent setup-creation operation.
class SetupResult {
  const SetupResult({
    required this.connectionId,
    required this.dashboardId,
    required this.panelCount,
  });

  final String connectionId;
  final String dashboardId;
  final int panelCount;
}

/// The persistence seam of the setup creation — abstract so tests (and the
/// coordinator) don't need a live database.
abstract class SetupStore {
  Future<SetupResult> create({
    required String host,
    required int port,
    required MqttProtocol protocol,
    String? username,
    String? password,
    String base,
    String dashboardName,
    int dashboardColor,
    int dashboardIcon,
    required List<ReviewRow> selected,
  });
}

/// Saves the first-run setup — connection, dashboard, and the selected
/// panels — as one idempotent operation.
///
/// Idempotency: a completed [create] is cached; calling again with the same
/// input returns the same ids without inserting duplicates. A failed [create]
/// rolls back everything it inserted, so a retry starts from a clean slate
/// and can never leave a half-configured connection behind.
class SetupCreator implements SetupStore {
  SetupCreator({
    required ConnectionRepo connections,
    required DashboardRepo dashboards,
    required SectionRepo sections,
    required PanelRepo panels,
    AppLocalizations? l10n,
  })  : _connections = connections,
        _dashboards = dashboards,
        _sections = sections,
        _panels = panels,
        _l10n = l10n ?? lookupAppLocalizations(const Locale('en'));

  final ConnectionRepo _connections;
  final DashboardRepo _dashboards;
  final SectionRepo _sections;
  final PanelRepo _panels;
  final AppLocalizations _l10n;

  SetupResult? _done;

  @override
  Future<SetupResult> create({
    required String host,
    required int port,
    required MqttProtocol protocol,
    String? username,
    String? password,
    String base = 'zigbee2mqtt',
    String dashboardName = 'Home',
    int dashboardColor = 0xFF00696B,
    int dashboardIcon = 0xe88a, // Icons.home codepoint
    required List<ReviewRow> selected,
  }) async {
    final done = _done;
    if (done != null) return done;

    String? connectionId;
    String? dashboardId;
    try {
      connectionId = await _connections.create(
        name: await _homeName(),
        host: host,
        port: port,
        protocol: protocol,
        username: username,
        password: password,
        autoConnect: true,
      );
      dashboardId = await _dashboards.create(
        connectionId: connectionId,
        name: dashboardName,
        topicPrefix: base,
        colorSeed: dashboardColor,
        iconCodepoint: dashboardIcon,
      );
      final count = await _createTiles(dashboardId, base, selected);
      return _done = SetupResult(
        connectionId: connectionId,
        dashboardId: dashboardId,
        panelCount: count,
      );
    } catch (_) {
      // Roll back in reverse order; deletes are best-effort so the original
      // error surfaces, not a cleanup one.
      if (dashboardId != null) {
        try {
          await _dashboards.delete(dashboardId);
        } catch (_) {}
      }
      if (connectionId != null) {
        try {
          await _connections.delete(connectionId);
        } catch (_) {}
      }
      rethrow;
    }
  }
}

extension on SetupCreator {
  /// "My Home" for the first real home, then "Home 2", "Home 3"…; the host
  /// stays visible in the Homes list.
  Future<String> _homeName() async {
    final homes = (await _connections.watchAll().first)
        .where((c) => !isDemoConnection(c.host))
        .length;
    return homes == 0 ? _l10n.homeFirstName : _l10n.homeNumberedName(homes + 1);
  }

  /// One device tile per selected device, grouped into sections by class
  /// (Lights; Switches and covers; Sensors; Other), each section created
  /// only when it has tiles. A device without an IEEE address (hand-built
  /// fixtures only) falls back to its raw suggested panel.
  Future<int> _createTiles(
    String dashboardId,
    String base,
    List<ReviewRow> selected,
  ) async {
    final groups = <_Group, List<ReviewRow>>{};
    for (final row in selected) {
      final group = row.device.ieeeAddress == null
          ? _Group.none
          : _groupOf(classifyExposes(row.device.rawExposes).deviceClass);
      (groups[group] ??= []).add(row);
    }
    var count = 0;
    var sectionOrder = 0;
    for (final group in _Group.values) {
      final rows = groups[group];
      if (rows == null) continue;
      final sectionId = group == _Group.none
          ? null
          : await _sections.create(
              dashboardId: dashboardId,
              name: switch (group) {
                _Group.lights => _l10n.sectionLights,
                _Group.switches => _l10n.sectionSwitchesCovers,
                _Group.sensors => _l10n.sectionSensors,
                _Group.other || _Group.none => _l10n.sectionOther,
              },
              sortOrder: sectionOrder++,
            );
      for (final row in rows) {
        if (row.device.ieeeAddress == null) {
          await _createSuggested(dashboardId, row.suggestion, count);
        } else {
          await _createDevice(dashboardId, base, row, sectionId, count);
        }
        count++;
      }
    }
    return count;
  }

  Future<void> _createDevice(
    String dashboardId,
    String base,
    ReviewRow row,
    String? sectionId,
    int sortOrder,
  ) {
    final device = row.device;
    final profile = classifyExposes(device.rawExposes);
    final model = [?device.vendor, ?device.model].join(' ');
    return _panels.create(
      dashboardId: dashboardId,
      name: device.friendlyName,
      type: PanelType.device,
      topic: 'set',
      subscribeTopic: '',
      topicPrefixOverride: '$base/${device.friendlyName}',
      width: switch (profile.deviceClass) {
        DeviceClass.colorLight || DeviceClass.cover => PanelWidth.wide,
        _ => PanelWidth.small,
      },
      sortOrder: sortOrder,
      sectionId: sectionId,
      deviceIeee: device.ieeeAddress,
      config: DeviceTileConfig(
        profile: profile,
        model: model.isEmpty ? null : model,
      ),
    );
  }

  Future<void> _createSuggested(
    String dashboardId,
    PanelSuggestion s,
    int sortOrder,
  ) =>
      _panels.create(
        dashboardId: dashboardId,
        name: s.name,
        type: s.type,
        // Suffixes under the device's prefix, as the panel form stores
        // them: PanelTile composes prefix + suffix.
        topic: s.publishTopicSuffix,
        subscribeTopic: s.subscribeTopicSuffix,
        topicPrefixOverride: s.topicPrefixOverride,
        sortOrder: sortOrder,
        config: panelConfigFor(s),
      );
}

/// Setup's sections, in dashboard order.
enum _Group { lights, switches, sensors, other, none }

_Group _groupOf(DeviceClass c) => switch (c) {
      DeviceClass.colorLight || DeviceClass.light => _Group.lights,
      DeviceClass.switchPlug || DeviceClass.cover => _Group.switches,
      DeviceClass.leakSmoke ||
      DeviceClass.contact ||
      DeviceClass.motion ||
      DeviceClass.climate =>
        _Group.sensors,
      DeviceClass.generic => _Group.other,
    };

/// Maps a panel suggestion to its type-specific config. Unknown/unsupported
/// mappings fall back to the panel type's default config.
PanelConfig panelConfigFor(PanelSuggestion suggestion) {
  switch (suggestion.type.name) {
    case 'toggle':
      return ToggleConfig(
        jsonPath: suggestion.jsonPath,
        onMatch: suggestion.onMatch ?? 'ON',
      );
    case 'slider':
      return SliderConfig(
        jsonPath: suggestion.jsonPath,
        max: suggestion.sliderIsBrightness ? 254 : 100,
        valueTemplate: suggestion.sliderIsBrightness
            ? '{"brightness":{value}}'
            : '{"position":{value}}',
      );
    case 'led':
      return LedConfig(
        jsonPath: suggestion.jsonPath,
        onMatch: suggestion.onMatch ?? 'true',
      );
    case 'progress':
      return ProgressConfig(
        jsonPath: suggestion.jsonPath,
        unit: suggestion.unit,
      );
    case 'combo':
      return OptionsConfig(jsonPath: suggestion.jsonPath);
    default:
      return PanelConfig.defaultFor(suggestion.type);
  }
}
