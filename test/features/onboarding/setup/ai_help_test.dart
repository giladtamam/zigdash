import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/features/connections/discovery/hub_probe.dart';
import 'package:zigdash/features/onboarding/setup/ai_help.dart';
import 'package:zigdash/features/onboarding/setup/ha_connect.dart';
import 'package:zigdash/features/onboarding/setup/setup_coordinator.dart';
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/shortcuts/shortcut_service.dart' show appChannel;

class _RecordingSink implements AnalyticsSink {
  _RecordingSink(this.sent);
  final List<(String, Map<String, String>)> sent;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  void send(String name, Map<String, String> props) => sent.add((name, props));
}

void main() {
  group('the write-up', () {
    const empty = AiHelpFacts(
      from: AiHelpFrom.scanEmpty,
      platform: SetupPlatform.homeAssistant,
      network: (kind: 'Wi-Fi', vpn: false),
      phoneAddress: '192.168.68.57',
      tried: (widened: true, hostsTried: 1020, aliveHosts: 23, lateHosts: 0),
    );

    test('says what setup found, in the app\'s own terms', () {
      final text = aiHelpText(empty);
      expect(
        text,
        contains('Where Zigbee2MQTT runs, my answer: Home Assistant.'),
      );
      expect(text, contains('on Wi-Fi'));
      expect(text, contains('VPN: off.'));
      expect(
        text,
        contains('tried 1020 addresses, including the neighbouring range'),
      );
      expect(text, contains('port 1883'));
      expect(text, contains('found no MQTT broker on my network'));
    });

    test('never an address: only its shape', () {
      final text = aiHelpText(empty);
      expect(text, isNot(contains('192.168.68.57')));
      expect(text, contains('private address in 192.168.x'));
    });

    test('asks for answers in the app\'s language', () {
      expect(
        aiHelpText(empty, languageCode: 'he'),
        contains('Please answer in Hebrew.'),
      );
      expect(aiHelpText(empty), isNot(contains('Please answer in')));
    });

    test('every stuck screen says where it is stuck', () {
      final all = [
        for (final hub in [null, ...HubKind.values])
          AiHelpFacts(from: AiHelpFrom.scanEmpty, hubSeen: hub),
        const AiHelpFacts(from: AiHelpFrom.login),
        const AiHelpFacts(from: AiHelpFrom.login, loginRejected: true),
        const AiHelpFacts(from: AiHelpFrom.noZigbee2mqtt, baseTopic: 'z2m'),
        for (final e in SetupErrorKind.values)
          AiHelpFacts(from: AiHelpFrom.failed, error: e),
        for (final p in [null, ...HaConnectProblem.values])
          AiHelpFacts(from: AiHelpFrom.haConnect, haProblem: p),
      ];
      for (final f in all) {
        final stuck = aiHelpText(f).split("Where I'm stuck: ").last;
        expect(stuck.length, greaterThan(20), reason: '$f');
        expect(stuck, isNot(contains('null')));
      }
      expect(
        aiHelpText(
          const AiHelpFacts(from: AiHelpFrom.noZigbee2mqtt, baseTopic: 'z2m'),
        ),
        contains('base topic z2m'),
      );
    });
  });

  group('the card', () {
    late List<(String, Map<String, String>)> sent;
    late List<MethodCall> calls;
    late bool shareWorks;

    setUp(() {
      sent = [];
      calls = [];
      shareWorks = true;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(appChannel, (call) async {
            calls.add(call);
            return call.method == 'shareText' ? shareWorks : null;
          });
    });
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(appChannel, null);
    });

    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            analyticsProvider.overrideWithValue(
              Analytics(_RecordingSink(sent), enabled: true),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AiHelpCard(
                facts: AiHelpFacts(
                  from: AiHelpFrom.login,
                  platform: SetupPlatform.homeAssistant,
                  loginRejected: true,
                ),
              ),
            ),
          ),
        ),
      );
    }

    List<Map<String, String>> steps() => [
      for (final (name, props) in sent)
        if (name == 'setup_step' && props['step'] == 'ai_help') props,
    ];

    testWidgets('shows the write-up first, then shares it', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Ask an AI'));
      await tester.pumpAndSettle();
      expect(find.text('What will be shared'), findsOneWidget);
      expect(
        find.textContaining('rejected the username and password'),
        findsOneWidget,
      );
      expect(calls, isEmpty, reason: 'nothing leaves before Share');
      await tester.tap(find.text('Share to an AI app'));
      await tester.pumpAndSettle();
      final share = calls.single;
      expect(share.method, 'shareText');
      expect((share.arguments as Map)['text'], contains('ZigDash'));
      expect(steps(), [
        {
          'step': 'ai_help',
          'platform': 'home_assistant',
          'result': 'opened',
          'choice': 'login',
        },
        {
          'step': 'ai_help',
          'platform': 'home_assistant',
          'result': 'shared',
          'choice': 'login',
        },
      ]);
      expect(find.text('What will be shared'), findsNothing);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AiHelpCard)),
      );
      expect(container.read(aiHelpUsedProvider), isTrue);
    });

    testWidgets('without a share sheet it copies, and says so', (tester) async {
      shareWorks = false;
      String? clip;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clip = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pump(tester);
      await tester.tap(find.text('Ask an AI'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share to an AI app'));
      await tester.pumpAndSettle();
      expect(clip, contains("Where I'm stuck"));
      expect(find.text('Copied. Paste it into any AI chat.'), findsOneWidget);
      expect(steps().last['result'], 'copied');
    });
  });
}
