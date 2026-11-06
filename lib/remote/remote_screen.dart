import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/analytics/analytics.dart';
import '../core/l10n/l10n_ext.dart';
import '../core/router/routes.dart';
import '../data/database/database.dart' show Connection;
import '../data/database/tables/connections.dart';
import '../data/repositories/connection_repo.dart';
import '../engine/engine_providers.dart';
import '../engine/engine_status.dart';
import '../features/pro/pro.dart';
import '../features/pro/pro_screen.dart';
import '../features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import '../mqtt/endpoint.dart';
import '../mqtt/mqtt_status.dart';
import '../mqtt/providers/mqtt_manager_provider.dart';
import 'remote_phones.dart';
import 'remote_setup.dart';

/// Step 1 of remote control, ZigDash Engine on the hub, as far as this
/// phone can tell right now.
enum RemoteEngineStep {
  /// On the hub.
  installed,

  /// Connected, and it isn't there: it can be installed (free).
  install,

  /// Connected, and this Zigbee2MQTT can't run it.
  tooOld,

  /// Connected, the hub hasn't said yet.
  checking,

  /// Not connected; it was there when this phone last saw the hub.
  seenBefore,

  /// Not connected, and nothing certain is kept: not there, too old and
  /// never looked are one stored value, so the page claims none of them.
  unknown,
}

RemoteEngineStep remoteEngineStep({
  required bool connected,
  required HubEnginePhase? phase,
  required bool seenInstalled,
}) {
  if (!connected) {
    return seenInstalled ? RemoteEngineStep.seenBefore : RemoteEngineStep.unknown;
  }
  return switch (phase) {
    HubEnginePhase.running ||
    HubEnginePhase.paused ||
    HubEnginePhase.stoppedSelf => RemoteEngineStep.installed,
    HubEnginePhase.tooOld => RemoteEngineStep.tooOld,
    HubEnginePhase.notInstalled ||
    HubEnginePhase.needsConsent => RemoteEngineStep.install,
    _ => RemoteEngineStep.checking,
  };
}

/// What the Remote control page shows (3.4.4, docs/design/remote-tab.md).
/// Every state is decided before anything is tapped.
RemoteState remoteStateOf({
  required bool fits,
  required bool sold,
  required bool on,
  required bool pro,
  required bool connected,
  required bool atHome,
  required RemoteEngineStep engine,
}) {
  if (!fits) return RemoteState.unfit;
  if (on) return RemoteState.on;
  if (!sold) return RemoteState.notSold;
  if (!pro) return connected ? RemoteState.noPro : RemoteState.noProOffline;
  if (!connected) return RemoteState.proOffline;
  if (engine != RemoteEngineStep.installed) return RemoteState.noEngine;
  return atHome ? RemoteState.ready : RemoteState.away;
}

/// Homes whose Remote control page was counted as opened since the app
/// started: `remote opened` is once per app start and home.
final remoteOpenedThisLaunchProvider = Provider<Set<String>>((ref) => {});

/// Whether "See Pro" on the Remote control page was counted since the app
/// started.
final remoteSeeProThisLaunchProvider = StateProvider<bool>((ref) => false);

/// Remote control through the ZigDash relay (3.1, zigdash-3.0.md §5), and
/// from 3.4.4 the place for "away from home": how this phone reaches the
/// home now, the two ways to reach it from away, and what remote control
/// takes, with the price last.
class RemoteScreen extends ConsumerStatefulWidget {
  const RemoteScreen({
    super.key,
    required this.connectionId,
    this.from = RemoteFrom.settings,
  });

  final String connectionId;

  /// The door on the dashboard, or Settings › Home.
  final RemoteFrom from;

  @override
  ConsumerState<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends ConsumerState<RemoteScreen>
    with WidgetsBindingObserver {
  bool _busy = false;
  String? _error;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back in front: a sale may have ended while the app was away.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.invalidate(proOfferProvider);
  }

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

