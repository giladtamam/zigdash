import 'dart:convert' show JsonEncoder;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/l10n/l10n_ext.dart';
import '../core/router/routes.dart';
import '../data/repositories/connection_repo.dart';
import '../features/devices/devices_providers.dart';
import '../l10n/app_localizations.dart';
import 'alert_push.dart';
import 'alerts_config.dart';
import 'alerts_providers.dart';
import 'alerts_service.dart';
import 'alert_editor_screen.dart' show alertKindsOf;
import '../features/devices/device_profile.dart' show classifyExposes;
import '../features/discovery/providers/discovery_provider.dart';
import '../features/panels/providers/panel_value_provider.dart' show composeTopic;
import 'node_red_installer.dart';

/// A Home's alerts (docs/design/alerts-2.3.md, "Alerts screen"): status,
/// Recent alerts, the alerts with their switches, and the buttons that set
/// things up: the hub's flow, this phone's notifications, a test.
class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  bool _busy = false;

  String get _id => widget.connectionId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final config = ref.watch(alertsConfigProvider(_id)).valueOrNull;
    final online = ref.watch(alertsBridgeOnlineProvider(_id)).valueOrNull;
    final recent = ref.watch(recentAlertsProvider(_id)).valueOrNull ?? const [];
    final push = ref.watch(pushAvailabilityProvider).valueOrNull;
    final service = ref.read(alertsServiceProvider);
    final theme = Theme.of(context);
    final thisPhone = config != null && service.thisPhoneIn(config);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.alertsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              _StatusCard(
                config: config,
                online: online,
                thisPhone: thisPhone,
                push: push,
              ),
              if (config == null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(l10n.alertsIntro, style: theme.textTheme.bodyMedium),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(l10n.alertsWhatLeaves,
                      style: theme.textTheme.bodySmall),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: _busy ? null : () => _setUp(l10n),
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(l10n.alertsSetUpHub),
                  ),
                ),
              ] else ...[
                _Header(l10n.alertsRecent),
                if (recent.isEmpty)
                  ListTile(title: Text(l10n.alertsRecentNone))
                else
                  for (final e in recent.take(20))
                    ListTile(
                      leading: Icon(_iconFor(e.kind)),
                      title: Text(e.text(l10n, oneHome: true)),
                      subtitle: Text(_age(context, e.at)),
                      onTap: e.device == null
                          ? null
                          : () => context.push(Routes.homeDevice(_id, e.device!)),
                    ),
                if (config.alerts.isEmpty) _Suggestions(connectionId: _id, config: config),
                _Header(l10n.alertsYourAlerts),
                for (final a in config.alerts)
                  ListTile(
                    leading: Icon(_iconFor(a.kind.name)),
                    title: Text(kindLabel(l10n, a.kind)),
                    subtitle: Text(a.devices.map((d) => d.name).join(', ')),
                    trailing: Switch(
                      value: a.enabled,
                      onChanged: (v) => _update(config.copyWith(alerts: [
                        for (final r in config.alerts)
                          r.id == a.id ? r.copyWith(enabled: v) : r,
                      ])),
                    ),
                    onTap: () => context.push(Routes.homeAlertEdit(_id, a.id)),
                  ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(l10n.alertsAdd),
                  onTap: () => context.push(Routes.homeAlertEdit(_id, 'new')),
                ),
                const Divider(),
                SwitchListTile(
                  secondary: const Icon(Icons.phone_android),
                  title: Text(l10n.alertsNotificationsOnThisPhone),
                  subtitle: push == PushAvailability.none
                      ? Text(l10n.alertsNoGoogle)
                      : null,
                  value: thisPhone,
                  onChanged: push == PushAvailability.none || _busy
                      ? null
                      : (v) => _thisPhone(v, l10n),
                ),
                ListTile(
                  leading: const Icon(Icons.send_outlined),
                  title: Text(l10n.alertsSendTest),
                  enabled: thisPhone && !_busy,
                  onTap: () => _test(l10n),
                ),
                ListTile(
                  leading: const Icon(Icons.hub_outlined),
                  title: Text(l10n.alertsSetUpHub),
                  enabled: !_busy,
                  onTap: () => _install(l10n),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.notifications_off_outlined,
                      color: theme.colorScheme.error),
                  title: Text(l10n.alertsTurnOff,
                      style: TextStyle(color: theme.colorScheme.error)),
                  onTap: () => _turnOff(l10n),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _update(AlertsConfig config) async {
    final service = ref.read(alertsServiceProvider);
    await service.save(config);
    await service.publish(_id);
  }

  /// First time: the config with fresh keys, the flow on the hub, this
  /// phone registered, then a test.
  Future<void> _setUp(AppLocalizations l10n) async {
    setState(() => _busy = true);
    try {
      await ref.read(alertsServiceProvider).ensure(_id, l10n);
      final ok = await _install(l10n);
      if (ok && mounted) await _thisPhone(true, l10n);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _install(AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final conn = ref.read(connectionByIdProvider(_id)).valueOrNull;
    if (conn == null) return false;
    final base = ref.read(homeBaseTopicProvider(_id)) ?? 'zigbee2mqtt';
    setState(() => _busy = true);
    try {
      final r = await NodeRedInstaller(host: conn.host).install(
          brokerHost: conn.host,
          brokerPort: conn.port,
          username: conn.username,
          baseTopic: base);
      if (!mounted) return false;
      switch (r) {
        case NodeRedInstall.installed:
          messenger.showSnackBar(SnackBar(content: Text(l10n.alertsHubInstalled)));
          await ref.read(alertsServiceProvider).publish(_id);
          return true;
        case NodeRedInstall.updated:
          messenger.showSnackBar(SnackBar(content: Text(l10n.alertsHubUpdated)));
          await ref.read(alertsServiceProvider).publish(_id);
          return true;
        case NodeRedInstall.needsLogin:
          await _manualSteps(l10n, conn.host, conn.port, conn.username, base);
          return true;
        case NodeRedInstall.notInstalled:
          await _say(l10n.alertsNoNodeRed(conn.host));
          return false;
        case NodeRedInstall.failed:
          messenger.showSnackBar(SnackBar(content: Text(l10n.alertsHubFailed)));
          return false;
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _manualSteps(AppLocalizations l10n, String host, int port,
      String? username, String base) async {
    final flow = await DefaultAssetBundle.of(context)
        .loadString(NodeRedInstaller.flowAsset);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.alertsSetUpHub),
        content: Text('${l10n.alertsHubNeedsLogin}\n\n${l10n.alertsHubManualSteps}'),
        actions: [
          TextButton(
            onPressed: () async {
              // The import format: the tab and its nodes, broker filled in.
              final tab = NodeRedInstaller.tabFor(flow,
                  brokerHost: host, brokerPort: port, username: username, baseTopic: base);
              await Clipboard.setData(ClipboardData(
                  text: const JsonEncoder.withIndent(' ').convert([
                    {'id': 'zigdash_alerts_tab', 'type': 'tab', 'label': tab['label'], 'info': tab['info']},
                    for (final n in tab['configs'] as List) n,
                    for (final n in tab['nodes'] as List) {...n as Map, 'z': 'zigdash_alerts_tab'},
                  ])));
              messenger.showSnackBar(SnackBar(content: Text(l10n.alertsFlowCopied)));
            },
            child: Text(l10n.alertsCopyFlow),
          ),
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(MaterialLocalizations.of(ctx).okButtonLabel)),
        ],
      ),
    );
  }

  Future<void> _thisPhone(bool on, AppLocalizations l10n) async {
    final service = ref.read(alertsServiceProvider);
    setState(() => _busy = true);
    try {
      if (on) {
        await AlertPush.askPermission();
        await service.enableThisPhone(_id, l10n);
      } else {
        await service.disableThisPhone(_id);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _test(AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final r = await ref.read(alertsServiceProvider).sendTest(_id);
      messenger.showSnackBar(SnackBar(
          content: Text(r.ok
              ? l10n.alertsTestSent
              : r.timedOut
                  ? l10n.alertsTestTimedOut
                  : r.status == null
                      ? l10n.alertsNotConnected
                      : l10n.alertsTestFailed('${r.status}'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _turnOff(AppLocalizations l10n) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.alertsTurnOff),
        content: Text(l10n.alertsTurnOffBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.alertsTurnOff)),
        ],
      ),
    );
    if (yes == true) await ref.read(alertsServiceProvider).turnOff(_id);
  }

  Future<void> _say(String text) => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(text),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(MaterialLocalizations.of(ctx).okButtonLabel)),
          ],
        ),
      );

  String _age(BuildContext context, DateTime at) {
    final m = MaterialLocalizations.of(context);
    return '${m.formatMediumDate(at)} ${m.formatTimeOfDay(TimeOfDay.fromDateTime(at))}';
  }
}

