import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n_ext.dart';
import '../core/router/routes.dart';
import 'remote_setup.dart';

/// The door to remote control in the dashboard's top bar (3.4.4,
/// docs/design/remote-tab.md): a globe that is always there, in place of a
/// card shown once. Only where remote control is sold and can work for
/// this home; lit in the accent colour while it is on.
class RemoteDoor extends ConsumerWidget {
  const RemoteDoor({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(remoteSoldProvider) ||
        !ref.watch(remoteFitsProvider(connectionId))) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final on = ref.watch(remoteHomeProvider(connectionId)).valueOrNull != null;
    return IconButton(
      key: const Key('remote-door'),
      icon: Icon(
        Icons.public,
        color: on ? Theme.of(context).colorScheme.primary : null,
      ),
      tooltip: on ? l10n.remoteOnTitle : l10n.remoteTitle,
      onPressed: () =>
          context.push(Routes.homeRemote(connectionId, fromDoor: true)),
    );
  }
}
