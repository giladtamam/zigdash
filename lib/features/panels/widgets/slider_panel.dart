import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../data/database/database.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import 'control_action.dart';

class SliderPanel extends ConsumerStatefulWidget {
  const SliderPanel({
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
  final SliderConfig config;

  @override
  ConsumerState<SliderPanel> createState() => _SliderPanelState();
}

class _SliderPanelState extends ConsumerState<SliderPanel> {
  double? _draggingValue;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(double v) {
    setState(() => _draggingValue = v);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () => _publish(v));
  }

  void _onChangeEnd(double v) {
    _debounce?.cancel();
    _publish(v);
    setState(() => _draggingValue = null);
  }

  Future<void> _publish(double v) async {
    await runControlAction(context, ref, widget.connectionId, (mgr) => mgr.publish(
      widget.publishTopic,
      widget.config.valueTemplate,
      v.round(),
      qos: mc.MqttQos.values[widget.panel.qos.clamp(0, 2)],
      retain: widget.panel.retain,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final valueAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: widget.connectionId,
      topic: widget.subscribeTopic,
      jsonPath: widget.config.jsonPath,
    )));

    final receivedValue = valueAsync.maybeWhen(
      data: (v) {
        if (v == null) return null;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString());
      },
      orElse: () => null,
    );

    final liveValue = _draggingValue ??
        receivedValue ??
        widget.config.min;
    final clamped = liveValue.clamp(widget.config.min, widget.config.max).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                  clamped.round().toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            Slider(
              value: clamped,
              min: widget.config.min,
              max: widget.config.max,
              divisions: widget.config.step > 0
                  ? ((widget.config.max - widget.config.min) / widget.config.step).round()
                  : null,
              onChanged: _onChanged,
              onChangeEnd: _onChangeEnd,
            ),
          ],
        ),
      ),
    );
  }
}
