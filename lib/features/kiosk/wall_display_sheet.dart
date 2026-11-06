import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../data/database/database.dart';
import '../../data/repositories/panel_repo.dart';
import '../dashboards/wall_display.dart';
import '../dashboards/wall_readings.dart';
import '../pro/pro.dart';
import '../pro/pro_screen.dart';
import '../history/app_history_recorder.dart';
import '../dashboards/wall_sensors.dart';
import '../devices/device_profile.dart';
import '../devices/devices_providers.dart';
import '../discovery/models/z2m_device.dart';
import '../discovery/providers/discovery_provider.dart';
import '../dashboards/widgets/export_dialog.dart';
import 'kiosk.dart';
import 'kiosk_pin_dialogs.dart';

/// The Wall display sheet for one dashboard (kiosk-2.6.md): keep the screen
/// on and hide the bars, Fullscreen, Dim after, and the Kiosk lock with its
/// PIN and Android screen pinning.
Future<void> showWallDisplaySheet(
  BuildContext context,
  String connectionId,
  Dashboard dashboard,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Over the navigation bar too, not inside the home shell's body.
    useRootNavigator: true,
    builder: (_) =>
        WallDisplaySheet(connectionId: connectionId, dashboard: dashboard),
  );
}

class WallDisplaySheet extends ConsumerWidget {
  const WallDisplaySheet({
    super.key,
    required this.connectionId,
    required this.dashboard,
  });