  /// `remote opened`, once per app start and home, when the page knows
  /// what it shows.
  void _count(RemoteState state, bool pro) {
    if (_counted) return;
    _counted = true;
    if (!ref.read(remoteOpenedThisLaunchProvider).add(widget.connectionId)) {
      return;
    }
    // Called while building: the event goes out after the frame.
    final analytics = ref.read(analyticsProvider);
    final from = widget.from;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      analytics.track(
        RemoteEvent(RemoteStep.opened, pro: pro, from: from, state: state),
      );
    });
  }

  void _seePro() {
    if (!ref.read(remoteSeeProThisLaunchProvider)) {
      ref.read(remoteSeeProThisLaunchProvider.notifier).state = true;
      ref.read(analyticsProvider).track(
        RemoteEvent(RemoteStep.seePro, pro: false, from: widget.from),
      );
    }
    openPro(
      context,
      from: widget.from == RemoteFrom.door
          ? ProFrom.remoteDoor
          : ProFrom.remoteSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final id = widget.connectionId;
    final homeAsync = ref.watch(connectionByIdProvider(id));
    final home = homeAsync.valueOrNull;
    final login = ref.watch(remoteHomeProvider(id));
    final on = login.valueOrNull != null;
    final fits = home != null && remoteFits(home);

    // A home that can't use the relay: say so, and keep the way out for
    // one that got in before 3.4.4.
    if (homeAsync.hasValue && !fits) {
      if (login.hasValue) {
        _count(RemoteState.unfit, ref.watch(proStatusProvider) == ProStatus.unlocked);
      }
      return Scaffold(
        appBar: AppBar(title: Text(l10n.remoteTitle)),
        body: SafeArea(
          child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              home != null && transportOf(home.transport) == ConnectionTransport.z2mPage
                  ? l10n.remoteUnfitZ2m
                  : l10n.remoteUnfitHa,
              key: const Key('remote-unfit'),
              style: theme.textTheme.bodyLarge,
            ),
            if (on) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                key: const Key('remote-off'),
                onPressed: _busy ? null : _turnOff,
                child: Text(l10n.remoteTurnOff),
              ),
            ],
          ],
          ),
        ),
      );
    }

    final status = ref.watch(connectionStatusProvider(id)).valueOrNull;
    final connected = status == MqttStatus.connected;
    final endpoint = ref.watch(connectionEndpointProvider(id)).valueOrNull;
    final viaRelay = connected && endpoint == MqttEndpoint.relay;
    final engineAsync = ref.watch(engineViewProvider(id));
    final engine = engineAsync.valueOrNull;
    final sold = ref.watch(remoteSoldProvider) || relayIsTest;
    final pro = ref.watch(proStatusProvider) == ProStatus.unlocked || relayIsTest;
    final step1 = remoteEngineStep(
      connected: connected,
      phase: engine?.phase,
      seenInstalled: engineKnownInstalled(ref.watch(sharedPreferencesProvider), id),
    );
    final state = remoteStateOf(
      fits: fits,
      sold: sold,
      on: on,
      pro: pro,
      connected: connected,
      atHome: ref.watch(atHomeProvider(id)),
      engine: step1,
    );
    // Counted once the page knows its state: the home and its login are
    // read, and a connected hub has said whether the Engine is there.
    // With Pro and connected, that means past "checking": the stream's
    // first word comes before the hub's, and would count an installed
    // Engine as missing.
    if (homeAsync.hasValue &&
        login.hasValue &&
        (!pro || !connected || on || step1 != RemoteEngineStep.checking)) {
      _count(state, pro);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.remoteTitle)),
      body: SafeArea(
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (home != null)
            _Now(
              home: home,
              connected: connected,
              endpoint: endpoint,
              z2mVersion: connected ? engine?.hub?.version : null,
            ),
          const SizedBox(height: 16),
          Text(on ? l10n.remoteOnTitle : l10n.remoteIntroTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(on ? l10n.remoteOnBody : l10n.remoteIntroBody, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          if (state == RemoteState.on) ...[
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
            RemotePhonesSection(connectionId: id),
            const SizedBox(height: 8),
            // Quoted when asking for the relay's data about this Home (privacy policy).
            SelectableText(l10n.remoteHomeId(login.value!.homeId), style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            OutlinedButton(
              key: const Key('remote-off'),
              onPressed: _busy ? null : _turnOff,
              child: Text(l10n.remoteTurnOff),
            ),
          ] else ...[
            if (home != null) _Ways(home: home),
            const SizedBox(height: 16),
            if (state == RemoteState.notSold)
              Text(l10n.remotePlayOnly, key: const Key('remote-play-only'))
            else ...[
              _Steps(
                engine: step1,
                pro: pro,
                atHome: state == RemoteState.ready || ref.watch(atHomeProvider(id)),
              ),
              const SizedBox(height: 16),
              ..._action(context, state, step1),
            ],
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
        ],
        ),
      ),
    );
  }

  /// The one thing to do next, for a home where remote control is off.
  List<Widget> _action(BuildContext context, RemoteState state, RemoteEngineStep step1) {
    final l10n = context.l10n;
    final id = widget.connectionId;
    Widget restore() => TextButton.icon(
      key: const Key('remote-restore'),
      onPressed: _busy ? null : () => restoreRemoteBackup(context, ref, id),
      icon: const Icon(Icons.key_outlined),
      label: Text(l10n.remoteBackupRestore),
    );
    switch (state) {
      case RemoteState.noPro || RemoteState.noProOffline:
        final price = ref.watch(proPriceProvider).valueOrNull;
        return [
          FilledButton(
            key: const Key('remote-see-pro'),
            onPressed: _seePro,
            child: Text(price == null ? l10n.autoCeilingSeePro : l10n.remoteSeePro(price)),
          ),
        ];
      case RemoteState.noEngine:
        return [
          if (step1 == RemoteEngineStep.install)
            FilledButton.tonal(
              key: const Key('remote-engine'),
              onPressed: () => context.go(Routes.homeAutomations(id)),
              child: Text(l10n.automationsTitle),
            ),
          restore(),
        ];
      case RemoteState.away || RemoteState.proOffline:
        return [
          Text(
            state == RemoteState.away ? l10n.remoteNotAtHome : l10n.remoteStepOnLater,
            key: const Key('remote-at-home-first'),
          ),
          const SizedBox(height: 8),
          restore(),
        ];
      case RemoteState.ready:
        return [
          FilledButton(
            key: const Key('remote-on'),
            onPressed: _busy ? null : _turnOn,
            child: _busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.remoteSetUp),
          ),
          const SizedBox(height: 8),
          restore(),
        ];
      case RemoteState.on || RemoteState.unfit || RemoteState.notSold:
        return const [];
    }
  }
}

