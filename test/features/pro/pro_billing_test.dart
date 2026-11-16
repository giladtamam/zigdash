import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/features/pro/pro.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

const _channel = MethodChannel('zigdash/billing');

/// Play's answers to "status", in order; the last one repeats.
List<String> _answers = [];
int _asked = 0;

Future<ProviderContainer> _container(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(p)]);
  addTearDown(c.dispose);
  return c;
}

// Pro after a reinstall or a hiccup: Play's last answer stands while Play
// doesn't answer, and Play is asked again.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _asked = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (call) async {
      if (call.method != 'status') return null;
      final a = _answers[_asked < _answers.length ? _asked : _answers.length - 1];
      _asked++;
      return a;
    });
  });
  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, null));

  test('Play saying unlocked is remembered; a later failure keeps it', () async {
    _answers = ['unlocked'];
    final c = await _container({});
    c.read(proBillingProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(c.read(proBillingProvider), ProStatus.unlocked);
    expect(c.read(sharedPreferencesProvider).getString(proOwnedKey), '1');

    _answers = ['error'];
    _asked = 0;
    expect(await c.read(proBillingProvider.notifier).refresh(), 'error');
    expect(c.read(proBillingProvider), ProStatus.unlocked);
  });

  test('a phone that remembered Pro starts unlocked, before Play answers', () async {
    _answers = ['error'];
    final c = await _container({proOwnedKey: '1'});
    expect(c.read(proBillingProvider), ProStatus.unlocked);
  });

  test('Play saying locked forgets a remembered purchase (a refund)', () async {
    _answers = ['locked'];
    final c = await _container({proOwnedKey: '1'});
    c.read(proBillingProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(c.read(proBillingProvider), ProStatus.locked);
    expect(c.read(sharedPreferencesProvider).getString(proOwnedKey), isNull);
  });

  test('no answer from Play: asked again after 3, 10 and 30 s, then waits', () {
    fakeAsync((async) {
      _answers = ['error', 'error', 'error', 'error'];
      late ProviderContainer c;
      _container({}).then((x) => c = x);
      async.flushMicrotasks();
      c.read(proBillingProvider);
      async.flushMicrotasks();
      expect(_asked, 1);
      async.elapse(const Duration(seconds: 3));
      expect(_asked, 2);
      async.elapse(const Duration(seconds: 10));
      expect(_asked, 3);
      async.elapse(const Duration(seconds: 30));
      expect(_asked, 4);
      async.elapse(const Duration(minutes: 5));
      expect(_asked, 4, reason: 'three retries, then the next resume or Restore');
      expect(c.read(proBillingProvider), ProStatus.unavailable);
    });
  });

  test('a fresh install that Play answers late: the retry unlocks', () {
    fakeAsync((async) {
      _answers = ['error', 'unlocked'];
      late ProviderContainer c;
      _container({}).then((x) => c = x);
      async.flushMicrotasks();
      c.read(proBillingProvider);
      async.flushMicrotasks();
      expect(c.read(proBillingProvider), ProStatus.unavailable);
      async.elapse(const Duration(seconds: 3));
      expect(c.read(proBillingProvider), ProStatus.unlocked);
    });
  });

  testWidgets('coming back to the app asks Play again while Pro isn\'t unlocked', (tester) async {
    _answers = ['locked', 'unlocked'];
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final c = await _container({});
    c.read(proBillingProvider);
    await tester.pump();
    expect(c.read(proBillingProvider), ProStatus.locked);
    for (final s in [AppLifecycleState.inactive, AppLifecycleState.hidden, AppLifecycleState.paused,
        AppLifecycleState.hidden, AppLifecycleState.inactive, AppLifecycleState.resumed]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pump();
    expect(c.read(proBillingProvider), ProStatus.unlocked);
  });
}
