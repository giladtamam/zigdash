import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../data/database/database.dart';
import '../../../mqtt/json_path.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';

class CoverPanel extends ConsumerStatefulWidget {
  const CoverPanel({
    super.key,
    required this.connectionId,
    required this.publishTopic,
    required this.subscribeTopic,
    required this.panel,
    required this.config,
  });

  final String connectionId;
  final String publishTopic;
  final String subscribeTopic;
  final Panel panel;
  final CoverConfig config;

  @override
  ConsumerState<CoverPanel> createState() => _CoverPanelState();
}

class _CoverPanelState extends ConsumerState<CoverPanel> {
  double? _draggingValue;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _publishRaw(String payload) async {
    final mgr = await ref.read(mqttManagerProvider(widget.connectionId).future);
    mgr.publish(
      widget.publishTopic,
      payload,
      '',
      qos: mc.MqttQos.values[widget.panel.qos.clamp(0, 2)],
      retain: widget.panel.retain,
    );
  }

  Future<void> _publishPosition(double v) async {
    final mgr = await ref.read(mqttManagerProvider(widget.connectionId).future);
    mgr.publish(
      widget.publishTopic,
      widget.config.positionTemplate,
      v.round(),
      qos: mc.MqttQos.values[widget.panel.qos.clamp(0, 2)],
      retain: widget.panel.retain,
    );
  }

  void _onSliderChanged(double v) {
    setState(() => _draggingValue = v);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () => _publishPosition(v));
  }

  void _onSliderEnd(double v) {
    _debounce?.cancel();
    _publishPosition(v);
    setState(() => _draggingValue = null);
  }

  @override
  Widget build(BuildContext context) {
    // One subscription, whole payload (jsonPath null → raw string).
    final valueAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: widget.connectionId,
      topic: widget.subscribeTopic,
      jsonPath: null,
    )));

    final cfg = widget.config;
    String? state;
    double? position;
    valueAsync.whenData((raw) {
      if (raw == null) return;
      state = extractByPath(raw.toString(), cfg.statePath)?.toString();
      final p = extractByPath(raw.toString(), cfg.positionPath);
      if (p is num) {
        position = p.toDouble();
      } else if (p != null) {
        position = double.tryParse(p.toString());
      }
    });

    final liveValue = (_draggingValue ?? position ?? 0).clamp(0, 100).toDouble();
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.panel.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                Text(
                  position == null ? '—' : '${position!.round()} %',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                emptySelectionAllowed: true,
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'OPEN', label: Text('Open'), icon: Icon(Icons.keyboard_arrow_up)),
                  ButtonSegment(value: 'STOP', label: Text('Stop'), icon: Icon(Icons.stop)),
                  ButtonSegment(value: 'CLOSE', label: Text('Close'), icon: Icon(Icons.keyboard_arrow_down)),
                ],
                selected: {if (state != null) state!},
                onSelectionChanged: (sel) {
                  if (sel.isEmpty) return;
                  switch (sel.first) {
                    case 'OPEN':
                      _publishRaw(cfg.openPayload);
                    case 'STOP':
                      _publishRaw(cfg.stopPayload);
                    case 'CLOSE':
                      _publishRaw(cfg.closePayload);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            if (cfg.presets.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: cfg.presets
                    .map((p) => ActionChip(
                          label: Text('$p%'),
                          onPressed: () => _publishPosition(p.toDouble()),
                        ))
                    .toList(),
              ),
            if (cfg.showSlider) ...[
              Slider(
                value: liveValue,
                min: 0,
                max: 100,
                divisions: 100,
                label: '${liveValue.round()}',
                onChanged: _onSliderChanged,
                onChangeEnd: _onSliderEnd,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0', style: TextStyle(color: scheme.outline)),
                  Text('100', style: TextStyle(color: scheme.outline)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