/// How this phone reaches the home right now, and the hub's Zigbee2MQTT.
class _Now extends StatelessWidget {
  const _Now({
    required this.home,
    required this.connected,
    required this.endpoint,
    required this.z2mVersion,
  });

  final Connection home;
  final bool connected;
  final MqttEndpoint? endpoint;
  final String? z2mVersion;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final (icon, text) = !connected
        ? (Icons.cloud_off_outlined, l10n.remoteNowOffline)
        : switch (endpoint) {
            MqttEndpoint.relay => (Icons.public, l10n.remoteNowRelay),
            MqttEndpoint.remote => (
              Icons.vpn_lock_outlined,
              l10n.remoteNowOwn(home.remoteHost ?? home.host),
            ),
            _ => (
              Icons.home_outlined,
              l10n.remoteNowHome('${home.host}:${home.port}'),
            ),
          };
    final version = z2mVersion;
    return Card(
      key: const Key('remote-now'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.remoteNowTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 22, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
              ],
            ),
            if (version != null && version.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Zigbee2MQTT $version', style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

/// The free way and the Pro way to reach the home from away, side by side:
/// nothing free moves behind Pro, and the page says so.
class _Ways extends StatelessWidget {
  const _Ways({required this.home});

  final Connection home;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final own = home.remoteHost?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.remoteWaysTitle, style: theme.textTheme.titleMedium),
        ListTile(
          key: const Key('remote-way-own'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.vpn_lock_outlined),
          title: Text(l10n.remoteWayOwnTitle),
          subtitle: Text(
            own.isEmpty ? l10n.remoteWayOwnUnset : l10n.remoteWayOwnSet(own),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/connections/${home.id}/edit'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.public),
          title: Text(l10n.remoteTitle),
          subtitle: Text(l10n.remoteWayRelayBody),
        ),
      ],
    );
  }
}

/// The three things remote control takes, each with its real state, shown
/// before the price: a person should know their hub can run it first.
class _Steps extends ConsumerWidget {
  const _Steps({required this.engine, required this.pro, required this.atHome});

  final RemoteEngineStep engine;
  final bool pro;

  /// Connected straight to the broker: step 3 can be done from here.
  final bool atHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final offer = ref.watch(proOfferProvider).valueOrNull;
    final sale = !pro && offer != null && offer.onSale(DateTime.now())
        ? proSaleLine(context, l10n, offer)
        : null;

    Widget step(int n, String title, String? detail, {required bool done}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              done
                  ? Icon(
                      Icons.check_circle,
                      size: 24,
                      color: theme.colorScheme.primary,
                      semanticLabel: l10n.remoteStepDone,
                    )
                  : CircleAvatar(
                      radius: 12,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      child: Text('$n', style: theme.textTheme.labelMedium),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyLarge),
                    if (detail != null)
                      Text(
                        detail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

    return Column(
      key: const Key('remote-steps'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.remoteStepsTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        step(
          1,
          l10n.remoteStepEngine,
          switch (engine) {
            RemoteEngineStep.installed => l10n.remoteStepDone,
            RemoteEngineStep.install => l10n.remoteStepEngineInstall,
            RemoteEngineStep.tooOld => l10n.remoteStepEngineTooOld,
            RemoteEngineStep.checking => l10n.engineChecking,
            RemoteEngineStep.seenBefore => l10n.remoteStepEngineSeen,
            RemoteEngineStep.unknown => l10n.remoteStepEngineLater,
          },
          done: engine == RemoteEngineStep.installed,
        ),
        step(
          2,
          l10n.proTitle,
          pro ? l10n.remoteStepDone : sale ?? l10n.remoteStepProNeeded,
          done: pro,
        ),
        step(
          3,
          l10n.remoteSetUp,
          atHome ? null : l10n.remoteStepOnLater,
          done: false,
        ),
      ],
    );
  }
}
