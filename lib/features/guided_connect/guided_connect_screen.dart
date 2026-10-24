import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../onboarding/setup/ai_help.dart' show aiHelpUsedProvider;
import '../support/support_details.dart';
import '../support/get_help_screen.dart' show GetHelpLink;
import '../support/community.dart';
import '../support/support_log.dart';
import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/router/routes.dart';
import '../../data/database/tables/connections.dart';
import '../../data/repositories/connection_repo.dart';
import '../../mqtt/broker_config.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import '../../mqtt/mqtt_status.dart';
import '../connections/diagnostics/connect_diagnostics.dart';
import '../connections/diagnostics/connect_diagnostics_provider.dart';
import '../connections/discovery/broker_scan_providers.dart';
import '../connections/discovery/subnet.dart';
import '../connections/screens/broker_scan_sheet.dart';
import '../connections/widgets/broker_fields.dart';
import '../connections/widgets/diagnostics_ladder_view.dart';
import '../connections/widgets/protocol_dropdown.dart';
import '../../data/database/daos/device_registry_dao.dart';
import '../../data/database/database.dart';
import '../../data/repositories/dashboard_repo.dart';
import '../../data/repositories/panel_repo.dart';
import '../../data/repositories/section_repo.dart';
import '../devices/devices_providers.dart';
import '../discovery/models/z2m_device.dart';
import '../discovery/providers/discovery_provider.dart';
import '../onboarding/first_run.dart';
import '../onboarding/setup/recommendation_policy.dart';
import '../onboarding/setup/setup_creator.dart';

enum _Phase { form, running, failed, success }

/// The guided-connect wizard (v1.9): Z2M preset → diagnostic ladder →
/// "Found N devices" success moment. Auto-saves the connection on success.
/// [initialHost] and [initialPort] fill the form in (2.5: a hub the scan
/// found but whose broker didn't answer).
class GuidedConnectScreen extends ConsumerStatefulWidget {
  const GuidedConnectScreen({super.key, this.initialHost, this.initialPort});

  final String? initialHost;
  final int? initialPort;

  @override
  ConsumerState<GuidedConnectScreen> createState() =>
      _GuidedConnectScreenState();
}

