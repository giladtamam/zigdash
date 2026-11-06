import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/engine/engine_providers.dart';
import 'package:zigdash/engine/engine_status.dart';

EngineView _running(int rules) => EngineView(
      phase: HubEnginePhase.running,
      report: EngineReport(
        version: '3.4.1',
        runningOn: 'z2m',
        rulesLoaded: rules,
        rulesUnknown: const [],
        stoppedSelf: false,
        at: DateTime(2026, 11, 5),
      ),
    );

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('a running Engine leaves its rule count for the next launch', () async {
    expect(engineKnownRules(prefs, 'a'), 0);
    rememberEngine(prefs, 'a', _running(3));
    await pumpEventQueue();
    expect(engineKnownInstalled(prefs, 'a'), isTrue);
    expect(engineKnownRules(prefs, 'a'), 3);
    expect(engineKnownRules(prefs, 'b'), 0);

    rememberEngine(prefs, 'a', _running(0));
    await pumpEventQueue();
    expect(engineKnownRules(prefs, 'a'), 0);
  });

  test('while the hub has not answered, the last count stays', () async {
    rememberEngine(prefs, 'a', _running(2));
    await pumpEventQueue();
    rememberEngine(prefs, 'a', const EngineView(phase: HubEnginePhase.checking));
    await pumpEventQueue();
    expect(engineKnownRules(prefs, 'a'), 2);
  });

  test('an Engine that is gone takes its count with it', () async {
    rememberEngine(prefs, 'a', _running(2));
    await pumpEventQueue();
    rememberEngine(prefs, 'a', const EngineView(phase: HubEnginePhase.notInstalled));
    await pumpEventQueue();
    expect(engineKnownInstalled(prefs, 'a'), isFalse);
    expect(engineKnownRules(prefs, 'a'), 0);
  });
}
