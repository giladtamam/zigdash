import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/analytics/analytics.dart';
import 'pro_trial.dart'
    show proTrialOfferedProvider, proTrialProp, proTrialProvider;
import '../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;

/// ZigDash Pro (docs/design/history-2.7.md): a one-time purchase on Google
/// Play that unlocks depth features, starting with the 7- and 30-day
/// history views.
enum ProStatus {
  /// Everything is open: a build outside Play, or Pro was bought.
  unlocked,

  /// Pro can be bought and isn't yet (or a payment is still pending): Pro
  /// views show the locked sample.
  locked,

  /// Pro isn't offered here: not live yet, no Play on the device, or the
  /// product can't be found. Pro views are hidden entirely, so nobody is
  /// shown something they can't get.
  unavailable,
}

/// Which build this is: `foss` (GitHub, IzzyOnDroid, F-Droid: no billing,
/// everything unlocked), `play`, or `appstore` (docs/design/ios.md). Set by
/// tool/build_release.sh together with the flavor of the same name.
const proFlavor = String.fromEnvironment(
  'ZIGDASH_FLAVOR',
  defaultValue: 'foss',
);

/// Whether this build sells Pro through its store: Play or the App Store.
const proSold = proFlavor == 'play' || proFlavor == 'appstore';

/// Whether the Play build offers Pro yet (the payments profile and the
/// product exist). Until then Pro views are hidden in the Play build.
const proLive = bool.fromEnvironment('ZIGDASH_PRO_LIVE');

const _billing = MethodChannel('zigdash/billing');

ProStatus _parse(Object? s) => switch (s) {
  'unlocked' => ProStatus.unlocked,
  // "changed": the price shown is no longer the price Play would charge,
  // so nothing was launched (3.4.4).
  'locked' || 'pending' || 'changed' => ProStatus.locked,
  _ => ProStatus.unavailable,
};

/// "1"/"0": Play's last answer to "is Pro offered on this phone" (bought or
/// buyable). Play answers a moment after start; until it does, views that
/// only exist where Pro is sold use this instead of popping in (3.4.4).
const proOfferedKey = 'pro_offered';

/// "1" once Play said Pro is owned on this phone, removed when Play says it
/// isn't: a moment without Play (offline, the billing service restarting,
/// a fresh install before Play has synced) then can't hide what was bought.
const proOwnedKey = 'pro_owned';

/// "1" once this install sent `unlocked` (3.8.6): the event goes once per
/// install, on the first change to owned after an Unlock tap, whichever
/// answer from Play brings it.
const proUnlockSentKey = 'pro_unlock_sent';

/// The last Unlock tap, as JSON (3.8.6): kept so a purchase Play confirms
/// after the app restarted (pending, cash, carrier billing) is still
/// counted with that tap's values. Removed once sent, or after
/// [proUnlockTapTtl].
const proUnlockTapKey = 'pro_unlock_tap';
const proUnlockTapTtl = Duration(days: 3);

typedef _UnlockTap = ({
  ProFrom? from,
  bool sale,
  String? trial,
  DateTime? trialEnd,
  DateTime at,
});

/// Waits before asking Play again after it didn't answer.
const proRetryDelays = [
  Duration(seconds: 3),
  Duration(seconds: 10),
  Duration(seconds: 30),
];

/// Where the Pro screen was opened from, for the purchase events: set by
/// `openPro`, read when Unlock is tapped.
final proFromProvider = StateProvider<ProFrom?>((ref) => null);

/// True after a tap on the price found the sale gone: the Pro screen says
/// so, and shows the price Play charges now.
final proSaleEndedProvider = StateProvider<bool>((ref) => false);

/// Play's answer: asked at start, again whenever the app comes back while
/// Pro isn't unlocked, after a purchase, and from Restore purchase. When Play
/// doesn't answer, the last known answer stands and Play is asked again after
/// [proRetryDelays].
class ProBilling extends Notifier<ProStatus> {
  Timer? _retry;
  int _tries = 0;

  /// The last Unlock tap (3.8.6): what `unlocked` is sent with when Play
  /// confirms the purchase, at once, minutes later (a resume or a retry
  /// asking again) or after a restart ([proUnlockTapKey]).
  _UnlockTap? _tap;
  bool _unlockSent = false;

