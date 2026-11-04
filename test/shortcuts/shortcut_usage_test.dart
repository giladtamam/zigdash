import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/shortcuts/shortcut_usage.dart';

class _Sink implements AnalyticsSink {
  final sent = <(String, Map<String, String>)>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add((name, props));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('shortcut events carry only the kind', () {
    expect(const ShortcutAdded(ShortcutEventKind.tile).props, {'kind': 'tile'});
    expect(const ShortcutUsed(ShortcutEventKind.control).name, 'shortcut_used');
  });

  test('what Android noted is sent once, then cleared', () async {
    SharedPreferences.setMockInitialValues({
      'shortcut.used.tile': '1',
      'shortcut.added.control': '1',
    });
    final prefs = await SharedPreferences.getInstance();
    final sink = _Sink();
    final analytics = Analytics(sink, enabled: true);

    await reportShortcutUsage(prefs, analytics);
    expect(sink.sent.map((e) => '${e.$1} ${e.$2}'),
        ['shortcut_used {kind: tile}', 'shortcut_added {kind: control}']);

    sink.sent.clear();
    await reportShortcutUsage(prefs, analytics);
    expect(sink.sent, isEmpty);
  });

  test('without consent nothing is sent and the note is dropped', () async {
    SharedPreferences.setMockInitialValues({'shortcut.used.control': '1'});
    final prefs = await SharedPreferences.getInstance();
    final sink = _Sink();
    await reportShortcutUsage(prefs, Analytics(sink, enabled: false));
    expect(sink.sent, isEmpty);
    expect(prefs.getString('shortcut.used.control'), isNull);
  });

  test('each widget added is reported', () async {
    SharedPreferences.setMockInitialValues({'shortcut.added.widget': '1'});
    final prefs = await SharedPreferences.getInstance();
    final sink = _Sink();
    final analytics = Analytics(sink, enabled: true);
    await reportShortcutUsage(prefs, analytics);
    expect(sink.sent.map((e) => '${e.$1} ${e.$2}'),
        ['shortcut_added {kind: widget, from: outside}']);
    expect(prefs.getString('shortcut.added.widget'), isNull);
  });

  // 3.3.3: a widget the app asked for is reported with where it was asked
  // from; one added more than an hour later came from the launcher.
  test('a widget asked for from the app says where from', () async {
    final t = DateTime(2026, 11, 3, 12);
    SharedPreferences.setMockInitialValues({'shortcut.added.widget': '1'});
    final prefs = await SharedPreferences.getInstance();
    await notePinFrom(prefs, ShortcutFrom.tileMenu, now: t);
    final sink = _Sink();
    final analytics = Analytics(sink, enabled: true);
    await reportShortcutUsage(prefs, analytics,
        now: t.add(const Duration(minutes: 5)));
    expect(sink.sent.single.$2, {'kind': 'widget', 'from': 'tile_menu'});
    expect(prefs.getString(shortcutPinFromKey), isNull);

    await prefs.setString('shortcut.added.widget', '1');
    await notePinFrom(prefs, ShortcutFrom.nudge, now: t);
    sink.sent.clear();
    await reportShortcutUsage(prefs, analytics,
        now: t.add(const Duration(hours: 2)));
    expect(sink.sent.single.$2, {'kind': 'widget', 'from': 'outside'});
  });

  test('a tile added from the nudge says so', () {
    expect(
        const ShortcutAdded(ShortcutEventKind.tile, from: ShortcutFrom.nudge)
            .props,
        {'kind': 'tile', 'from': 'nudge'});
  });

  test('scene and group widgets are reported by their kind', () async {
    SharedPreferences.setMockInitialValues({
      'shortcut.added.scene_widget': '1',
      'shortcut.used.scene_widget': '1',
      'shortcut.added.group_widget': '1',
    });
    final prefs = await SharedPreferences.getInstance();
    final sink = _Sink();
    await reportShortcutUsage(prefs, Analytics(sink, enabled: true));
    expect(sink.sent.map((e) => '${e.$1} ${e.$2}').toSet(), {
      'shortcut_used {kind: scene_widget}',
      'shortcut_added {kind: scene_widget, from: outside}',
      'shortcut_added {kind: group_widget, from: outside}',
    });
    expect(prefs.getKeys(), isEmpty);
  });
}
