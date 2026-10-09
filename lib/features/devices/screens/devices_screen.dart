import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/theme/signal_icons.dart';
import '../../../core/theme/signal_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../../discovery/models/z2m_device.dart';
import '../../discovery/providers/discovery_provider.dart';
import '../../home/home_shell.dart';
import '../../panels/screens/add_tile_screen.dart' show showAddDeviceSheet;
import '../../panels/widgets/device_tile_panel.dart'
    show deviceClassIcon, deviceStateLine, ltr;
import '../../panels/widgets/panel_reliability_frame.dart'
    show formatValueAge;
import '../device_health.dart';
import '../device_profile.dart';
import '../device_registry.dart';
import '../device_state.dart';
import '../devices_providers.dart';
import '../z2m_bridge.dart';

/// Which devices the list shows.
enum DeviceFilter { all, attention, unassigned }

/// The Devices tab (devices-tablet-1.13.md §3): the current home's devices
/// with their health, attention first. Tapping a row opens its device page,
/// or, when [onSelect] is given (the list pane of list-detail), selects it.
class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({
    super.key,
    required this.connectionId,
    this.onSelect,
    this.selectedIeee,
  });

  final String connectionId;
  final ValueChanged<String>? onSelect;
  final String? selectedIeee;

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  var _filter = DeviceFilter.all;
  String? _query;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String get _base =>
      ref.read(homeBaseTopicProvider(widget.connectionId)) ?? 'zigbee2mqtt';

  void _refresh() {
    final args = (connectionId: widget.connectionId, base: _base);
    ref.invalidate(deviceHealthProvider(args));
  }

  void _openPairing() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PairingSheet(
        connectionId: widget.connectionId,
        base: _base,
      ),
    );
  }

  void _open(Z2mDevice d) {
    final ieee = d.ieeeAddress;
    if (ieee == null) return;
    final select = widget.onSelect;
    if (select != null) {
      select(ieee);
    } else {
      context.push(Routes.homeDevice(widget.connectionId, ieee));
    }
  }

  Future<void> _menu(Z2mDevice d, {required bool isNew}) async {
    final l10n = context.l10n;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(l10n.deviceAddToDashboard),
              onTap: () => Navigator.pop(ctx, 'add'),
            ),
            if (isNew)
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined),
                title: Text(l10n.deviceDismiss),
                onTap: () => Navigator.pop(ctx, 'dismiss'),
              ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case 'add':
        await showAddDeviceSheet(context,
            connectionId: widget.connectionId, device: d);
      case 'dismiss':
        await dismissDevices(ref, widget.connectionId, [d]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final base = ref.watch(homeBaseTopicProvider(widget.connectionId)) ??
        'zigbee2mqtt';
    final args = (connectionId: widget.connectionId, base: base);
    final healthAsync = ref.watch(deviceHealthProvider(args));
    final availability =
        ref.watch(availabilityConfigProvider(args)).valueOrNull ??
            AvailabilityConfig.unknown;
    final linked =
        ref.watch(linkedIeeesProvider(widget.connectionId)).valueOrNull ??
            const <String>{};
    final newIeees = {
      for (final d
          in ref.watch(unassignedDevicesProvider(widget.connectionId)).valueOrNull ??
              const <Z2mDevice>[])
        d.ieeeAddress,
    };
    final all = healthAsync.valueOrNull ?? const <DeviceHealth>[];
    final searchable = all.length >= 8;

    return Scaffold(
      appBar: AppBar(
        title: _query != null
            ? TextField(
                controller: _search,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.addTileSearch,
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : HomeTitle(connectionId: widget.connectionId),
        actions: [
          if (_query != null)
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _query = null;
                _search.clear();
              }),
            )
          else if (searchable)
            IconButton(
              tooltip: l10n.addTileSearch,
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _query = ''),
            ),
          const SettingsAction(),
          PopupMenuButton<String>(
            onSelected: (_) => _refresh(),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'refresh', child: Text(l10n.a11yRefresh)),
            ],
          ),
        ],
      ),
      body: healthAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.discoverFailed, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: _refresh, child: Text(l10n.retry)),
              ],
            ),
          ),
        ),
        data: (rows) {
          if (rows.isEmpty) return _NoDevices(args: args);
          bool unassigned(DeviceHealth h) =>
              h.device.ieeeAddress != null &&
              !linked.contains(h.device.ieeeAddress);
          final attention = rows.where((h) => h.needsAttention).length;
          final notOn = rows.where(unassigned).length;
          final filter = switch (_filter) {
            DeviceFilter.attention when attention == 0 => DeviceFilter.all,
            DeviceFilter.unassigned when notOn == 0 => DeviceFilter.all,
            final f => f,
          };
          final q = _query?.trim().toLowerCase() ?? '';
          final shown = [
            for (final h in rows)
              if ((filter == DeviceFilter.all ||
                      (filter == DeviceFilter.attention && h.needsAttention) ||
                      (filter == DeviceFilter.unassigned && unassigned(h))) &&
                  (q.isEmpty || h.friendlyName.toLowerCase().contains(q)))
                h,
          ]..sort(compareHealth);
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.devicesFilterAll),
                      selected: filter == DeviceFilter.all,
                      onSelected: (_) =>
                          setState(() => _filter = DeviceFilter.all),
                    ),
                    if (attention > 0)
                      ChoiceChip(
                        label: Text(l10n.devicesFilterAttention(attention)),
                        selected: filter == DeviceFilter.attention,
                        onSelected: (_) =>
                            setState(() => _filter = DeviceFilter.attention),
                      ),
                    if (notOn > 0)
                      ChoiceChip(
                        label: Text(l10n.devicesFilterUnassigned(notOn)),
                        selected: filter == DeviceFilter.unassigned,
                        onSelected: (_) =>
                            setState(() => _filter = DeviceFilter.unassigned),
                      ),
                  ],
                ),
              ),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.devicesNoMatch, textAlign: TextAlign.center),
                ),
              for (final h in shown)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: DeviceHealthRow(
                    health: h,
                    onDashboard: !unassigned(h),
                    selected: h.device.ieeeAddress != null &&
                        h.device.ieeeAddress == widget.selectedIeee,
                    onTap: () => _open(h.device),
                    onLongPress: () => _menu(h.device,
                        isNew: newIeees.contains(h.device.ieeeAddress)),
                  ),
                ),
              if (!availability.any)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                  child: _AvailabilityNote(
                    onHelp: () => context.push(Routes.help),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPairing,
        icon: const Icon(Icons.add),
        label: Text(l10n.devicesAddButton),
      ),
    );
  }
}

