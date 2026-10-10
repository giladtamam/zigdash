import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/alerts/alert_event.dart';
import 'package:zigdash/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('an event from the hub is read and worded', () {
    final e = AlertEvent.decode(
        '{"v":1,"kind":"leak","connection":"home","device":"0x1","name":"Kitchen sensor",'
        '"home":"My Home","cleared":false,"value":null,"at":"2026-10-10T20:13:57.000Z"}')!;
    expect(e.connectionId, 'home');
    expect(e.urgent, isTrue);
    expect(e.text(l10n), '💧 Leak — Kitchen sensor (My Home)');
    expect(e.text(l10n, oneHome: true), '💧 Leak — Kitchen sensor');
    expect(e.at.toUtc().hour, 20);
  });

  test('cleared, opened, battery and test texts', () {
    AlertEvent ev(String kind, {bool cleared = false, num? value}) => AlertEvent(
        kind: kind, connectionId: 'home', device: '0x1', name: 'X', home: '',
        cleared: cleared, value: value, at: DateTime(2026));
    expect(ev('leak', cleared: true).text(l10n), '✅ X is dry again');
    expect(ev('leak', cleared: true).urgent, isFalse);
    expect(ev('smoke').text(l10n), '🔥 Smoke — X');
    expect(ev('opened').text(l10n), '🚪 X opened');
    expect(ev('battery', value: 12).text(l10n), '🔋 Battery low — X, 12%');
    expect(ev('test').text(l10n), 'ZigDash test alert');
  });

  test('rubbish is rejected', () {
    expect(AlertEvent.decode('nope'), isNull);
    expect(AlertEvent.decode('[1]'), isNull);
  });
}
