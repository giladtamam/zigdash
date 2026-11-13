import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/devices/device_health.dart';
import 'package:zigdash/features/devices/devices_providers.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/features/support/assistant_client.dart';
import 'package:zigdash/features/support/help_bubble.dart';
import 'package:zigdash/features/support/support_details.dart';
import 'package:zigdash/features/support/support_facts.dart';
import 'package:zigdash/features/support/support_log.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

final _stamp = DateTime(2026, 11, 10);
Connection _home({String host = '192.168.1.20'}) => Connection(
  transport: ConnectionTransport.mqtt,
  id: 'c1',
  name: 'Office',
  host: host,
  port: 1883,
  protocol: MqttProtocol.tcp,
  keepAliveSeconds: 60,
  autoConnect: true,
  createdAt: _stamp,
  updatedAt: _stamp,
);

late SharedPreferences _prefs;
final _calls = <AssistantRequest>[];

const _door = Z2mDevice(
  friendlyName: 'Back door',
  type: 'EndDevice',
  ieeeAddress: '0x01',
);
const _bulb = Z2mDevice(
  friendlyName: 'Hall bulb',
  type: 'Router',
  ieeeAddress: '0x02',
);
const _plug = Z2mDevice(
  friendlyName: 'Plug',
  type: 'Router',
  ieeeAddress: '0x03',
);

