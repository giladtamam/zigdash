import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:rxdart/rxdart.dart';
import 'package:zigdash/core/theme/signal_colors.dart';
import 'package:zigdash/core/theme/signal_icons.dart';
import 'package:zigdash/core/utils/material_icon.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/widgets/panel_tile.dart';
import 'package:zigdash/features/panels/widgets/toggle_panel.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

// A custom toggle drawn as a device tile (3.8.7, own-switch-look-387.md):
// the real snapshot stream over a fake manager whose status$ emits.

class _Manager extends MqttManager {
  _Manager()
    : super(
        config: const BrokerConfig(
          id: 'c1',
          host: 'localhost',
          port: 1883,
          protocol: MqttProtocol.tcp,
        ),
        password: '',
      );

  final incoming = BehaviorSubject<MqttRxMessage>();
  final statuses = BehaviorSubject<MqttStatus>.seeded(MqttStatus.connected);
  final sent = <String>[];

  @override
  int get connectionGeneration => 1;
  @override
  bool get isConnected => true;
  @override
  Stream<MqttStatus> get status$ => statuses.stream;
  @override
  Stream<MqttRxMessage> subscribe(String pattern) => incoming.stream;
  @override
  void unsubscribe(String pattern) {}
  @override
  void publish(
    String topic,
    String template,
    Object value, {
    mc.MqttQos qos = mc.MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    sent.add(template);
  }

  void emit(String payload) => incoming.add(
    MqttRxMessage(
      topic: 'home/hall',
      payload: payload,
      receivedAt: DateTime.now(),
      connectionGeneration: 1,
    ),
  );
}

Panel _toggle(ToggleConfig config) => Panel(
  id: 'p1',
  dashboardId: 'd1',
  name: '1_Licht-Flur',
  type: PanelType.toggle,
  topic: 'hall/set',
  subscribeTopic: 'hall',
  topicPrefixOverride: null,
  qos: 1,
  retain: false,
  width: PanelWidth.small,
  sortOrder: 0,
  config: config.encode(),
  mergeFlags: 0,
  createdAt: DateTime(2026, 11, 21),
  updatedAt: DateTime(2026, 11, 21),
);

Future<_Manager> _pump(
  WidgetTester tester,
  ToggleConfig config, {
  Locale locale = const Locale('en'),
}) async {
  final mgr = _Manager();
  addTearDown(mgr.incoming.close);
  addTearDown(mgr.statuses.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mqttManagerProvider.overrideWith((ref, _) async => mgr),
        connectionStatusProvider.overrideWith(
          (ref, _) => Stream.value(MqttStatus.connected),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 220,
            child: PanelTile(
              connectionId: 'c1',
              dashboardId: 'd1',
              topicPrefix: 'home',
              panel: _toggle(config),
              locked: true,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return mgr;
}

Color? _cardColor(WidgetTester tester) => tester
    .widget<Card>(
      find.descendant(
        of: find.byType(TogglePanel),
        matching: find.byType(Card),
      ),
    )
    .color;

Color _role(WidgetTester tester, Color Function(SignalColors) pick) =>
    pick(SignalColors.of(tester.element(find.byType(TogglePanel))));

void main() {
  testWidgets('waiting before any message, then a dash without the value', (
    tester,
  ) async {
    final mgr = await _pump(tester, const ToggleConfig());
    expect(find.text('Waiting for first report'), findsOneWidget);
    mgr.emit('{"battery":90}');
    await tester.pumpAndSettle();
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('a raw JSON payload with no path reads as a dash', (
    tester,
  ) async {
    final mgr = await _pump(tester, const ToggleConfig(jsonPath: null));
    mgr.emit('{"a":1}');
    await tester.pumpAndSettle();
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('on: amber, chip filled; off: idle; one publish per tap', (
    tester,
  ) async {
    final mgr = await _pump(tester, const ToggleConfig());
    expect(find.byType(Switch), findsNothing);

    mgr.emit('{"state":"ON"}');
    await tester.pumpAndSettle();
    expect(find.text('On'), findsOneWidget);
    expect(_cardColor(tester), _role(tester, (r) => r.active));
    expect(
      tester
          .widget<SignalIcon>(
            find.descendant(
              of: find.byType(TogglePanel),
              matching: find.byType(SignalIcon),
            ),
          )
          .active,
      isTrue,
    );
    await tester.tap(find.text('1_Licht-Flur'));
    await tester.pumpAndSettle();
    expect(mgr.sent, ['{"state":"OFF"}']);

    mgr.emit('{"state":"OFF"}');
    await tester.pumpAndSettle();
    expect(find.text('Off'), findsOneWidget);
    expect(_cardColor(tester), isNot(_role(tester, (r) => r.active)));
    await tester.tap(find.text('1_Licht-Flur'));
    await tester.pumpAndSettle();
    expect(mgr.sent, ['{"state":"OFF"}', '{"state":"ON"}']);
  });

  testWidgets('German says An and Aus', (tester) async {
    final mgr = await _pump(
      tester,
      const ToggleConfig(),
      locale: const Locale('de'),
    );
    mgr.emit('{"state":"ON"}');
    await tester.pumpAndSettle();
    expect(find.text('An'), findsOneWidget);
    mgr.emit('{"state":"OFF"}');
    await tester.pumpAndSettle();
    expect(find.text('Aus'), findsOneWidget);
  });

  testWidgets('an unknown value draws idle, and a tap turns it on', (
    tester,
  ) async {
    final mgr = await _pump(tester, const ToggleConfig());
    expect(_cardColor(tester), isNot(_role(tester, (r) => r.active)));
    await tester.tap(find.byType(TogglePanel));
    await tester.pumpAndSettle();
    expect(mgr.sent, ['{"state":"ON"}']);
  });

  testWidgets('one semantics node, read like a switch', (tester) async {
    final handle = tester.ensureSemantics();
    final mgr = await _pump(tester, const ToggleConfig());
    mgr.emit('{"state":"ON"}');
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.byType(TogglePanel));
    expect(
      node,
      isSemantics(
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        label: '1_Licht-Flur',
        value: 'On',
        hasTapAction: true,
      ),
    );
    tester.semantics.tap(find.semantics.byLabel('1_Licht-Flur'));
    await tester.pumpAndSettle();
    expect(mgr.sent, ['{"state":"OFF"}']);
    handle.dispose();
  });

  testWidgets('icons: both stored by state, one stored always, none the plug', (
    tester,
  ) async {
    IconData chipIcon() => tester
        .widget<SignalIcon>(
          find.descendant(
            of: find.byType(TogglePanel),
            matching: find.byType(SignalIcon),
          ),
        )
        .icon;

    final both = await _pump(
      tester,
      ToggleConfig(
        onIconCodepoint: Icons.lightbulb.codePoint,
        offIconCodepoint: Icons.lightbulb_outline.codePoint,
      ),
    );
    both.emit('{"state":"ON"}');
    await tester.pumpAndSettle();
    expect(chipIcon(), materialIcon(Icons.lightbulb.codePoint));
    both.emit('{"state":"OFF"}');
    await tester.pumpAndSettle();
    expect(chipIcon(), materialIcon(Icons.lightbulb_outline.codePoint));

    final one = await _pump(
      tester,
      ToggleConfig(offIconCodepoint: Icons.tv.codePoint),
    );
    one.emit('{"state":"ON"}');
    await tester.pumpAndSettle();
    expect(chipIcon(), materialIcon(Icons.tv.codePoint));
    one.emit('{"state":"OFF"}');
    await tester.pumpAndSettle();
    expect(chipIcon(), materialIcon(Icons.tv.codePoint));

    await _pump(tester, const ToggleConfig());
    expect(chipIcon(), Symbols.powerSettingsNew);
  });
}
