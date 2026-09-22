import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/providers/settings_controller.dart';

/// Play's in-app review flow, behind a seam so [ReviewPromptGate] can be unit
/// tested without the platform channel.
abstract class ReviewRequester {
  Future<bool> isAvailable();
  Future<void> requestReview();
}

/// Real implementation. On builds installed outside Play (F-Droid,
/// IzzyOnDroid, a sideloaded APK) `isAvailable()` reports false and the gate
/// stays silent, so this never shows a dead dialog.
class PlayReviewRequester implements ReviewRequester {
  const PlayReviewRequester();

  @override
  Future<bool> isAvailable() => InAppReview.instance.isAvailable();

  @override
  Future<void> requestReview() => InAppReview.instance.requestReview();
}

const _kFirstSeen = 'review_first_seen_ms';
const _kSuccessCount = 'review_success_count';
const _kLastPrompt = 'review_last_prompt_ms';

/// Qualifying success moments before asking, so we only ask people for whom
/// the app demonstrably works.
@visibleForTesting
const reviewMinSuccesses = 3;

/// Days since the first success moment before asking, so a first-run burst of
/// launches cannot trip the prompt on day one.
@visibleForTesting
const reviewMinAgeDays = 3;

/// Days to wait before asking again. Play enforces its own quota on top.
@visibleForTesting
const reviewCooldownDays = 120;

/// Decides whether to ask for a Play review, and asks at most once per app
/// launch.
///
/// A "success moment" is the user reaching their dashboards with the broker
/// connected — i.e. the app is doing the job it was installed for. The caller
/// reports those; this class owns all the gating.
class ReviewPromptGate {
  ReviewPromptGate({
    required SharedPreferences prefs,
    required ReviewRequester requester,
    DateTime Function()? now,
  })  : _prefs = prefs,
        _requester = requester,
        _now = now ?? DateTime.now;

  final SharedPreferences _prefs;
  final ReviewRequester _requester;
  final DateTime Function() _now;

  bool _handledThisSession = false;

  /// Records one success moment and asks for a review if every gate passes.
  ///
  /// Only the first call per app launch does anything, so callers are free to
  /// invoke this from a widget that rebuilds. Returns true if the Play review
  /// flow was actually requested.
  Future<bool> onSuccessMoment() async {
    if (_handledThisSession) return false;
    _handledThisSession = true;

    final nowMs = _now().millisecondsSinceEpoch;

    final firstSeen = _prefs.getInt(_kFirstSeen);
    if (firstSeen == null) {
      await _prefs.setInt(_kFirstSeen, nowMs);
      // First qualifying moment ever: record it and wait for the app to prove
      // itself over a few more sessions.
      await _prefs.setInt(_kSuccessCount, 1);
      return false;
    }

    final successes = (_prefs.getInt(_kSuccessCount) ?? 0) + 1;
    await _prefs.setInt(_kSuccessCount, successes);

    if (successes < reviewMinSuccesses) return false;

    if (nowMs - firstSeen < _days(reviewMinAgeDays)) return false;

    final lastPrompt = _prefs.getInt(_kLastPrompt);
    if (lastPrompt != null && nowMs - lastPrompt < _days(reviewCooldownDays)) {
      return false;
    }

    if (!await _requester.isAvailable()) return false;

    // Record before requesting: if the request throws or Play silently drops
    // it against its quota, we still respect the cooldown rather than retrying
    // on every launch.
    await _prefs.setInt(_kLastPrompt, nowMs);
    await _requester.requestReview();
    return true;
  }

  static int _days(int n) => Duration(days: n).inMilliseconds;
}

final reviewRequesterProvider =
    Provider<ReviewRequester>((ref) => const PlayReviewRequester());

final reviewPromptGateProvider = Provider<ReviewPromptGate>(
  (ref) => ReviewPromptGate(
    prefs: ref.read(sharedPreferencesProvider),
    requester: ref.read(reviewRequesterProvider),
  ),
);

/// Reports a success moment to [ReviewPromptGate] while [active] is true.
///
/// Renders [child] unchanged; it exists only to own the lifecycle callback.
class ReviewPromptTrigger extends ConsumerStatefulWidget {
  const ReviewPromptTrigger({
    super.key,
    required this.active,
    required this.child,
  });

  final bool active;
  final Widget child;

  @override
  ConsumerState<ReviewPromptTrigger> createState() =>
      _ReviewPromptTriggerState();
}

class _ReviewPromptTriggerState extends ConsumerState<ReviewPromptTrigger> {
  @override
  void initState() {
    super.initState();
    _maybeReport();
  }

  @override
  void didUpdateWidget(ReviewPromptTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _maybeReport();
  }

  void _maybeReport() {
    if (!widget.active) return;
    // Defer past the current frame so the prompt never competes with the
    // dashboard's first paint.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Asking for a review is never worth breaking the dashboard over, so a
      // gate that cannot run (unavailable prefs, a Play API failure) is
      // dropped rather than surfaced.
      try {
        ref
            .read(reviewPromptGateProvider)
            .onSuccessMoment()
            .catchError((Object _) => false);
      } catch (_) {
        // Intentionally ignored; see above.
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