String kindLabel(AppLocalizations l10n, AlertKind kind) => switch (kind) {
      AlertKind.leak => l10n.alertKindLeak,
      AlertKind.smoke => l10n.alertKindSmoke,
      AlertKind.opened => l10n.alertKindOpened,
      AlertKind.battery => l10n.alertKindBattery,
    };

IconData _iconFor(String kind) => switch (kind) {
      'leak' => Icons.water_drop_outlined,
      'smoke' => Icons.local_fire_department_outlined,
      'opened' => Icons.door_front_door_outlined,
      'battery' => Icons.battery_alert_outlined,
      _ => Icons.notifications_outlined,
    };

/// A fresh id for an alert.
String newAlertId() {
  final r = Random.secure();
  return List.generate(12, (_) => r.nextInt(16).toRadixString(16)).join();
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}

class _StatusCard extends ConsumerWidget {
  const _StatusCard(
      {required this.config,
      required this.online,
      required this.thisPhone,
      required this.push});
  final AlertsConfig? config;
  final bool? online;
  final bool thisPhone;
  final PushAvailability? push;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final restricted = ref.watch(backgroundRestrictedProvider).valueOrNull ?? false;
    final (text, icon, color) = switch ((config, online, thisPhone)) {
      (null, _, _) => (l10n.alertsStatusNotSetUp, Icons.notifications_none, theme.colorScheme.onSurfaceVariant),
      (_, false, _) => (l10n.alertsStatusPaused, Icons.pause_circle_outline, theme.colorScheme.error),
      (_, _, false) => (l10n.alertsStatusPhoneOff, Icons.phone_disabled_outlined, theme.colorScheme.tertiary),
      _ => (l10n.alertsStatusOn, Icons.notifications_active_outlined, theme.colorScheme.primary),
    };
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(text),
        subtitle: config != null && thisPhone && restricted
            ? Text(l10n.alertsRestricted, style: theme.textTheme.bodySmall)
            : null,
        trailing: config != null && thisPhone && restricted
            ? IconButton(
                tooltip: l10n.alertsOpenSettings,
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => launchUrl(Uri.parse('app-settings:')),
              )
            : null,
      ),
    );
  }
}

