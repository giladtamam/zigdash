import '../../../data/database/tables/connections.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../discovery/models/device_panel_suggestion.dart';
import '../../panels/models/panel_config.dart';
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
    required PanelRepo panels,
  })  : _connections = connections,
        _dashboards = dashboards,
        _panels = panels;

  final ConnectionRepo _connections;
  final DashboardRepo _dashboards;
  final PanelRepo _panels;

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
        name: host,
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
      var count = 0;
      for (final row in selected) {
        final s = row.suggestion;
        await _panels.create(
          dashboardId: dashboardId,
          name: s.name,
          type: s.type,
          topic: s.topicPrefixOverride,
          subscribeTopic: s.subscribeTopicSuffix.isEmpty
              ? s.topicPrefixOverride
              : '${s.topicPrefixOverride}/${s.subscribeTopicSuffix}',
          topicPrefixOverride: s.topicPrefixOverride,
          sortOrder: count,
          config: panelConfigFor(s),
        );
        count++;
      }
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
