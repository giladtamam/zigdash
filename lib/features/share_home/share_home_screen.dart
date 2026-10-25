import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../data/database/database.dart';
import '../../data/repositories/backup_service.dart';
import '../../data/repositories/connection_repo.dart';
import '../../mqtt/endpoint.dart';
import '../../mqtt/mqtt_manager.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import 'home_share.dart';

/// Share this home (3.1.7): shows, on a tap, the QR code another phone at
/// home scans to join. While it shows, the dashboards wait on the home
/// broker under its one-time topic; they are cleared when it hides.
class ShareHomeScreen extends ConsumerStatefulWidget {
  const ShareHomeScreen({super.key, required this.connectionId});

  final String connectionId;

  /// How long the code stays on screen.
  static const shownFor = Duration(minutes: 2);

  @override
  ConsumerState<ShareHomeScreen> createState() => _ShareHomeScreenState();
}

class _ShareHomeScreenState extends ConsumerState<ShareHomeScreen> {
  HomeInvite? _invite;
  MqttManager? _mgr;
  Timer? _hide;
  var _busy = false;
  var _failed = false;

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  /// Removes the waiting dashboards and hides the code.
  void _clear() {
    _hide?.cancel();
    _hide = null;
    final invite = _invite, mgr = _mgr;
    if (invite != null && mgr != null) {
      mgr.publish(invite.dashboardsTopic, '{value}', '', retain: true);
    }
    _invite = null;
  }

  Future<void> _show(Connection home) async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final mgr = await ref.read(mqttManagerProvider(home.id).future);
      if (!mgr.isConnected || mgr.activeEndpoint == MqttEndpoint.relay) {
        throw StateError('not at home');
      }
      final password = await ref
          .read(connectionRepoProvider)
          .readPassword(home.id);
      final dashboards = await ref
          .read(backupServiceProvider)
          .exportConnection(home.id);
      final invite = HomeInvite.of(
        home,
        password: password,
        code: newShareCode(),
      );
      // The template is only the placeholder: a tile's own "{value}" in the
      // export must reach the other phone unchanged.
      mgr.publish(invite.dashboardsTopic, '{value}', dashboards, retain: true);
      ref
          .read(analyticsProvider)
          .track(const HomeShareEvent(HomeShareStep.codeShown));
      if (!mounted) return;
      setState(() {
        _mgr = mgr;
        _invite = invite;
        _busy = false;
      });
      _hide = Timer(ShareHomeScreen.shownFor, () {
        if (!mounted) return;
        setState(_clear);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final home = ref
        .watch(connectionsStreamProvider)
        .valueOrNull
        ?.where((c) => c.id == widget.connectionId)
        .firstOrNull;
    final invite = _invite;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.shareHomeTitle)),
      body: home == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!canShareHome(home))
                  Text(l10n.shareHomeViaHa, style: theme.textTheme.bodyLarge)
                else ...[
                  Text(l10n.shareHomeIntro, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  if (invite == null) ...[
                    Text(
                      l10n.shareHomeLoginWarning,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      key: const Key('share-home-show'),
                      onPressed: _busy ? null : () => _show(home),
                      icon: const Icon(Icons.qr_code_2),
                      label: Text(l10n.shareHomeShow),
                    ),
                    if (_failed) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.shareHomeAtHome,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ] else ...[
                    Center(
                      child: Container(
                        color: Colors
                            .white, // a QR code needs a light quiet zone in dark mode too
                        padding: const EdgeInsets.all(12),
                        child: QrImageView(
                          key: const Key('share-home-qr'),
                          data: invite.link(),
                          size: 260,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.shareHomeScanHint, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(_clear),
                        child: Text(l10n.shareHomeHide),
                      ),
                    ),
                  ],
                ],
              ],
            ),
    );
  }
}
