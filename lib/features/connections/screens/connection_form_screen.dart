import 'dart:async';

import 'package:flutter/material.dart';
import '../../../engine/engine_providers.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../devices/device_tiles.dart' show z2mBase;
import '../../../core/router/routes.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/signal_colors.dart';
import '../../onboarding/first_run.dart';
import '../../../data/database/tables/connections.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../mqtt/broker_config.dart';
import '../diagnostics/connect_diagnostics.dart';
import '../diagnostics/connect_diagnostics_provider.dart';
import '../discovery/z2m_frontend.dart';
import '../widgets/broker_fields.dart';
import '../widgets/diagnostics_ladder_view.dart';
import '../widgets/protocol_dropdown.dart';
import 'broker_help_sheet.dart';
import 'broker_scan_sheet.dart';

/// How long Save waits for the broker check on a page Home (3.8.6): the
/// ladder's own steps can take ~40 s with a login.
const pageGuardTimeout = Duration(seconds: 15);

/// The Zigbee2MQTT base topic the form's checks count devices under
/// (3.8.6): the Home's own setting, else its first dashboard's prefix,
/// else what Zigbee2MQTT's page says, else the default.
String formBaseTopic({
  String? stored,
  String? firstDashboardPrefix,
  String? pageBase,
}) {
  final set = stored?.trim() ?? '';
  if (set.isNotEmpty) return set;
  final prefix = firstDashboardPrefix?.trim() ?? '';
  if (prefix.isNotEmpty) return z2mBase(prefix);
  final page = pageBase?.trim() ?? '';
  return page.isNotEmpty ? page : 'zigbee2mqtt';
}

class ConnectionFormScreen extends ConsumerStatefulWidget {
  const ConnectionFormScreen({super.key, this.connectionId});

  /// Null for "create", non-null for "edit".
  final String? connectionId;

  @override
  ConsumerState<ConnectionFormScreen> createState() =>
      _ConnectionFormScreenState();
}