  final String connectionId;
  final Dashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final id = dashboard.id;
    final wall = ref.watch(wallDisplayProvider(id));
    final fullscreen = ref.watch(wallFullscreenProvider(id));
    final dim = ref.watch(wallDimProvider(id));
    final idleShow = ref.watch(wallIdleShowProvider(id));
    // Pro rows (wall-tablet-2.9.md §7): hidden where Pro can't be had,
    // shown locked with one note where it can be bought.
    final pro = ref.watch(proStatusProvider);
    final proOpen = pro == ProStatus.unlocked;
    final kiosk = ref.watch(kioskProvider);
    final locked = kiosk.dashboardId == id;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
        children: [
          ListTile(
            title: Text(l10n.wallSheetTitle, style: theme.textTheme.titleLarge),
            subtitle: Text(l10n.wallSheetSubtitle),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.light_mode_outlined),
            title: Text(l10n.wallKeepOn),
            subtitle: Text(l10n.wallKeepOnSubtitle),
            value: wall,
            onChanged: (on) =>
                ref.read(wallDisplayProvider(id).notifier).set(on),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fullscreen),
            title: Text(l10n.wallFullscreen),
            subtitle: Text(l10n.wallFullscreenSubtitle),
            value: fullscreen,
            onChanged: (on) =>
                ref.read(wallFullscreenProvider(id).notifier).set(on),
          ),
          ListTile(
            leading: const Icon(Icons.hourglass_bottom),
            title: Text(l10n.wallIdleTitle),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(l10n.wallIdleAfter),
                const SizedBox(height: 4),
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: [
                    for (final m in wallDimChoices)
                      ButtonSegment(
                        value: m,
                        label: Text(
                          m == 0 ? l10n.wallIdleNever : l10n.wallDimMinutes(m),
                        ),
                      ),
                  ],
                  selected: {dim},
                  onSelectionChanged: (s) =>
                      ref.read(wallDimProvider(id).notifier).set(s.first),
                ),
                if (dim > 0) ...[
                  const SizedBox(height: 12),
                  Text(l10n.wallIdleShow),
                  const SizedBox(height: 4),
                  // Chips that wrap: four choices don't fit one row on a phone.
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final (show, label) in [
                        (WallIdleShow.dim, l10n.wallIdleShowDim),
                        (WallIdleShow.clock, l10n.wallIdleShowClock),
                        if (pro != ProStatus.unavailable)
                          (
                            WallIdleShow.readings,
                            proOpen
                                ? l10n.wallIdleShowReadings
                                : '${l10n.wallIdleShowReadings} · ${l10n.proBadge}',
                          ),
                        (WallIdleShow.black, l10n.wallIdleShowBlack),
                      ])
                        ChoiceChip(
                          label: Text(label),
                          selected:
                              show ==
                              (idleShow == WallIdleShow.readings && !proOpen
                                  ? WallIdleShow.clock
                                  : idleShow),
                          onSelected: show == WallIdleShow.readings && !proOpen
                              ? null
                              : (_) => ref
                                    .read(wallIdleShowProvider(id).notifier)
                                    .set(show),
                        ),
                    ],
                  ),
                  if (idleShow == WallIdleShow.readings && proOpen)
                    _ReadingsPicker(dashboardId: id),
                ],
              ],
            ),
          ),
          if (pro != ProStatus.unavailable) ...[
            _MotionSection(
              connectionId: connectionId,
              dashboardId: id,
              open: proOpen,
            ),
            _NightSection(dashboardId: id, open: proOpen),
            _AlarmsSection(dashboardId: id, open: proOpen),
          ],
          if (pro == ProStatus.locked) const _ProNote(),
          // History without Node-RED (2.9.1): a wall tablet that stays open
          // is the natural recorder.
          SwitchListTile(
            secondary: const Icon(Icons.timeline),
            title: Text(l10n.wallRecordHistory),
            subtitle: Text(l10n.wallRecordHistorySubtitle),
            value: ref.watch(historyRecordHereProvider(connectionId)),
            onChanged: (on) => ref
                .read(historyRecordHereProvider(connectionId).notifier)
                .set(on),
          ),
          const Divider(height: 24),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline),
            title: Text(l10n.kioskLock),
            subtitle: Text(l10n.kioskLockSubtitle),
            value: locked,
            onChanged: (on) => on
                ? _startKiosk(context, ref)
                : ref.read(kioskProvider.notifier).stop(),
          ),
          ListTile(
            leading: const Icon(Icons.pin_outlined),
            title: Text(l10n.kioskPin),
            subtitle: Text(
              kiosk.hasPin ? l10n.kioskPinSet : l10n.kioskPinNotSet,
            ),
            trailing: Wrap(
              spacing: 4,
              children: [
                TextButton(
                  onPressed: () => _setPin(context, ref),
                  child: Text(
                    kiosk.hasPin ? l10n.kioskPinChange : l10n.kioskPinSet,
                  ),
                ),
                if (kiosk.hasPin)
                  TextButton(
                    onPressed: () =>
                        ref.read(kioskProvider.notifier).clearPin(),
                    child: Text(l10n.kioskPinRemove),
                  ),
              ],
            ),
          ),
          if (!kiosk.hasPin)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.kioskPinForgotBody,
                    style: theme.textTheme.bodySmall,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.save_alt),
                    label: Text(l10n.kioskExportBackup),
                    onPressed: () =>
                        showExportDashboardsDialog(context, ref, connectionId),
                  ),
                ],
              ),
            ),
          SwitchListTile(
            secondary: const Icon(Icons.push_pin_outlined),
            title: Text(l10n.kioskOsPin),
            subtitle: Text(l10n.kioskOsPinSubtitle),
            value: kiosk.osPinning,
            onChanged: (on) =>
                ref.read(kioskProvider.notifier).setOsPinning(on),
          ),
        ],
      ),
    );
  }

  Future<void> _setPin(BuildContext context, WidgetRef ref) async {
    final pin = await askNewKioskPin(context);
    if (pin == null) return;
    await ref.read(kioskProvider.notifier).setPin(pin);
  }

  /// Turning the lock on: Fullscreen and a 5-minute Dim unless the user
  /// already chose, then kiosk starts and the sheet closes.
  Future<void> _startKiosk(BuildContext context, WidgetRef ref) async {
    final id = dashboard.id;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final fullscreen = ref.read(wallFullscreenProvider(id).notifier);
    if (!fullscreen.chosen) await fullscreen.set(true);
    final dim = ref.read(wallDimProvider(id).notifier);
    if (!dim.chosen) await dim.set(5);
    final kiosk = ref.read(kioskProvider);
    await ref.read(kioskProvider.notifier).start(connectionId, id);
    ref
        .read(analyticsProvider)
        .track(
          KioskStarted(
            pin: kiosk.hasPin,
            osPinning: kiosk.osPinning,
            dimMinutes: ref.read(wallDimProvider(id)),
            // What will show: readings without Pro is the clock.
            idleShow:
                (ref.read(wallIdleShowProvider(id)) == WallIdleShow.readings &&
                            ref.read(proStatusProvider) != ProStatus.unlocked
                        ? WallIdleShow.clock
                        : ref.read(wallIdleShowProvider(id)))
                    .name,
            motion: ref.read(wallMotionSensorsProvider(id)).isNotEmpty,
            night: ref.read(wallNightProvider(id)).on,
            alarms: ref.read(wallAlarmProvider(id)).on,
          ),
        );
    if (!context.mounted) return;
    Navigator.pop(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.kioskOn)));
  }
}

