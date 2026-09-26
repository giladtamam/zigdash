import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../../data/database/tables/panels.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../../data/repositories/section_repo.dart';
import '../../../l10n/app_localizations.dart';
import '../../devices/device_profile.dart';
import '../../devices/device_registry.dart';
import '../../devices/device_tiles.dart';
import '../../discovery/models/z2m_device.dart';
import '../../discovery/providers/discovery_provider.dart';
import '../widgets/device_tile_panel.dart' show deviceClassIcon;

/// Add tile, device-first (docs/design/dashboard-1.12.md §8): devices not on
/// any dashboard first, then all devices; Reading and Custom MQTT tile below.
class AddTileScreen extends ConsumerStatefulWidget {
  const AddTileScreen({
    super.key,
    required this.connectionId,
    required this.dashboardId,
    required this.onCustomTile,
  });

  final String connectionId;
  final String dashboardId;

  /// Opens the Custom MQTT tile type list (today's panel picker).
  final void Function(BuildContext context) onCustomTile;

  @override
  ConsumerState<AddTileScreen> createState() => _AddTileScreenState();
}

class _AddTileScreenState extends ConsumerState<AddTileScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dashboard = ref.watch(dashboardByIdProvider(widget.dashboardId));
    final base = dashboard.valueOrNull?.topicPrefix;
    final devicesAsync = base == null || base.isEmpty
        ? const AsyncValue<List<Z2mDevice>>.data([])
        : ref.watch(bridgeDevicesStreamProvider(
            (connectionId: widget.connectionId, base: base)));
    final linked =
        ref.watch(linkedIeeesProvider(widget.connectionId)).valueOrNull ??
            const <String>{};

    final q = _query.text.trim().toLowerCase();
    bool matches(Z2mDevice d) =>
        q.isEmpty ||
        d.friendlyName.toLowerCase().contains(q) ||
        (deviceModelLabel(d)?.toLowerCase().contains(q) ?? false);
    final devices = [
      for (final d in devicesAsync.valueOrNull ?? const <Z2mDevice>[])
        if (d.ieeeAddress != null && d.supported && matches(d)) d,
    ];
    final unassigned = [
      for (final d in devices)
        if (!linked.contains(d.ieeeAddress)) d,
    ];

    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SearchBar(
          controller: _query,
          hintText: l10n.addTileSearch,
          leading: const Icon(Icons.search),
          onChanged: (_) => setState(() {}),
        ),
      ),
    ];
    void section(String title) => children.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
        ));

    if (devicesAsync.isLoading && devices.isEmpty) {
      children.add(const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ));
    } else if (devices.isEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.addTileNoDevices),
      ));
    } else {
      if (unassigned.isNotEmpty) {
        section(l10n.addTileNotOnDashboard);
        children.addAll(unassigned.map(_row));
      }
      section(l10n.addTileAllDevices);
      children.addAll(devices.map(_row));
    }

    children.addAll([
      const Divider(height: 32),
      ListTile(
        leading: const Icon(Icons.speed),
        title: Text(l10n.addTileReading),
        subtitle: Text(l10n.addTileReadingSubtitle),
        onTap: () => context.pushReplacement(
          '/connections/${widget.connectionId}/dashboards/'
          '${widget.dashboardId}/panels/new?type=reading',
        ),
      ),
      ListTile(
        leading: const Icon(Icons.settings_ethernet),
        title: Text(l10n.addTileCustom),
        subtitle: Text(l10n.addTileCustomSubtitle),
        onTap: () => widget.onCustomTile(context),
      ),
      const SizedBox(height: 24),
    ]);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashAddTile)),
      body: ListView(children: children),
    );
  }

  Widget _row(Z2mDevice d) {
    final l10n = context.l10n;
    final cls = classifyExposes(d.rawExposes).deviceClass;
    return ListTile(
      leading: Icon(deviceClassIcon(cls)),
      title: Text(d.friendlyName),
      subtitle: Text([
        deviceClassLabel(cls, l10n),
        ?deviceModelLabel(d),
      ].join(' · ')),
      onTap: () => _confirm(d, cls),
    );
  }

  Future<void> _confirm(Z2mDevice device, DeviceClass cls) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _AddDeviceSheet(
        dashboardId: widget.dashboardId,
        device: device,
        deviceClass: cls,
      ),
    );
    if (added == true && mounted) Navigator.pop(context);
  }
}

