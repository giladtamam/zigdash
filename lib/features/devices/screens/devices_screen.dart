import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../discovery/providers/discovery_provider.dart';
import '../device_health.dart';
import '../devices_providers.dart';
import '../z2m_bridge.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  final _baseController = TextEditingController(text: 'zigbee2mqtt');
  String _base = 'zigbee2mqtt';

  @override
  void dispose() {
    _baseController.dispose();
    super.dispose();
  }

  void _refresh() {
    final newBase = _baseController.text.trim();
    if (newBase.isEmpty) return;
    final args = (connectionId: widget.connectionId, base: newBase);
    ref.invalidate(discoveredDevicesProvider(args));
    ref.invalidate(deviceHealthProvider(args));
    setState(() => _base = newBase);
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final args = (connectionId: widget.connectionId, base: _base);
    final healthAsync = ref.watch(deviceHealthProvider(args));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.devicesTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _baseController,
                    decoration: InputDecoration(
                      labelText: l10n.discoverBaseTopic,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _refresh(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _refresh,
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          Expanded(
            child: healthAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.discoverFailed,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _refresh,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
              data: (devices) {
                if (devices.isEmpty) {
                  return Center(child: Text(l10n.devicesNone));
                }
                return ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, i) {
                    final d = devices[i];
                    return _DeviceHealthTile(health: d);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPairing,
        icon: const Icon(Icons.add),
        label: Text(l10n.devicesAddButton),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Device health list tile
// ---------------------------------------------------------------------------

class _DeviceHealthTile extends StatelessWidget {
  const _DeviceHealthTile({required this.health});

  final DeviceHealth health;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final battery = health.battery;
    final lq = health.linkQuality;
    final online = health.online;

    return ListTile(
      title: Text(health.friendlyName),
      subtitle: Row(
        children: [
          // Battery
          const Icon(Icons.battery_4_bar, size: 16),
          const SizedBox(width: 2),
          Text(
            battery != null ? '$battery%' : '—',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 12),
          // Link quality
          const Icon(Icons.wifi, size: 16),
          const SizedBox(width: 2),
          Text(
            lq != null ? '$lq' : '—',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: _OnlineIndicator(
        online: online,
        labelOnline: l10n.devicesOnline,
        labelOffline: l10n.devicesOffline,
      ),
    );
  }
}

class _OnlineIndicator extends StatelessWidget {
  const _OnlineIndicator({
    required this.online,
    required this.labelOnline,
    required this.labelOffline,
  });

  final bool? online;
  final String labelOnline;
  final String labelOffline;

  @override
  Widget build(BuildContext context) {
    if (online == null) {
      return Icon(Icons.cloud_off, color: Colors.grey.shade400, size: 20);
    }
    return Tooltip(
      message: online! ? labelOnline : labelOffline,
      child: Icon(
        online! ? Icons.cloud : Icons.cloud_off,
        color: online! ? Colors.green : Colors.grey,
        size: 20,
      ),
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
        color: entry.ready ? Colors.green : Colors.orange,
      ),
      title: Text(
        entry.ready
            ? l10n.devicesPaired(entry.name)
            : '${entry.name} — interviewing…',
      ),
    );
  }
}