/// One device in the Devices list: class icon, name, one line (the reason
/// it needs attention, else its state), and a health signal only when it
/// matters.
class DeviceHealthRow extends StatelessWidget {
  const DeviceHealthRow({
    super.key,
    required this.health,
    required this.onDashboard,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  final DeviceHealth health;
  final bool onDashboard;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = classifyExposes(health.device.rawExposes);
    final state = DeviceState(profile, health.state ?? const {});
    final on = profile.switches.any((f) => state.isOn(f) == true);
    final line = deviceHealthLine(context, health, state);
    final signal = _signal(context);

    return Material(
      color: selected
          ? scheme.secondaryContainer
          : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                SignalIcon(
                    deviceClassIcon(profile.deviceClass, alarm: state.alarm),
                    active: on,
                    color: on ? SignalColors.of(context).active : null),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(health.friendlyName,
                          style: theme.textTheme.titleSmall),
                      Text(line,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: health.needsAttention
                                  ? scheme.error
                                  : scheme.onSurfaceVariant)),
                      if (!onDashboard)
                        Text(l10n.addTileNotOnDashboard,
                            style: theme.textTheme.labelMedium
                                ?.copyWith(color: scheme.primary)),
                    ],
                  ),
                ),
                if (signal != null) ...[const SizedBox(width: 8), signal],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _signal(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    Widget chip(IconData icon, String text, Color bg, Color fg) => Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 4),
            Text(text,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: fg)),
          ]),
        );
    if (health.lowBattery) {
      final b = health.battery;
      return chip(Icons.battery_alert, b == null ? l10n.deviceBatteryLow : ltr('$b%'),
          scheme.errorContainer, scheme.onErrorContainer);
    }
    if (health.notResponding || health.offline) {
      return Icon(Icons.cloud_off, size: 20, color: scheme.error);
    }
    if (health.weakLink) {
      return chip(Symbols.signalCellularAlt1Bar, l10n.deviceLinkWeak,
          scheme.surfaceContainerHighest, scheme.onSurfaceVariant);
    }
    return null;
  }
}

/// The line under a device's name: why it needs attention, else its state
/// with the age when the value is not fresh.
String deviceHealthLine(
    BuildContext context, DeviceHealth health, DeviceState state) {
  final l10n = context.l10n;
  if (health.unsupported) return l10n.deviceUnsupported;
  if (health.device.interviewFailed) return l10n.deviceInterviewFailed;
  if (health.offline) return l10n.devicesOffline;
  if (health.notResponding) return l10n.deviceNotResponding;
  if (!state.hasReported) return l10n.deviceNoReport;
  final line = deviceStateLine(state, l10n);
  final at = health.lastHeard;
  if (!health.stale || at == null) return line;
  return '$line · ${formatValueAge(context, at, DateTime.now())}';
}

