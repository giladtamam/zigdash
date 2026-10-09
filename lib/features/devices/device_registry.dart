import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/daos/device_registry_dao.dart';
import '../../data/database/database.dart';
import '../../data/database/tables/panels.dart';
import '../discovery/models/z2m_device.dart';
import '../discovery/providers/discovery_provider.dart';
import 'devices_providers.dart';
import '../panels/providers/panel_value_provider.dart';

/// Keeps a home's tiles in step with its Zigbee2MQTT device list. Runs on
/// every `bridge/devices` message and is safe to repeat.
class DeviceRegistry {
  DeviceRegistry(this._dao);

  final DeviceRegistryDao _dao;

  Future<void> sync(
    String connectionId,
    String base,
    List<Z2mDevice> devices,
  ) async {
    final byIeee = {
      for (final d in devices)
        if (d.ieeeAddress != null) d.ieeeAddress!: d,
    };
    final byTopic = {
      for (final d in byIeee.values) '$base/${d.friendlyName}': d,
    };
    final tiles = await _dao.tilesOfHome(connectionId);
    for (final (tile, dashboardPrefix) in tiles) {
      final ieee = tile.deviceIeee;
      if (ieee != null) {
        // Follow renames: device and reading tiles address the device by its
        // current friendly name.
        final device = byIeee[ieee];
        final expected = device == null ? null : '$base/${device.friendlyName}';
        if (expected != null &&
            (tile.type == PanelType.device || tile.type == PanelType.reading) &&
            tile.topicPrefixOverride != expected) {
          await _dao.setPrefix(tile.id, expected);
        }
        continue;
      }
      // Link custom tiles that read or command a known device's topic, so
      // devices already on a dashboard never count as unassigned.
      final prefix = tile.topicPrefixOverride ?? dashboardPrefix;
      for (final topic in {
        composeTopic(prefix, tile.subscribeTopic ?? tile.topic),
        composeTopic(prefix, tile.topic),
      }) {
        final state = topic.endsWith('/set')
            ? topic.substring(0, topic.length - 4)
            : topic;
        final device = byTopic[state];
        if (device != null) {
          await _dao.setLink(tile.id, device.ieeeAddress!);
          break;
        }
      }
    }
    // Once per home: devices that exist now count as seen, so an upgrade or
    // a fresh setup never raises the new-device dot. Only later pairings do.
    if (await _dao.devicesSeenAt(connectionId) == null) {
      final linked = (await _dao.tilesOfHome(connectionId))
          .map((t) => t.$1.deviceIeee)
          .whereType<String>()
          .toSet();
      await _dao.dismiss(
        connectionId,
        byIeee.keys.where((ieee) => !linked.contains(ieee)),
      );
      await _dao.markDevicesSeen(connectionId);
    }
  }
}

/// Devices of a home that are on no dashboard and not dismissed: what the
/// Devices-tab dot and the Edit-mode card count.
List<Z2mDevice> unassignedDevices(
  List<Z2mDevice> devices,
  Set<String> linked,
  Set<String> dismissed,
) =>
    [
      for (final d in devices)
        if (d.ieeeAddress != null &&
            !linked.contains(d.ieeeAddress) &&
            !dismissed.contains(d.ieeeAddress))
          d,
    ];

final deviceRegistryProvider = Provider<DeviceRegistry>(
  (ref) => DeviceRegistry(DeviceRegistryDao(ref.watch(appDatabaseProvider))),
);

/// Keeps [DeviceRegistry] in step with a home's device list while watched:
/// runs a sync on the retained list and on every update. An empty or
/// unreadable list is skipped, so a bad payload never marks devices seen.
final homeDeviceSyncProvider =
    Provider.autoDispose.family<void, DiscoveryArgs>((ref, args) {
  ref.listen(bridgeDevicesStreamProvider(args), (_, next) {
    final devices = next.valueOrNull;
    if (devices == null || devices.isEmpty) return;
    ref
        .read(deviceRegistryProvider)
        .sync(args.connectionId, args.base, devices)
        .ignore();
  }, fireImmediately: true);
});

/// IEEE addresses on any tile of a home.
final linkedIeeesProvider =
    StreamProvider.autoDispose.family<Set<String>, String>((ref, connectionId) =>
        DeviceRegistryDao(ref.watch(appDatabaseProvider))
            .watchLinkedIeees(connectionId));

/// IEEE addresses dismissed in a home.
final dismissedIeeesProvider =
    StreamProvider.autoDispose.family<Set<String>, String>((ref, connectionId) =>
        DeviceRegistryDao(ref.watch(appDatabaseProvider))
            .watchDismissed(connectionId));

/// A home's devices on no dashboard and not dismissed: the Edit-mode card
/// and the Devices dot. Empty until the device list arrives.
final unassignedDevicesProvider = Provider.autoDispose
    .family<AsyncValue<List<Z2mDevice>>, String>((ref, connectionId) {
  final base = ref.watch(homeBaseTopicProvider(connectionId));
  if (base == null) return const AsyncValue.data([]);
  final devices = ref.watch(bridgeDevicesStreamProvider(
      (connectionId: connectionId, base: base)));
  final linked = ref.watch(linkedIeeesProvider(connectionId)).valueOrNull;
  final dismissed = ref.watch(dismissedIeeesProvider(connectionId)).valueOrNull;
  if (linked == null || dismissed == null) return const AsyncValue.data([]);
  return devices.whenData((d) => unassignedDevices(d, linked, dismissed));
});

/// How many devices the Devices dot counts.
final unassignedCountProvider =
    Provider.autoDispose.family<AsyncValue<int>, String>((ref, connectionId) =>
        ref
            .watch(unassignedDevicesProvider(connectionId))
            .whenData((d) => d.length));

/// Dismisses [devices] in a home: they stop counting as new.
Future<void> dismissDevices(
        WidgetRef ref, String connectionId, Iterable<Z2mDevice> devices) =>
    DeviceRegistryDao(ref.read(appDatabaseProvider))
        .dismiss(connectionId, devices.map((d) => d.ieeeAddress).whereType());
