import 'package:flutter/material.dart';
import '../../../core/theme/signal_colors.dart';
import '../../../core/theme/signal_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/last_dashboard_store.dart';
import '../../../core/router/routes.dart';
import '../../../data/database/daos/device_registry_dao.dart';
import '../../../data/database/database.dart';
import '../../../data/database/tables/panels.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../../l10n/app_localizations.dart';
import '../../discovery/models/z2m_device.dart';
import '../../discovery/providers/discovery_provider.dart';
import '../../panels/screens/add_tile_screen.dart'
    show deviceClassLabel, showAddDeviceSheet;
import '../../panels/widgets/device_sheet.dart'
    show DeviceControls, humanizeProperty;
import '../../panels/widgets/device_tile_panel.dart'
    show deviceClassIcon, formatReading, ltr;
import '../../panels/widgets/panel_reliability_frame.dart'
    show formatValueAge;
import '../device_health.dart';
import '../device_profile.dart';
import '../device_registry.dart';
import '../device_state.dart';
import '../device_tiles.dart';
import '../devices_providers.dart';
import '../z2m_bridge.dart';
import '../../panels/models/panel_config.dart';
import '../../../shortcuts/add_tile_button.dart';
import 'devices_screen.dart' show deviceHealthLine;

/// Tiles of a home that show one device, with dashboard and section.
final deviceTilesProvider = StreamProvider.autoDispose.family<
    List<(Panel, Dashboard, Section?)>,
    ({String connectionId, String ieee})>((ref, key) =>
    DeviceRegistryDao(ref.watch(appDatabaseProvider))
        .watchTilesOfDevice(key.connectionId, key.ieee));

/// The page for one device (devices-tablet-1.13.md §4): its controls,
/// readings, health, and the dashboards it is on. Addressed by IEEE so it
/// follows renames. [embedded] drops the app bar for the detail pane.
class DevicePage extends ConsumerStatefulWidget {
  const DevicePage({
    super.key,
    required this.connectionId,
    required this.ieee,
    this.embedded = false,
  });

  final String connectionId;
  final String ieee;
  final bool embedded;

  @override
  ConsumerState<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends ConsumerState<DevicePage> {
  @override
  void initState() {
    super.initState();
    _acknowledge();
  }

  @override
  void didUpdateWidget(DevicePage old) {
    super.didUpdateWidget(old);
    if (old.ieee != widget.ieee) _acknowledge();
  }

  /// Renames the device in Zigbee2MQTT; tiles follow (device registry).
  Future<void> _rename(BuildContext context, String base, String current) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController(text: current);
    final to = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deviceRenameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(helperText: l10n.deviceRenameHint),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.deviceRename)),
        ],
      ),
    );
    controller.dispose();
    if (to == null || to.isEmpty || to == current) return;
    final error = await renameDevice(ref, widget.connectionId, base,
        from: current, to: to);
    messenger.showSnackBar(SnackBar(
        content: Text(error == null
            ? l10n.deviceRenamed(to)
            : l10n.deviceRenameFailed(
                error.isEmpty ? l10n.deviceRenameNoAnswer : error))));
  }

  /// Opening the page is seeing the device: its low battery stops lighting
  /// the Devices dot.
  void _acknowledge() => DeviceRegistryDao(ref.read(appDatabaseProvider))
      .acknowledgeBattery(widget.connectionId, widget.ieee)
      .ignore();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final base = ref.watch(homeBaseTopicProvider(widget.connectionId)) ??
        'zigbee2mqtt';
    final args = (connectionId: widget.connectionId, base: base);
    final devices = ref.watch(bridgeDevicesStreamProvider(args));
    final device = devices.valueOrNull
        ?.where((d) => d.ieeeAddress == widget.ieee)
        .firstOrNull;
    final health = ref
        .watch(deviceHealthProvider(args))
        .valueOrNull
        ?.where((h) => h.device.ieeeAddress == widget.ieee)
        .firstOrNull;
    final tiles = ref
            .watch(deviceTilesProvider(
                (connectionId: widget.connectionId, ieee: widget.ieee)))
            .valueOrNull ??
        const [];
    final title = device?.friendlyName ??
        tiles.firstOrNull?.$1.name ??
        widget.ieee;

    final Widget body;
    if (device == null) {
      body = devices.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(l10n.deviceGone),
                ),
                _DashboardsCard(
                    connectionId: widget.connectionId,
                    device: null,
                    tiles: tiles),
              ],
            );
    } else {
      body = _DeviceBody(
        connectionId: widget.connectionId,
        base: base,
        device: device,
        health: health ?? DeviceHealth(device: device),
        tiles: tiles,
      );
    }

    // Only devices with a switch or a cover, shown on a dashboard, can be
    // a tile: the tile switches them like the dashboard tile's quick action.
    final tileable = AddTileButton.available &&
        tiles.any((t) {
          if (t.$1.type != PanelType.device) return false;
          final c = PanelConfig.decode(t.$1.type, t.$1.config);
          return c is DeviceTileConfig &&
              (c.profile.switches.isNotEmpty ||
                  c.profile.deviceClass == DeviceClass.cover);
        });
    final addTile = tileable
        ? AddTileButton(
            connectionId: widget.connectionId, ieee: widget.ieee, name: title)
        : null;
    final rename = device == null
        ? null
        : IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.deviceRename,
            onPressed: () => _rename(context, base, device.friendlyName),
          );

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 12, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      semanticsLabel: title),
                ),
                ?rename,
                ?addTile,
              ],
            ),
          ),
          Expanded(child: body),
        ],
      );
    }
    return Scaffold(
        appBar: AppBar(title: Text(title), actions: [?rename, ?addTile]),
        body: body);
  }
}

