import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_events.dart';
import 'command_confirmations.dart';
import 'review_prompt_controller.dart';

/// Which confirmed command of the session may ask for a review (3.4.8):
/// the third, not the first, so one lucky tap is not enough.
const kReviewNthCommand = 3;

/// Wait after the confirmation before asking, so the tile's own
/// confirmation is seen first.
const kReviewDelay = Duration(milliseconds: 1500);

/// Invisible widget that feeds [ReviewPromptController] while a dashboard is
/// on screen. Every confirmed command on [connectionId] (a command the user
/// sent, answered by the device's state update) and the first passive device
/// report (2.8.1) count the day. Being connected alone does not count.
///
/// The ask (3.4.8): only on the [kReviewNthCommand]th confirmed command of
/// this widget's life (the count resets with it), after [kReviewDelay], and
/// only if the widget is still mounted, so a dashboard the user has left
/// does not ask from under another screen. A passive report may ask on the
/// same terms, but the controller allows that only for installs that never
/// confirmed a command (sensor-only homes).
///
/// Uses `listenManual` from `initState` so the subscriptions are created
/// once, not on every rebuild.
class ReviewPromptTrigger extends ConsumerStatefulWidget {
  const ReviewPromptTrigger({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<ReviewPromptTrigger> createState() =>
      _ReviewPromptTriggerState();
}

class _ReviewPromptTriggerState extends ConsumerState<ReviewPromptTrigger> {
  int _confirmed = 0;
  final List<Timer> _pending = [];

  @override
  void initState() {
    super.initState();
    // Only fresh values; not a loading or error state that still carries an
    // earlier one.
    ref.listenManual(commandConfirmedProvider(widget.connectionId), (
      AsyncValue<DateTime>? _,
      AsyncValue<DateTime> next,
    ) {
      if (next is! AsyncData<DateTime>) return;
      ref.read(reviewPromptControllerProvider).recordCommandConfirmed();
      _confirmed++;
      if (_confirmed == kReviewNthCommand) {
        _askLater(ReviewTrigger.command, nth: _confirmed);
      }
    });
    // 2.8.1: live data on the dashboard counts too (sensor-only homes).
    ref.listenManual(deviceReportedProvider(widget.connectionId), (
      AsyncValue<DateTime>? _,
      AsyncValue<DateTime> next,
    ) {
      if (next is! AsyncData<DateTime>) return;
      ref.read(reviewPromptControllerProvider).recordSuccessfulSession();
      _askLater(ReviewTrigger.report);
    });
  }

  void _askLater(ReviewTrigger trigger, {int? nth}) {
    late final Timer timer;
    timer = Timer(kReviewDelay, () {
      _pending.remove(timer);
      if (!mounted) return;
      ref
          .read(reviewPromptControllerProvider)
          .maybeRequest(trigger: trigger, nth: nth);
    });
    _pending.add(timer);
  }

  @override
  void dispose() {
    for (final t in _pending) {
      t.cancel();
    }
    _pending.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
