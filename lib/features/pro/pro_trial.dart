import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/analytics/analytics.dart';
import '../../data/database/tables/connections.dart';
import 'pro.dart';

/// The 14-day Pro trial (3.6, docs/design/pro-trial-360.md §3): Google Play
/// build only, started when History first records after this install's own
/// "Turn on History", or offered to a Home that already records. It lives
/// in its own file, kept out of Android backup, so a reinstall or a new
/// phone starts fresh.

const proTrialLength = Duration(days: 14);

/// The day-12 card: this long before the end.
const proTrialEndingNotice = Duration(days: 2);

/// Whether this build offers the trial: Play with Pro on sale. Not the
/// foss builds (Pro is unlocked there) and not iOS (Apple needs its own
/// free purchase for a time-limited trial).
bool proTrialOfferedFor(String flavor, {required bool live}) =>
    flavor == 'play' && live;

final proTrialOfferedProvider = Provider<bool>(
  (_) => proTrialOfferedFor(proFlavor, live: proLive),
);

/// Where a trial began: right after setup, from the History card later, a
/// History sheet, or the offer to a Home that already recorded.
enum ProTrialFrom { finish, card, sheet, offer }

/// What the person used during the trial, each counted once.
enum ProTrialUse { history, wall, automation }

class ProTrial {
  const ProTrial({
    this.loaded = false,
    this.start,
    this.seenMax,
    this.pendingFrom,
    this.offerAnswered = false,
    this.startNoticeSeen = false,
    this.endingDismissed = false,
    this.endedSent = false,
    this.used = const {},
  });

  /// False until the file was read: nothing is open or offered before.
  final bool loaded;
  final DateTime? start;

  /// The latest clock time seen: setting the clock back can't extend it.
  final DateTime? seenMax;

  /// This install turned History on (and from where): the trial starts
  /// when a recorder first reports online.
  final ProTrialFrom? pendingFrom;
  final bool offerAnswered;
  final bool startNoticeSeen;
  final bool endingDismissed;
  final bool endedSent;
  final Set<ProTrialUse> used;

  DateTime? get end => start?.add(proTrialLength);

  /// Running at [now]: started, not before its start, and no clock time
  /// seen since (including [now]) is past its end.
  bool runningAt(DateTime now) {
    final s = start;
    if (s == null || now.isBefore(s)) return false;
    final latest = seenMax != null && seenMax!.isAfter(now) ? seenMax! : now;
    return latest.difference(s) < proTrialLength;
  }

  bool endedAt(DateTime now) => start != null && !runningAt(now);

  ProTrial copyWith({
    DateTime? start,
    DateTime? seenMax,
    ProTrialFrom? pendingFrom,
    bool? offerAnswered,
    bool? startNoticeSeen,
    bool? endingDismissed,
    bool? endedSent,
    Set<ProTrialUse>? used,
  }) => ProTrial(
    loaded: true,
    start: start ?? this.start,
    seenMax: seenMax ?? this.seenMax,
    pendingFrom: pendingFrom ?? this.pendingFrom,
    offerAnswered: offerAnswered ?? this.offerAnswered,
    startNoticeSeen: startNoticeSeen ?? this.startNoticeSeen,
    endingDismissed: endingDismissed ?? this.endingDismissed,
    endedSent: endedSent ?? this.endedSent,
    used: used ?? this.used,
  );

  String toJson() => jsonEncode({
    if (start != null) 'start': start!.millisecondsSinceEpoch,
    if (seenMax != null) 'seen_max': seenMax!.millisecondsSinceEpoch,
    if (pendingFrom != null) 'pending': pendingFrom!.name,
    'offer_answered': offerAnswered,
    'notice_seen': startNoticeSeen,
    'ending_dismissed': endingDismissed,
    'ended_sent': endedSent,
    'used': [for (final u in used) u.name],
  });

  static ProTrial fromJson(String? raw) {
    if (raw == null || raw.isEmpty) return const ProTrial(loaded: true);
    try {
      final j = jsonDecode(raw) as Map<String, Object?>;
      DateTime? at(String k) =>
          j[k] is int ? DateTime.fromMillisecondsSinceEpoch(j[k] as int) : null;
      return ProTrial(
        loaded: true,
        start: at('start'),
        seenMax: at('seen_max'),
        pendingFrom: ProTrialFrom.values
            .where((f) => f.name == j['pending'])
            .firstOrNull,
        offerAnswered: j['offer_answered'] == true,
        startNoticeSeen: j['notice_seen'] == true,
        endingDismissed: j['ending_dismissed'] == true,
        endedSent: j['ended_sent'] == true,
        used: {
          for (final u in (j['used'] as List? ?? const []))
            ...ProTrialUse.values.where((v) => v.name == u),
        },
      );
    } catch (_) {
      return const ProTrial(loaded: true);
    }
  }
}

