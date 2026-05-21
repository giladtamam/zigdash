import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../data/database/database.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../models/panel_config.dart';

class TextInputPanel extends ConsumerStatefulWidget {
  const TextInputPanel({
    super.key,
    required this.connectionId,
    required this.publishTopic,
    required this.panel,
    required this.config,
  });

  final String connectionId;
  final String publishTopic;
  final Panel panel;
  final TextInputConfig config;

  @override
  ConsumerState<TextInputPanel> createState() => _TextInputPanelState();
}

class _TextInputPanelState extends ConsumerState<TextInputPanel> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final mgr = await ref.read(mqttManagerProvider(widget.connectionId).future);
    mgr.publish(
      widget.publishTopic,
      widget.config.template,
      _controller.text,
      qos: mc.MqttQos.values[widget.panel.qos.clamp(0, 2)],
      retain: widget.panel.retain,
    );
    if (widget.config.clearOnSend) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.panel.name,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(),
                      hintText: widget.config.hint.isEmpty
                          ? 'Type a value…'
                          : widget.config.hint,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.send),
                  onPressed: _send,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
