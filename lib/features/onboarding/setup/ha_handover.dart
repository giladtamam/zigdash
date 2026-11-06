import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/router/routes.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../mqtt/ha_address.dart';
import '../../../shortcuts/shortcut_service.dart' show appChannel;
import '../demo_service.dart' show demoHost;

/// Whether ZigDash is offered in other apps' share sheets as the place to
/// send a Home Assistant address (docs/design/ha-share-paste.md): on
/// Android, and only until a real home exists. A share target is a row in
/// every share sheet on the phone; someone already connected has no use
/// for it, and adds a second home with Paste.
final haShareTargetProvider = StreamProvider<bool>((ref) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return Stream.value(false);
  }
  return ref
      .watch(connectionRepoProvider)
      .watchAll()
      .map((homes) => homes.every((home) => home.host == demoHost))
      .distinct();
});

/// Turns the share target on or off in Android's own list of them.
Future<void> syncShareTarget(bool on) async {
  try {
    await appChannel.invokeMethod<void>('setShareTarget', {'enabled': on});
  } on MissingPluginException {
    // Not Android.
  } on PlatformException {
    // The phone refused; the target stays as it was.
  }
}

/// Text another app shared to ZigDash: the Home Assistant app's "Share
/// server" link, or a page shared from a browser. Opens the Home Assistant
/// sign-in with the address it held, or with none and a line saying so.
/// Counted as found or not; never the text.
void openSharedHaText(GoRouter router, Analytics analytics, String text) {
  final address = haAddressIn(text);
  analytics.track(
    SetupStep(
      SetupStepKind.haShare,
      result: address == null ? HaHandover.noAddress : HaHandover.address,
    ),
  );
  router.push(Routes.haConnectShared(address));
}