class _ConnectionFormScreenState extends ConsumerState<ConnectionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _host = TextEditingController();
  final _port = TextEditingController(text: '1883');
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _keepAlive = TextEditingController(text: '60');
  final _remoteHost = TextEditingController();

  MqttProtocol _protocol = MqttProtocol.tcp;
  bool _autoConnect = false;
  bool _loaded = false;
  bool _saving = false;
  bool _testing = false;
  bool _passwordExists = false;

  /// How the home connects (2.10); a Home Assistant home shows its address
  /// read-only: the sign-in is replaced by deleting the home and
  /// connecting again, never by typing a broker.
  ConnectionTransport _transport = ConnectionTransport.mqtt;
  bool get _viaHa => _transport == ConnectionTransport.homeAssistant;

  /// 3.2: a Home set up through the Zigbee2MQTT page, getting its broker
  /// here; saving moves it onto the broker.
  bool get _fromPage => _transport == ConnectionTransport.z2mPage;

  /// 3.8.6: what the page Home used to reach the page, kept for reading
  /// Zigbee2MQTT's settings before the form's broker defaults replace them.
  int? _pagePort;
  String? _pageToken;
  String? _pageHost;

  /// Where devices are counted (3.8.6, [formBaseTopic]).
  String? _storedBase;
  String? _dashboardPrefix;
  String? _pageBase;
  String get _base => formBaseTopic(
    stored: _storedBase,
    firstDashboardPrefix: _dashboardPrefix,
    pageBase: _pageBase,
  );

  /// Reading Zigbee2MQTT's own broker settings (3.8.6), and the server it
  /// named. Fields changed since load are never pre-filled.
  bool _readingZ2m = false;
  String? _z2mServer;
  bool _hostTouched = false;
  bool _portTouched = false;
  bool _protocolTouched = false;
  bool _userTouched = false;

  /// The broker check before a page Home's Save (3.8.6). A result for an
  /// old generation (cancelled, timed out, form left) is ignored.
  bool _guarding = false;
  int _guardGen = 0;
  Timer? _guardTimer;

  bool get _isEdit => widget.connectionId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _load();
    } else {
      _loaded = true;
    }
  }

  Future<void> _load() async {
    final repo = ref.read(connectionRepoProvider);
    final c = await repo.getById(widget.connectionId!);
    if (c == null || !mounted) return;
    final pw = await repo.readPassword(c.id);
    String? prefix;
    try {
      prefix = (await ref.read(dashboardRepoProvider).getByConnection(c.id))
          .firstOrNull
          ?.topicPrefix;
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _storedBase = c.z2mBaseTopic;
      _dashboardPrefix = prefix;
      _name.text = c.name;
      _host.text = c.host;
      _port.text = c.port.toString();
      _protocol = c.protocol;
      _username.text = c.username ?? '';
      _passwordExists = pw != null && pw.isNotEmpty;
      _keepAlive.text = c.keepAliveSeconds.toString();
      _remoteHost.text = c.remoteHost ?? '';
      _autoConnect = c.autoConnect;
      _transport = transportOf(c.transport);
      if (_transport == ConnectionTransport.z2mPage) {
        // The page's port and token are not the broker's; kept to read
        // Zigbee2MQTT's settings (3.8.6).
        _pageHost = c.host;
        _pagePort = c.port;
        _pageToken = pw;
        _port.text = '1883';
        _protocol = MqttProtocol.tcp;
        _passwordExists = false;
      }
      _loaded = true;
    });
    if (_fromPage) unawaited(_prefillFromZ2m());
  }

  /// 3.8.6: pre-fills a page Home's broker from Zigbee2MQTT's own `mqtt`
  /// settings: this session's `bridge/info` when the Home's manager is
  /// already loaded (never awaited, so no connect is started or waited
  /// on), else asked from the page. Fields changed since load are kept.
  Future<void> _prefillFromZ2m() async {
    final host = _pageHost;
    final id = widget.connectionId;
    if (host == null || id == null) return;
    setState(() => _readingZ2m = true);
    Map<String, dynamic>? mqtt;
    try {
      final provider = mqttManagerProvider(id);
      final mgr = ref.exists(provider) ? ref.read(provider).valueOrNull : null;
      if (mgr != null) {
        final info = mgr
            .liveUnder('')
            .where((m) => m.topic.endsWith('/bridge/info'))
            .firstOrNull;
        if (info != null) mqtt = z2mMqttConfigOfInfo(info.payload);
      } else {
        mqtt = await ref
            .read(z2mPageConfigProvider)(
              host,
              _pagePort ?? 8080,
              token: _pageToken,
            )
            .timeout(const Duration(seconds: 6));
      }
    } catch (_) {
      // Locked page, no answer: today's pre-fill stays.
    }
    if (!mounted) return;
    final setting = z2mBrokerSetting(mqtt, frontendHost: host);
    final base = mqtt?['base_topic'];
    setState(() {
      _readingZ2m = false;
      if (base is String) _pageBase = base;
      if (setting == null) return;
      _z2mServer = setting.server;
      if (!_hostTouched && setting.hosts.isNotEmpty) {
        _host.text = setting.hosts.first;
      }
      if (!_portTouched) _port.text = '${setting.port}';
      if (!_protocolTouched) {
        _protocol = setting.tls ? MqttProtocol.tcpSsl : MqttProtocol.tcp;
      }
      final user = setting.user;
      if (!_userTouched && user != null) _username.text = user;
    });
  }

  void _onProtocolChanged(MqttProtocol p) {
    applyProtocolPortDefault(_port, _protocol, p);
    setState(() {
      _protocol = p;
      _protocolTouched = true;
      _portTouched = true;
    });
  }

  /// Opens the network scan; on a tapped result, fills host/port/protocol.
  Future<void> _findBrokers() async {
    final result = await BrokerScanSheet.show(context);
    if (result == null || !mounted) return;
    setState(() {
      applyScanResult(
        host: _host,
        port: _port,
        onProtocol: (p) => _protocol = p,
        result: result,
      );
      _hostTouched = _portTouched = _protocolTouched = true;
    });
  }

  void _tidyAddress() => setState(
    () => tidyBrokerAddress(
      host: _host,
      port: _port,
      protocol: _protocol,
      onProtocol: (p) => _protocol = p,
    ),
  );

  Future<void> _save() async {
    if (!_viaHa) _tidyAddress();
    if (!_formKey.currentState!.validate()) return;
    if (_fromPage && _isEdit) return _guardedSave();
    await _write();
  }

  /// 3.8.6: a page Home moves onto the broker only when the broker has
  /// its devices. The check runs on the local address only (no remote,
  /// no relay), for at most [pageGuardTimeout]; it is not counted as a
  /// `manual_test`.
  Future<void> _guardedSave() async {
    final gen = ++_guardGen;
    setState(() => _guarding = true);
    final cfg = _formConfig(remote: false);
    final diagnostics = ref.read(connectDiagnosticsProvider);
    final outcome = Completer<DiagnosticsReport?>();
    _guardTimer?.cancel();
    _guardTimer = Timer(pageGuardTimeout, () {
      if (!outcome.isCompleted) outcome.complete(null);
    });
    unawaited(
      diagnostics
          .run(config: cfg, password: _password.text, base: _base)
          .then<DiagnosticsReport?>((r) => r, onError: (_) => _noAnswer)
          .then((r) {
            if (!outcome.isCompleted) outcome.complete(r);
          }),
    );
    final report = await outcome.future;
    _guardTimer?.cancel();
    if (!mounted || gen != _guardGen) return;
    setState(() => _guarding = false);
    final answered = report == null
        ? PageBrokerAnswered.timeout
        : report.connected
        ? PageBrokerAnswered.yes
        : PageBrokerAnswered.no;
    final devices = report != null && report.connected
        ? report.deviceNames.length
        : null;
    void track(PageBrokerResult result) => ref
        .read(analyticsProvider)
        .track(PageBrokerEvent(result, answered: answered, devices: devices));
    if (devices != null && devices > 0) {
      track(PageBrokerResult.saved);
      return _write();
    }
    final saveAnyway = await _askKeepPage(report);
    if (!mounted || gen != _guardGen) return;
    if (saveAnyway) {
      track(PageBrokerResult.savedAnyway);
      return _write();
    }
    track(PageBrokerResult.keptPage);
  }

  static const _noAnswer = DiagnosticsReport(
    steps: [],
    connected: false,
    candidatesTried: 1,
  );

  void _cancelGuard() {
    _guardGen++;
    _guardTimer?.cancel();
    setState(() => _guarding = false);
    ref
        .read(analyticsProvider)
        .track(const PageBrokerEvent(PageBrokerResult.cancelled));
  }

  /// "Keep using the Zigbee2MQTT page?": true for Save anyway. [report] is
  /// null when the check gave up.
  Future<bool> _askKeepPage(DiagnosticsReport? report) async {
    final l10n = context.l10n;
    final empty = report != null && report.connected;
    final failure = report?.steps
        .where((s) => s.status == StepStatus.fail)
        .firstOrNull;
    final detail = empty ? null : diagnosticDetail(context, failure?.detailKey);
    final server = _z2mServer;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('conn-keep-page'),
        title: Text(l10n.connKeepPageTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                empty
                    ? l10n.connKeepPageBodyEmpty
                    : l10n.connKeepPageBodyNoAnswer,
              ),
              if (empty && server != null) ...[
                const SizedBox(height: 8),
                Text(l10n.connZ2mUses(server)),
              ],
              if (detail != null) ...[const SizedBox(height: 8), Text(detail)],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.connSaveAnyway),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.connKeepPage),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// The broker as typed. Without [remote], the local address only.
  BrokerConfig _formConfig({bool remote = true}) => BrokerConfig(
    id: 'test-${DateTime.now().microsecondsSinceEpoch}',
    host: _host.text.trim(),
    port: int.parse(_port.text),
    protocol: _protocol,
    username: _username.text.trim().isEmpty ? null : _username.text.trim(),
    keepAliveSeconds: int.parse(_keepAlive.text),
    remoteHost: !remote || _remoteHost.text.trim().isEmpty
        ? null
        : _remoteHost.text.trim(),
  );

  Future<void> _write() async {
    setState(() => _saving = true);
    final repo = ref.read(connectionRepoProvider);
    final port = int.parse(_port.text);
    final keepAlive = int.parse(_keepAlive.text);
    // From the page, the stored secret is the page's token: always replace.
    final passwordToWrite = _password.text.isEmpty && _isEdit && !_fromPage
        ? null
        : _password.text;

    try {
      if (_isEdit) {
        await repo.update(
          id: widget.connectionId!,
          name: _name.text.trim(),
          host: _host.text.trim(),
          port: port,
          protocol: _protocol,
          username: _username.text.trim().isEmpty
              ? null
              : _username.text.trim(),
          password: passwordToWrite,
          keepAliveSeconds: keepAlive,
          autoConnect: _autoConnect,
          remoteHost: _remoteHost.text.trim().isEmpty
              ? null
              : _remoteHost.text.trim(),
          transport: _fromPage ? ConnectionTransport.mqtt : null,
        );
        if (_fromPage) {
          // The Home now goes through the broker: reconnect it, and let the
          // Engine screens look again.
          ref.invalidate(mqttManagerProvider(widget.connectionId!));
          ref.invalidate(engineViewProvider(widget.connectionId!));
        }
      } else {
        final id = await repo.create(
          name: _name.text.trim(),
          host: _host.text.trim(),
          port: port,
          protocol: _protocol,
          username: _username.text.trim().isEmpty
              ? null
              : _username.text.trim(),
          password: _password.text.isEmpty ? null : _password.text,
          keepAliveSeconds: keepAlive,
          autoConnect: _autoConnect,
          remoteHost: _remoteHost.text.trim().isEmpty
              ? null
              : _remoteHost.text.trim(),
        );
        // A new real home counts as completing setup: it ends first run and
        // removes the demo home. Bookkeeping failures must not block saving.
        try {
          await ref.read(firstRunProvider).finish(id);
        } catch (_) {}
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _testConnection() async {
    _tidyAddress();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _testing = true);

    final cfg = _formConfig();
    final diagnostics = ref.read(connectDiagnosticsProvider);

    try {
      final report = await diagnostics.run(
        config: cfg,
        password: _password.text,
        base: _base,
      );
      if (!mounted) return;
      // 3.8.5: counted here too, so an encrypted broker the phone doesn't
      // trust is seen wherever it is tested.
      ref
          .read(analyticsProvider)
          .track(
            SetupStep(
              SetupStepKind.manualTest,
              result: manualTestResult(report),
              devices: report.connected ? report.deviceNames.length : null,
              portClass: portClassOf(cfg.port),
              manualFrom: ManualFrom.form,
            ),
          );
      setState(() => _testing = false);
      _showLadderSheet(report);
    } catch (e) {
      // The ladder reports per-step failures itself; an unexpected throw just
      // falls back to the old generic failure message.
      if (!mounted) return;
      setState(() => _testing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.connTestFailed(e.toString()))),
      );
    }
  }

  /// Shows the diagnostic ladder for the just-run test. Retry re-runs the
  /// ladder with the current form values.
  void _showLadderSheet(DiagnosticsReport report) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DiagnosticsLadderView(
                steps: report.steps,
                showTriedHint: true,
                candidatesTried: report.candidatesTried,
              ),
              const SizedBox(height: 16),
              // 3.8.6: on a page Home, an empty broker is not a success:
              // saving would leave the dashboards empty.
              if (report.connected &&
                  _fromPage &&
                  report.deviceNames.isEmpty) ...[
                _NoDevicesWarning(server: _z2mServer),
                const SizedBox(height: 16),
              ],
              if (report.connected &&
                  !(_fromPage && report.deviceNames.isEmpty))
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.check),
                    label: Text(context.l10n.connTestOk),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(
                          report.connected
                              ? MaterialLocalizations.of(
                                  context,
                                ).closeButtonLabel
                              : context.l10n.cancel,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _testConnection();
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(context.l10n.retry),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _guardGen++;
    _guardTimer?.cancel();
    _name.dispose();
    _host.dispose();
    _remoteHost.dispose();
    _port.dispose();
    _username.dispose();
    _password.dispose();
    _keepAlive.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? context.l10n.connEdit : context.l10n.connNew),
        actions: [
          if (_guarding) ...[
            const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            TextButton(
              key: const Key('conn-guard-cancel'),
              onPressed: _cancelGuard,
              child: Text(context.l10n.cancel),
            ),
          ] else
            TextButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? context.l10n.saving : context.l10n.save),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_fromPage) ...[
              Card.outlined(
                key: const Key('conn-from-page'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.connFromPageNote),
                      if (_readingZ2m) ...[
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.connReadingZ2m,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ] else if (_z2mServer != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.connZ2mUses(_z2mServer!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_guarding) ...[
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(context.l10n.connChecking),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ],
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: context.l10n.connName,
                hintText: context.l10n.connNameHint,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? context.l10n.fieldRequired
                  : null,
            ),
            const SizedBox(height: 12),
            if (_viaHa) ...[
              _HaHomeCard(
                address: _host.text,
                onSignInAgain: () async {
                  await context.push(
                    Routes.haConnectAgain(widget.connectionId!, _host.text),
                  );
                  if (mounted) _load();
                },
              ),
              const SizedBox(height: 12),
            ] else ...[
              ProtocolDropdown(value: _protocol, onChanged: _onProtocolChanged),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _host,
                      onChanged: (_) => _hostTouched = true,
                      decoration: InputDecoration(
                        labelText: context.l10n.connLocalHost,
                        hintText: context.l10n.connHostHint,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? context.l10n.fieldRequired
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _port,
                      onChanged: (_) => _portTouched = true,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.l10n.connPort,
                      ),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1 || n > 65535) {
                          return context.l10n.connPortRange;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.wifi_find, size: 18),
                    label: Text(context.l10n.connFindBrokers),
                    onPressed: _findBrokers,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => BrokerHelpSheet.show(context),
                    child: Text(context.l10n.connHowToFind),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _username,
                onChanged: (_) => _userTouched = true,
                decoration: InputDecoration(
                  labelText: context.l10n.connUsernameOptional,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.l10n.connPasswordOptional,
                  hintText: _isEdit && _passwordExists
                      ? context.l10n.connPasswordKeepHint
                      : null,
                ),
              ),
              const SizedBox(height: 12),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.connAutoConnect),
              value: _autoConnect,
              onChanged: (v) => setState(() => _autoConnect = v),
            ),
            const SizedBox(height: 4),
            // The test ladder is MQTT-shaped; a Home Assistant home was
            // checked when it was connected.
            if (!_viaHa) ...[
              OutlinedButton.icon(
                onPressed: _testing ? null : _testConnection,
                icon: _testing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering),
                label: Text(context.l10n.connTestButton),
              ),
              const SizedBox(height: 4),
            ],
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(context.l10n.advanced),
              children: [
                TextFormField(
                  controller: _remoteHost,
                  decoration: InputDecoration(
                    labelText: _viaHa
                        ? context.l10n.haHomeRemote
                        : context.l10n.connRemoteHost,
                    hintText: _viaHa
                        ? 'https://xyz.ui.nabu.casa'
                        : context.l10n.connRemoteHostHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _keepAlive,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.l10n.connKeepAlive,
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 5 || n > 3600) {
                      return context.l10n.connKeepAliveRange;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Test on a page Home reached a broker with none of its devices (3.8.6).
class _NoDevicesWarning extends StatelessWidget {
  const _NoDevicesWarning({this.server});
  final String? server;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final roles = SignalColors.of(context);
    final text = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: roles.onAttention);
    return Card(
      key: const Key('conn-no-devices'),
      margin: EdgeInsets.zero,
      elevation: 0,
      color: roles.attention,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: roles.onAttention),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.connBrokerNoDevices, style: text),
                  if (server != null) ...[
                    const SizedBox(height: 4),
                    Text(l10n.connZ2mUses(server!), style: text),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A home that connects through Home Assistant: where, and how to change
/// the sign-in (docs/design/ha-route.md).
class _HaHomeCard extends StatelessWidget {
  const _HaHomeCard({required this.address, required this.onSignInAgain});
  final String address;
  final VoidCallback onSignInAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.home_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.haHomeConnected,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(address, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              l10n.haHomeChange,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                onPressed: onSignInAgain,
                icon: const Icon(Icons.login),
                label: Text(l10n.haHomeSignInAgain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
