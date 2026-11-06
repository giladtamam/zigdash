import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../engine/engine_setup.dart';
import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/review/review_prompt_controller.dart';
import '../../core/theme/signal_colors.dart';
import '../../l10n/app_localizations.dart';
import '../panels/providers/panel_value_provider.dart';
import '../panels/widgets/device_tile_panel.dart' show formatReading;
import '../kiosk/kiosk.dart';
import '../pro/pro.dart';
import '../pro/pro_screen.dart';
import 'history_chart.dart';
import 'history_config.dart' show decodeHistoryReadings;
import 'app_history_recorder.dart';
import 'history_record.dart';
import 'history_service.dart';

/// Opens a reading's history (docs/design/history-2.7.md): [ieee] and
/// [path] name the reading, [title] is shown on top.
Future<void> showHistorySheet(
  BuildContext context, {
  required String connectionId,
  required String ieee,
  required String path,
  required String title,
  String? unit,
  String? topic,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => HistorySheet(
    connectionId: connectionId,
    ieee: ieee,
    path: path,
    title: title,
    unit: unit,
    topic: topic,
  ),
);

class HistorySheet extends ConsumerStatefulWidget {
  const HistorySheet({
    super.key,
    required this.connectionId,
    required this.ieee,
    required this.path,
    required this.title,
    this.unit,
    this.topic,
    this.now,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 24),
  });

  /// Around the content: the sheet's margins, or none inside a card.
  final EdgeInsetsGeometry padding;

  final String connectionId;
  final String ieee;
  final String path;
  final String title;
  final String? unit;

  /// The device's state topic: the big number is its live value, like the
  /// tile's (decision 9). Without it, the newest recorded point.
  final String? topic;

  /// The clock, for tests.
  final DateTime Function()? now;

  @override
  ConsumerState<HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends ConsumerState<HistorySheet> {
  HistoryRange _range = HistoryRange.day;
  HistoryPoint? _scrub;
  bool _busy = false;
  bool _lockedSeen = false;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).track(const FeatureUsed(Feature.history));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final signal = theme.extension<SignalColors>();
    final active = signal?.active ?? theme.colorScheme.primary;
    // On the light ground Signal's amber is a fill colour, too pale for a
    // 2-pixel line: darken it toward the ink. Dark mode keeps it as is.
    final accent = theme.brightness == Brightness.light
        ? Color.lerp(active, theme.colorScheme.onSurface, 0.45)!
        : active;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = (widget.now ?? DateTime.now)();
    final pro = ref.watch(proStatusProvider);
    final ranges = [
      for (final r in HistoryRange.values)
        if (!r.isPro || pro != ProStatus.unavailable) r,
    ];
    final range = ranges.contains(_range) ? _range : HistoryRange.day;
    final locked = range.isPro && pro == ProStatus.locked;
    if (locked && !_lockedSeen) {
      _lockedSeen = true;
      ref.read(analyticsProvider).track(const ProEvent(ProStep.lockedShown));
    }
    final online = ref
        .watch(historyRecorderOnlineProvider(widget.connectionId))
        .valueOrNull;
    final days = locked
        ? const <String, List<HistoryPoint>>{}
        : ref
                  .watch(
                    historyDaysProvider((
                      connectionId: widget.connectionId,
                      ieee: widget.ieee,
                      attr: historyAttr(widget.path),
                      range: range,
                    )),
                  )
                  .valueOrNull ??
              const {};
    final series = historySeries(range, now, days);
    final from = now.subtract(range.span);
    final step = switch (range) {
      HistoryRange.day => const Duration(minutes: historySlotMinutes),
      HistoryRange.week => const Duration(hours: 1),
      HistoryRange.month => const Duration(days: 1),
    };
    String value(double v) => formatReading(v, widget.unit);
    String axisTime(DateTime t) => switch (range) {
      HistoryRange.day => DateFormat.Hm(locale).format(t),
      HistoryRange.week => DateFormat.E(locale).format(t),
      HistoryRange.month => DateFormat.MMMd(locale).format(t),
    };
    String scrubTime(DateTime t) => switch (range) {
      HistoryRange.day => DateFormat.Hm(locale).format(t),
      HistoryRange.week => DateFormat.MEd(locale).add_Hm().format(t),
      HistoryRange.month => DateFormat.MMMEd(locale).format(t),
    };
    final topic = widget.topic;
    final live = topic == null
        ? null
        : ref
              .watch(
                panelValueProvider(
                  PanelStreamKey(
                    connectionId: widget.connectionId,
                    topic: topic,
                    jsonPath: widget.path,
                  ),
                ),
              )
              .valueOrNull;
    final liveValue = live is num ? live.toDouble() : double.tryParse('$live');
    final double? shownValue =
        _scrub?.avg ?? liveValue ?? (series.isEmpty ? null : series.last.avg);

    final Widget body;
    if (locked) {
      body = _LockedSample(accent: accent, label: theme.textTheme.labelSmall!);
    } else if (series.isEmpty) {
      // A running recorder that doesn't have this reading on its list will
      // never fill the graph: say why instead of "no values yet".
      final recorded = decodeHistoryReadings(
        ref
                .watch(historyRetainedConfigProvider(widget.connectionId))
                .valueOrNull ??
            '',
      ).any((r) => r.ieee == widget.ieee && r.attr == historyAttr(widget.path));
      // A config on the broker but no heartbeat: installed, never
      // connected. Most often a broker login Node-RED doesn't have yet.
      final installed =
          (ref
                      .watch(historyRetainedConfigProvider(widget.connectionId))
                      .valueOrNull ??
                  '')
              .isNotEmpty;
      body = online != true
          ? _SetupCard(
              busy: _busy,
              notConnected: installed,
              onSetUp: () => _install(l10n),
              onRecordHere: () => _recordHere(l10n),
            )
          : _Note(text: recorded ? l10n.historyEmpty : l10n.historyNotRecorded);
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 220,
            child: HistoryChart(
              points: series,
              from: from,
              to: now,
              step: step,
              color: accent,
              gridColor: theme.colorScheme.outlineVariant,
              labelStyle: theme.textTheme.labelSmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              formatValue: value,
              formatTime: axisTime,
              onScrub: (p) => setState(() => _scrub = p),
            ),
          ),
          if (series.first.at.isAfter(from.add(step * 2))) ...[
            const SizedBox(height: 8),
            Text(
              l10n.historyRecordingSince(
                DateFormat.MMMd(locale).add_Hm().format(series.first.at),
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (online == false) ...[
            const SizedBox(height: 8),
            _Note(text: l10n.historyRecorderOffline),
          ],
        ],
      );
    }

    return SingleChildScrollView(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            shownValue == null ? '–' : value(shownValue),
            style: theme.textTheme.displaySmall,
          ),
          // The time under the finger while scrubbing; the line keeps its
          // height so the graph doesn't jump.
          SizedBox(
            height: 20,
            child: _scrub == null
                ? null
                : Text(
                    scrubTime(_scrub!.at),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          if (ranges.length > 1) ...[
            SegmentedButton<HistoryRange>(
              segments: [
                for (final r in ranges)
                  ButtonSegment(
                    value: r,
                    label: Text(switch (r) {
                      HistoryRange.day => l10n.historyRangeDay,
                      HistoryRange.week => l10n.historyRangeWeek,
                      HistoryRange.month => l10n.historyRangeMonth,
                    }),
                  ),
              ],
              selected: {range},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() {
                _range = s.first;
                _scrub = null;
              }),
            ),
            const SizedBox(height: 16),
          ],
          body,
        ],
      ),
    );
  }

  /// The recorder runs in the ZigDash Engine on the hub (zigdash-3.0.md §4):
  /// inside Zigbee2MQTT, so no Node-RED and no broker password.
  Future<void> _install(AppLocalizations l10n) async {
    final service = ref.read(historyServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final r = await ensureEngine(context, ref, widget.connectionId, from: EngineFrom.history);
      if (!mounted) return;
      switch (r) {
        case EngineSetup.ready:
          _track(HistorySetupResult.installed);
          await service.publishConfig(widget.connectionId);
          messenger.showSnackBar(SnackBar(content: Text(l10n.historyInstalled)));
          // A happy moment (2.8.1): the review policy still decides.
          await ref.read(reviewPromptControllerProvider).recordSuccessfulSession();
        case EngineSetup.needsUser:
          break;
        case EngineSetup.failed:
          _track(HistorySetupResult.failed);
          final here = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              content: Text('${l10n.alertsHubFailed}\n\n${l10n.historyRecordHereHint}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.historyRecordHere),
                ),
              ],
            ),
          );
          if (here == true) await _recordHere(l10n);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// No Node-RED (2.9.1): this device records while ZigDash is open.
  Future<void> _recordHere(AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(historyRecordHereProvider(widget.connectionId).notifier)
        .set(true);
    _track(HistorySetupResult.thisDevice);
    messenger.showSnackBar(SnackBar(content: Text(l10n.historyRecordingHere)));
  }

  void _track(HistorySetupResult r) =>
      ref.read(analyticsProvider).track(HistorySetup(r));

}