class _GuidedConnectScreenState extends ConsumerState<GuidedConnectScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _host = TextEditingController(text: widget.initialHost ?? '');
  late final _port = TextEditingController(
    text: '${widget.initialPort ?? 1883}',
  );
  final _base = TextEditingController(text: 'zigbee2mqtt');
  final _username = TextEditingController();
  final _password = TextEditingController();

  MqttProtocol _protocol = MqttProtocol.tcp;
  _Phase _phase = _Phase.form;
  DiagnosticsReport? _report;

  /// Failed checks on this screen: after two, a card offers a person
  /// (2.9.2; the small link at the bottom was opened by 6 of 53 stuck users).
  int _failures = 0;
  bool _offerTracked = false;
  String? _savedConnectionId;
  String _baseTopic = 'zigbee2mqtt';
  bool _pairingRequested = false;
  bool _saveFailed = false;
  bool _building = false;

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
    setState(
      () => applyScanResult(
        host: _host,
        port: _port,
        onProtocol: (p) => _protocol = p,
        result: result,
      ),
    );
  }

  Future<void> _start() async {
    // The form is only mounted in the form phase (retry runs from the failed
    // phase, where there is no form to validate).
    var tidied = false;
    if (_phase == _Phase.form) {
      setState(
        () => tidied = tidyBrokerAddress(
          host: _host,
          port: _port,
          protocol: _protocol,
          onProtocol: (p) => _protocol = p,
        ),
      );
      if (!_formKey.currentState!.validate()) return;
    }
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
      report = await diagnostics.run(
        config: cfg,
        password: _password.text,
        base: base,
      );
    } catch (_) {
      // The ladder reports per-step failures; an unexpected throw returns to
      // the form rather than wedging the running phase.
      if (mounted) setState(() => _phase = _Phase.form);
      return;
    }
    if (!mounted) return;
    if (!report.connected) {
      ref.read(supportLogProvider).recordFailure(failureKindFromLadder(report));
    }
    // 2.7.2: where the broker form loses people. A user spent three minutes
    // here and all we knew was that the form had opened.
    ref
        .read(analyticsProvider)
        .track(
          SetupStep(
            SetupStepKind.manualTest,
            result: manualTestResult(report),
            devices: report.connected ? report.deviceNames.length : null,
            tidied: tidied,
            portClass: portClassOf(port),
          ),
        );

    if (report.connected) {
      // Auto-save per the spec: on success the connection saves with
      // autoConnect on, then the success moment is shown.
      final id = await _save(cfg, base);
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
        _failures++;
        _phase = _Phase.failed;
      });
    }
  }

  Future<String?> _save(BrokerConfig cfg, String base) async {
    try {
      final repo = ref.read(connectionRepoProvider);
      final id = await repo.create(
        name: cfg.host,
        host: cfg.host,
        port: cfg.port,
        protocol: cfg.protocol,
        username: cfg.username,
        password: _password.text.isEmpty ? null : _password.text,
        autoConnect: true,
      );
      // A custom base topic belongs to the home, so Devices and later
      // dashboards find the bridge too (as setup does).
      if (base != 'zigbee2mqtt') await repo.setBaseTopic(id, base);
      return id;
    } catch (_) {
      return null;
    }
  }

  /// Builds the home's first dashboard from its devices, as setup does, so
  /// "Continue to dashboard" does not land on an empty home. Best effort: if
  /// the devices can't be read or nothing is worth a tile, the home opens
  /// as it is.
  Future<void> _buildFirstDashboard(String connectionId) async {
    final base = _baseTopic;
    // The language this screen shows, for the dashboard and section names.
    final l10n = context.l10n;
    try {
      final hasDashboard =
          (await ref.read(dashboardRepoProvider).getByConnection(connectionId))
              .isNotEmpty;
      if (hasDashboard) return;
      // The provider is autoDispose: listen while reading, or it is disposed
      // (unsubscribing) before the retained list arrives.
      final args = (connectionId: connectionId, base: base);
      final keepAlive = ref.listenManual(
        discoveredDevicesProvider(args),
        (_, _) {},
      );
      final List<Z2mDevice> devices;
      try {
        devices = await ref.read(discoveredDevicesProvider(args).future);
      } finally {
        keepAlive.close();
      }
      final rows = recommendDevices(devices, base: base);
      final selected = rows.where((r) => r.selected).toList();
      if (selected.isEmpty) return;
      final creator = SetupCreator(
        connections: ref.read(connectionRepoProvider),
        dashboards: ref.read(dashboardRepoProvider),
        sections: ref.read(sectionRepoProvider),
        panels: ref.read(panelRepoProvider),
        registry: DeviceRegistryDao(ref.read(appDatabaseProvider)),
        l10n: l10n,
      );
      await creator.createDashboard(
        connectionId: connectionId,
        base: base,
        selected: selected,
        notSelected: rows.where((r) => !r.selected).toList(),
      );
    } catch (_) {
      // Opening the home without a dashboard is still a working result.
    }
  }

  void _showSaveFailed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.guidedSaveFailed)));
  }

  Future<void> _startPairing() async {
    final id = _savedConnectionId;
    if (id == null || _pairingRequested) return;
    setState(() => _pairingRequested = true);
    await setPermitJoin(ref, id, _baseTopic, enable: true);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.pairingEnabled)));
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
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () {
                ref
                    .read(analyticsProvider)
                    .track(
                      const SetupStep(
                        SetupStepKind.haOpened,
                        choice: HaSignInFrom.manualForm,
                      ),
                    );
                context.push(Routes.haConnect);
              },
              icon: const Icon(Icons.home_outlined),
              label: Text(l10n.haConnectManualLink),
            ),
          ),
          const SizedBox(height: 8),
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
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.fieldRequired : null,
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
          const _HostHints(),
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
          GetHelpLink(
            onPressed: () =>
                context.push(Routes.getHelpFrom(HelpFrom.manualForm.name)),
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
    final offer = !_saveFailed && _failures >= 2;
    if (offer && !_offerTracked) {
      _offerTracked = true;
      ref
          .read(analyticsProvider)
          .track(const HelpOffered(HelpFrom.manualConnect));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (offer) ...[
          _StuckCard(
            onTelegram: () => openCommunity(ref, HelpFrom.manualConnect),
            onHelp: () =>
                context.push(Routes.getHelpFrom(HelpFrom.manualConnect.name)),
          ),
          const SizedBox(height: 16),
        ],
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
        GetHelpLink(
          onPressed: () =>
              context.push(Routes.getHelpFrom(HelpFrom.manualConnect.name)),
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
          onPressed: _building
              ? null
              : () async {
                  final id = _savedConnectionId;
                  if (id == null) return;
                  setState(() => _building = true);
                  if (!zeroDevices) await _buildFirstDashboard(id);
                  if (!mounted) return;
                  setState(() => _building = false);
                  // 3.1.3: a home made here is a finished setup too.
                  ref
                      .read(analyticsProvider)
                      .track(
                        SetupStep(
                          SetupStepKind.complete,
                          devices: count,
                          via: SetupVia.brokerForm,
                          aiHelped: ref.read(aiHelpUsedProvider),
                        ),
                      );
                  ref.read(aiHelpUsedProvider.notifier).state = false;
                  try {
                    await ref.read(firstRunProvider).finish(id);
                  } catch (_) {
                    // The home is saved; bookkeeping failing must not strand the
                    // user on this screen.
                  }
                  if (context.mounted) context.go(Routes.homeDashboards(id));
                },
          icon: _building
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.dashboard_outlined),
          label: Text(l10n.continueToDashboard),
        ),
      ],
    );
  }
}

/// Where to find the address (2.5): the phone's own address says what the
/// hub's usually starts with, and Home Assistant users already know theirs.
class _HostHints extends ConsumerWidget {
  const _HostHints();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final style = Theme.of(context).textTheme.bodySmall;
    final ip = ref.watch(deviceIpProvider).valueOrNull;
    final prefix = ip == null ? null : subnetBaseFromIp(ip);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ip != null && prefix != null)
            Text(l10n.guidedHostYourPhone(ip, prefix), style: style),
          Text(l10n.guidedHostHa, style: style),
        ],
      ),
    );
  }
}

/// "Start pairing" CTA on the zero-device success state. Enabled once the
/// auto-saved connection's manager reports connected (pairing publishes over
/// the live broker connection).
class _PairingButton extends ConsumerWidget {
  const _PairingButton({
    required this.savedConnectionId,
    required this.onPressed,
  });

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

/// After two failed checks: a person can help, in one tap (2.9.2).
class _StuckCard extends StatelessWidget {
  const _StuckCard({required this.onTelegram, required this.onHelp});

  final VoidCallback onTelegram;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.guidedStuckTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.guidedStuckBody, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onTelegram,
                  icon: const Icon(Icons.forum_outlined),
                  label: Text(l10n.guidedStuckTelegram),
                ),
                OutlinedButton(
                  onPressed: onHelp,
                  child: Text(l10n.guidedStuckHelp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
