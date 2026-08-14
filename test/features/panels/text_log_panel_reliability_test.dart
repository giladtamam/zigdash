import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/panels/widgets/text_log_panel.dart';
import 'package:zigdash/l10n/app_localizations.dart';

PanelValueSnapshot _snapshot({
  required DateTime receivedAt,
  required PanelFreshness freshness,
}) => PanelValueSnapshot(
  value: 'door opened',
  receivedAt: receivedAt,
  connectionGeneration: 3,
  freshness: freshness,
);

void main() {
  testWidgets('status transitions do not duplicate retained log messages', (
    tester,
  ) async {
    final snapshots = StreamController<PanelValueSnapshot>.broadcast();
    final values = StreamController<Object?>.broadcast();
    addTearDown(snapshots.close);
    addTearDown(values.close);
    const key = PanelStreamKey(
      connectionId: 'c1',
      topic: 'home/events',
      jsonPath: null,
    );
    final panel = Panel(
      id: 'p1',
      dashboardId: 'd1',
      name: 'Events',
      type: PanelType.textLog,
      topic: 'events',
      subscribeTopic: null,
      topicPrefixOverride: null,
      qos: 1,
      retain: false,
      width: PanelWidth.full,
      sortOrder: 0,
      config: const TextLogConfig().encode(),
      mergeFlags: 0,
      createdAt: DateTime(2026, 8, 14),
      updatedAt: DateTime(2026, 8, 14),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        panelValueSnapshotProvider(key).overrideWith((ref) => snapshots.stream),
        panelValueProvider(key).overrideWith((ref) => values.stream),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TextLogPanel(
            connectionId: 'c1',
            subscribeTopic: 'home/events',
            panel: panel,
            config: const TextLogConfig(),
          ),
        ),
      ),
    ));

    final firstReceivedAt = DateTime(2026, 8, 14, 10);
    snapshots.add(_snapshot(
      receivedAt: firstReceivedAt,
      freshness: PanelFreshness.fresh,
    ));
    values.add('door opened');
    await tester.pump(const Duration(milliseconds: 20));
    snapshots.add(_snapshot(
      receivedAt: firstReceivedAt,
      freshness: PanelFreshness.stale,
    ));
    values.add('door opened');
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.textContaining('door opened'), findsOneWidget);

    snapshots.add(_snapshot(
      receivedAt: firstReceivedAt.add(const Duration(seconds: 1)),
      freshness: PanelFreshness.fresh,
    ));
    values.add('door opened');
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.textContaining('door opened'), findsNWidgets(2));
  });
}