  SharedPreferences? get _prefs {
    try {
      return ref.read(sharedPreferencesProvider);
    } catch (_) {
      return null;
    }
  }

  void _saveTap(_UnlockTap tap) {
    _tap = tap;
    unawaited(
      _prefs
          ?.setString(
            proUnlockTapKey,
            jsonEncode({
              'from': tap.from?.name,
              'sale': tap.sale,
              'trial': tap.trial,
              'trialEnd': tap.trialEnd?.millisecondsSinceEpoch,
              'at': tap.at.millisecondsSinceEpoch,
            }),
          )
          .then((_) {}, onError: (_) {}),
    );
  }

  void _forgetTap() {
    _tap = null;
    unawaited(_prefs?.remove(proUnlockTapKey).then((_) {}, onError: (_) {}));
  }

  /// This session's tap, else the stored one; an expired or unreadable
  /// one is forgotten.
  _UnlockTap? _currentTap() {
    final now = DateTime.now();
    var tap = _tap;
    if (tap == null) {
      final raw = _prefs?.getString(proUnlockTapKey);
      if (raw == null) return null;
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final from = m['from'] as String?;
        final end = m['trialEnd'] as int?;
        tap = (
          from: from == null
              ? null
              : ProFrom.values.where((f) => f.name == from).firstOrNull,
          sale: m['sale'] == true,
          trial: m['trial'] as String?,
          trialEnd: end == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(end),
          at: DateTime.fromMillisecondsSinceEpoch(m['at'] as int),
        );
      } catch (_) {
        tap = null;
      }
    }
    if (tap == null || now.difference(tap.at) > proUnlockTapTtl) {
      _forgetTap();
      return null;
    }
    return tap;
  }

  @override
  ProStatus build() {
    AppLifecycleListener? life;
    try {
      life = AppLifecycleListener(
        onResume: () {
          if (state != ProStatus.unlocked) unawaited(refresh());
        },
      );
    } catch (_) {
      // No Flutter binding (plain unit tests): no resume to listen to.
    }
    ref.onDispose(() {
      _retry?.cancel();
      life?.dispose();
    });
    unawaited(Future.microtask(() => _ask('status')));
    // An Unlock tap from an earlier run that expired is forgotten (3.8.6).
    unawaited(Future.microtask(_currentTap));
    bool owned;
    try {
      owned = ref.read(sharedPreferencesProvider).getString(proOwnedKey) == '1';
    } catch (_) {
      owned = false;
    }
    return owned ? ProStatus.unlocked : ProStatus.unavailable;
  }

  /// Asks Play again now (Restore purchase, the app coming back) and returns
  /// its raw answer ("error" when it didn't answer; the status then stays).
  Future<String?> refresh() async {
    _retry?.cancel();
    _tries = 0;
    return _ask('status');
  }

  /// Play's raw answer, or null where there is no Play to ask. "error" (and
  /// a timeout or a channel error) leaves the status as it was and tries
  /// again later.
  Future<String?> _ask(String method, [Object? arguments]) async {
    String? answer;
    try {
      final call = _billing.invokeMethod<String>(method, arguments);
      // On the App Store build, buy and restore wait for Apple's own sheet
      // (Face ID, an Apple ID sign-in), which can take longer than 20 s.
      answer = proFlavor == 'appstore' && (method == 'buy' || method == 'restore')
          ? await call
          : await call.timeout(const Duration(seconds: 20));
    } on MissingPluginException {
      answer = 'unavailable';
    } on PlatformException {
      answer = 'error';
    } on TimeoutException {
      answer = 'error';
    }
    if (answer == 'error') {
      if (method == 'status' && _tries < proRetryDelays.length) {
        _retry?.cancel();
        _retry = Timer(
          proRetryDelays[_tries++],
          () => unawaited(_ask('status')),
        );
      }
      return answer;
    }
    if (method == 'status') _tries = 0;
    final was = state;
    state = _parse(answer);
    if (was != ProStatus.unlocked && state == ProStatus.unlocked) {
      _trackUnlocked();
    }
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(
        proOfferedKey,
        state == ProStatus.unavailable ? '0' : '1',
      );
      if (state == ProStatus.unlocked) {
        await prefs.setString(proOwnedKey, '1');
      } else if (answer == 'locked') {
        // Play says it isn't owned (a refund, another account): forget it.
        await prefs.remove(proOwnedKey);
      }
    } catch (_) {
      // Preferences are a convenience here; Play's answer stands without.
    }
    return answer;
  }

  /// Opens Play's purchase sheet for the price that is on the button; the
  /// status follows what Play says after. When that price is gone (a sale
  /// ended between showing and tapping) nothing opens: the price is asked
  /// again and the screen says the sale has ended, so nobody is charged
  /// more than they were shown.
  Future<void> buy() async {
    final analytics = ref.read(analyticsProvider);
    final from = ref.read(proFromProvider);
    final shown = ref.read(proOfferProvider).valueOrNull;
    final sale = shown?.onSale(DateTime.now()) ?? false;
    final trial = ref.read(proTrialProvider);
    final trialWire = proTrialProp(
      ref.read(proTrialOfferedProvider),
      trial,
      DateTime.now(),
    );
    analytics.track(
      ProEvent(ProStep.unlockTapped, from: from, sale: sale, trial: trialWire),
    );
    _saveTap((
      from: from,
      sale: sale,
      trial: trialWire,
      trialEnd: trial.end,
      at: DateTime.now(),
    ));
    final answer = await _ask('buy', {
      'offerId': shown?.offerId,
      'priceMicros': shown?.priceMicros,
    });
    if (answer == 'changed') {
      // The other way round (a sale began in between) only shows the new,
      // lower price: nothing to explain.
      if (sale) ref.read(proSaleEndedProvider.notifier).state = true;
      ref.invalidate(proOfferProvider);
      return;
    }
  }

  /// `unlocked`, once per install, when Pro turns owned after an Unlock tap
  /// (3.8.6). Until 3.8.5 it was sent only when Play had confirmed by the
  /// time buy() returned, and Play often confirms later. A purchase
  /// restored without a tap (start, reinstall) is never counted; a tap
  /// older than [proUnlockTapTtl] doesn't count either.
  void _trackUnlocked() {
    if (_unlockSent) return;
    final tap = _currentTap();
    if (tap == null) return;
    final prefs = _prefs;
    if (prefs?.getString(proUnlockSentKey) == '1') {
      _forgetTap();
      return;
    }
    _unlockSent = true;
    _forgetTap();
    unawaited(
      prefs?.setString(proUnlockSentKey, '1').then((_) {}, onError: (_) {}),
    );
    final analytics = ref.read(analyticsProvider);
    analytics.track(
      ProEvent(
        ProStep.unlocked,
        from: tap.from,
        sale: tap.sale,
        trial: tap.trial,
      ),
    );
    // 3.6: bought while the trial ran or within a week after it.
    final end = tap.trialEnd;
    if (end != null &&
        DateTime.now().isBefore(end.add(const Duration(days: 7)))) {
      analytics.track(const ProTrialEvent(ProTrialStep.kept));
    }
  }

  /// Asks the App Store again for a Pro bought on another device or before
  /// a reinstall; App Review requires the button.
  Future<String?> restore() => _ask('restore');
}

