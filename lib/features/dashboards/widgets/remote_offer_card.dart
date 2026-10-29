import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/review/review_prompt_controller.dart';
import '../../../core/router/routes.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../mqtt/endpoint.dart';
import '../../../mqtt/mqtt_status.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../../../remote/remote_setup.dart';
import '../../ha_import/ha_import_offer.dart';
import '../../onboarding/demo_service.dart' show isDemoConnection;
import '../../pro/pro.dart';
import '../../pro/pro_screen.dart';
import '../../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;

/// "1" once the remote control offer was opened or put away: asked once.
const remoteOfferDoneKey = 'remote_offer_done';

/// "1" once the offer was counted as shown.
const remoteOfferShownKey = 'remote_offer_shown';

/// Days on a connected dashboard before remote control is offered.
const remoteOfferAfterDays = 5;

/// Whether this build sells Pro, and so remote control: the Play build
/// once Play answered.
final remoteSoldProvider = Provider.autoDispose<bool>(
  (ref) =>
      proFlavor == 'play' &&
      ref.watch(proStatusProvider) != ProStatus.unavailable,
);

/// Whether this phone is at [connectionId]'s home right now: connected
/// straight to the broker on the home network, where remote control can be
/// turned on (not through the relay, nor the home's own remote address).
final atHomeProvider = Provider.autoDispose.family<bool, String>((
  ref,
  connectionId,
) {
  final status = ref.watch(connectionStatusProvider(connectionId)).valueOrNull;
  final mgr = ref.watch(mqttManagerProvider(connectionId)).valueOrNull;
  return status == MqttStatus.connected &&
      mgr?.activeEndpoint == MqttEndpoint.local;
});

/// Whether the remote control offer shows on [connectionId]'s dashboard
/// (3.1.11): once, after [remoteOfferAfterDays] days, where Pro is sold,
/// on a real home without remote control, and only at home, where it can
/// be turned on. The usage-data question and the Home Assistant import
/// come first; "What made you try ZigDash?" is long gone by day five (it
/// stops on day three, answered or not); the poll waits for it.
final remoteOfferProvider = Provider.autoDispose.family<bool, String>((
  ref,
  connectionId,
) {
  if (!ref.watch(remoteSoldProvider)) return false;
  final prefs = ref.watch(sharedPreferencesProvider);
  if (prefs.getString(remoteOfferDoneKey) != null) return false;
  final days = prefs.getInt(ReviewPromptController.kSessions) ?? 0;
  if (days < remoteOfferAfterDays) return false;
  final host = ref
      .watch(connectionByIdProvider(connectionId))
      .valueOrNull
      ?.host;
  if (host == null || isDemoConnection(host)) return false;
  if (ref.watch(analyticsAvailableProvider) &&
      ref.watch(analyticsConsentProvider) == AnalyticsConsent.unasked) {
    return false;
  }
  if (ref.watch(haImportOfferProvider) == connectionId) return false;
  final remote = ref.watch(remoteHomeProvider(connectionId));
  if (!remote.hasValue || remote.value != null) return false;
  return ref.watch(atHomeProvider(connectionId));
});

/// "Control your home from anywhere" on the dashboard, once: remote control
/// is otherwise only found in Settings › Home. Without Pro it opens the Pro
/// screen, with Pro the Remote control screen.
class RemoteOfferCard extends ConsumerStatefulWidget {
  const RemoteOfferCard({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<RemoteOfferCard> createState() => _RemoteOfferCardState();
}

class _RemoteOfferCardState extends ConsumerState<RemoteOfferCard> {
  bool _done = false;

  Future<void> _finish(RemoteStep step) async {
    final hasPro = ref.read(proStatusProvider) == ProStatus.unlocked;
    ref.read(analyticsProvider).track(RemoteEvent(step, pro: hasPro));
    setState(() => _done = true);
    await ref
        .read(sharedPreferencesProvider)
        .setString(remoteOfferDoneKey, '1');
    ref.invalidate(remoteOfferProvider(widget.connectionId));
  }

  void _countShown(bool hasPro) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getString(remoteOfferShownKey) != null) return;
    prefs.setString(remoteOfferShownKey, '1');
    ref
        .read(analyticsProvider)
        .track(RemoteEvent(RemoteStep.offerShown, pro: hasPro));
  }

  @override
  Widget build(BuildContext context) {
    if (_done || !ref.watch(remoteOfferProvider(widget.connectionId))) {
      return const SizedBox.shrink();
    }
    final hasPro = ref.watch(proStatusProvider) == ProStatus.unlocked;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _countShown(hasPro);
    });
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      key: const Key('remote-offer'),
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.public, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.remoteIntroTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Text(
                hasPro ? l10n.remoteOfferBodyPro : l10n.remoteOfferBody,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => _finish(RemoteStep.offerNotNow),
                  child: Text(l10n.pollNotNow),
                ),
                FilledButton(
                  key: const Key('remote-offer-open'),
                  onPressed: () {
                    _finish(RemoteStep.offerOpened);
                    if (hasPro) {
                      context.push(Routes.homeRemote(widget.connectionId));
                    } else {
                      openPro(context);
                    }
                  },
                  child: Text(l10n.remoteOfferShow),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
