import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'remote_home.dart';
import 'remote_setup.dart';

/// A founder's pass (docs/design/founders-pass.md): remote control and Chat
/// for one Home, 90 days from the day its code was entered, kept by the
/// relay. What this phone last heard about it, kept with the Home's remote
/// login. The code itself is never kept.
class FounderStatus {
  const FounderStatus({
    this.kind,
    this.expiresAt,
    this.ended = false,
    this.deleted = false,
    required this.fetchedAt,
  });

  /// "founder" for a pass; null for a Home bought with Pro.
  final String? kind;

  /// When the pass ends; null for a Pro Home.
  final DateTime? expiresAt;

  /// The relay said the pass has ended (or answered 402 `pass_ended`).
  final bool ended;

  /// The relay deleted the Home (410 `deleted`).
  final bool deleted;

  /// When the relay last said so.
  final DateTime fetchedAt;

  bool get founder => kind == 'founder';

  /// The pass is over at [now]: the relay said so, or its end has passed.
  bool endedAt(DateTime now) =>
      founder && (ended || deleted || (expiresAt != null && !now.isBefore(expiresAt!)));

  /// Remote control and Chat work through the pass at [now].
  bool activeAt(DateTime now) => founder && !deleted && !endedAt(now);

  /// The last 7 days of the pass: both screens show the date and Get Pro.
  bool endsSoonAt(DateTime now) =>
      activeAt(now) && expiresAt != null && expiresAt!.difference(now) <= const Duration(days: 7);

  FounderStatus copyWith({bool? ended, bool? deleted, DateTime? fetchedAt}) => FounderStatus(
        kind: kind,
        expiresAt: expiresAt,
        ended: ended ?? this.ended,
        deleted: deleted ?? this.deleted,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );

  /// From `GET /v1/homes/<id>`: `{kind, expires_at, ended}`, or the
  /// founder answer of `POST /v1/homes`.
  static FounderStatus fromRelay(Map<String, Object?> j, DateTime now) {
    final ms = j['expires_at'];
    return FounderStatus(
      kind: j['kind'] == 'founder' ? 'founder' : null,
      expiresAt: ms is num ? DateTime.fromMillisecondsSinceEpoch(ms.toInt()) : null,
      ended: j['ended'] == true,
      fetchedAt: now,
    );
  }

  Map<String, Object?> toJson() => {
        'kind': kind,
        'expires_at': expiresAt?.millisecondsSinceEpoch,
        'ended': ended,
        'deleted': deleted,
        'fetched_at': fetchedAt.millisecondsSinceEpoch,
      };

  static FounderStatus? fromJson(Object? j) {
    if (j is! Map) return null;
    final fetched = j['fetched_at'];
    if (fetched is! num) return null;
    final ms = j['expires_at'];
    return FounderStatus(
      kind: j['kind'] == 'founder' ? 'founder' : null,
      expiresAt: ms is num ? DateTime.fromMillisecondsSinceEpoch(ms.toInt()) : null,
      ended: j['ended'] == true,
      deleted: j['deleted'] == true,
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(fetched.toInt()),
    );
  }
}

/// A founder's code as the relay hashes it: upper case, spaces and dashes
/// gone, I and L read as 1, O as 0 (Crockford base32).
String normaliseFounderCode(String code) => code
    .toUpperCase()
    .replaceAll(RegExp(r'[\s\-‐-―]'), '')
    .replaceAll(RegExp('[IL]'), '1')
    .replaceAll('O', '0');

const _nonceChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-';

/// A random `redeem_nonce` (24 characters of `[A-Za-z0-9_-]`).
String newRedeemNonce([Random? random]) {
  final r = random ?? Random.secure();
  return String.fromCharCodes([for (var i = 0; i < 24; i++) _nonceChars.codeUnitAt(r.nextInt(_nonceChars.length))]);
}

/// The clock the pass is read against; replaced in tests.
final founderNowProvider = Provider<DateTime Function()>((_) => DateTime.now);

