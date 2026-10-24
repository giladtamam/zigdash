import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';

/// A check in progress during setup (3.1.4): the spinner and what it is
/// doing, a note once it has taken a while, and a way out.
class SetupWaiting extends StatefulWidget {
  const SetupWaiting({
    super.key,
    required this.title,
    required this.onCancel,
    this.slowAfter = const Duration(seconds: 5),
  });

  final String title;
  final VoidCallback onCancel;

  /// When the "can take a while" note appears.
  final Duration slowAfter;

  @override
  State<SetupWaiting> createState() => _SetupWaitingState();
}

class _SetupWaitingState extends State<SetupWaiting> {
  Timer? _timer;
  var _slow = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.slowAfter, () {
      if (mounted) setState(() => _slow = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(widget.title, textAlign: TextAlign.center),
            ),
            if (_slow) ...[
              const SizedBox(height: 8),
              Text(
                l10n.setupStillChecking,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            TextButton(onPressed: widget.onCancel, child: Text(l10n.cancel)),
          ],
        ),
      ),
    );
  }
}
