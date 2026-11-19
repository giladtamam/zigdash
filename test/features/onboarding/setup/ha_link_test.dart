import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/core/router/routes.dart';
import 'package:zigdash/features/kiosk/kiosk.dart';
import 'package:zigdash/features/onboarding/setup/ha_link.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

class _Sink implements AnalyticsSink {
  final sent = <(String, Map<String, String>)>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add((name, props));
}

Future<(ProviderContainer, _Sink, SharedPreferences)> _container(
  Map<String, Object> prefs,
) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final sink = _Sink();
  final c = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(p),
      analyticsAvailableProvider.overrideWithValue(true),
      analyticsSinkProvider.overrideWithValue(sink),
    ],
  );
  addTearDown(c.dispose);
  return (c, sink, p);
}

const _home = 'http://192.168.1.20:8123';
final _link = Uri.parse(
  'https://zigdash.app/c#ha=${Uri.encodeQueryComponent(_home)}',
);

// docs/design/ha-link.md
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parsing', () {
    final vectors =
        jsonDecode(File('test/fixtures/ha_link_vectors.json').readAsStringSync())
            as List;
    for (final v in vectors.cast<Map>()) {
      test('vector "${v['params']}"', () {
        final link = haLinkFromParams(v['params'] as String);
        expect(link.addresses, v['addresses']);
        expect(
          link.src == HaLinkSrc.haIntegration ? 'ha_integration' : 'site',
          v['src'],
        );
      });
    }

    test('the fragment, else the query of the intent:// button', () {
      expect(parseHaLink(_link).address, _home);
      expect(openedBy(_link), HaLinkOpened.appLink);
      final viaButton = Uri.parse(
        'https://zigdash.app/c?ha=${Uri.encodeQueryComponent(_home)}',
      );
      expect(parseHaLink(viaButton).address, _home);
      expect(openedBy(viaButton), HaLinkOpened.intent);
      expect(parseHaLink(Uri.parse('https://zigdash.app/c')).address, isNull);
    });
  });

  group('taking a link in', () {
    test('first run: waits on setup, counted after the usage answer', () async {
      final (c, sink, _) = await _container({});
      expect(c.read(haLinksProvider).route(_link), Routes.setup);
      expect(c.read(pendingHaLinkProvider)?.address, _home);
      expect(sink.sent, isEmpty, reason: 'nothing before the answer');

      await c.read(analyticsConsentProvider.notifier).set(true);
      await c.read(pendingHaLinkProvider.notifier).countHeld();
      await c.read(pendingHaLinkProvider.notifier).countHeld();
      expect(sink.sent, hasLength(1));
      final (name, props) = sink.sent.single;
      expect(name, 'setup_step');
      expect(props, {
        'step': 'ha_link',
        'choice': 'app_link',
        'result': 'address',
        'link_src': 'site',
      });
      expect(c.read(pendingHaLinkProvider)?.address, _home,
          reason: 'still waiting for the Home Assistant answer');
    });

    test('first run, usage data declined: nothing is sent', () async {
      final (c, sink, _) = await _container({});
      c.read(haLinksProvider).route(_link);
      await c.read(analyticsConsentProvider.notifier).set(false);
      await c.read(pendingHaLinkProvider.notifier).countHeld();
      expect(sink.sent, isEmpty);
    });

    test('a home exists: straight to the sign-in, counted at once', () async {
      final (c, sink, _) = await _container({
        'onboarding_complete': true,
        'analytics_consent': true,
      });
      final to = Uri.parse(c.read(haLinksProvider).route(_link));
      expect(to.path, Routes.haConnect);
      expect(to.queryParameters, {'host': _home, 'from': 'link'});
      expect(sink.sent.single.$2['step'], 'ha_link');
      expect(c.read(pendingHaLinkProvider), isNull);
    });

    test('a foss build after setup (no usage data at all) goes straight '
        'to the sign-in too', () async {
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      final p = await SharedPreferences.getInstance();
      final c = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(p),
          analyticsAvailableProvider.overrideWithValue(false),
        ],
      );
      addTearDown(c.dispose);
      expect(
        Uri.parse(c.read(haLinksProvider).route(_link)).path,
        Routes.haConnect,
      );
    });

    test('the demo home is not a home', () async {
      final (c, _, _) = await _container({
        'onboarding_complete': true,
        'demo_mode': true,
      });
      expect(c.read(haLinksProvider).route(_link), Routes.setup);
      expect(c.read(pendingHaLinkProvider)?.address, _home);
    });

    test('a redirect run twice takes the link in once', () async {
      final (c, sink, _) = await _container({
        'onboarding_complete': true,
        'analytics_consent': true,
      });
      final links = c.read(haLinksProvider);
      expect(links.route(_link), links.route(_link));
      expect(sink.sent, hasLength(1));
    });

    test('a link with no address opens the sign-in that says so', () async {
      final (c, sink, _) = await _container({
        'onboarding_complete': true,
        'analytics_consent': true,
      });
      final to = Uri.parse(
        c.read(haLinksProvider).route(Uri.parse('https://zigdash.app/c#x=1')),
      );
      expect(to.queryParameters, {'from': 'link'});
      expect(sink.sent.single.$2['result'], 'no_address');
    });

    test('kiosk: a link never leaves the pinned Home', () {
      const kiosk = KioskState(connectionId: 'h', dashboardId: 'd');
      expect(kioskRedirect(kiosk: kiosk, location: Routes.haLink), isNotNull);
    });
  });

  group('the source of a finished setup', () {
    Future<SharedPreferences> linked({bool used = true, int daysAgo = 0}) async {
      final (c, _, p) = await _container({'onboarding_complete': true});
      c.read(haLinksProvider).route(_link);
      if (daysAgo > 0) {
        await p.setInt(
          'ha_link_at',
          DateTime.now()
              .subtract(Duration(days: daysAgo))
              .millisecondsSinceEpoch,
        );
      }
      if (used) markHaLinkUsed(p);
      return p;
    }

    test('the link\'s address made the home', () async {
      final p = await linked();
      expect(takeHaLinkSrc(p, viaHa: true), HaLinkSrc.site);
      expect(takeHaLinkSrc(p, viaHa: true), isNull, reason: 'taken once');
    });

    test('the next day still counts', () async {
      final p = await linked(daysAgo: 1);
      expect(takeHaLinkSrc(p, viaHa: true), HaLinkSrc.site);
    });

    test('an edited address does not count', () async {
      final p = await linked(used: false);
      expect(takeHaLinkSrc(p, viaHa: true), isNull);
    });

    test('a setup another way ends the link\'s part', () async {
      final p = await linked();
      expect(takeHaLinkSrc(p, viaHa: false), isNull);
      expect(p.getString('ha_link_src'), isNull);
    });

    test('after 14 days it no longer counts', () async {
      final p = await linked(daysAgo: 15);
      expect(takeHaLinkSrc(p, viaHa: true), isNull);
    });
  });

  group('install referrer', () {
    const channel = MethodChannel('zigdash/referrer');
    void answer(String? referrer) => TestDefaultBinaryMessengerBinding
        .instance
        .defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => referrer);
    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    test('a link opened before installing, read once', () async {
      answer('ha=${Uri.encodeQueryComponent(_home)}&src=site');
      final (c, _, _) = await _container({});
      expect(await c.read(haLinksProvider).takeReferrer(), Routes.setup);
      final pending = c.read(pendingHaLinkProvider)!;
      expect(pending.address, _home);
      expect(pending.opened, HaLinkOpened.referrer);
      expect(await c.read(haLinksProvider).takeReferrer(), isNull);
    });

    test('any other referrer is left alone', () async {
      answer('utm_source=ha_forum&utm_campaign=thread_1018963');
      final (c, _, _) = await _container({});
      expect(await c.read(haLinksProvider).takeReferrer(), isNull);
      expect(c.read(pendingHaLinkProvider), isNull);
    });

    test('the foss build has no referrer', () async {
      final (c, _, _) = await _container({});
      expect(await c.read(haLinksProvider).takeReferrer(), isNull);
    });
  });
}