/// How long a status from the relay stands before it is asked again.
const founderStatusFor = Duration(days: 1);

/// The founder status of [connectionId]'s Home: the cached one, asked of the
/// relay again when it is over a day old. Null without a remote login.
final founderStatusProvider = FutureProvider.autoDispose.family<FounderStatus?, String>((ref, connectionId) async {
  final login = await ref.watch(remoteHomeProvider(connectionId).future);
  if (login == null) return null;
  FounderStatus? cached;
  try {
    cached = await ref.watch(remoteHomeStoreProvider).readFounder(connectionId);
  } catch (_) {}
  final now = ref.read(founderNowProvider)();
  if (cached != null && now.difference(cached.fetchedAt) < founderStatusFor) return cached;
  try {
    return await ref.read(remoteSetupProvider).founderStatus(connectionId) ?? cached;
  } catch (_) {
    return cached;
  }
});

/// Asks the relay for the status now (the Remote and Chat screens do on
/// opening), then shows what it said. Replaced in tests.
final founderRefreshProvider = Provider<Future<void> Function(String connectionId)>((ref) => (id) async {
      try {
        if (await ref.read(remoteHomeStoreProvider).read(id) == null) return;
        await ref.read(remoteSetupProvider).founderStatus(id);
      } catch (_) {
        return;
      }
      ref.invalidate(founderStatusProvider(id));
    });

/// Whether remote control is offered for [connectionId]: where Pro is sold,
/// and for a founder's Home even where Play billing isn't available.
final remoteSoldForProvider = Provider.autoDispose.family<bool, String>((ref, connectionId) =>
    ref.watch(remoteSoldProvider) || (ref.watch(founderStatusProvider(connectionId)).valueOrNull?.founder ?? false));

/// "Get Pro" was tapped on a founder line for this Home: when that purchase
/// succeeds, the Home moves to it (`/upgrade`). Kept until the relay
/// answers, so a lost connection is retried later; nothing else upgrades
/// without the person's yes.
String founderUpgradeKey(String connectionId) => 'founder_upgrade::$connectionId';

/// Moves a founder's Home to this phone's Pro purchase, only when asked:
/// retried on network errors only, and stopped by any answer from the relay.
class FounderUpgrader {
  FounderUpgrader(this._setup, this._prefs, {Duration Function(int attempt)? delay})
      : _delay = delay ?? ((n) => Duration(seconds: 2 << n));

  final RemoteSetup _setup;
  final SharedPreferences _prefs;
  final Duration Function(int attempt) _delay;

  static const attempts = 3;

  bool wanted(String connectionId) => _prefs.getBool(founderUpgradeKey(connectionId)) ?? false;

  Future<void> remember(String connectionId) => _prefs.setBool(founderUpgradeKey(connectionId), true);

  Future<void> forget(String connectionId) => _prefs.remove(founderUpgradeKey(connectionId));

  Future<FounderUpgradeResult> run(String connectionId) async {
    var r = FounderUpgradeResult.unreachable;
    for (var i = 0; i < attempts; i++) {
      if (i > 0) await Future<void>.delayed(_delay(i - 1));
      r = await _setup.upgrade(connectionId);
      if (r != FounderUpgradeResult.unreachable) break;
    }
    // Asked for, and the relay answered: done or refused, never again by
    // itself. Unreachable: the next visit tries again.
    if (r != FounderUpgradeResult.unreachable) await forget(connectionId);
    return r;
  }
}

final founderUpgraderProvider = Provider<FounderUpgrader>(
    (ref) => FounderUpgrader(ref.watch(remoteSetupProvider), ref.watch(sharedPreferencesProvider)));

/// The founder status, kept with the Home's remote login.
extension FounderStore on RemoteHomeStore {
  Future<FounderStatus?> readFounder(String connectionId) async =>
      FounderStatus.fromJson(await readFounderJson(connectionId));

  Future<void> writeFounder(String connectionId, FounderStatus status) =>
      writeFounderJson(connectionId, status.toJson());
}