/// Leaves kiosk from the dashboard's title: the PIN when one is set, else a
/// plain confirmation. Returns true when kiosk was turned off.
Future<bool> leaveKiosk(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final kiosk = ref.read(kioskProvider.notifier);
  // The store itself, not the cached flag: right after launch the flag is
  // still being read, and this is the lock.
  final hasPin = await ref.read(kioskPinStoreProvider).read() != null;
  if (!context.mounted) return false;
  bool ok;
  if (hasPin) {
    ok = await askKioskPin(context, kiosk.checkPin);
  } else {
    ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.kioskLeaveTitle),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.kioskStay),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.kioskLeave),
              ),
            ],
          ),
        ) ??
        false;
  }
  if (ok) await kiosk.stop();
  return ok;
}

/// Which of the dashboard's numbers the idle clock shows, up to
/// [wallMaxReadings]; the first ones until the user picks.
class _ReadingsPicker extends ConsumerWidget {
  const _ReadingsPicker({required this.dashboardId});

  final String dashboardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final all = ref.watch(wallReadingsAvailableProvider(dashboardId));
    final shown = {
      for (final r in ref.watch(wallIdleReadingsProvider(dashboardId))) r.key,
    };
    if (all.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(l10n.wallIdleReadingsNone),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(l10n.wallIdleReadingsPick(wallMaxReadings)),
        for (final r in all)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(r.name),
            subtitle: r.unit == null ? null : Text(r.unit!),
            value: shown.contains(r.key),
            onChanged: shown.contains(r.key) || shown.length < wallMaxReadings
                ? (on) {
                    final next = [
                      for (final x in all)
                        if (x.key == r.key ? on! : shown.contains(x.key)) x.key,
                    ];
                    ref
                        .read(
                          wallIdleReadingsSettingProvider(dashboardId).notifier,
                        )
                        .set(next);
                  }
                : null,
          ),
      ],
    );
  }
}

/// The one mention of Pro in the sheet: what it adds and Unlock. No pop-up.
class _ProNote extends ConsumerWidget {
  const _ProNote();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final buy = ref.watch(proPurchaseProvider);
    return ListTile(
      leading: const Icon(Icons.workspace_premium_outlined),
      title: Text(l10n.wallProNote),
      trailing: TextButton(
        onPressed: buy == null
            ? null
            : () => openPro(context, from: ProFrom.wall),
        child: Text(l10n.historyUnlock),
      ),
    );
  }
}

/// "Wake on motion": the Home's motion, presence and door sensors to pick
/// from (wall-tablet-2.9.md §4). Locked without Pro.
class _MotionSection extends ConsumerWidget {
  const _MotionSection({
    required this.connectionId,
    required this.dashboardId,
    required this.open,
  });

