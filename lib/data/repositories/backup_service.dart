import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/panels/models/panel_config.dart';
import '../database/tables/panels.dart';
import 'dashboard_repo.dart';
import 'panel_repo.dart';

/// Exports and imports a connection's dashboards (and their panels) as a JSON
/// document, so a setup can be backed up or copied to another device. IDs and
/// timestamps are regenerated on import; the imported dashboards are attached
/// to the target connection.
class BackupService {
  BackupService(this._dashboards, this._panels);

  final DashboardRepo _dashboards;
  final PanelRepo _panels;

  static const int formatVersion = 1;

  Future<String> exportConnection(String connectionId) async {
    final dashboards = await _dashboards.getByConnection(connectionId);
    final out = <String, dynamic>{
      'version': formatVersion,
      'dashboards': [
        for (final d in dashboards)
          {
            'name': d.name,
            'topicPrefix': d.topicPrefix,
            'colorSeed': d.colorSeed,
            'iconCodepoint': d.iconCodepoint,
            'locked': d.locked,
            'sortOrder': d.sortOrder,
            'panels': [
              for (final p in await _panels.getByDashboard(d.id))
                {
                  'name': p.name,
                  'type': p.type.name,
                  'topic': p.topic,
                  'subscribeTopic': p.subscribeTopic,
                  'topicPrefixOverride': p.topicPrefixOverride,
                  'qos': p.qos,
                  'retain': p.retain,
                  'width': p.width.name,
                  'sortOrder': p.sortOrder,
                  'config': json.decode(p.config),
                },
            ],
          },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(out);
  }

  /// Returns the number of dashboards imported. Throws [FormatException] on
  /// malformed input.
  Future<int> importToConnection(String connectionId, String raw) async {
    final doc = json.decode(raw);
    if (doc is! Map || doc['dashboards'] is! List) {
      throw const FormatException('Not a ZigDash backup (missing dashboards)');
    }
    final dashboards = doc['dashboards'] as List;
    for (final d in dashboards.cast<Map<String, dynamic>>()) {
      final dashboardId = await _dashboards.create(
        connectionId: connectionId,
        name: (d['name'] as String?)?.trim().isNotEmpty == true
            ? d['name'] as String
            : 'Imported',
        topicPrefix: d['topicPrefix'] as String?,
        colorSeed: (d['colorSeed'] as num?)?.toInt() ?? 0xFF6750A4,
        iconCodepoint: (d['iconCodepoint'] as num?)?.toInt() ?? 0xe1ac,
        locked: d['locked'] as bool? ?? false,
        sortOrder: (d['sortOrder'] as num?)?.toInt() ?? 0,
      );
      final panels = (d['panels'] as List?) ?? const [];
      for (final p in panels.cast<Map<String, dynamic>>()) {
        final type = _parsePanelType(p['type'] as String?);
        final config = PanelConfig.decode(type, json.encode(p['config'] ?? {}));
        await _panels.create(
          dashboardId: dashboardId,
          name: (p['name'] as String?) ?? 'Panel',
          type: type,
          topic: (p['topic'] as String?) ?? '',
          subscribeTopic: p['subscribeTopic'] as String?,
          topicPrefixOverride: p['topicPrefixOverride'] as String?,
          qos: (p['qos'] as num?)?.toInt() ?? 1,
          retain: p['retain'] as bool? ?? false,
          width: _parsePanelWidth(p['width'] as String?),
          sortOrder: (p['sortOrder'] as num?)?.toInt() ?? 0,
          config: config,
        );
      }
    }
    return dashboards.length;
  }

  static PanelType _parsePanelType(String? s) {
    return PanelType.values.firstWhere(
      (t) => t.name == s,
      orElse: () => PanelType.button,
    );
  }

  static PanelWidth _parsePanelWidth(String? s) {
    return PanelWidth.values.firstWhere(
      (w) => w.name == s,
      orElse: () => PanelWidth.full,
    );
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    ref.watch(dashboardRepoProvider),
    ref.watch(panelRepoProvider),
  );
});
