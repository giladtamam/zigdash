import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/analytics/analytics.dart';
import '../core/l10n/l10n_ext.dart';
import '../core/router/routes.dart';
import '../engine/engine_providers.dart';
import '../mqtt/endpoint.dart';
import '../mqtt/providers/mqtt_manager_provider.dart';
import '../features/pro/pro.dart';
import '../features/pro/pro_screen.dart';
import 'remote_phones.dart';
import 'remote_setup.dart';

/// Remote control through the ZigDash relay (3.1, zigdash-3.0.md §5).
class RemoteScreen extends ConsumerStatefulWidget {
  const RemoteScreen({super.key, required this.connectionId});
  final String connectionId;

  @override
  ConsumerState<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends ConsumerState<RemoteScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _turnOn() async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(remoteSetupProvider).setUp(widget.connectionId);
    if (!mounted) return;
    if (r == RemoteSetupResult.ready) {
      ref.read(analyticsProvider).track(const RemoteEvent(RemoteStep.turnedOn));
      ref.invalidate(remoteHomeProvider(widget.connectionId));
      ref.invalidate(mqttManagerProvider(widget.connectionId)); // the relay joins the endpoints
    }
    setState(() {
      _busy = false;
      _error = switch (r) {
        RemoteSetupResult.ready => null,
        RemoteSetupResult.noPro => l10n.remoteNeedsPro,
        RemoteSetupResult.notAtHome => l10n.remoteNotAtHome,
        RemoteSetupResult.unreachable => l10n.remoteUnreachable,
        RemoteSetupResult.refused => l10n.remoteRefused,
      };
    });
  }

  Future<void> _reconnectHub() async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(remoteSetupProvider).reconnectHub(widget.connectionId);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = switch (r) {
        RemoteSetupResult.ready => null,
        RemoteSetupResult.notAtHome => l10n.remoteNotAtHome,
        RemoteSetupResult.unreachable => l10n.remoteUnreachable,
        _ => l10n.remoteRefused,
      };
    });
  }

  Future<void> _turnOff() async {
    final l10n = context.l10n;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.remoteTurnOff),
        content: Text(l10n.remoteTurnOffConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.remoteTurnOff)),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    setState(() => _busy = true);
    await ref.read(remoteSetupProvider).turnOff(widget.connectionId);
    ref.read(analyticsProvider).track(const RemoteEvent(RemoteStep.turnedOff));
    if (!mounted) return;
    ref.invalidate(remoteHomeProvider(widget.connectionId));
    ref.invalidate(mqttManagerProvider(widget.connectionId));
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final home = ref.watch(remoteHomeProvider(widget.connectionId));
    final engine = ref.watch(engineViewProvider(widget.connectionId)).valueOrNull;
    final mgr = ref.watch(mqttManagerProvider(widget.connectionId)).valueOrNull;
    final viaRelay = mgr?.activeEndpoint == MqttEndpoint.relay;
    final on = home.valueOrNull != null;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.remoteTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(on ? l10n.remoteOnTitle : l10n.remoteIntroTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(on ? l10n.remoteOnBody : l10n.remoteIntroBody, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          if (on) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(engine?.report?.remoteConnected == true ? Icons.cloud_done_outlined : Icons.cloud_off_outlined),
              title: Text(engine?.report?.remoteConnected == true ? l10n.remoteHubOnline : l10n.remoteHubOffline),
            ),
            if (engine?.report != null && engine!.report!.remoteConnected != true && !viaRelay)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  key: const Key('remote-reconnect-hub'),
                  onPressed: _busy ? null : _reconnectHub,
                  icon: const Icon(Icons.sync),
                  label: Text(l10n.remoteReconnectHub),
                ),
              ),
            if (viaRelay)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.public),
                title: Text(l10n.remoteViaRelayNow),
              ),
            RemotePhonesSection(connectionId: widget.connectionId),
            const SizedBox(height: 8),
            // Quoted when asking for the relay's data about this Home (privacy policy).
            SelectableText(l10n.remoteHomeId(home.value!.homeId), style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            OutlinedButton(
              key: const Key('remote-off'),
              onPressed: _busy ? null : _turnOff,
              child: Text(l10n.remoteTurnOff),
            ),
          ] else if (engine != null && !engine.installed) ...[
            Text(l10n.remoteNeedsEngine),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => context.go(Routes.homeAutomations(widget.connectionId)),
              child: Text(l10n.automationsTitle),
            ),
          ] else if (!proSold && !relayIsTest)
            Text(l10n.remotePlayOnly)
          else if (proSold && !relayIsTest && ref.watch(proStatusProvider) != ProStatus.unlocked) ...[
            Text(l10n.remoteNeedsPro),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => openPro(context), child: Text(l10n.autoCeilingSeePro)),
          ] else ...[
            FilledButton(
              key: const Key('remote-on'),
              onPressed: _busy ? null : _turnOn,
              child: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.remoteSetUp),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              key: const Key('remote-restore'),
              onPressed: _busy ? null : () => restoreRemoteBackup(context, ref, widget.connectionId),
              icon: const Icon(Icons.key_outlined),
              label: Text(l10n.remoteBackupRestore),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
        ],
      ),
    );
  }
}
