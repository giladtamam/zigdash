import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/review/command_confirmations.dart';

void main() {
  final t0 = DateTime(2026, 9, 26, 12);
  CommandConfirmations make() => CommandConfirmations();

  // First-run decision: a successful session is a day on which the user sent
  // a command and received a confirming state update.
  test('a Zigbee2MQTT state update after its /set command confirms it', () {
    final c = make();
    c.commandSent('zigbee2mqtt/lamp/set', t0);
    expect(c.messageReceived('zigbee2mqtt/lamp', t0.add(const Duration(seconds: 1))),
        isTrue);
  });

  test('a state update without a command confirms nothing', () {
    expect(make().messageReceived('zigbee2mqtt/lamp', t0), isFalse);
  });

  test('another device answering does not confirm the command', () {
    final c = make();
    c.commandSent('zigbee2mqtt/lamp/set', t0);
    expect(c.messageReceived('zigbee2mqtt/plug', t0), isFalse);
  });

  test('an update after the 10 second window does not count', () {
    final c = make();
    c.commandSent('zigbee2mqtt/lamp/set', t0);
    expect(
        c.messageReceived('zigbee2mqtt/lamp', t0.add(const Duration(seconds: 11))),
        isFalse);
  });

  test('a custom topic confirms on the same topic', () {
    final c = make();
    c.commandSent('home/relay', t0);
    expect(c.messageReceived('home/relay', t0), isTrue);
  });

  test('one command is confirmed once', () {
    final c = make();
    c.commandSent('zigbee2mqtt/lamp/set', t0);
    expect(c.messageReceived('zigbee2mqtt/lamp', t0), isTrue);
    expect(c.messageReceived('zigbee2mqtt/lamp', t0), isFalse);
  });
}