/// On first visit (no alerts yet): one suggestion per kind the Home's
/// devices report, turned on with one tap (alerts-2.3.md).
class _Suggestions extends ConsumerWidget {
  const _Suggestions({required this.connectionId, required this.config});
  final String connectionId;
  final AlertsConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final base = ref.watch(homeBaseTopicProvider(connectionId)) ?? 'zigbee2mqtt';
    final devices = ref
            .watch(bridgeDevicesStreamProvider((connectionId: connectionId, base: base)))
            .valueOrNull ??
        const [];
    final byKind = <AlertKind, List<AlertDevice>>{};
    for (final d in devices) {
      final ieee = d.ieeeAddress;
      if (ieee == null) continue;
      for (final k in alertKindsOf(classifyExposes(d.rawExposes))) {
        (byKind[k] ??= []).add(AlertDevice(
            ieee: ieee, topic: composeTopic(base, d.friendlyName), name: d.friendlyName));
      }
    }
    if (byKind.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(l10n.alertsSuggested),
        for (final k in AlertKind.values)
          if (byKind[k] case final list?)
            ListTile(
              leading: Icon(_iconFor(k.name)),
              title: Text(kindLabel(l10n, k)),
              subtitle: Text(l10n.alertsSuggestedCount(list.length)),
              trailing: FilledButton.tonal(
                onPressed: () async {
                  final service = ref.read(alertsServiceProvider);
                  await service.save(config.copyWith(alerts: [
                    ...config.alerts,
                    AlertRule(
                        id: newAlertId(),
                        kind: k,
                        devices: list,
                        from: k == AlertKind.opened ? '23:00' : null,
                        to: k == AlertKind.opened ? '06:00' : null),
                  ]));
                  await service.publish(connectionId);
                },
                child: Text(l10n.alertsTurnOn),
              ),
            ),
      ],
    );
  }
}