final proBillingProvider = NotifierProvider<ProBilling, ProStatus>(
  ProBilling.new,
);

/// This build's Pro status.
final proStatusProvider = Provider<ProStatus>((ref) {
  if (!proSold) return ProStatus.unlocked;
  if (!proLive) return ProStatus.unavailable;
  return ref.watch(proBillingProvider);
});

/// Starts buying Pro; null when this build can't (outside Play, before Pro
/// is live, or once it's bought), which disables Unlock.
final proPurchaseProvider = Provider<VoidCallback?>((ref) {
  if (!proSold || !proLive) return null;
  if (ref.watch(proStatusProvider) != ProStatus.locked) return null;
  return () => ref.read(proBillingProvider.notifier).buy();
});

/// The proof of an owned Pro for the ZigDash relay (3.1): Play's purchase
/// token, or the App Store's signed transaction; null without Pro.
/// Which store [proPurchaseToken] comes from, for the relay.
const proStore = proFlavor == 'appstore' ? 'apple' : 'play';

Future<String?> proPurchaseToken() async {
  if (!proSold) return null;
  try {
    final t = await _billing.invokeMethod<String>('token');
    return (t == null || t.isEmpty) ? null : t;
  } on PlatformException {
    return null;
  } on MissingPluginException {
    return null;
  }
}