  final String connectionId;
  final String dashboardId;
  final bool open;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final base = ref.watch(homeBaseTopicProvider(connectionId));
    final devices = base == null
        ? const <Z2mDevice>[]
        : ref
                  .watch(
                    bridgeDevicesStreamProvider((
                      connectionId: connectionId,
                      base: base,
                    )),
                  )
                  .valueOrNull ??
              const <Z2mDevice>[];
    final sensors = [
      for (final d in devices)
        if (d.ieeeAddress != null &&
            const {
              DeviceClass.motion,
              DeviceClass.contact,
            }.contains(classifyExposes(d.rawExposes).deviceClass))
          d,
    ];
    final chosen = ref.watch(wallMotionSensorsProvider(dashboardId));
    // The names the user gave the tiles ("sensor 1"), not Zigbee's
    // ("Motion sensor e8a1"), so the list matches the dashboard (2.9.2).
    final tileNames = {
      for (final p
          in ref.watch(panelsForDashboardProvider(dashboardId)).valueOrNull ??
              const <Panel>[])
        if (p.deviceIeee != null) p.deviceIeee!: p.name,
    };
    final title = open
        ? l10n.wallMotionTitle
        : '${l10n.wallMotionTitle} · ${l10n.proBadge}';
    return ListTile(
      leading: const Icon(Icons.directions_walk),
      enabled: open,
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.wallMotionSubtitle),
          if (open && sensors.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l10n.wallMotionNone),
            ),
          if (open)
            for (final d in sensors)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(tileNames[d.ieeeAddress] ?? d.displayName),
                value: chosen.contains(d.ieeeAddress),
                onChanged: (on) => ref
                    .read(wallMotionSensorsProvider(dashboardId).notifier)
                    .set([
                      for (final x in chosen)
                        if (x != d.ieeeAddress) x,
                      if (on!) d.ieeeAddress!,
                    ]),
              ),
        ],
      ),
    );
  }
}

/// "Alarms take over the screen" and its sound (wall-tablet-2.9.md §6).
class _AlarmsSection extends ConsumerWidget {
  const _AlarmsSection({required this.dashboardId, required this.open});

  final String dashboardId;
  final bool open;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final alarms = ref.watch(wallAlarmProvider(dashboardId));
    final setting = ref.read(wallAlarmProvider(dashboardId).notifier);
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.warning_amber_rounded),
          title: Text(
            open
                ? l10n.wallAlarmsTitle
                : '${l10n.wallAlarmsTitle} · ${l10n.proBadge}',
          ),
          subtitle: Text(l10n.wallAlarmsSubtitle),
          value: open && alarms.on,
          onChanged: open ? setting.setOn : null,
        ),
        if (open && alarms.on)
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: Text(l10n.wallAlarmSound),
            value: alarms.sound,
            onChanged: setting.setSound,
          ),
      ],
    );
  }
}

/// "Night": black between two times, motion wakes only dimly
/// (wall-tablet-2.9.md §5).
class _NightSection extends ConsumerWidget {
  const _NightSection({required this.dashboardId, required this.open});

  final String dashboardId;
  final bool open;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final loc = MaterialLocalizations.of(context);
    final night = ref.watch(wallNightProvider(dashboardId));
    final setting = ref.read(wallNightProvider(dashboardId).notifier);
    String label(int minutes) => loc.formatTimeOfDay(
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    Future<int?> pick(int minutes) async {
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      );
      return t == null ? null : t.hour * 60 + t.minute;
    }

    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.nightlight_outlined),
          title: Text(
            open
                ? l10n.wallNightTitle
                : '${l10n.wallNightTitle} · ${l10n.proBadge}',
          ),
          subtitle: Text(l10n.wallNightSubtitle),
          value: open && night.on,
          onChanged: open ? (on) => setting.set(on: on) : null,
        ),
        if (open && night.on)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 56, end: 16),
            child: Row(
              children: [
                Text(l10n.wallNightFrom),
                TextButton(
                  onPressed: () async {
                    final m = await pick(night.from);
                    if (m != null) await setting.set(from: m);
                  },
                  child: Text(label(night.from)),
                ),
                const SizedBox(width: 16),
                Text(l10n.wallNightTo),
                TextButton(
                  onPressed: () async {
                    final m = await pick(night.to);
                    if (m != null) await setting.set(to: m);
                  },
                  child: Text(label(night.to)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
