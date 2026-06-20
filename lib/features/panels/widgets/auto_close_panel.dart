import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../../data/repositories/panel_repo.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import '../services/auto_close_config_publisher.dart';

/// Dashboard tile for a server-side auto-close rule. Shows an enable switch
/// and a single status line driven by the Node-RED flow's published state
/// topic. The countdown text is recomputed locally every second from the
/// `pendingCloseAt` timestamp — no provider rebuild loop.
class AutoClosePanel extends ConsumerStatefulWidget {
  const AutoClosePanel({
    super.key,
    required this.connectionId,
    required this.triggerTopic,
    required this.target,
    required this.panel,
    required this.config,
  });

  final String connectionId;
  final String triggerTopic; // device's state topic (full, composed)
  final String target;       // device's command topic (full, composed)
  final Panel panel;
  final AutoCloseConfig config;

  @override
  ConsumerState<AutoClosePanel> createState() => _AutoClosePanelState();
}

class _AutoClosePanelState extends ConsumerState<AutoClosePanel> {
  bool _busy = false;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _toggleEnabled(bool v) async {
    if (_busy) return;
    setState(() => _busy = true);
    final panel = widget.panel;
    final next = widget.config.copyWith(enabled: v);
    try {
      await ref.read(panelRepoProvider).update(
            id: panel.id,
            name: panel.name,
            topic: panel.topic,
            subscribeTopic: panel.subscribeTopic,
            topicPrefixOverride: panel.topicPrefixOverride,
            qos: panel.qos,
            retain: panel.retain,
            width: panel.width,
            config: next,
          );
      final ok =
          await ref.read(autoCloseConfigPublisherProvider).publishConfig(
                connectionId: widget.connectionId,
                panelId: panel.id,
                name: panel.name,
                triggerTopic: widget.triggerTopic,
                target: widget.target,
                config: next,
              );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.panelAutoCloseSavedOffline),
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final panel = widget.panel;
    final config = widget.config;

    final stateAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: widget.connectionId,
      topic: AutoCloseConfigPublisher.stateTopic(panel.id),
      jsonPath: null,
    )));
    final bridgeAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: widget.connectionId,
      topic: AutoCloseConfigPublisher.bridgeStateTopic,
      jsonPath: null,
    )));

    final offline = bridgeAsync.maybeWhen(
      data: (v) => v?.toString() != 'online',
      orElse: () => true,
    );

    String? status;
    DateTime? pendingCloseAt;
    stateAsync.whenData((raw) {
      if (raw == null) return;
      try {
        final j = json.decode(raw.toString()) as Map<String, dynamic>;
        status = j['status'] as String?;
        final s = j['pendingCloseAt'] as String?;
        if (s != null) pendingCloseAt = DateTime.tryParse(s);
      } catch (_) {
        // Ignore malformed payloads; UI falls back to "Idle" below.
      }
    });

    String statusLine;
    if (offline) {
      statusLine = context.l10n.panelAutoCloseOffline;
    } else if (status == 'disabled' || !config.enabled) {
      statusLine = context.l10n.panelAutoCloseDisabled;
    } else if (status == 'pending' && pendingCloseAt != null) {
      final secs = pendingCloseAt!.difference(DateTime.now().toUtc()).inSeconds;
      statusLine = secs > 0
          ? context.l10n.panelAutoCloseClosingIn(secs)
          : context.l10n.panelAutoCloseClosingNow;
    } else {
      statusLine = context.l10n.panelAutoCloseIdle;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(Icons.timer_outlined, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(panel.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Switch(
                value: config.enabled,
                onChanged: _busy ? null : _toggleEnabled,
              ),
            ]),
            const SizedBox(height: 4),
            if (offline)
              Row(children: [
                Icon(Icons.cloud_off, size: 16, color: scheme.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(statusLine,
                      style: TextStyle(color: scheme.error, fontSize: 12)),
                ),
              ])
            else
              Text(statusLine,
                  style: TextStyle(color: scheme.outline, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
