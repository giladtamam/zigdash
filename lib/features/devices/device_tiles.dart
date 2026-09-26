import '../../data/database/tables/panels.dart';
import '../../data/repositories/panel_repo.dart';
import '../discovery/models/z2m_device.dart';
import '../panels/models/panel_config.dart';
import 'device_profile.dart';

/// The Zigbee2MQTT base topic for a dashboard: its topic prefix, or the
/// Zigbee2MQTT default when a hand-made dashboard left it empty.
String z2mBase(String? dashboardPrefix) {
  final p = dashboardPrefix?.trim() ?? '';
  return p.isEmpty ? 'zigbee2mqtt' : p;
}

/// A tile's default size for a device class: Wide for colour lights and
/// covers, Small otherwise.
PanelWidth defaultTileSize(DeviceClass c) => switch (c) {
      DeviceClass.colorLight || DeviceClass.cover => PanelWidth.wide,
      _ => PanelWidth.small,
    };

/// True for a Zigbee2MQTT friendly name that is still the IEEE address.
bool isIeeeName(String name) => RegExp(r'^0x[0-9a-fA-F]{16}$').hasMatch(name);

/// "Tuya CK-BL702-AL-01", or null.
String? deviceModelLabel(Z2mDevice d) {
  final label = [?d.vendor, ?d.model].join(' ');
  return label.isEmpty ? null : label;
}

/// Creates a device tile for [device]: bound by IEEE address, reading
/// `<base>/<friendly name>` and commanding its `/set`.
Future<String> createDeviceTile(
  PanelRepo panels, {
  required String dashboardId,
  required String base,
  required Z2mDevice device,
  String? name,
  PanelWidth? size,
  String? sectionId,
  required int sortOrder,
}) {
  final profile = classifyExposes(device.rawExposes);
  return panels.create(
    dashboardId: dashboardId,
    name: name ?? device.friendlyName,
    type: PanelType.device,
    topic: 'set',
    subscribeTopic: '',
    topicPrefixOverride: '$base/${device.friendlyName}',
    width: size ?? defaultTileSize(profile.deviceClass),
    sortOrder: sortOrder,
    sectionId: sectionId,
    deviceIeee: device.ieeeAddress,
    config: DeviceTileConfig(profile: profile, model: deviceModelLabel(device)),
  );
}
