import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../data/database/tables/connections.dart';
import '../../data/repositories/connection_repo.dart';
import '../../mqtt/broker_config.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import '../../mqtt/mqtt_status.dart';
import '../connections/diagnostics/connect_diagnostics.dart';
import '../connections/diagnostics/connect_diagnostics_provider.dart';
import '../connections/screens/broker_scan_sheet.dart';
import '../connections/widgets/broker_fields.dart';
import '../connections/widgets/diagnostics_ladder_view.dart';
import '../connections/widgets/protocol_dropdown.dart';
import '../devices/devices_providers.dart';
import '../onboarding/first_run.dart';

enum _Phase { form, running, failed, success }

/// The guided-connect wizard (v1.9): Z2M preset → diagnostic ladder →
/// "Found N devices" success moment. Auto-saves the connection on success.
class GuidedConnectScreen extends ConsumerStatefulWidget {
  const GuidedConnectScreen({super.key});

  @override
  ConsumerState<GuidedConnectScreen> createState() => _GuidedConnectScreenState();
}

class _GuidedConnectScreenState extends ConsumerState<GuidedConnectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _host = TextEditingController(text: 'localhost');
  final _port = TextEditingController(text: '1883');
  final _base = TextEditingController(text: 'zigbee2mqtt');
  final _username = TextEditingController();
  final _password = TextEditingController();

  MqttProtocol _protocol = MqttProtocol.tcp;
  _Phase _phase = _Phase.form;
  DiagnosticsReport? _report;
  String? _savedConnectionId;
  String _baseTopic = 'zigbee2mqtt';
  bool _pairingRequested = false;
  bool _saveFailed = false;

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    _base.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onProtocolChanged(MqttProtocol p) {
    applyProtocolPortDefault(_port, _protocol, p);
    setState(() => _protocol = p);
  }

  Future<void> _findBrokers() async {
    final result = await BrokerScanSheet.show(context);
    if (result == null || !mounted) return;
    setState(() => applyScanResult(
          host: _host,
          port: _port,
          onProtocol: (p) => _protocol = p,
          result: result,
        ));
  }

  Future<void> _start() async {
    // The form is only mounted in the form phase (retry runs from the failed
    // phase, where there is no form to validate).
    if (_phase == _Phase.form && !_formKey.currentState!.validate()) return;
    final host = _host.text.trim();
    final port = int.parse(_port.text);
    final base = _base.text.trim();

    final cfg = BrokerConfig(
      id: 'guided-${DateTime.now().microsecondsSinceEpoch}',
      host: host,
      port: port,
      protocol: _protocol,
      username: _username.text.trim().isEmpty ? null : _username.text.trim(),
      keepAliveSeconds: 60,
    );
    final diagnostics = ref.read(connectDiagnosticsProvider);

    setState(() {
      _phase = _Phase.running;
      _report = null;
      _pairingRequested = false;
      _saveFailed = false;
    });
    final DiagnosticsReport report;
    try {
      report =
          await diagnostics.run(config: cfg, password: _password.text, base: base);
    } catch (_) {
      // The ladder reports per-step failures; an unexpected throw returns to
      // the form rather than wedging the running phase.
      if (mounted) setState(() => _phase = _Phase.form);
      return;
    }
    if (!mounted) return;

    if (report.connected) {
      // Auto-save per the spec: on success the connection saves with
      // autoConnect on, then the success moment is shown.
      final id = await _save(cfg);
      if (!mounted) return;
      if (id == null) {
        _showSaveFailed();
        setState(() {
          _report = report;
          _saveFailed = true;
          _phase = _Phase.failed;
        });
        return;
      }
      setState(() {
        _report = report;
        _savedConnectionId = id;
        _baseTopic = base;
        _phase = _Phase.success;
      });
    } else {
      setState(() {
        _report = report;
        _phase = _Phase.failed;
      });
    }
  }

  Future<String?> _save(BrokerConfig cfg) async {
    try {
      final repo = ref.read(connectionRepoProvider);
      return await repo.create(
        name: cfg.host,
        host: cfg.host,
        port: cfg.port,
        protocol: cfg.protocol,
        username: cfg.username,
        password: _password.text.isEmpty ? null : _password.text,
        autoConnect: true,
      );
    } catch (_) {
      return null;
    }
  }

  void _showSaveFailed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.guidedSaveFailed)),
    );
  }

  Future<void> _startPairing() async {
    final id = _savedConnectionId;
    if (id == null || _pairingRequested) return;
    setState(() => _pairingRequested = true);
    await setPermitJoin(ref, id, _baseTopic, enable: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.pairingEnabled)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.guidedConnectTitle)),
      body: switch (_phase) {
        _Phase.form => _buildForm(context),
        _Phase.running => _buildRunning(context),
        _Phase.failed => _buildFailed(context),
        _Phase.success => _buildSuccess(context),
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.guidedConnectIntro,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ProtocolDropdown(value: _protocol, onChanged: _onProtocolChanged),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _host,
                  decoration: InputDecoration(
                    labelText: l10n.connLocalHost,
                    hintText: l10n.connHostHint,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.fieldRequired
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _port,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.connPort),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1 || n > 65535) {
                      return l10n.connPortRange;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _base,
            decoration: InputDecoration(
              labelText: l10n.guidedBaseTopic,
              hintText: l10n.guidedBaseTopicHint,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? l10n.fieldRequired : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _username,
            decoration: InputDecoration(labelText: l10n.connUsernameOptional),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.connPasswordOptional),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.wifi_find, size: 18),
            label: Text(l10n.connFindBrokers),
            onPressed: _findBrokers,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _start,
            icon: const Icon(Icons.wifi_tethering),
            label: Text(l10n.guidedConnect),
          ),
        ],
      ),
    );
  }

  Widget _buildRunning(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          context.l10n.guidedTesting,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        DiagnosticsLadderView(steps: const [], running: true),
        const SizedBox(height: 24),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildFailed(BuildContext context) {
    final report = _report!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_saveFailed)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(context.l10n.guidedSaveFailed),
            ),
          ),
        if (!_saveFailed) ...[
          DiagnosticsLadderView(
            steps: report.steps,
            showTriedHint: true,
            candidatesTried: report.candidatesTried,
          ),
          const SizedBox(height: 24),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _phase = _Phase.form),
                icon: const Icon(Icons.settings),
                label: Text(context.l10n.guidedBackToForm),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final report = _report!;
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final count = report.deviceNames.length;
    final zeroDevices = count == 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Icon(Icons.check_circle, size: 56, color: cs.tertiary),
        const SizedBox(height: 16),
        Text(
          zeroDevices ? l10n.noDevicesTitle : l10n.foundDevices(count),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          zeroDevices ? l10n.noDevicesHint : l10n.foundDevicesHint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (!zeroDevices && report.deviceNames.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in report.deviceNames.take(8))
                Chip(label: Text(name)),
            ],
          ),
        ],
        if (zeroDevices) ...[
          const SizedBox(height: 16),
          _PairingButton(
            savedConnectionId: _savedConnectionId,
            onPressed: _startPairing,
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () async {
            final id = _savedConnectionId;
            if (id == null) return;
            await ref.read(firstRunProvider).finish(id);
            if (context.mounted) context.go('/connections/$id/dashboards');
          },
          icon: const Icon(Icons.dashboard_outlined),
          label: Text(l10n.continueToDashboard),
        ),
      ],
    );
  }
}

/// "Start pairing" CTA on the zero-device success state. Enabled once the
/// auto-saved connection's manager reports connected (pairing publishes over
/// the live broker connection).
class _PairingButton extends ConsumerWidget {
  const _PairingButton({required this.savedConnectionId, required this.onPressed});

  final String? savedConnectionId;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = savedConnectionId;
    if (id == null) return const SizedBox.shrink();
    final status = ref.watch(connectionStatusProvider(id));
    final connected = status.valueOrNull == MqttStatus.connected;
    return FilledButton.tonalIcon(
      onPressed: connected ? onPressed : null,
      icon: const Icon(Icons.add_circle_outline),
      label: Text(context.l10n.startPairing),
    );
  }
}