String deviceClassLabel(DeviceClass c, AppLocalizations l10n) => switch (c) {
      DeviceClass.colorLight => l10n.deviceClassColorLight,
      DeviceClass.light => l10n.deviceClassLight,
      DeviceClass.switchPlug => l10n.deviceClassSwitch,
      DeviceClass.cover => l10n.deviceClassCover,
      DeviceClass.leakSmoke => l10n.deviceClassLeak,
      DeviceClass.contact => l10n.deviceClassContact,
      DeviceClass.motion => l10n.deviceClassMotion,
      DeviceClass.climate => l10n.deviceClassClimate,
      DeviceClass.generic => l10n.deviceClassGeneric,
    };

/// The recommended tile for a device — name, size, section — editable
/// before it is added.
class _AddDeviceSheet extends ConsumerStatefulWidget {
  const _AddDeviceSheet({
    required this.dashboardId,
    required this.device,
    required this.deviceClass,
  });

  final String dashboardId;
  final Z2mDevice device;
  final DeviceClass deviceClass;

  @override
  ConsumerState<_AddDeviceSheet> createState() => _AddDeviceSheetState();
}

class _AddDeviceSheetState extends ConsumerState<_AddDeviceSheet> {
  late final _name = TextEditingController(
    // An IEEE address is not a name: ask for one.
    text: isIeeeName(widget.device.friendlyName)
        ? ''
        : widget.device.friendlyName,
  );
  late PanelWidth _size = defaultTileSize(widget.deviceClass);
  String? _sectionId;
  bool _sectionChosen = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _add(Dashboard dashboard, int sortOrder) async {
    setState(() => _saving = true);
    final name = _name.text.trim();
    await createDeviceTile(
      ref.read(panelRepoProvider),
      dashboardId: widget.dashboardId,
      base: dashboard.topicPrefix ?? 'zigbee2mqtt',
      device: widget.device,
      name: name.isEmpty ? widget.device.friendlyName : name,
      size: _size,
      sectionId: _sectionId,
      sortOrder: sortOrder,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final dashboard =
        ref.watch(dashboardByIdProvider(widget.dashboardId)).valueOrNull;
    final sections =
        ref.watch(sectionsForDashboardProvider(widget.dashboardId)).valueOrNull ??
            const <Section>[];
    final tiles =
        ref.watch(panelsForDashboardProvider(widget.dashboardId)).valueOrNull ??
            const <Panel>[];
    if (!_sectionChosen) {
      // Default to the section named after the class's group, if any.
      final group = _groupName(widget.deviceClass, l10n);
      _sectionId = sections.where((s) => s.name == group).firstOrNull?.id;
    }
    final sortOrder = tiles.fold<int>(-1, (m, p) => p.sortOrder > m ? p.sortOrder : m) + 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(deviceClassIcon(widget.deviceClass), size: 32),
            title: Text(deviceClassLabel(widget.deviceClass, l10n),
                style: theme.textTheme.titleMedium),
            subtitle: Text([
              widget.device.friendlyName,
              ?deviceModelLabel(widget.device),
            ].join(' · ')),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            autofocus: isIeeeName(widget.device.friendlyName),
            decoration: InputDecoration(
              labelText: l10n.addTileName,
              hintText: deviceModelLabel(widget.device) == null
                  ? null
                  : l10n.addTileNameHint(deviceModelLabel(widget.device)!),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.addTileSize, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<PanelWidth>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                  value: PanelWidth.small, label: Text(l10n.tileSizeSmall)),
              ButtonSegment(
                  value: PanelWidth.wide, label: Text(l10n.tileSizeWide)),
              ButtonSegment(
                  value: PanelWidth.full, label: Text(l10n.tileSizeFull)),
            ],
            selected: {_size},
            onSelectionChanged: (s) => setState(() => _size = s.first),
          ),
          if (sections.isNotEmpty) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _sectionId,
              decoration: InputDecoration(labelText: l10n.addTileSection),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.addTileNoSection)),
                for (final s in sections)
                  DropdownMenuItem(value: s.id, child: Text(s.name)),
              ],
              onChanged: (v) => setState(() {
                _sectionChosen = true;
                _sectionId = v;
              }),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: dashboard == null || _saving
                ? null
                : () => _add(dashboard, sortOrder),
            child: Text(l10n.addTileAdd),
          ),
        ],
      ),
    );
  }

  static String _groupName(DeviceClass c, AppLocalizations l10n) => switch (c) {
        DeviceClass.colorLight || DeviceClass.light => l10n.sectionLights,
        DeviceClass.switchPlug || DeviceClass.cover =>
          l10n.sectionSwitchesCovers,
        DeviceClass.generic => l10n.sectionOther,
        _ => l10n.sectionSensors,
      };
}