class _DeviceBody extends ConsumerWidget {
  const _DeviceBody({
    required this.connectionId,
    required this.base,
    required this.device,
    required this.health,
    required this.tiles,
  });

  final String connectionId;
  final String base;
  final Z2mDevice device;
  final DeviceHealth health;
  final List<(Panel, Dashboard, Section?)> tiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = classifyExposes(device.rawExposes);
    final state = DeviceState(profile, health.state ?? const {});
    final on = profile.switches.any((f) => state.isOn(f) == true);
    final controls = !health.unsupported && DeviceControls.hasControls(profile);
    final readings = _readings(profile);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Row(
            children: [
              // Signal: amber and a filled icon when on, as on the tiles.
              CircleAvatar(
                radius: 28,
                backgroundColor: on
                    ? SignalColors.of(context).active
                    : scheme.surfaceContainerHighest,
                foregroundColor:
                    on ? SignalColors.of(context).onActive : scheme.onSurface,
                child: SignalIcon(
                    deviceClassIcon(profile.deviceClass, alarm: state.alarm),
                    active: on,
                    size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deviceHealthLine(context, health, state),
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: health.needsAttention ? scheme.error : null)),
                    Text(
                      [
                        ?deviceModelLabel(device),
                        deviceClassLabel(profile.deviceClass, l10n),
                      ].join(' · '),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (health.unsupported)
          _Card(
            title: l10n.deviceControlTitle,
            children: [Text(l10n.deviceUnsupportedBody)],
          )
        else if (controls)
          _Card(
            title: l10n.deviceControlTitle,
            children: [
              DeviceControls(
                connectionId: connectionId,
                publishTopic: '$base/${device.friendlyName}/set',
                profile: profile,
                state: state,
                readings: false,
              ),
            ],
          ),
        if (readings.isNotEmpty)
          _Card(
            title: l10n.deviceReadingsTitle,
            children: [
              for (final f in readings)
                _ReadingRow(
                  label: humanizeProperty(f.property),
                  value: _value(l10n, state.values[f.property], f),
                  large: !controls,
                  onAdd: f.type == 'numeric'
                      ? () => _addReading(context, ref, f)
                      : null,
                ),
            ],
          ),
        _HealthCard(connectionId: connectionId, base: base, health: health),
        _DashboardsCard(
            connectionId: connectionId, device: device, tiles: tiles),
      ],
    );
  }

  /// Values to list: every readable, normal expose that the controls do not
  /// already show, minus battery and link quality (in the health card).
  List<DeviceFeature> _readings(DeviceProfile profile) {
    final shown = {
      ...profile.switches,
      ?profile.brightness,
      ?profile.colorTemp,
      ?profile.position,
      ...DeviceControls.genericControls(profile),
    };
    const health = {'battery', 'battery_low', 'linkquality', 'voltage'};
    return [
      for (final f in profile.normal)
        if (f.readable &&
            f.type != 'composite' &&
            f.type != 'list' &&
            f.parent != 'light' &&
            f.parent != 'cover' &&
            !shown.contains(f) &&
            !health.contains(f.property))
          f,
    ];
  }

  String _value(AppLocalizations l10n, Object? v, DeviceFeature f) {
    if (v == null) return '—';
    if (v is num) return formatReading(v, f.unit);
    if (f.type == 'binary') {
      final on = v == (f.valueOn ?? true);
      return switch (f.property) {
        'contact' => on ? l10n.deviceClosed : l10n.deviceOpen,
        'occupancy' || 'presence' => on ? l10n.deviceMotion : l10n.deviceClear,
        _ => on ? l10n.deviceOn : l10n.deviceOff,
      };
    }
    return humanizeProperty('$v');
  }

