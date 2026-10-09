import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/router/routes.dart';
import '../../core/theme/signal_icons.dart';
import '../../core/utils/window_class.dart';
import '../../data/database/database.dart';
import '../../data/repositories/connection_repo.dart';
import '../../data/repositories/dashboard_repo.dart';
import '../../data/repositories/section_repo.dart';
import '../dashboards/edit_mode.dart';
import '../devices/device_registry.dart';
import '../dashboards/wall_display.dart';
import '../devices/devices_providers.dart';
import '../panels/widgets/edit_grid.dart' show askSectionName;

/// The navigation shell of one home (docs/design/dashboard-1.12.md §6):
/// Dashboards, Devices and Scenes in the bottom bar, all showing the current
/// home. The Devices destination carries a dot while a device is on no
/// dashboard and not dismissed.
class HomeShell extends ConsumerWidget {
  const HomeShell({
    super.key,
    required this.connectionId,
    required this.location,
    required this.child,
  });

  final String connectionId;
  final String location;
  final Widget child;

  static int indexOf(String location) {
    if (location.contains('/devices')) return 1;
    if (location.contains('/scenes')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final newDevices =
        ref.watch(unassignedCountProvider(connectionId)).valueOrNull ?? 0;
    // Battery readings feed the dot while the home is open.
    final base = ref.watch(homeBaseTopicProvider(connectionId));
    if (base != null) {
      ref.watch(batteryWatchProvider((connectionId: connectionId, base: base)));
    }
    final lowBatteries =
        ref.watch(batteryAlertsProvider(connectionId)).valueOrNull?.length ?? 0;
    final dot = newDevices > 0 || lowBatteries > 0;
    final dotReason = [
      if (newDevices > 0) l10n.devicesNewDot,
      if (lowBatteries > 0) l10n.devicesDotBattery,
    ].join(', ');
    // Edit mode belongs to a dashboard of this home that still exists.
    final editingId = ref.watch(editModeProvider);
    final editing = editingId != null &&
            ref
                    .watch(dashboardsForConnectionProvider(connectionId))
                    .valueOrNull
                    ?.any((d) => d.id == editingId) ==
                true
        ? editingId
        : null;
    final selected = indexOf(location);
    // A wall display hides the navigation until the screen is touched.
    final chromeHidden = ref.watch(wallChromeHiddenProvider) && selected == 0;
    void go(int i) => context.go(switch (i) {
          1 => Routes.homeDevices(connectionId),
          2 => Routes.homeScenes(connectionId),
          _ => Routes.homeDashboards(connectionId),
        });
    Widget devicesIcon(IconData icon, {bool active = false}) => Badge(
          isLabelVisible: dot,
          child: SignalIcon(icon, active: active),
        );

    // Medium and expanded windows: a navigation rail, which stays in Edit
    // mode (Add tile and Add section move into the Edit header).
    if (chromeHidden) return Scaffold(body: child);
    if (WindowClass.of(context).hasRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selected,
              onDestinationSelected: go,
              labelType: NavigationRailLabelType.all,
              groupAlignment: -1,
              minWidth: 88,
              destinations: [
                NavigationRailDestination(
                  icon: const SignalIcon(Symbols.dashboard),
                  selectedIcon: const SignalIcon(Symbols.dashboard, active: true),
                  label: Text(l10n.navDashboards),
                ),
                NavigationRailDestination(
                  icon: dot
                      ? Tooltip(
                          message: '${l10n.navDevices}, $dotReason',
                          child: devicesIcon(Symbols.devicesOther),
                        )
                      : devicesIcon(Symbols.devicesOther),
                  selectedIcon: devicesIcon(Symbols.devicesOther, active: true),
                  label: Text(l10n.navDevices),
                ),
                NavigationRailDestination(
                  icon: const SignalIcon(Symbols.autoAwesome),
                  selectedIcon: const SignalIcon(Symbols.autoAwesome, active: true),
                  label: Text(l10n.navScenes),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            // The page's route carries BlockSemantics, which hides whatever
            // was painted before it in the same container, and the rail is.
            // A container of its own keeps the rail reachable by TalkBack.
            Expanded(child: Semantics(container: true, child: child)),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      // In Edit mode the bar offers the two ways to add, instead of the tabs.
      bottomNavigationBar: editing != null && selected == 0
          ? _EditBar(connectionId: connectionId, dashboardId: editing)
          : NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: go,
        destinations: [
          NavigationDestination(
            icon: const SignalIcon(Symbols.dashboard),
            selectedIcon: const SignalIcon(Symbols.dashboard, active: true),
            label: l10n.navDashboards,
          ),
          NavigationDestination(
            icon: devicesIcon(Symbols.devicesOther),
            selectedIcon: devicesIcon(Symbols.devicesOther, active: true),
            label: l10n.navDevices,
            tooltip: dot ? '${l10n.navDevices}, $dotReason' : null,
          ),
          NavigationDestination(
            icon: const SignalIcon(Symbols.autoAwesome),
            selectedIcon: const SignalIcon(Symbols.autoAwesome, active: true),
            label: l10n.navScenes,
          ),
        ],
            ),
          );
  }
}

class _EditBar extends ConsumerWidget {
  const _EditBar({required this.connectionId, required this.dashboardId});

  final String connectionId;
  final String dashboardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return BottomAppBar(
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l10n.dashAddTile),
              onPressed: () => context.push(
                  '/connections/$connectionId/dashboards/$dashboardId/add'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.segment),
              label: Text(l10n.editAddSection),
              onPressed: () => addSection(context, ref, dashboardId),
            ),
          ),
        ],
      ),
    );
  }
}

