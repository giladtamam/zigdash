import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../settings/providers/settings_controller.dart';
import '../../core/analytics/analytics.dart';

/// Keeps the screen on; a seam so tests need no platform channel.
class ScreenWake {
  const ScreenWake();
  Future<void> keepOn(bool on) => WakelockPlus.toggle(enable: on);
}

final screenWakeProvider = Provider<ScreenWake>((_) => const ScreenWake());

/// "Wall display" for one dashboard (signal-2.0.md §7): off by default,
/// stored on this phone per dashboard.
class WallDisplaySetting extends FamilyNotifier<bool, String> {
  String get _key => 'wall_display_$arg';

  @override
  bool build(String arg) =>
      ref.read(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> toggle() async {
    state = !state;
    if (state) ref.read(analyticsProvider).track(const FeatureUsed(Feature.wallDisplay));
    await ref.read(sharedPreferencesProvider).setBool(_key, state);
  }
}

final wallDisplayProvider =
    NotifierProvider.family<WallDisplaySetting, bool, String>(
        WallDisplaySetting.new);

/// True while a wall-display dashboard has had no touch for [wallChromeDelay]:
/// the header and the navigation hide until the screen is touched.
final wallChromeHiddenProvider = StateProvider<bool>((_) => false);

const wallChromeDelay = Duration(seconds: 10);

/// Applies Wall display to the dashboard on screen: keeps the screen on and
/// hides the chrome after [wallChromeDelay] without a touch. [active] is
/// false in Edit mode, which never hides anything.
class WallDisplayScope extends ConsumerStatefulWidget {
  const WallDisplayScope({
    super.key,
    required this.dashboardId,
    required this.active,
    required this.child,
  });

  final String dashboardId;
  final bool active;
  final Widget child;

  @override
  ConsumerState<WallDisplayScope> createState() => _WallDisplayScopeState();
}

class _WallDisplayScopeState extends ConsumerState<WallDisplayScope> {
  Timer? _timer;
  bool _wakeOn = false;

  bool get _on =>
      widget.active && ref.read(wallDisplayProvider(widget.dashboardId));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _apply());
  }

  @override
  void didUpdateWidget(WallDisplayScope old) {
    super.didUpdateWidget(old);
    if (old.dashboardId != widget.dashboardId || old.active != widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _apply());
    }
  }

  void _apply() {
    if (!mounted) return;
    final on = _on;
    if (on != _wakeOn) {
      _wakeOn = on;
      ref.read(screenWakeProvider).keepOn(on).ignore();
    }
    _touched();
  }

  /// Shows the chrome and, on a wall display, hides it again after a while.
  void _touched() {
    _timer?.cancel();
    final hidden = ref.read(wallChromeHiddenProvider.notifier);
    if (hidden.state) hidden.state = false;
    if (!_on) return;
    _timer = Timer(wallChromeDelay, () {
      if (mounted && _on) ref.read(wallChromeHiddenProvider.notifier).state = true;
    });
  }

  /// For [dispose], where `ref` can no longer be used.
  late ProviderContainer _container;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container = ProviderScope.containerOf(context, listen: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    final container = _container;
    if (_wakeOn) container.read(screenWakeProvider).keepOn(false).ignore();
    // Leaving the dashboard brings the chrome back for the other screens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        container.read(wallChromeHiddenProvider.notifier).state = false;
      } on StateError {
        // The whole scope is gone (app closing): nothing to restore.
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(wallDisplayProvider(widget.dashboardId), (_, __) => _apply());
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _touched(),
      child: widget.child,
    );
  }
}
