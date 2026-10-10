import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/analytics/analytics.dart';
import '../core/l10n/l10n_ext.dart';
import '../features/devices/device_profile.dart';
import '../features/devices/devices_providers.dart';
import '../features/discovery/providers/discovery_provider.dart';
import '../features/panels/providers/panel_value_provider.dart' show composeTopic;
import 'alerts_config.dart';
import 'alerts_screen.dart' show kindLabel, newAlertId;
import 'alerts_service.dart';

/// Adds or edits one alert (docs/design/alerts-2.3.md, "Add or edit an
/// alert"): the kind, the devices that report it, a door's hours, a
/// battery's threshold.
class AlertEditorScreen extends ConsumerStatefulWidget {
  const AlertEditorScreen(
      {super.key,
      required this.connectionId,
      required this.alertId,
      this.kind,
      this.ieee});

  final String connectionId;

  /// `new` for a new alert.
  final String alertId;

  /// For a new alert from a device page: its kind and the device to tick.
  final String? kind;
  final String? ieee;

  @override
  ConsumerState<AlertEditorScreen> createState() => _AlertEditorScreenState();
}

class _AlertEditorScreenState extends ConsumerState<AlertEditorScreen> {
  AlertRule? _rule;
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final config = ref.watch(alertsConfigProvider(widget.connectionId)).valueOrNull;
    final base = ref.watch(homeBaseTopicProvider(widget.connectionId)) ?? 'zigbee2mqtt';
    final devices = ref
            .watch(bridgeDevicesStreamProvider(
                (connectionId: widget.connectionId, base: base)))
            .valueOrNull ??
        const [];
    if (config != null && !_loaded && (widget.ieee == null || devices.isNotEmpty)) {
      _loaded = true;
      final wantedKind = AlertKind.values.asNameMap()[widget.kind];
      // From a device page: the alert that device is already in, or a new
      // one of that kind with the device ticked.
      final existing = widget.ieee == null
          ? null
          : config.alerts
              .where((a) =>
                  (wantedKind == null || a.kind == wantedKind) &&
                  a.devices.any((d) => d.ieee == widget.ieee))
              .firstOrNull;
      final device = devices.where((d) => d.ieeeAddress == widget.ieee).firstOrNull;
      _rule = config.alerts.where((a) => a.id == widget.alertId).firstOrNull ??
          existing ??
          AlertRule(
              id: newAlertId(),
              kind: wantedKind ?? AlertKind.leak,
              devices: [
                if (device != null)
                  AlertDevice(
                      ieee: device.ieeeAddress!,
                      topic: composeTopic(base, device.friendlyName),
                      name: device.friendlyName),
              ]);
    }
    final rule = _rule;
    if (rule == null) {
      return Scaffold(appBar: AppBar(title: Text(l10n.alertsEditTitle)));
    }
    final candidates = [
      for (final d in devices)
        if (d.ieeeAddress != null && _reports(classifyExposes(d.rawExposes), rule.kind))
          AlertDevice(
              ieee: d.ieeeAddress!,
              topic: composeTopic(base, d.friendlyName),
              name: d.friendlyName),
    ];
    final chosen = {for (final d in rule.devices) d.ieee};
    final isNew = !config!.alerts.any((a) => a.id == rule.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? l10n.alertsAdd : l10n.alertsEditTitle),
        actions: [
          if (!isNew)
            IconButton(
              tooltip: l10n.alertsDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _save(config, remove: true),
            ),
          TextButton(
            onPressed: rule.devices.isEmpty ? null : () => _save(config),
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.alertsKind, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final k in AlertKind.values)
                    ChoiceChip(
                      label: Text(kindLabel(l10n, k)),
                      selected: rule.kind == k,
                      onSelected: (_) => setState(() =>
                          _rule = rule.copyWith(kind: k, devices: const [])),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.alertsDevices, style: Theme.of(context).textTheme.labelLarge),
              if (candidates.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(l10n.alertsNoDevicesForKind),
                ),
              for (final d in candidates)
                CheckboxListTile(
                  title: Text(d.name),
                  value: chosen.contains(d.ieee),
                  onChanged: (v) => setState(() => _rule = rule.copyWith(devices: [
                        for (final x in rule.devices)
                          if (x.ieee != d.ieee) x,
                        if (v == true) d,
                      ])),
                ),
              if (rule.kind == AlertKind.opened) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(l10n.alertsHours),
                  subtitle: Text(rule.from == null
                      ? l10n.alertsHoursAny
                      : '${rule.from} – ${rule.to}'),
                  value: rule.from != null,
                  onChanged: (v) => setState(() => _rule = rule.copyWith(
                      from: () => v ? '23:00' : null, to: () => v ? '06:00' : null)),
                ),
                if (rule.from != null)
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(l10n.alertsHoursFrom),
                          subtitle: Text(rule.from!),
                          onTap: () => _pickTime(rule.from!, (t) =>
                              setState(() => _rule = rule.copyWith(from: () => t))),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(l10n.alertsHoursTo),
                          subtitle: Text(rule.to!),
                          onTap: () => _pickTime(rule.to!, (t) =>
                              setState(() => _rule = rule.copyWith(to: () => t))),
                        ),
                      ),
                    ],
                  ),
              ],
              if (rule.kind == AlertKind.battery) ...[
                const SizedBox(height: 16),
                Text('${l10n.alertsThreshold} ${rule.threshold}%',
                    style: Theme.of(context).textTheme.labelLarge),
                Slider(
                  value: rule.threshold.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  label: '${rule.threshold}%',
                  onChanged: (v) =>
                      setState(() => _rule = rule.copyWith(threshold: v.round())),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static bool _reports(DeviceProfile p, AlertKind kind) => alertKindsOf(p).contains(kind);


  Future<void> _pickTime(String hhmm, void Function(String) done) async {
    final parts = hhmm.split(':');
    final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])));
    if (t != null) {
      done('${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _save(AlertsConfig config, {bool remove = false}) async {
    final rule = _rule!;
    final others = [for (final a in config.alerts) if (a.id != rule.id) a];
    final service = ref.read(alertsServiceProvider);
    final added = !remove && !config.alerts.any((a) => a.id == rule.id);
    await service.save(config.copyWith(alerts: remove ? others : [...others, rule]));
    await service.publish(widget.connectionId);
    if (added) ref.read(analyticsProvider).track(AlertAdded(rule.kind.name));
    if (mounted) Navigator.of(context).pop();
  }
}

/// The alert kinds a device can have, from what it reports.
Set<AlertKind> alertKindsOf(DeviceProfile p) => {
      if (p.feature('water_leak') != null) AlertKind.leak,
      if (p.feature('smoke') != null) AlertKind.smoke,
      if (p.feature('contact') != null) AlertKind.opened,
      if (p.battery != null || p.feature('battery_low') != null) AlertKind.battery,
    };

/// The alert a device page offers first (`leak`, `smoke`, `opened`,
/// `battery`), or null when the device reports none of these.
String? alertKindFor(DeviceProfile p) {
  final kinds = alertKindsOf(p);
  for (final k in AlertKind.values) {
    if (kinds.contains(k)) return k.name;
  }
  return null;
}
