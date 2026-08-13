import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/onboarding/setup/recommendation_policy.dart';

Z2mDevice dev(
  String name, {
  String type = 'EndDevice',
  bool supported = true,
  List<Z2mExpose> exposes = const [],
}) =>
    Z2mDevice(
      friendlyName: name,
      type: type,
      supported: supported,
      exposes: exposes,
    );

void main() {
  group('recommendDevices', () {
    test('light is recommended and preselected', () {
      final rows = recommendDevices([
        dev('lamp', exposes: const [Z2mExpose(type: 'light')]),
      ]);
      expect(rows.single.group, ReviewGroup.recommended);
      expect(rows.single.selected, isTrue);
      expect(rows.single.suggestion.type, PanelType.slider);
    });

    test('cover and switch are recommended and preselected', () {
      final rows = recommendDevices([
        dev('shutter', exposes: const [Z2mExpose(type: 'cover')]),
        dev('plug', exposes: const [Z2mExpose(type: 'switch')]),
      ]);
      expect(rows.every((r) => r.group == ReviewGroup.recommended), isTrue);
      expect(rows.every((r) => r.selected), isTrue);
    });

    test('meaningful binary sensor is recommended', () {
      final rows = recommendDevices([
        dev('door',
            exposes: const [Z2mExpose(type: 'binary', property: 'contact')]),
      ]);
      expect(rows.single.group, ReviewGroup.recommended);
      expect(rows.single.selected, isTrue);
    });

    test('button-like enum device is recommended', () {
      final rows = recommendDevices([
        dev('remote', exposes: const [
          Z2mExpose(type: 'enum', property: 'action'),
        ]),
      ]);
      expect(rows.single.group, ReviewGroup.recommended);
      expect(rows.single.selected, isTrue);
    });

    test('battery-only device goes to Other, unselected', () {
      final rows = recommendDevices([
        dev('sensor',
            exposes: const [Z2mExpose(type: 'numeric', property: 'battery')]),
      ]);
      expect(rows.single.group, ReviewGroup.other);
      expect(rows.single.selected, isFalse);
    });

    test('linkquality-only device goes to Other, unselected', () {
      final rows = recommendDevices([
        dev('router',
            type: 'Router',
            exposes: const [
              Z2mExpose(type: 'numeric', property: 'linkquality')
            ]),
      ]);
      expect(rows.single.group, ReviewGroup.other);
      expect(rows.single.selected, isFalse);
    });

    test('unsupported device is shown explicitly, unselectable', () {
      final rows = recommendDevices([dev('mystery', supported: false)]);
      expect(rows.single.group, ReviewGroup.unsupported);
      expect(rows.single.selected, isFalse);
      expect(rows.single.selectable, isFalse);
    });

    test('recommended rows sort before other and unsupported', () {
      final rows = recommendDevices([
        dev('b_battery',
            exposes: const [Z2mExpose(type: 'numeric', property: 'battery')]),
        dev('a_light', exposes: const [Z2mExpose(type: 'light')]),
        dev('c_unsupported', supported: false),
      ]);
      expect(rows.map((r) => r.device.friendlyName),
          ['a_light', 'b_battery', 'c_unsupported']);
    });

    test('empty input yields empty list', () {
      expect(recommendDevices(const []), isEmpty);
    });
  });
}
