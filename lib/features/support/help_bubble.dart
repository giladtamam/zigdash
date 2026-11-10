import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/router/routes.dart';
import '../../data/repositories/connection_repo.dart';
import '../devices/devices_providers.dart';
import '../onboarding/demo_service.dart' show isDemoConnection;
import '../onboarding/setup/setup_completed_at.dart' show kSetupCompletedAtMs;
import '../../mqtt/mqtt_status.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import '../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'assistant_client.dart';
import 'assistant_panel.dart';
import 'help_tips.dart';
import 'support_details.dart' show DeviceAttention;
import 'support_facts.dart';

/// The help bubble on a connected home's dashboard (3.5.0,
/// assistant-in-app-2026-11.md revision 5): a second doorway to the same
/// assistant Get help has, in home mode. Three states of one element: a
/// "Need help?" pill until it is opened once, the icon alone after that,
/// and gone after a long-press › Hide (Settings › Get help brings it back).
/// Shown on the Dashboards tab only, never over Edit mode, the wall display
/// or a kiosk; the HomeShell decides that.
const kHelpBubbleOpened = 'help_bubble_opened';
const kHelpBubbleHidden = 'help_bubble_hidden';

/// When the pill was first shown: after [kPillDays] it decays to the dot
/// even if never opened, so it never nags for good.
const kHelpBubbleFirstShownMs = 'help_bubble_first_shown_ms';
const kPillDays = 7;

/// No pill in the hour after setup: that screen already has its own
/// first-steps to show. The dot is still there.
const kQuietAfterSetup = Duration(hours: 1);

/// Pill or dot, for this phone's state. Pure, for tests.
bool helpBubbleShowsPill({
  required bool opened,
  int? firstShownMs,
  int? setupCompletedMs,
  DateTime? now,
}) {
  if (opened) return false;
  final t = now ?? DateTime.now();
  if (setupCompletedMs != null &&
      t.difference(DateTime.fromMillisecondsSinceEpoch(setupCompletedMs)) <
          kQuietAfterSetup) {
    return false;
  }
  if (firstShownMs != null &&
      t.difference(DateTime.fromMillisecondsSinceEpoch(firstShownMs)) >
          const Duration(days: kPillDays)) {
    return false;
  }
  return true;
}

/// Whether the bubble has been opened once on this phone (pill → icon).
final helpBubbleOpenedProvider = NotifierProvider<_PrefFlag, bool>(
  () => _PrefFlag(kHelpBubbleOpened),
);

/// Whether the person hid the bubble (long-press, or the Settings switch).
final helpBubbleHiddenProvider = NotifierProvider<_PrefFlag, bool>(
  () => _PrefFlag(kHelpBubbleHidden),
);

class _PrefFlag extends Notifier<bool> {
  _PrefFlag(this.key);
  final String key;

