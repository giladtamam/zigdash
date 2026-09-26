import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/router/routes.dart';
import '../../data/database/database.dart';
import '../../data/repositories/connection_repo.dart';
import '../devices/device_registry.dart';

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
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: indexOf(location),
        onDestinationSelected: (i) => context.go(switch (i) {
          1 => Routes.homeDevices(connectionId),
          2 => Routes.homeScenes(connectionId),
          _ => Routes.homeDashboards(connectionId),
        }),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navDashboards,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: newDevices > 0,
              child: const Icon(Icons.devices_other_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: newDevices > 0,
              child: const Icon(Icons.devices_other),
            ),
            label: l10n.navDevices,
            tooltip: newDevices > 0
                ? '${l10n.navDevices}, ${l10n.devicesNewDot}'
                : null,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome),
            label: l10n.navScenes,
          ),
        ],
      ),
    );
  }
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
      onSelected: (v) => switch (v) {
        '__add__' => context.push(Routes.setup),
        '__manage__' => context.push(Routes.connections),
        _ => context.go(Routes.homeDashboards(v)),
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
