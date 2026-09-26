import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../mqtt/mqtt_status.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import 'review_prompt_controller.dart';

/// Invisible widget that reports a successful session to
/// [ReviewPromptController] whenever [connectionId] is connected while it is
/// mounted. Mount it only where a dashboard is actually on screen, so
/// "connected + dashboards exist" is guaranteed by placement.
///
/// Uses `listenManual` from `initState` (like [AppLifecycleReconnector]) so
/// the subscription is created once, not on every rebuild, and
/// `fireImmediately` covers the case where the connection is already up when
/// the screen opens.
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
      connectionStatusProvider(widget.connectionId),
      (_, next) {
        if (next.valueOrNull == MqttStatus.connected) {
          ref.read(reviewPromptControllerProvider).recordSuccessfulSession();
        }
      },
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
