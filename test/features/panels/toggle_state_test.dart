import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/panels/widgets/toggle_panel.dart';
import 'package:zigdash/l10n/app_localizations.dart';

// A custom toggle's state, compared as strings on both sides (3.8.7,
// own-switch-look-387.md §4).

PanelValueSnapshot _snap(Object? value) => PanelValueSnapshot(
  value: value,
  receivedAt: DateTime(2026, 11, 21),
  connectionGeneration: 1,
  freshness: PanelFreshness.fresh,
);

ToggleStateKind _kind(ToggleConfig c, Object? value) =>
    toggleState(c, _snap(value)).kind;

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  test('on and off with the default config (path state)', () {
    const c = ToggleConfig();
    expect(_kind(c, 'ON'), ToggleStateKind.on);
    expect(_kind(c, 'OFF'), ToggleStateKind.off);
  });

  test('a raw topic without a path: the payload itself', () {
    const c = ToggleConfig(
      onPayload: '1',
      offPayload: '0',
      jsonPath: null,
      onMatch: '1',
    );
    expect(_kind(c, '0'), ToggleStateKind.off);
    expect(_kind(c, '1'), ToggleStateKind.on);
  });

  test('bool and number values from the path', () {
    const b = ToggleConfig(
      onPayload: '{"state":true}',
      offPayload: '{"state":false}',
      onMatch: 'true',
    );
    expect(_kind(b, false), ToggleStateKind.off);
    expect(_kind(b, true), ToggleStateKind.on);
    const n = ToggleConfig(
      onPayload: '{"power":1}',
      offPayload: '{"power":0}',
      jsonPath: 'power',
      onMatch: '1',
    );
    expect(_kind(n, 0), ToggleStateKind.off);
    expect(_kind(n, 1), ToggleStateKind.on);
  });

  test('an off payload with nothing at the path still counts as itself', () {
    const c = ToggleConfig(onPayload: 'ON', offPayload: 'OFF', onMatch: 'ON');
    expect(_kind(c, 'OFF'), ToggleStateKind.off);
  });

  test('anything else is raw; JSON reads as a dash', () {
    const c = ToggleConfig();
    final toggle = toggleState(c, _snap('TOGGLE'));
    expect(toggle.kind, ToggleStateKind.raw);
    expect(toggleStateLine(toggle, en), 'TOGGLE');
    final map = toggleState(c, _snap({'a': 1}));
    expect(map.kind, ToggleStateKind.raw);
    expect(toggleStateLine(map, en), '—');
    final whole = toggleState(
      const ToggleConfig(jsonPath: null),
      _snap(' {"a":1}'),
    );
    expect(toggleStateLine(whole, en), '—');
  });

  test('no message: waiting; a message without the value: a dash', () {
    expect(
      toggleState(const ToggleConfig(), null).kind,
      ToggleStateKind.waiting,
    );
    expect(
      toggleStateLine(toggleState(const ToggleConfig(), null), en),
      'Waiting for first report',
    );
    final none = toggleState(const ToggleConfig(), _snap(null));
    expect(none.kind, ToggleStateKind.noValue);
    expect(toggleStateLine(none, en), '—');
  });

  test('on and off in the app\'s words', () {
    final de = lookupAppLocalizations(const Locale('de'));
    expect(
      toggleStateLine(toggleState(const ToggleConfig(), _snap('ON')), de),
      'An',
    );
    expect(
      toggleStateLine(toggleState(const ToggleConfig(), _snap('OFF')), en),
      'Off',
    );
  });
}
