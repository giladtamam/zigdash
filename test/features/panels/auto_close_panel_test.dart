import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/panels/services/auto_close_config_publisher.dart';
import 'package:zigdash/features/panels/widgets/auto_close_panel.dart';
import 'package:zigdash/l10n/app_localizations.dart';

Panel _panel({String name = 'Door auto-close'}) => Panel(
      id: 'p1',
      dashboardId: 'd1',
      name: name,
      type: PanelType.autoClose,
      topic: 'door',
      subscribeTopic: null,
      topicPrefixOverride: null,
      qos: 1,
      retain: false,
      width: PanelWidth.full,
      sortOrder: 0,
      config: '{}',
      mergeFlags: 0,
      createdAt: DateTime(2026, 6, 20),
      updatedAt: DateTime(2026, 6, 20),
    );

Widget _wrap(Widget child, {required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AutoClosePanel status line', () {
    testWidgets('renders Idle when state.status = idle and bridge online',
        (tester) async {
      await tester.pumpWidget(_wrap(
        AutoClosePanel(
          connectionId: 'c1',
          triggerTopic: 'zigbee2mqtt/door',
          target: 'zigbee2mqtt/door/set',
          panel: _panel(),
          config: AutoCloseConfig(),
        ),
        overrides: [
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.stateTopic('p1'),
            jsonPath: null,
          )).overrideWith(
              (ref) => Stream.value('{"status":"idle","enabled":true}')),
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.bridgeStateTopic,
            jsonPath: null,
          )).overrideWith((ref) => Stream.value('online')),
        ],
      ));
      // pumpAndSettle would loop forever because of the 1s periodic Timer;
      // a couple of microtask drains is enough to render the first frame
      // after the streams resolve.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining('Idle'), findsOneWidget);
    });

    testWidgets('renders Disabled when state.status = disabled',
        (tester) async {
      await tester.pumpWidget(_wrap(
        AutoClosePanel(
          connectionId: 'c1',
          triggerTopic: 'zigbee2mqtt/door',
          target: 'zigbee2mqtt/door/set',
          panel: _panel(),
          config: AutoCloseConfig(enabled: false),
        ),
        overrides: [
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.stateTopic('p1'),
            jsonPath: null,
          )).overrideWith(
              (ref) => Stream.value('{"status":"disabled","enabled":false}')),
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.bridgeStateTopic,
            jsonPath: null,
          )).overrideWith((ref) => Stream.value('online')),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining('Disabled'), findsOneWidget);
    });

    testWidgets('renders Offline when bridge heartbeat != "online"',
        (tester) async {
      await tester.pumpWidget(_wrap(
        AutoClosePanel(
          connectionId: 'c1',
          triggerTopic: 'zigbee2mqtt/door',
          target: 'zigbee2mqtt/door/set',
          panel: _panel(),
          config: AutoCloseConfig(),
        ),
        overrides: [
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.stateTopic('p1'),
            jsonPath: null,
          )).overrideWith(
              (ref) => Stream.value('{"status":"idle","enabled":true}')),
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.bridgeStateTopic,
            jsonPath: null,
          )).overrideWith((ref) => Stream.value('offline')),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('shows a countdown for status = pending', (tester) async {
      final future = DateTime.now()
          .toUtc()
          .add(const Duration(seconds: 45))
          .toIso8601String();
      await tester.pumpWidget(_wrap(
        AutoClosePanel(
          connectionId: 'c1',
          triggerTopic: 'zigbee2mqtt/door',
          target: 'zigbee2mqtt/door/set',
          panel: _panel(),
          config: AutoCloseConfig(),
        ),
        overrides: [
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.stateTopic('p1'),
            jsonPath: null,
          )).overrideWith((ref) => Stream.value(
              '{"status":"pending","enabled":true,"pendingCloseAt":"$future"}')),
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.bridgeStateTopic,
            jsonPath: null,
          )).overrideWith((ref) => Stream.value('online')),
        ],
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      // The exact remaining seconds depends on test-runner timing; assert that
      // SOME positive whole-seconds countdown text is shown (e.g., "44s").
      expect(find.textContaining(RegExp(r'\b\d+s\b')), findsOneWidget);
    });
  });
}