Widget _app({
  Connection? home,
  MqttStatus status = MqttStatus.connected,
  String answer = 'Open **Devices** and look for it.',
  List<DeviceHealth>? health,
  Z2mFacts? z2m = const Z2mFacts(version: '2.6.0', online: true, devices: 12),
}) => ProviderScope(
  overrides: [
    sharedPreferencesProvider.overrideWithValue(_prefs),
    connectionByIdProvider.overrideWith(
      (ref, id) async => home ?? _home(),
    ),
    connectionStatusProvider.overrideWith((ref, id) => Stream.value(status)),
    homeBaseTopicProvider.overrideWith(
      (ref, _) => health == null ? null : 'zigbee2mqtt',
    ),
    if (health != null)
      deviceHealthProvider.overrideWith((ref, _) => Stream.value(health)),
    platformFactsProvider.overrideWith(
      (ref) async => (
        appVersion: '3.5.0',
        build: '108',
        android: '15',
        ios: null,
        phone: 'Pixel',
      ),
    ),
    supportLogProvider.overrideWithValue(
      SupportLog(read: () async => null, write: (_) async {}),
    ),
    // The real provider reaches for the database and the MQTT manager.
    supportDetailsProvider.overrideWith(
      (ref, q) async => SupportDetails(
        appVersion: '3.5.0',
        build: '108',
        android: '15',
        phone: 'Pixel',
        openedFrom: q.openedFrom,
        z2m: z2m,
      ),
    ),
    assistantCallerProvider.overrideWithValue((request, timeout) async {
      _calls.add(request);
      return AssistantReply(AssistantOutcome.answered, text: answer);
    }),
  ],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(
      body: SizedBox.expand(),
      floatingActionButton: HelpBubble(connectionId: 'c1'),
    ),
  ),
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
    _calls.clear();
  });

  group('pill or dot', () {
    test('a fresh phone gets the pill', () {
      expect(helpBubbleShowsPill(opened: false), isTrue);
    });
    test('opened once: the dot', () {
      expect(helpBubbleShowsPill(opened: true), isFalse);
    });
    test('quiet in the hour after setup', () {
      final now = DateTime(2026, 11, 10, 12);
      expect(
        helpBubbleShowsPill(
          opened: false,
          setupCompletedMs: now
              .subtract(const Duration(minutes: 20))
              .millisecondsSinceEpoch,
          now: now,
        ),
        isFalse,
      );
      expect(
        helpBubbleShowsPill(
          opened: false,
          setupCompletedMs: now
              .subtract(const Duration(hours: 2))
              .millisecondsSinceEpoch,
          now: now,
        ),
        isTrue,
      );
    });
    test('the pill decays to the dot after seven days unopened', () {
      final now = DateTime(2026, 11, 10, 12);
      expect(
        helpBubbleShowsPill(
          opened: false,
          firstShownMs: now
              .subtract(const Duration(days: 8))
              .millisecondsSinceEpoch,
          now: now,
        ),
        isFalse,
      );
    });
  });

  testWidgets('the pill shows, and nothing is sent until a chip is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('Need help?'), findsOneWidget);
    expect(_prefs.getInt(kHelpBubbleFirstShownMs), isNotNull);

    await tester.tap(find.byKey(const Key('help-bubble')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('assistant-home')), findsOneWidget);
    expect(find.textContaining('Office is connected'), findsOneWidget);
    expect(_calls, isEmpty, reason: 'opening the sheet sends nothing');
    // The reply field is open from the start in home mode.
    expect(
      tester.widget<TextField>(find.byKey(const Key('assistant-reply'))).enabled,
      isTrue,
    );
    // A connected home never offers "Home can't be reached".
    expect(find.byKey(const Key('assistant-chip-unreachable')), findsNothing);

    await tester.tap(find.byKey(const Key('assistant-chip-device')));
    await tester.pumpAndSettle();
    expect(_calls, hasLength(1));
    expect(_calls.single.mode, AssistantMode.home);
    expect(_calls.single.turns.single.text, 'A device stopped responding');
    expect(_calls.single.details, contains('Dashboard › help bubble'));
    expect(find.textContaining('look for it'), findsOneWidget);
    // Bold renders, the markers do not.
    expect(find.textContaining('**'), findsNothing);
    // No help_seen stamp from the bubble.
    expect(_prefs.getInt('assistant_answered_at_ms'), isNull);
    expect(_prefs.getBool(kHelpBubbleOpened), isTrue);
  });

  testWidgets('the details carry attention counts, never names', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        health: [
          // Offline: counted as attention, not as not-responding.
          const DeviceHealth(device: _door, online: false),
          // Never heard from and the request timed out.
          const DeviceHealth(device: _bulb, notResponding: true),
          DeviceHealth(device: _plug, state: const {'state': 'ON'}),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('help-bubble')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('assistant-chip-device')));
    await tester.pumpAndSettle();
    final details = _calls.single.details;
    expect(details, contains('Devices needing attention: 2 (1 not responding)'));
    expect(details, isNot(contains('Back door')));
    expect(details, isNot(contains('Hall bulb')));
  });

  testWidgets('no Zigbee2MQTT facts: the generic opening, never 0 devices', (
    tester,
  ) async {
    await tester.pumpWidget(_app(z2m: null));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('help-bubble')));
    await tester.pumpAndSettle();
    expect(find.textContaining('0 devices'), findsNothing);
    expect(find.textContaining('no devices report'), findsNothing);
    expect(find.textContaining("I'll help you get connected"), findsOneWidget);
  });

  testWidgets('after the first open only the dot remains', (tester) async {
    await _prefs.setBool(kHelpBubbleOpened, true);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('help-bubble')), findsOneWidget);
    expect(find.text('Need help?'), findsNothing);
  });

  testWidgets('an unreachable home offers that one chip', (tester) async {
    await tester.pumpWidget(_app(status: MqttStatus.disconnected));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('help-bubble')));
    await tester.pumpAndSettle();
    expect(find.textContaining("can't reach Office"), findsOneWidget);
    expect(find.byKey(const Key('assistant-chip-unreachable')), findsOneWidget);
    expect(find.byKey(const Key('assistant-chip-device')), findsNothing);
  });

  testWidgets('Hide in the sheet removes the bubble and remembers it', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('help-bubble')));
    await tester.pumpAndSettle();
    final hide = find.byKey(const Key('assistant-home-hide'));
    await tester.ensureVisible(hide);
    await tester.pumpAndSettle();
    await tester.tap(hide);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('help-bubble')), findsNothing);
    expect(_prefs.getBool(kHelpBubbleHidden), isTrue);
    expect(find.textContaining('Settings'), findsOneWidget);
  });

  testWidgets('hidden stays hidden; the demo home has no bubble', (
    tester,
  ) async {
    await _prefs.setBool(kHelpBubbleHidden, true);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('help-bubble')), findsNothing);

    await _prefs.setBool(kHelpBubbleHidden, false);
    await tester.pumpWidget(_app(home: _home(host: 'demo.local')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('help-bubble')), findsNothing);
  });
}
