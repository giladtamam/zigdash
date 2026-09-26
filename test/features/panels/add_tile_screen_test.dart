import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/daos/panel_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/data/repositories/panel_repo.dart';
import 'package:zigdash/data/repositories/section_repo.dart';
import 'package:zigdash/features/devices/device_registry.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/discovery/providers/discovery_provider.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/screens/add_tile_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';

class _Recording extends PanelRepo {
  _Recording(super.dao);
  final created = <Map<String, Object?>>[];

  @override
  Future<String> create({
    required String dashboardId,
    required String name,
    required PanelType type,
    required String topic,
    String? subscribeTopic,
    String? topicPrefixOverride,
    int qos = 1,
    bool retain = false,
    PanelWidth width = PanelWidth.small,
    int sortOrder = 0,
    String? sectionId,
    String? deviceIeee,
    required PanelConfig config,
  }) async {
    created.add({
      'name': name,
      'type': type,
      'prefix': topicPrefixOverride,
      'width': width,
      'sortOrder': sortOrder,
      'section': sectionId,
      'ieee': deviceIeee,
    });
    return 'new';
  }
}

final _stamp = DateTime(2026, 9, 26);
const _light = [
  {
    'type': 'light',
    'features': [
      {'type': 'binary', 'name': 'state', 'property': 'state', 'access': 7},
    ],
  },
];

Z2mDevice _dev(String name, String ieee, {String? model}) => Z2mDevice(
      friendlyName: name,
      type: 'Router',
      vendor: model == null ? null : 'Tuya',
      model: model,
      ieeeAddress: ieee,
      rawExposes: _light,
    );

void main() {
  late AppDatabase db;
  late _Recording repo;
  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
    repo = _Recording(PanelDao(db));
  });
  tearDown(() => db.close());

  Widget app(List<Z2mDevice> devices,
          {Set<String> linked = const {}, String? prefix = 'zigbee2mqtt'}) =>
      ProviderScope(
        overrides: [
          panelRepoProvider.overrideWithValue(repo),
          dashboardByIdProvider.overrideWith((ref, _) async => Dashboard(
                id: 'd1',
                connectionId: 'c1',
                name: 'Home',
                topicPrefix: prefix,
                colorSeed: 0,
                iconCodepoint: 0,
                locked: false,
                sortOrder: 0,
                createdAt: _stamp,
                updatedAt: _stamp,
              )),
          bridgeDevicesStreamProvider.overrideWith((ref, args) =>
              Stream.value(args.base == 'zigbee2mqtt' ? devices : [])),
          linkedIeeesProvider.overrideWith((ref, _) => Stream.value(linked)),
          sectionsForDashboardProvider.overrideWith((ref, _) => Stream.value([
                Section(
                    id: 's1',
                    dashboardId: 'd1',
                    name: 'Lights',
                    sortOrder: 0,
                    createdAt: _stamp,
                    updatedAt: _stamp),
              ])),
          panelsForDashboardProvider
              .overrideWith((ref, _) => Stream.value(const <Panel>[])),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AddTileScreen(
            connectionId: 'c1',
            dashboardId: 'd1',
            onCustomTile: (_) {},
          ),
        ),
      );

  testWidgets('devices not on a dashboard come first; custom stays below',
      (tester) async {
    await tester.pumpWidget(app(
      [_dev('desk_lamp', '0x1'), _dev('hall', '0x2')],
      linked: {'0x1'},
    ));
    await tester.pumpAndSettle();

    double y(Finder f) => tester.getTopLeft(f).dy;
    expect(find.text('Not on a dashboard'), findsOneWidget);
    expect(find.text('hall'), findsNWidgets(2), reason: 'listed in both');
    expect(find.text('desk_lamp'), findsOneWidget);
    expect(y(find.text('hall').first), lessThan(y(find.text('All devices'))));
    await tester.scrollUntilVisible(find.text('Custom MQTT tile'), 100,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Custom MQTT tile'), findsOneWidget);
  });

  testWidgets('a dashboard with no topic prefix still lists Zigbee2MQTT devices',
      (tester) async {
    await tester.pumpWidget(app([_dev('hall', '0x2')], prefix: null));
    await tester.pumpAndSettle();
    expect(find.text('hall'), findsWidgets);
  });

  testWidgets('adding a device creates its tile in the matching section',
      (tester) async {
    await tester.pumpWidget(app([
      _dev('0xc4d7fdbbfeba0000', '0xc4d7fdbbfeba0000', model: 'CK-BL702-AL-01'),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('0xc4d7fdbbfeba0000').first);
    await tester.pumpAndSettle();
    // An IEEE address is not offered as the name.
    expect(find.text('e.g. Tuya CK-BL702-AL-01'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Desk lamp');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(repo.created.single, {
      'name': 'Desk lamp',
      'type': PanelType.device,
      'prefix': 'zigbee2mqtt/0xc4d7fdbbfeba0000',
      'width': PanelWidth.small,
      'sortOrder': 0,
      'section': 's1',
      'ieee': '0xc4d7fdbbfeba0000',
    });
  });
}
