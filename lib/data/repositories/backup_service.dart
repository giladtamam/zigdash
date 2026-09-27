import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/panels/models/panel_config.dart';
import '../database/database.dart';
import '../database/tables/panels.dart';
import 'connection_repo.dart';
import 'dashboard_repo.dart';
import 'panel_repo.dart';
import 'section_repo.dart';

/// Exports and imports a connection's dashboards (with their sections and
/// panels) as a JSON document, so a setup can be backed up or copied to
/// another device. IDs and timestamps are regenerated on import; the imported
/// dashboards are attached to the target connection.
///
/// Format 2 (1.12) adds sections, device links and the Small / Wide / Full
/// sizes. Format 1 backups still import: half and third become Small.
/// Format 3 (1.13) adds the home's Zigbee2MQTT base topic, applied on import
/// only when the target home has none set.
/// Last-known values are never part of a backup.
class BackupService {
  BackupService(this._dashboards, this._sections, this._panels, this._homes);

  final ConnectionRepo _homes;
  final DashboardRepo _dashboards;
  final SectionRepo _sections;
  final PanelRepo _panels;

  static const int formatVersion = 3;

  Future<String> exportConnection(String connectionId) async {
    final dashboards = await _dashboards.getByConnection(connectionId);
    final home = await _homes.getById(connectionId);
    final out = <String, dynamic>{
      'version': formatVersion,
      if (home?.z2mBaseTopic != null) 'z2mBaseTopic': home!.z2mBaseTopic,
      'dashboards': [
        for (final d in dashboards) await _exportDashboard(d),
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(out);
  }

  Future<Map<String, dynamic>> _exportDashboard(Dashboard d) async {
    final sections = await _sections.getByDashboard(d.id);
    final sectionIndex = {
      for (var i = 0; i < sections.length; i++) sections[i].id: i,
    };
    return {
      'name': d.name,
      'topicPrefix': d.topicPrefix,
      'colorSeed': d.colorSeed,
      'iconCodepoint': d.iconCodepoint,
      'locked': d.locked,
      'sortOrder': d.sortOrder,
      'sections': [
        for (final s in sections) {'name': s.name, 'sortOrder': s.sortOrder},
      ],
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
            'section': sectionIndex[p.sectionId],
            'deviceIeee': p.deviceIeee,
            'config': json.decode(p.config),
          },
      ],
    };
  }

  /// Returns the number of dashboards imported. Throws [FormatException] on
  /// malformed input.
  Future<int> importToConnection(String connectionId, String raw) async {
    final doc = json.decode(raw);
    if (doc is! Map || doc['dashboards'] is! List) {
      throw const FormatException('Not a ZigDash backup (missing dashboards)');
    }
    final dashboards = doc['dashboards'] as List;
    final base = doc['z2mBaseTopic'];
    if (base is String && base.trim().isNotEmpty) {
      final home = await _homes.getById(connectionId);
      if (home != null && home.z2mBaseTopic == null) {
        await _homes.setBaseTopic(connectionId, base);
      }
    }
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
      final sectionIds = <String>[];
      for (final sec in ((d['sections'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()) {
        final name = (sec['name'] as String?)?.trim();
        sectionIds.add(await _sections.create(
          dashboardId: dashboardId,
          name: name == null || name.isEmpty ? 'Section' : name,
          sortOrder: (sec['sortOrder'] as num?)?.toInt() ?? sectionIds.length,
        ));
      }
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
          width: PanelWidthLegacy.parse(p['width'] as String?),
          sortOrder: (p['sortOrder'] as num?)?.toInt() ?? 0,
          sectionId: _sectionAt(sectionIds, p['section']),
          deviceIeee: p['deviceIeee'] as String?,
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

  static String? _sectionAt(List<String> ids, Object? index) {
    if (index is! num) return null;
    final i = index.toInt();
    return i >= 0 && i < ids.length ? ids[i] : null;
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    ref.watch(dashboardRepoProvider),
    ref.watch(sectionRepoProvider),
    ref.watch(panelRepoProvider),
    ref.watch(connectionRepoProvider),
  );
});