/// No recorder yet: what it is, and the one-tap install.
class _SetupCard extends StatelessWidget {
  const _SetupCard({
    required this.busy,
    required this.onSetUp,
    required this.onRecordHere,
    this.notConnected = false,
  });

  final bool busy;

  /// The recorder was installed but never came online.
  final bool notConnected;
  final VoidCallback onSetUp;

  /// No Node-RED: record on this device instead (2.9.1).
  final VoidCallback onRecordHere;

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
            Text(l10n.historySetupTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              notConnected ? l10n.historyNotConnected : l10n.historySetupBody,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.historyPersistence,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: busy ? null : onSetUp,
              icon: busy
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.timeline),
              label: Text(l10n.historySetupAction),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.historyRecordHereHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton.icon(
              onPressed: busy ? null : onRecordHere,
              icon: const Icon(Icons.tablet_android_outlined),
              label: Text(l10n.historyRecordHere),
            ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

/// A Pro view before Pro is bought (decision 8): a blurred made-up graph,
/// never the user's data, one line and Unlock.
class _LockedSample extends StatelessWidget {
  const _LockedSample({required this.accent, required this.label});

  final Color accent;
  final TextStyle label;

  static final _start = DateTime(2026);
  static final _sample = [
    for (var i = 0; i < 7 * 24; i++)
      () {
        final v = 21 + 2.5 * math.sin(i / 24 * 2 * math.pi) + (i % 5) * 0.1;
        return HistoryPoint(
          _start.add(Duration(hours: i)),
          v,
          v - 0.8,
          v + 0.8,
        );
      }(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 220,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: IgnorePointer(
              child: HistoryChart(
                points: _sample,
                from: _start,
                to: _start.add(const Duration(days: 7)),
                step: const Duration(hours: 1),
                color: accent,
                gridColor: theme.colorScheme.outlineVariant,
                labelStyle: label,
                formatValue: (v) => '',
                formatTime: (t) => '',
              ),
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.historyLocked,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                const _UnlockButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Buys Pro. Wired to Play Billing in the Play build (pro_billing.dart).
class _UnlockButton extends ConsumerWidget {
  const _UnlockButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kiosk guests (a child at the wall tablet) never reach Play's
    // purchase sheet: the sample stays, Unlock goes.
    if (ref.watch(kioskProvider).on) return const SizedBox.shrink();
    final buy = ref.watch(proPurchaseProvider);
    return FilledButton(
      onPressed: buy == null
          ? null
          : () => openPro(context, from: ProFrom.history),
      child: Text(context.l10n.historyUnlock),
    );
  }
}