/// Asks for a name and appends a section to [dashboardId].
Future<void> addSection(
    BuildContext context, WidgetRef ref, String dashboardId) async {
  final name = await askSectionName(context);
  if (name == null) return;
  final repo = ref.read(sectionRepoProvider);
  final count = (await repo.getByDashboard(dashboardId)).length;
  await repo.create(dashboardId: dashboardId, name: name, sortOrder: count);
}

/// The header title of a home's screens: the home's name, opening the home
/// switcher when there are two or more homes.
class HomeTitle extends ConsumerWidget {
  const HomeTitle({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homes =
        ref.watch(connectionsStreamProvider).valueOrNull ?? const <Connection>[];
    final current = homes.where((c) => c.id == connectionId).firstOrNull;
    final name = Text(
      current?.name ?? '',
      overflow: TextOverflow.ellipsis,
    );
    if (homes.length < 2) return name;
    return PopupMenuButton<String>(
      tooltip: context.l10n.homeSwitch,
      position: PopupMenuPosition.under,
      onSelected: (v) {
        ref.read(editModeProvider.notifier).exit();
        switch (v) {
          case '__add__':
            context.push(Routes.setup);
          case '__manage__':
            context.push(Routes.settings);
          default:
            context.go(Routes.homeDashboards(v));
        }
      },
      itemBuilder: (ctx) => [
        for (final h in homes)
          PopupMenuItem(
            value: h.id,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                  h.id == connectionId ? Icons.home : Icons.home_outlined),
              title: Text(h.name),
              trailing: h.id == connectionId ? const Icon(Icons.check) : null,
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: '__add__',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.add),
            title: Text(ctx.l10n.homeAdd),
          ),
        ),
        PopupMenuItem(
          value: '__manage__',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.manage_accounts_outlined),
            title: Text(ctx.l10n.homeManage),
          ),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: name),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}

/// Settings, in the header of every home screen.
class SettingsAction extends StatelessWidget {
  const SettingsAction({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: context.l10n.navSettings,
        icon: const Icon(Icons.settings_outlined),
        onPressed: () => context.push(Routes.settings),
      );
}

/// Opens the first home when none is remembered, or setup when there are
/// no homes (all deleted after first run).
class HomeStartScreen extends ConsumerWidget {
  const HomeStartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homes = ref.watch(connectionsStreamProvider).valueOrNull;
    if (homes != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.go(homes.isEmpty
            ? Routes.setup
            : Routes.homeDashboards(homes.first.id));
      });
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
