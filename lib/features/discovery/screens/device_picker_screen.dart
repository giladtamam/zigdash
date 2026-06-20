import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/tables/panels.dart';
import '../models/device_panel_suggestion.dart';
import '../providers/discovery_provider.dart';

class DevicePickerScreen extends ConsumerStatefulWidget {
  const DevicePickerScreen({
    super.key,
    required this.connectionId,
    required this.dashboardId,
  });

  final String connectionId;
  final String dashboardId;

  @override
  ConsumerState<DevicePickerScreen> createState() => _DevicePickerScreenState();
}

class _DevicePickerScreenState extends ConsumerState<DevicePickerScreen> {
  final _baseController = TextEditingController(text: 'zigbee2mqtt');
  String _base = 'zigbee2mqtt';

  @override
  void dispose() {
    _baseController.dispose();
    super.dispose();
  }

  void _scan() {
    final newBase = _baseController.text.trim();
    if (newBase.isEmpty) return;
    final args = (connectionId: widget.connectionId, base: newBase);
    ref.invalidate(discoveredDevicesProvider(args));
    setState(() => _base = newBase);
  }

  IconData _iconForType(PanelType type) => switch (type) {
        PanelType.toggle => Icons.toggle_on,
        PanelType.slider => Icons.tune,
        PanelType.led => Icons.circle,
        PanelType.progress => Icons.battery_5_bar,
        PanelType.cover => Icons.blinds,
        PanelType.combo => Icons.arrow_drop_down_circle_outlined,
        PanelType.textLog => Icons.notes,
        PanelType.button => Icons.send,
        PanelType.nodeStatus => Icons.cloud_done,
        PanelType.multiState => Icons.view_week,
        PanelType.radio => Icons.radio_button_checked,
        PanelType.textInput => Icons.keyboard,
        PanelType.schedule => Icons.schedule,
        PanelType.scene => Icons.auto_awesome,
        PanelType.autoClose => Icons.timer_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final args = (connectionId: widget.connectionId, base: _base);
    final devicesAsync = ref.watch(discoveredDevicesProvider(args));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.discoverTitle)),
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
                    onSubmitted: (_) => _scan(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _scan,
                  child: const Icon(Icons.radar),
                ),
              ],
            ),
          ),
          Expanded(
            child: devicesAsync.when(
              loading: () => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.discoverScanning),
                  ],
                ),
              ),
              error: (_, __) => Center(
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
                        onPressed: _scan,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
              data: (devices) {
                if (devices.isEmpty) {
                  return Center(child: Text(l10n.discoverNone));
                }
                return ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, i) {
                    final device = devices[i];
                    final suggestion = suggestPanel(device, base: _base);
                    final vendorModel = [device.vendor, device.model]
                        .whereType<String>()
                        .join(' ');
                    return ListTile(
                      leading: Icon(_iconForType(suggestion.type)),
                      title: Text(device.friendlyName),
                      subtitle: vendorModel.isNotEmpty ? Text(vendorModel) : null,
                      onTap: () {
                        context.push(
                          '/connections/${widget.connectionId}/dashboards/${widget.dashboardId}/panels/new',
                          extra: suggestion,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