  Future<void> _addReading(
      BuildContext context, WidgetRef ref, DeviceFeature f) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final dashboards = await ref
        .read(dashboardRepoProvider)
        .getByConnection(connectionId);
    if (dashboards.isEmpty || !context.mounted) return;
    final target = dashboards.length == 1
        ? dashboards.single
        : await showDialog<Dashboard>(
            context: context,
            builder: (ctx) => SimpleDialog(
              title: Text(l10n.deviceAddReadingTo),
              children: [
                for (final d in dashboards)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(ctx, d),
                    child: Text(d.name),
                  ),
              ],
            ),
          );
    if (target == null || !context.mounted) return;
    final panels = ref.read(panelRepoProvider);
    final existing = await panels.getByDashboard(target.id);
    if (!context.mounted) return;
    final wide = MediaQuery.sizeOf(context).width >= 840;
    await createReadingTile(
      panels,
      dashboardId: target.id,
      base: base,
      device: device,
      feature: f,
      name: '${device.friendlyName} ${humanizeProperty(f.property).toLowerCase()}',
      size: wide ? PanelWidth.wide : PanelWidth.small,
      sortOrder: existing.length,
    );
    messenger.showSnackBar(
        SnackBar(content: Text(l10n.deviceAddedTo(target.name))));
  }

}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children, this.alert = false});

  final String title;
  final List<Widget> children;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card.filled(
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: alert ? BorderSide(color: scheme.error) : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ),
              const SizedBox(height: 4),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingRow extends StatelessWidget {
  const _ReadingRow({
    required this.label,
    required this.value,
    this.large = false,
    this.onAdd,
  });

  final String label;
  final String value;
  final bool large;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: large
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value, style: theme.textTheme.headlineMedium),
                      Text(label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: Text(label)),
                      Text(value, style: theme.textTheme.titleMedium),
                    ],
                  ),
          ),
          if (onAdd != null)
            IconButton(
              tooltip: l10n.deviceAddReadingTile,
              icon: const Icon(Icons.add_chart),
              onPressed: onAdd,
            ),
        ],
      ),
    );
  }
}

class _HealthCard extends ConsumerWidget {
  const _HealthCard({
    required this.connectionId,
    required this.base,
    required this.health,
  });

  final String connectionId;
  final String base;
  final DeviceHealth health;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final config = ref
            .watch(availabilityConfigProvider(
                (connectionId: connectionId, base: base)))
            .valueOrNull ??
        AvailabilityConfig.unknown;
    final b = health.battery;
    final lq = health.linkQuality;
    final at = health.lastHeard;
    final source = health.device.powerSource;
    Widget row(String k, String v, {Color? color, IconData? icon}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
            ],
            Expanded(child: Text(k)),
            Flexible(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(v,
                    textAlign: TextAlign.end,
                    style:
                        TextStyle(color: color ?? scheme.onSurfaceVariant)),
              ),
            ),
          ]),
        );
    return _Card(
      title: l10n.deviceHealthTitle,
      alert: health.needsAttention,
      children: [
        if (b != null || health.lowBattery)
          row(
            l10n.devicesBattery,
            health.lowBattery
                ? [if (b != null) ltr('$b%'), l10n.deviceBatteryLow].join(' · ')
                : ltr('$b%'),
            color: health.lowBattery ? scheme.error : null,
            icon: health.lowBattery ? Icons.battery_alert : null,
          ),
        if (lq != null)
          row(
            l10n.deviceLinkQuality,
            '${health.weakLink ? l10n.deviceLinkWeak : l10n.deviceLinkGood} · ${ltr('$lq')}',
          ),
        if (source != null)
          row(l10n.devicePowerSource,
              source.toLowerCase().startsWith('battery')
                  ? l10n.devicePowerBattery
                  : l10n.devicePowerMains),
        row(l10n.deviceLastHeard,
            at == null ? l10n.deviceNoReport : formatValueAge(context, at, DateTime.now())),
        row(
          l10n.deviceAvailability,
          !config.tracks(health.device.ieeeAddress)
              ? l10n.deviceAvailabilityOff
              : health.online == null
                  ? '—'
                  : health.online!
                      ? l10n.devicesOnline
                      : l10n.devicesOffline,
          color: health.offline ? scheme.error : null,
        ),
      ],
    );
  }
}

class _DashboardsCard extends ConsumerWidget {
  const _DashboardsCard({
    required this.connectionId,
    required this.device,
    required this.tiles,
  });

  final String connectionId;
  final Z2mDevice? device;
  final List<(Panel, Dashboard, Section?)> tiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final d = device;
    final isNew = d != null &&
        (ref.watch(unassignedDevicesProvider(connectionId)).valueOrNull ??
                const <Z2mDevice>[])
            .any((x) => x.ieeeAddress == d.ieeeAddress);
    return _Card(
      title: l10n.deviceOnDashboards,
      children: [
        if (tiles.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(l10n.addTileNotOnDashboard),
          ),
        for (final (panel, dashboard, section) in tiles)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.dashboard_outlined),
            title: Text([dashboard.name, ?section?.name].join(' › ')),
            subtitle: panel.name == d?.friendlyName ? null : Text(panel.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await ref
                  .read(lastDashboardStoreProvider)
                  .rememberDashboard(connectionId, dashboard.id);
              if (context.mounted) {
                context.go(Routes.homeDashboards(connectionId));
              }
            },
          ),
        if (d != null)
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonalIcon(
                icon: const Icon(Icons.add),
                label: Text(l10n.deviceAddToDashboard),
                onPressed: () => showAddDeviceSheet(context,
                    connectionId: connectionId, device: d),
              ),
              if (isNew)
                TextButton(
                  onPressed: () => dismissDevices(ref, connectionId, [d]),
                  child: Text(l10n.deviceDismiss),
                ),
            ],
          ),
      ],
    );
  }
}