/// The empty list. When Zigbee2MQTT never sent its device list (a broker
/// restart drops it), says so and offers to restart Zigbee2MQTT instead of
/// claiming there are no devices.
class _NoDevices extends ConsumerStatefulWidget {
  const _NoDevices({required this.args});

  final DiscoveryArgs args;

  @override
  ConsumerState<_NoDevices> createState() => _NoDevicesState();
}

class _NoDevicesState extends ConsumerState<_NoDevices> {
  bool _restarting = false;

  Future<void> _restart() async {
    setState(() => _restarting = true);
    await restartZigbee2mqtt(ref, widget.args.connectionId, widget.args.base);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final missing =
        ref.watch(bridgeDevicesMissingProvider(widget.args)).valueOrNull ??
            false;
    if (!missing) return Center(child: Text(l10n.devicesNone));
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.devicesListMissing, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (_restarting)
              Text(l10n.devicesRestartingZ2m, textAlign: TextAlign.center)
            else
              FilledButton(
                onPressed: _restart,
                child: Text(l10n.devicesRestartZ2m),
              ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityNote extends StatelessWidget {
  const _AvailabilityNote({required this.onHelp});

  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline,
            size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.devicesAvailabilityOff,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 40),
                    alignment: AlignmentDirectional.centerStart),
                onPressed: onHelp,
                child: Text(l10n.devicesAvailabilityHow),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pairing bottom sheet
// ---------------------------------------------------------------------------

class _PairingSheet extends ConsumerStatefulWidget {
  const _PairingSheet({
    required this.connectionId,
    required this.base,
  });

  final String connectionId;
  final String base;

  @override
  ConsumerState<_PairingSheet> createState() => _PairingSheetState();
}

class _PairingSheetState extends ConsumerState<_PairingSheet> {
  Timer? _countdownTimer;
  int _secondsLeft = 254;
  final List<_PairedEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _startPairing();
  }

  Future<void> _startPairing() async {
    await setPermitJoin(
      ref,
      widget.connectionId,
      widget.base,
      enable: true,
    );
    if (!mounted) return;
    setState(() {
      _secondsLeft = 254;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
      });
    });
  }

  Future<void> _stopPairing() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    await setPermitJoin(
      ref,
      widget.connectionId,
      widget.base,
      enable: false,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    // Best-effort stop (fire-and-forget) — don't await in dispose.
    setPermitJoin(ref, widget.connectionId, widget.base, enable: false);
    super.dispose();
  }

  void _handleEvent(BridgeEvent event) {
    final name = event.friendlyName;
    if (name == null) return;

    final isReady = event.type == BridgeEventType.deviceJoined ||
        (event.type == BridgeEventType.deviceInterview &&
            event.interviewStatus == 'successful');

    setState(() {
      final idx = _entries.indexWhere((e) => e.name == name);
      if (idx >= 0) {
        if (isReady) {
          _entries[idx] = _PairedEntry(name: name, ready: true);
        }
      } else {
        _entries.add(_PairedEntry(name: name, ready: isReady));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Listen to bridge events.
    ref.listen(
      bridgeEventsProvider(
          (connectionId: widget.connectionId, base: widget.base)),
      (_, next) {
        next.whenData(_handleEvent);
      },
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.devicesPairingTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await _stopPairing();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(l10n.devicesPairingStop),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Hint with countdown
            Text(
              l10n.devicesPairingHint(_secondsLeft),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_entries.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              ..._entries.map((entry) => _PairedEntryTile(entry: entry)),
              const SizedBox(height: 8),
              Text(
                l10n.devicesPairedHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PairedEntry {
  const _PairedEntry({required this.name, required this.ready});
  final String name;
  final bool ready;
}

class _PairedEntryTile extends StatelessWidget {
  const _PairedEntryTile({required this.entry});

  final _PairedEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListTile(
      contentPadding: EdgeInsetsDirectional.zero,
      leading: Icon(
        entry.ready ? Icons.check_circle : Icons.hourglass_top,
        color: entry.ready
            ? SignalColors.of(context).onHealthy
            : SignalColors.of(context).onAttention,
      ),
      title: Text(
        entry.ready
            ? l10n.devicesPaired(entry.name)
            : '${entry.name} — interviewing…',
      ),
    );
  }
}
