import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/alerts/alerts_config.dart';

void main() {
  const phone = AlertPhone(
      id: 'p1', name: 'Galaxy', endpoint: 'https://fcm/x', p256dh: 'k', auth: 'a');
  final config = AlertsConfig(
    connectionId: 'home',
    home: 'My Home',
    base: 'zigbee2mqtt',
    timeZone: 'Asia/Jerusalem',
    vapid: const VapidKeys(publicKey: 'PUB', privateJwk: {'kty': 'EC', 'd': 'D'}),
    phones: const [phone],
    text: const {'leak': '💧 Leak — {name}'},
    alerts: const [
      AlertRule(id: 'a1', kind: AlertKind.leak, devices: [
        AlertDevice(ieee: '0x1', topic: 'zigbee2mqtt/Kitchen', name: 'Kitchen')
      ]),
      AlertRule(id: 'a2', kind: AlertKind.opened, devices: [
        AlertDevice(ieee: '0x2', topic: 'zigbee2mqtt/Door', name: 'Door')
      ], from: '23:00', to: '06:00'),
      AlertRule(id: 'a3', kind: AlertKind.battery, devices: [
        AlertDevice(ieee: '0x3', topic: 'zigbee2mqtt/Bed', name: 'Bed')
      ], threshold: 15),
    ],
  );

  test('the contract round-trips, with what the hub reads', () {
    final j = config.toJson();
    expect(j['version'], 1);
    expect(j['connection'], 'home');
    expect((j['alerts'] as List)[1], containsPair('from', '23:00'));
    expect((j['alerts'] as List)[2], containsPair('threshold', 15));
    expect((j['alerts'] as List)[0], isNot(contains('threshold')));
    final back = AlertsConfig.decode(jsonEncode(j))!;
    expect(back.encode(), config.encode());
    expect(back.alerts[2].kind, AlertKind.battery);
    expect(back.phones.single.endpoint, 'https://fcm/x');
  });

  test('an empty retained payload means alerts are off', () {
    expect(AlertsConfig.decode(''), isNull);
    expect(AlertsConfig.decode('  '), isNull);
    expect(AlertsConfig.decode('not json'), isNull);
  });

  test('phones are added or replaced by id, and removed', () {
    final two = config.withPhone(const AlertPhone(
        id: 'p2', name: 'Pixel', endpoint: 'e2', p256dh: 'k2', auth: 'a2'));
    expect(two.phones.map((p) => p.id), ['p1', 'p2']);
    final replaced = two.withPhone(const AlertPhone(
        id: 'p1', name: 'Galaxy', endpoint: 'new', p256dh: 'k', auth: 'a'));
    expect(replaced.phones.map((p) => p.endpoint), ['e2', 'new']);
    expect(replaced.withoutPhone('p2').phones.map((p) => p.id), ['p1']);
  });

  test("the retained config wins, except this phone's own entry", () {
    // Another phone renamed an alert's device and added itself.
    final retained = AlertsConfig.fromJson(config.toJson()).copyWith(
      phones: [
        const AlertPhone(id: 'p2', name: 'Pixel', endpoint: 'e2', p256dh: 'k2', auth: 'a2'),
        const AlertPhone(id: 'p1', name: 'Galaxy', endpoint: 'stale', p256dh: 'k', auth: 'a'),
      ],
      alerts: [config.alerts.first],
    );
    final merged = config.mergedFrom(retained, myPhoneId: 'p1');
    expect(merged.alerts.length, 1, reason: 'their alerts');
    expect(merged.phones.map((p) => '${p.id}:${p.endpoint}'),
        ['p2:e2', 'p1:https://fcm/x'],
        reason: 'their phones, my own entry as I have it');
  });
}
