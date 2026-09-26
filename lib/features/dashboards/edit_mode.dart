import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The dashboard being edited, or null (docs/design/dashboard-1.12.md §7).
/// One dashboard is edited at a time; changes save as they happen, so
/// leaving Edit mode never discards anything.
class EditModeController extends Notifier<String?> {
  @override
  String? build() => null;

  void enter(String dashboardId) => state = dashboardId;

  void exit() => state = null;
}

final editModeProvider =
    NotifierProvider<EditModeController, String?>(EditModeController.new);
