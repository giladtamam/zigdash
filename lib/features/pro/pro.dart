import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics.dart';

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
  'locked' || 'pending' => ProStatus.locked,
  _ => ProStatus.unavailable,
};

/// Play's answer: asked once at start, and again after a purchase.
class ProBilling extends Notifier<ProStatus> {
  @override
  ProStatus build() {
    _ask('status');
    return ProStatus.unavailable;
  }

  Future<void> _ask(String method) async {
    try {
      state = _parse(await _billing.invokeMethod<String>(method));
    } on PlatformException {
      state = ProStatus.unavailable;
    } on MissingPluginException {
      state = ProStatus.unavailable;
    }
  }

  /// Opens Play's purchase sheet; the status follows what Play says after.
  Future<void> buy() async {
    final analytics = ref.read(analyticsProvider);
    analytics.track(const ProEvent(ProStep.unlockTapped));
    await _ask('buy');
    if (state == ProStatus.unlocked) {
      analytics.track(const ProEvent(ProStep.unlocked));
    }
  }

  /// Asks the App Store again for a Pro bought on another device or before
  /// a reinstall; App Review requires the button.
  Future<void> restore() => _ask('restore');
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

/// Pro's price as Play formats it for this user ("€7.99"), or null where
/// Pro can't be bought or Play doesn't say (2.9.6).
final proPriceProvider = FutureProvider<String?>((ref) async {
  if (!proSold || !proLive) return null;
  try {
    final price = await _billing.invokeMethod<String>('price');
    return (price == null || price.isEmpty) ? null : price;
  } on PlatformException {
    return null;
  } on MissingPluginException {
    return null;
  }
});