/// Reads and writes the trial file; tests replace it.
class ProTrialStore {
  const ProTrialStore({required this.read, required this.write});
  final Future<String?> Function() read;
  final Future<void> Function(String contents) write;
}

const proTrialFileName = 'pro_trial.json';

Future<File> _file() async => File(
  p.join((await getApplicationDocumentsDirectory()).path, proTrialFileName),
);

final proTrialStoreProvider = Provider<ProTrialStore>(
  (_) => ProTrialStore(
    read: () async {
      try {
        final f = await _file();
        return await f.exists() ? await f.readAsString() : null;
      } catch (_) {
        return null;
      }
    },
    write: (contents) async {
      try {
        await (await _file()).writeAsString(contents);
      } catch (_) {}
    },
  ),
);

/// The clock; tests replace it.
final proTrialNowProvider = Provider<DateTime Function()>((_) => DateTime.now);

/// The install's first-open week, for the read's cohorts (ISO year-week).
final proTrialInstallWeekProvider = FutureProvider<String?>((_) async {
  try {
    final t = (await PackageInfo.fromPlatform()).installTime;
    return t == null ? null : isoWeek(t);
  } catch (_) {
    return null;
  }
});

String isoWeek(DateTime d) {
  final day = DateTime.utc(d.year, d.month, d.day);
  final thursday = day.add(Duration(days: 4 - day.weekday));
  final first = DateTime.utc(thursday.year);
  final week = thursday.difference(first).inDays ~/ 7 + 1;
  return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
}

/// The platform name used in `pro_trial` events.
String trialHubOf(ConnectionTransport? t) => switch (transportOf(t)) {
  ConnectionTransport.mqtt => 'zigbee2mqtt',
  ConnectionTransport.homeAssistant => 'home_assistant',
  ConnectionTransport.z2mPage => 'z2m_page',
};

class ProTrialController extends Notifier<ProTrial> {
  Timer? _end;
  bool _disposed = false;

  DateTime get _now => ref.read(proTrialNowProvider)();

  @override
  ProTrial build() {
    ref.onDispose(() {
      _disposed = true;
      _end?.cancel();
    });
    _load();
    return const ProTrial();
  }

  Future<void> _load() async {
    final raw = await ref.read(proTrialStoreProvider).read();
    if (_disposed) return;
    state = ProTrial.fromJson(raw);
    noteSeen();
    _arm();
  }

  bool get _offered => ref.read(proTrialOfferedProvider);

  bool get _bought => ref.read(proStatusProvider) == ProStatus.unlocked;

  Future<void> _save(ProTrial next) async {
    state = next;
    _arm();
    await ref.read(proTrialStoreProvider).write(next.toJson());
  }

  /// Keeps the latest clock time (at most once a minute, and never while a
  /// provider is building: the write waits for a microtask).
  void noteSeen() {
    final now = _now;
    final max = state.seenMax;
    if (state.start == null) return;
    if (max != null && now.difference(max) < const Duration(minutes: 1)) {
      return;
    }
    Future.microtask(() {
      if (_disposed) return;
      final latest = state.seenMax;
      if (latest == null || now.isAfter(latest)) {
        _save(state.copyWith(seenMax: now));
      }
    });
  }

  /// A timer to the end, so open views lock without a restart.
  void _arm() {
    _end?.cancel();
    final end = state.end;
    if (end == null) return;
    final left = end.difference(_now);
    if (left.isNegative) return;
    _end = Timer(left + const Duration(seconds: 1), () {
      state = state.copyWith();
    });
  }

  bool runningNow() {
    if (!state.loaded) return false;
    noteSeen();
    return state.runningAt(_now);
  }

  /// "Turn on History" here or on a History sheet: remember it, so the
  /// trial starts when a recorder first reports online.
  Future<void> markOwnAction(ProTrialFrom from) async {
    if (!_offered || state.start != null || state.pendingFrom != null) return;
    await _save(state.copyWith(pendingFrom: from));
  }

