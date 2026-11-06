import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/analytics/analytics.dart';
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
/// everything unlocked) or `play`. Set by tool/build_release.sh together
/// with the Android flavor of the same name.
const proFlavor = String.fromEnvironment(
  'ZIGDASH_FLAVOR',
  defaultValue: 'foss',
);

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

/// Where the Pro screen was opened from, for the purchase events: set by
/// `openPro`, read when Unlock is tapped.
final proFromProvider = StateProvider<ProFrom?>((ref) => null);

/// True after a tap on the price found the sale gone: the Pro screen says
/// so, and shows the price Play charges now.
final proSaleEndedProvider = StateProvider<bool>((ref) => false);

/// Play's answer: asked once at start, and again after a purchase.
class ProBilling extends Notifier<ProStatus> {
  @override
  ProStatus build() {
    _ask('status');
    return ProStatus.unavailable;
  }

  /// Play's raw answer, or null where there is no Play to ask.
  Future<String?> _ask(String method, [Object? arguments]) async {
    String? answer;
    try {
      answer = await _billing.invokeMethod<String>(method, arguments);
      state = _parse(answer);
    } on PlatformException {
      state = ProStatus.unavailable;
    } on MissingPluginException {
      state = ProStatus.unavailable;
    }
    try {
      await ref
          .read(sharedPreferencesProvider)
          .setString(proOfferedKey, state == ProStatus.unavailable ? '0' : '1');
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
    analytics.track(ProEvent(ProStep.unlockTapped, from: from, sale: sale));
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
    if (state == ProStatus.unlocked) {
      analytics.track(ProEvent(ProStep.unlocked, from: from, sale: sale));
    }
  }
}

final proBillingProvider = NotifierProvider<ProBilling, ProStatus>(
  ProBilling.new,
);

/// This build's Pro status.
final proStatusProvider = Provider<ProStatus>((ref) {
  if (proFlavor != 'play') return ProStatus.unlocked;
  if (!proLive) return ProStatus.unavailable;
  return ref.watch(proBillingProvider);
});

/// Starts buying Pro; null when this build can't (outside Play, before Pro
/// is live, or once it's bought), which disables Unlock.
final proPurchaseProvider = Provider<VoidCallback?>((ref) {
  if (proFlavor != 'play' || !proLive) return null;
  if (ref.watch(proStatusProvider) != ProStatus.locked) return null;
  return () => ref.read(proBillingProvider.notifier).buy();
});

/// The Play purchase token of an owned Pro, for the ZigDash relay (3.1);
/// null outside Play or without Pro.
Future<String?> proPurchaseToken() async {
  if (proFlavor != 'play') return null;
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
  if (proFlavor != 'play' || !proLive) return null;
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
  if (proFlavor != 'play' || !proLive) return false;
  if (ref.watch(proBillingProvider) != ProStatus.unavailable) return true;
  try {
    return ref.watch(sharedPreferencesProvider).getString(proOfferedKey) == '1';
  } catch (_) {
    return false;
  }
});
