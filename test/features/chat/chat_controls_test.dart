import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/chat/chat_controls.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';

const light = [
  {
    'type': 'light',
    'features': [
      {'type': 'binary', 'name': 'state', 'property': 'state', 'access': 7, 'value_on': 'ON', 'value_off': 'OFF'},
      {'type': 'numeric', 'name': 'brightness', 'property': 'brightness', 'access': 7},
    ],
  },
];
const cover = [
  {
    'type': 'cover',
    'features': [
      {'type': 'enum', 'name': 'state', 'property': 'state', 'access': 3, 'values': ['OPEN', 'CLOSE', 'STOP']},
      {'type': 'numeric', 'name': 'position', 'property': 'position', 'access': 7},
    ],
  },
];
const plug = [
  {
    'type': 'switch',
    'features': [
      {'type': 'binary', 'name': 'state', 'property': 'state', 'access': 7, 'value_on': 'ON', 'value_off': 'OFF'},
    ],
  },
  {'type': 'numeric', 'name': 'power', 'property': 'power', 'access': 5},
];
const thermostat = [
  {
    'type': 'climate',
    'features': [
      {'type': 'numeric', 'name': 'occupied_heating_setpoint', 'property': 'occupied_heating_setpoint', 'access': 7},
      {'type': 'numeric', 'name': 'local_temperature', 'property': 'local_temperature', 'access': 5},
    ],
  },
];
const lock = [
  {
    'type': 'lock',
    'features': [
      {'type': 'binary', 'name': 'state', 'property': 'state', 'access': 7, 'value_on': 'LOCK', 'value_off': 'UNLOCK'},
      {'type': 'enum', 'name': 'lock_state', 'property': 'lock_state', 'access': 1, 'values': ['locked', 'unlocked']},
    ],
  },
];
// A water valve sold as a switch: Zigbee2MQTT exposes a plain switch, the
// definition says what it is.
const valveSwitch = [
  {
    'type': 'switch',
    'features': [
      {'type': 'binary', 'name': 'state', 'property': 'state', 'access': 7, 'value_on': 'ON', 'value_off': 'OFF'},
    ],
  },
];
const siren = [
  {
    'type': 'composite',
    'name': 'warning',
    'property': 'warning',
    'access': 2,
    'features': [
      {'type': 'enum', 'name': 'mode', 'property': 'mode', 'access': 2, 'values': ['stop', 'burglar']},
    ],
  },
];
const contact = [
  {'type': 'binary', 'name': 'contact', 'property': 'contact', 'access': 1},
];

Z2mDevice dev(String name, String ieee, List<Object?> exposes, {String? description, String? model}) => Z2mDevice(
      friendlyName: name,
      type: 'Router',
      ieeeAddress: ieee,
      rawExposes: exposes,
      description: description,
      model: model,
    );

void main() {
  test('kinds come from the exposes, never the name', () {
    expect(chatKindOf(light), ChatKind.light);
    expect(chatKindOf(cover), ChatKind.cover);
    expect(chatKindOf(plug), ChatKind.switchPlug);
    expect(chatKindOf(thermostat), ChatKind.thermostat);
    expect(chatKindOf(lock), ChatKind.lock);
    expect(chatKindOf(siren), ChatKind.siren);
    expect(chatKindOf(valveSwitch, description: 'Smart water valve'), ChatKind.valve);
    expect(chatKindOf(valveSwitch, description: 'Smart plug'), ChatKind.switchPlug);
    // A thermostat called a radiator valve stays a thermostat.
    expect(chatKindOf(thermostat, description: 'Thermostatic radiator valve'), ChatKind.thermostat);
    expect(chatKindOf(contact), ChatKind.other);
  });

  test('gate, garage and door words in the 13 languages, whole words only', () {
    for (final name in [
      'Garage door', 'Front gate', // en
      'Brána', 'Garážová vrata', // cs
      'Tor', 'Garagentor', 'Hintertür', 'Einfahrtstor', // de
      'Puerta del garaje', 'Portón', // es
      'Portail', 'Porte du garage', // fr
      'שער', 'השער הראשי', 'דלת אחורית', // he
      'Cancello', 'Portone', // it
      'Garasjeport', 'Ytterdør', // nb
      'Poort', 'Achterdeur', 'Garagedeur', // nl
      'Brama wjazdowa', 'Drzwi', // pl
      'Portão', 'Garagem', // pt
      'Ворота', 'Гаражная дверь', // ru
      'Grind', 'Altandörr', 'Garageport', // sv
    ]) {
      expect(chatLooksLikeGate(name), isTrue, reason: name);
    }
    for (final name in [
      'Monitor light', 'Motor blind', 'Office shutter', 'Support', 'Outdoor blind', 'Indoor plug',
      'Kitchen', 'Portable heater', 'Torch', 'Doorbell light', 'Schlafzimmer',
    ]) {
      expect(chatLooksLikeGate(name), isFalse, reason: name);
    }
  });

  test('the control list defaults: lights and covers on tiles on; the rest off; locks, valves, sirens never listed',
      () {
    final items = chatControlItems(
      [
        dev('Hall light', '0x01', light),
        dev('Spare bulb', '0x02', light),
        dev('Office shutter', '0x03', cover),
        dev('Shutter 2', '0x04', cover),
        dev('Kettle plug', '0x05', plug),
        dev('Boiler relay', '0x06', plug),
        dev('Bedroom thermostat', '0x07', thermostat),
        dev('Front lock', '0x08', lock),
        dev('Water main', '0x09', valveSwitch, description: 'Zigbee water valve'),
        dev('Siren', '0x0a', siren),
        dev('Back door sensor', '0x0b', contact),
        dev('Ворота', '0x0c', cover),
        dev('Kettle 2', '0x0d', plug),
      ],
      onTiles: {'0x01', '0x03', '0x04', '0x05', '0x06', '0x07', '0x08', '0x09', '0x0a', '0x0c'},
      // Shutter 2's tile sits on the "Garage" dashboard.
      tags: {
        '0x04': ['Shutter 2', 'Garage'],
      },
    );
    final byName = {for (final i in items) i.name: i};
    expect(byName.keys, isNot(contains('Front lock')));
    expect(byName.keys, isNot(contains('Water main')));
    expect(byName.keys, isNot(contains('Siren')));
    expect(byName.keys, isNot(contains('Back door sensor')));
    expect(byName['Hall light']!.defaultOn, isTrue);
    expect(byName['Spare bulb']!.defaultOn, isFalse, reason: 'no dashboard tile');
    expect(byName['Office shutter']!.defaultOn, isTrue);
    expect(byName['Shutter 2']!.defaultOn, isFalse, reason: 'on the Garage dashboard');
    expect(byName['Ворота']!.defaultOn, isFalse, reason: 'a gate by name');
    expect(byName['Kettle plug']!.defaultOn, isFalse);
    expect(byName['Boiler relay']!.defaultOn, isFalse);
    expect(byName['Bedroom thermostat']!.defaultOn, isFalse);
    // Lights, covers, switches and plugs, thermostats.
    expect(items.map((i) => i.kind).toList(), [
      ChatKind.light, ChatKind.light, ChatKind.cover, ChatKind.cover, ChatKind.cover,
      ChatKind.switchPlug, ChatKind.switchPlug, ChatKind.switchPlug, ChatKind.thermostat,
    ]);
  });
}
