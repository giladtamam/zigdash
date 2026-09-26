import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'command_confirmations.dart';
import 'review_prompt_controller.dart';

/// Invisible widget that reports a successful session to
/// [ReviewPromptController] when a command sent on [connectionId] is
/// confirmed by the device's state update, while a dashboard is on screen.
/// Being connected alone does not count.
///
/// Uses `listenManual` from `initState` so the subscription is created once,
/// not on every rebuild.
class ReviewPromptTrigger extends ConsumerStatefulWidget {
  const ReviewPromptTrigger({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<ReviewPromptTrigger> createState() =>
      _ReviewPromptTriggerState();
}

class _ReviewPromptTriggerState extends ConsumerState<ReviewPromptTrigger> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(
      commandConfirmedProvider(widget.connectionId),
      (_, next) {
        // Only a fresh confirmation; not a loading or error state that
        // still carries an earlier value.
        if (next is AsyncData<DateTime>) {
          ref.read(reviewPromptControllerProvider).recordSuccessfulSession();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
