import 'package:flutter_test/flutter_test.dart';

import '../../bin/smoke.dart' as smoke;

void main() {
  test(
    'normal delivery output preserves the legacy topic-tab-payload format',
    () {
      expect(
        smoke.formatSmokeDelivery('zigbee2mqtt/lamp', '{"state":"ON"}'),
        'zigbee2mqtt/lamp\t{"state":"ON"}',
      );
    },
  );

  test('outage delivery output includes its delivery number', () {
    expect(
      smoke.formatSmokeDelivery(
        'zigbee2mqtt/lamp',
        '{"state":"ON"}',
        deliveryNumber: 2,
      ),
      '[delivery 2]\tzigbee2mqtt/lamp\t{"state":"ON"}',
    );
  });

  test('checkpoint confirmation rejects EOF', () {
    expect(smoke.checkpointConfirmed(() => null), isFalse);
  });

  test('checkpoint confirmation accepts an empty Enter line', () {
    expect(smoke.checkpointConfirmed(() => ''), isTrue);
  });
}