/// What Play sells Pro for right now: the price, and during a sale the
/// full price, the percentage and when it ends (3.4.4). All of it is Play's
/// own answer for this user's country; nothing is computed from a fixed
/// price or a fixed date.
class ProOffer {
  const ProOffer({
    required this.price,
    this.priceMicros,
    this.fullPriceMicros,
    this.currency,
    this.percent,
    this.ends,
    this.offerId,
  });

  /// As Play formats it: "€4.79".
  final String price;
  final int? priceMicros;

  /// The price without the sale; null outside one.
  final int? fullPriceMicros;

  /// ISO 4217 code of both prices.
  final String? currency;

  /// Whole percent off; null outside a sale.
  final int? percent;

  /// When the sale ends; null when Play gives no end.
  final DateTime? ends;

  /// Play's id of the discount offer; null for the plain price.
  final String? offerId;

  /// Whether the sale line may be drawn at [now]: Play named a discount,
  /// and its end has not passed.
  bool onSale(DateTime now) =>
      fullPriceMicros != null &&
      percent != null &&
      percent! > 0 &&
      (ends == null || ends!.isAfter(now));

  /// The price without the sale, written for [locale]; null outside a sale
  /// or when the currency is unknown.
  String? fullPrice(String? locale) {
    final micros = fullPriceMicros;
    final code = currency;
    if (micros == null || code == null || code.isEmpty) return null;
    try {
      return NumberFormat.simpleCurrency(
        locale: locale,
        name: code,
      ).format(micros / 1000000);
    } catch (_) {
      return null;
    }
  }

  /// From the billing channel's answer; null when it carries no price.
  static ProOffer? fromChannel(Map<Object?, Object?>? m) {
    final price = m?['price'];
    if (m == null || price is! String || price.isEmpty) return null;
    final micros = (m['priceMicros'] as num?)?.toInt();
    final fullMicros = (m['fullPriceMicros'] as num?)?.toInt();
    final endMs = (m['endMs'] as num?)?.toInt();
    final sale = micros != null && fullMicros != null && fullMicros > micros;
    return ProOffer(
      price: price,
      priceMicros: micros,
      fullPriceMicros: sale ? fullMicros : null,
      currency: m['currency'] as String?,
      percent: sale
          ? (m['percent'] as num?)?.toInt() ??
                ((1 - micros / fullMicros) * 100).round()
          : null,
      ends: endMs == null || endMs <= 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(endMs),
      offerId: m['offerId'] as String?,
    );
  }
}

/// Play's current offer for Pro, or null where Pro can't be bought or Play
/// doesn't say. Asked again whenever a screen that shows it opens, and when
/// the app comes back to the front (the screens invalidate it), so a sale
/// line never outlives the sale.
final proOfferProvider = FutureProvider.autoDispose<ProOffer?>((ref) async {
  if (!proSold || !proLive) return null;
  try {
    final m = await _billing.invokeMethod<Map<Object?, Object?>>('offer');
    return ProOffer.fromChannel(m);
  } on PlatformException {
    return null;
  } on MissingPluginException {
    return null;
  }
});

/// Pro's price as Play formats it for this user ("€7.99"), or null where
/// Pro can't be bought or Play doesn't say (2.9.6).
final proPriceProvider = FutureProvider.autoDispose<String?>(
  (ref) async => (await ref.watch(proOfferProvider.future))?.price,
);

/// Whether Pro is offered on this phone, as far as is known: Play's answer
/// once it came, its last answer before that.
final proOfferedProvider = Provider<bool>((ref) {
  if (!proSold || !proLive) return false;
  if (ref.watch(proBillingProvider) != ProStatus.unavailable) return true;
  try {
    return ref.watch(sharedPreferencesProvider).getString(proOfferedKey) == '1';
  } catch (_) {
    return false;
  }
});
