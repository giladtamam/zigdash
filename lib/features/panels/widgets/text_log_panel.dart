import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';

class TextLogPanel extends ConsumerStatefulWidget {
  const TextLogPanel({
    super.key,
    required this.connectionId,
    required this.subscribeTopic,
    required this.panel,
    required this.config,
  });

  final String connectionId;
  final String subscribeTopic;
  final Panel panel;
  final TextLogConfig config;

  @override
  ConsumerState<TextLogPanel> createState() => _TextLogPanelState();
}

class _LogEntry {
  _LogEntry(this.time, this.text);
  final DateTime time;
  final String text;
}

class _TextLogPanelState extends ConsumerState<TextLogPanel> {
  final List<_LogEntry> _log = [];

  String _ts(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final key = PanelStreamKey(
      connectionId: widget.connectionId,
      topic: widget.subscribeTopic,
      jsonPath: widget.config.jsonPath,
    );
    ref.listen(panelValueProvider(key), (prev, next) {
      next.whenData((v) {
        if (v == null) return;
        setState(() {
          _log.insert(0, _LogEntry(DateTime.now(), v.toString()));
          if (_log.length > widget.config.maxLines) {
            _log.removeRange(widget.config.maxLines, _log.length);
          }
        });
      });
    });

    final scheme = Theme.of(context).colorScheme;
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
            SizedBox(
              height: 160,
              child: _log.isEmpty
                  ? Center(
                      child: Text('Waiting for messages…',
                          style: Theme.of(context).textTheme.bodySmall),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: _log.length,
                      itemBuilder: (_, i) {
                        final e = _log[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                text: '${_ts(e.time)}  ',
                                style: TextStyle(
                                    color: scheme.outline,
                                    fontFeatures: const [],
                                    fontFamily: 'monospace'),
                              ),
                              TextSpan(
                                text: e.text,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ]),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