  /// A recorder reported online for a Home: start the trial if this
  /// install turned History on itself.
  Future<void> recorderOnline(ConnectionTransport? transport) async {
    if (!_offered || !state.loaded || state.start != null || _bought) return;
    final from = state.pendingFrom;
    if (from == null) return;
    await _start(from, transport);
  }

  /// The offer card's Start, for a Home that already recorded.
  Future<void> startFromOffer(ConnectionTransport? transport) async {
    if (!_offered || state.start != null || _bought) return;
    await _start(ProTrialFrom.offer, transport, answered: true);
  }

  Future<void> declineOffer() async {
    ref
        .read(analyticsProvider)
        .track(const ProTrialEvent(ProTrialStep.declined));
    await _save(state.copyWith(offerAnswered: true));
  }

  Future<void> _start(
    ProTrialFrom from,
    ConnectionTransport? transport, {
    bool answered = false,
  }) async {
    final now = _now;
    await _save(
      state.copyWith(
        start: now,
        seenMax: now,
        offerAnswered: answered ? true : null,
      ),
    );
    final week = await ref.read(proTrialInstallWeekProvider.future);
    ref
        .read(analyticsProvider)
        .track(
          ProTrialEvent(
            ProTrialStep.started,
            from: from.name,
            hub: trialHubOf(transport),
            week: week,
          ),
        );
  }

  /// Counted once per feature, only while the trial runs and only when it
  /// showed something (a History view with data, a wall extra on, a
  /// fourth automation made).
  Future<void> used(ProTrialUse what) async {
    if (!runningNow() || state.used.contains(what) || _bought) return;
    ref
        .read(analyticsProvider)
        .track(ProTrialEvent(ProTrialStep.used, what: what.name));
    await _save(state.copyWith(used: {...state.used, what}));
  }

  Future<void> noticeSeen() => _save(state.copyWith(startNoticeSeen: true));

  Future<void> endingShown() async {
    ref
        .read(analyticsProvider)
        .track(const ProTrialEvent(ProTrialStep.endingShown));
  }

  Future<void> dismissEnding() => _save(state.copyWith(endingDismissed: true));

  /// Once, the first launch after the end.
  Future<void> endedIfDue() async {
    if (state.endedSent || !state.endedAt(_now)) return;
    ref.read(analyticsProvider).track(const ProTrialEvent(ProTrialStep.ended));
    await _save(state.copyWith(endedSent: true));
  }
}

final proTrialProvider = NotifierProvider<ProTrialController, ProTrial>(
  ProTrialController.new,
);

/// The trial as `pro` events report it.
String proTrialWire(ProTrial t, DateTime now) => t.start == null
    ? 'none'
    : t.runningAt(now)
    ? 'running'
    : 'ended';

/// The `trial` property for `pro` events: only in a build that offers it.
String? proTrialProp(bool offered, ProTrial t, DateTime now) =>
    offered ? proTrialWire(t, now) : null;

/// Pro features are open: bought, or the trial runs (Play build only).
final proAccessProvider = Provider<bool>(
  dependencies: [
    proStatusProvider,
    proTrialOfferedProvider,
    proTrialProvider,
    proTrialNowProvider,
  ],
  (ref) {
    if (ref.watch(proStatusProvider) == ProStatus.unlocked) return true;
    if (!ref.watch(proTrialOfferedProvider)) return false;
    final trial = ref.watch(proTrialProvider);
    if (!trial.loaded) return false;
    final running = trial.runningAt(ref.read(proTrialNowProvider)());
    if (running) ref.read(proTrialProvider.notifier).noteSeen();
    return running;
  },
);

/// Pro rows are shown at all: open, or Pro can be bought here.
final proVisibleProvider = Provider<bool>(
  dependencies: [proAccessProvider, proStatusProvider],
  (ref) =>
      ref.watch(proAccessProvider) ||
      ref.watch(proStatusProvider) != ProStatus.unavailable,
);

/// A "get Pro" note belongs here: not open, and Pro is for sale.
final proLockedProvider = Provider<bool>(
  dependencies: [proAccessProvider, proStatusProvider],
  (ref) =>
      !ref.watch(proAccessProvider) &&
      ref.watch(proStatusProvider) == ProStatus.locked,
);
