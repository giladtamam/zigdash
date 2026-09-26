import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

/// The two calls we need from the platform review flow, behind an interface
/// we own so tests never touch a platform channel.
abstract interface class ReviewLauncher {
  Future<bool> isAvailable();
  Future<void> requestReview();
}

/// Production adapter over Google's in-app review API. The dialog is drawn by
/// Play itself; the app sends nothing and learns nothing about the outcome.
class InAppReviewLauncher implements ReviewLauncher {
  const InAppReviewLauncher();

  @override
  Future<bool> isAvailable() => InAppReview.instance.isAvailable();

  @override
  Future<void> requestReview() => InAppReview.instance.requestReview();
}

final reviewLauncherProvider =
    Provider<ReviewLauncher>((ref) => const InAppReviewLauncher());