  @override
  bool build() {
    try {
      return ref.read(sharedPreferencesProvider).getBool(key) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> set(bool value) async {
    state = value;
    try {
      await ref.read(sharedPreferencesProvider).setBool(key, value);
    } catch (_) {}
  }
}

class HelpBubble extends ConsumerWidget {
  const HelpBubble({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(helpBubbleHiddenProvider)) return const SizedBox.shrink();
    // The demo home's facts mean nothing to the assistant.
    final home = ref.watch(connectionByIdProvider(connectionId)).valueOrNull;
    if (home == null || isDemoConnection(home.host)) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final opened = ref.watch(helpBubbleOpenedProvider);
    int? firstShown;
    int? setupAt;
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      firstShown = prefs.getInt(kHelpBubbleFirstShownMs);
      setupAt = prefs.getInt(kSetupCompletedAtMs);
      if (firstShown == null && !opened) {
        prefs.setInt(
          kHelpBubbleFirstShownMs,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (_) {}
    final pill = helpBubbleShowsPill(
      opened: opened,
      firstShownMs: firstShown,
      setupCompletedMs: setupAt,
    );
    final dot = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: scheme.tertiary, shape: BoxShape.circle),
    );
    return Semantics(
      button: true,
      label: l10n.assistantTitle,
      child: Material(
        key: const Key('help-bubble'),
        color: scheme.primaryContainer,
        elevation: 3,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            ref.read(helpBubbleOpenedProvider.notifier).set(true);
            showAssistantSheet(
              context,
              connectionId,
              state: pill ? 'pill' : 'dot',
            );
          },
          onLongPress: () => _hideMenu(context, ref),
          child: Padding(
            padding: pill
                ? const EdgeInsetsDirectional.fromSTEB(14, 14, 18, 14)
                : const EdgeInsets.all(14),
            child: !pill
                ? Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: scheme.onPrimaryContainer,
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      dot,
                      const SizedBox(width: 8),
                      Text(
                        l10n.helpBubbleLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _hideMenu(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final box = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    final origin = box.localToGlobal(Offset.zero, ancestor: overlay);
    final hide = await showMenu<bool>(
      context: context,
      position: RelativeRect.fromLTRB(
        origin.dx,
        origin.dy - 56,
        overlay.size.width - origin.dx - box.size.width,
        overlay.size.height - origin.dy,
      ),
      items: [
        PopupMenuItem(
          key: const Key('help-bubble-hide'),
          value: true,
          child: Text(l10n.helpBubbleHide),
        ),
      ],
    );
    if (hide != true || !context.mounted) return;
    await hideHelpBubble(context, ref);
  }
}

/// Hides the bubble, records it, and says where it comes back.
Future<void> hideHelpBubble(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.maybeOf(context);
  await ref.read(helpBubbleHiddenProvider.notifier).set(true);
  ref
      .read(analyticsProvider)
      .track(const AssistantEvent(AssistantStep.hidden, HelpFrom.bubble));
  messenger?.showSnackBar(SnackBar(content: Text(l10n.helpBubbleHidden)));
}

/// The assistant in a bottom sheet over the dashboard, so the person can
/// look at a tile while asking. Nothing is sent until they tap a chip or
/// write. Talk to a person closes the sheet and opens Get help for this
/// home with the conversation attached (a route extra, never the URL).
Future<void> showAssistantSheet(
  BuildContext context,
  String connectionId, {
  String? state,
}) {
  final host = context;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.66,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (sheet, scroll) => _AssistantSheet(
        connectionId: connectionId,
        scroll: scroll,
        state: state,
        onPerson: (handoff) {
          Navigator.of(sheet).pop();
          host.push(
            Routes.getHelpFrom(HelpFrom.bubble.name, home: connectionId),
            extra: handoff,
          );
        },
        onHide: (ref) async {
          // Hide while the sheet's ref is alive, then close it; the snack
          // bar goes to the dashboard's messenger.
          await hideHelpBubble(host, ref);
          if (sheet.mounted) Navigator.of(sheet).pop();
        },
      ),
    ),
  );
}

class _AssistantSheet extends ConsumerWidget {
  const _AssistantSheet({
    required this.connectionId,
    required this.scroll,
    required this.onPerson,
    required this.onHide,
    this.state,
  });

  final String connectionId;
  final ScrollController scroll;
  final String? state;
  final ValueChanged<AssistantHandoff> onPerson;
  final ValueChanged<WidgetRef> onHide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final details = ref.watch(
      supportDetailsProvider((
        openedFrom: openedFromLabel(HelpFrom.bubble, null),
        connectionId: connectionId,
      )),
    );
    final name =
        ref.watch(connectionByIdProvider(connectionId)).valueOrNull?.name ?? '';
    final connected =
        ref.watch(connectionStatusProvider(connectionId)).valueOrNull ==
        MqttStatus.connected;
    // Counts only (never names): what the Devices tab lists under Needs
    // attention, so "a device stopped responding" gets a specific answer.
    final base = ref.watch(homeBaseTopicProvider(connectionId));
    DeviceAttention? attention;
    if (connected && base != null) {
      final health = ref
          .watch(deviceHealthProvider((connectionId: connectionId, base: base)))
          .valueOrNull;
      if (health != null) {
        attention = DeviceAttention(
          total: health.where((h) => h.needsAttention).length,
          notResponding: health.where((h) => h.notResponding).length,
        );
      }
    }
    // The chips fit the state: an unreachable home gets that one question;
    // a connected one never does.
    final chips = connected
        ? [
            AssistantChip(
              l10n.assistantChipDevice,
              'device',
              'A device stopped responding',
            ),
            AssistantChip(l10n.assistantChipTile, 'tile', 'Add a tile'),
            AssistantChip(
              l10n.assistantChipAutomations,
              'automations',
              'Automations',
            ),
          ]
        : [
            AssistantChip(
              l10n.assistantChipUnreachable,
              'unreachable',
              "Home can't be reached",
            ),
          ];
    return SingleChildScrollView(
      controller: scroll,
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: details.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.assistantFailed),
        ),
        data: (d) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AssistantPanel(
              key: const Key('assistant-home'),
              mode: AssistantMode.home,
              framed: false,
              from: HelpFrom.bubble,
              shownState: state,
              details: d.withAttention(attention),
              triage: const AssistantTriage(),
              opening: connected
                  ? l10n.assistantHomeOpening(name, d.z2m?.devices ?? 0)
                  : l10n.assistantHomeOpeningOffline(name),
              chips: chips,
              onTalkToPerson: onPerson,
              onReport: onPerson,
            ),
            // Hide, visible (a long-press is not, least of all to TalkBack).
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                key: const Key('assistant-home-hide'),
                onPressed: () => onHide(ref),
                icon: const Icon(Icons.visibility_off_outlined, size: 18),
                label: Text(l10n.helpBubbleHideSheet),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
