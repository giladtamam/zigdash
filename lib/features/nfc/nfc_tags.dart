import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_ext.dart';

/// NFC tags (3.3): a tag runs a scene or toggles a device when the phone
/// taps it (NfcTagActivity.kt). Free, Android only.
enum NfcTagAction { scene, toggle }

/// Labels on a tag are cut to this many characters: a small sticker
/// (NTAG213) holds 137 bytes, and the Home id alone takes 36.
const nfcTagLabelMax = 16;

/// The link written to a tag. Nothing secret: the phone's own saved Home
/// connects, so a tag only works on a phone that has that Home.
String nfcTagUri({
  required String connectionId,
  required NfcTagAction action,
  required String target,
  required String label,
}) {
  final short = label.characters.take(nfcTagLabelMax).toString();
  return Uri(
    scheme: 'zigdash',
    host: 'tag',
    queryParameters: {
      'h': connectionId,
      'a': action.name,
      't': target,
      if (short.isNotEmpty) 'n': short,
    },
  ).toString();
}

enum NfcState { on, off, none }

enum NfcWriteOutcome { written, readonly, tooSmall, unsupported, failed, cancelled }

/// The "zigdash/nfc" channel (NfcTags.kt); a fake in tests.
class NfcBridge {
  static const _channel = MethodChannel('zigdash/nfc');

  Future<NfcState> state() async {
    if (kIsWeb || !Platform.isAndroid) return NfcState.none;
    try {
      return switch (await _channel.invokeMethod<String>('state')) {
        'on' => NfcState.on,
        'off' => NfcState.off,
        _ => NfcState.none,
      };
    } on PlatformException {
      return NfcState.none;
    } on MissingPluginException {
      return NfcState.none;
    }
  }

  /// Waits for a tag and writes [uri] to it.
  Future<NfcWriteOutcome> write(String uri) async {
    try {
      return switch (await _channel.invokeMethod<String>('write', {
        'uri': uri,
      })) {
        'written' => NfcWriteOutcome.written,
        'readonly' => NfcWriteOutcome.readonly,
        'too_small' => NfcWriteOutcome.tooSmall,
        'unsupported' => NfcWriteOutcome.unsupported,
        'cancelled' => NfcWriteOutcome.cancelled,
        _ => NfcWriteOutcome.failed,
      };
    } on PlatformException {
      return NfcWriteOutcome.failed;
    } on MissingPluginException {
      return NfcWriteOutcome.failed;
    }
  }

  Future<void> cancel() async {
    try {
      await _channel.invokeMethod<void>('cancel');
    } on PlatformException {
      // Nothing was waiting.
    } on MissingPluginException {
      // Not on Android.
    }
  }
}

final nfcBridgeProvider = Provider<NfcBridge>((ref) => NfcBridge());

/// Whether this phone has NFC, and whether it's on.
final nfcStateProvider = FutureProvider<NfcState>(
  (ref) => ref.watch(nfcBridgeProvider).state(),
);

/// Opens the sheet that writes a tag for [label]'s scene or device.
Future<void> showWriteNfcTag(
  BuildContext context, {
  required String connectionId,
  required NfcTagAction action,
  required String target,
  required String label,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isDismissible: true,
  builder: (_) => WriteNfcTagSheet(
    uri: nfcTagUri(
      connectionId: connectionId,
      action: action,
      target: target,
      label: label,
    ),
    label: label,
  ),
);

class WriteNfcTagSheet extends ConsumerStatefulWidget {
  const WriteNfcTagSheet({super.key, required this.uri, required this.label});

  final String uri;
  final String label;

  @override
  ConsumerState<WriteNfcTagSheet> createState() => _WriteNfcTagSheetState();
}

class _WriteNfcTagSheetState extends ConsumerState<WriteNfcTagSheet> {
  NfcState? _nfc;
  NfcWriteOutcome? _outcome;
  bool _waiting = false;

  // Kept from initState: dispose can't use ref.
  late final NfcBridge _bridge;

  @override
  void initState() {
    super.initState();
    _bridge = ref.read(nfcBridgeProvider);
    unawaited(_start());
  }

  @override
  void dispose() {
    // Also after a write: the phone keeps reading tags until the sheet closes.
    unawaited(_bridge.cancel());
    super.dispose();
  }

  Future<void> _start() async {
    final bridge = _bridge;
    final nfc = await bridge.state();
    if (!mounted) return;
    setState(() {
      _nfc = nfc;
      _outcome = null;
      _waiting = nfc == NfcState.on;
    });
    if (nfc != NfcState.on) return;
    final outcome = await bridge.write(widget.uri);
    if (!mounted) return;
    setState(() {
      _waiting = false;
      _outcome = outcome;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final (IconData icon, String title, String body) = switch ((
      _nfc,
      _outcome,
    )) {
      (NfcState.none, _) => (Icons.nfc, l10n.nfcNoneTitle, l10n.nfcNoneBody),
      (NfcState.off, _) => (Icons.nfc, l10n.nfcOffTitle, l10n.nfcOffBody),
      (_, NfcWriteOutcome.written) => (
        Icons.check_circle_outline,
        l10n.nfcWrittenTitle,
        l10n.nfcWrittenBody(widget.label),
      ),
      (_, NfcWriteOutcome.readonly) => (
        Icons.lock_outline,
        l10n.nfcFailedTitle,
        l10n.nfcReadonlyBody,
      ),
      (_, NfcWriteOutcome.tooSmall) => (
        Icons.error_outline,
        l10n.nfcFailedTitle,
        l10n.nfcTooSmallBody,
      ),
      (_, NfcWriteOutcome.unsupported) => (
        Icons.error_outline,
        l10n.nfcFailedTitle,
        l10n.nfcUnsupportedBody,
      ),
      (_, NfcWriteOutcome.failed) => (
        Icons.error_outline,
        l10n.nfcFailedTitle,
        l10n.nfcFailedBody,
      ),
      _ => (Icons.nfc, l10n.nfcHoldTitle, l10n.nfcHoldBody(widget.label)),
    };
    final retry =
        _outcome != null &&
        _outcome != NfcWriteOutcome.written &&
        _outcome != NfcWriteOutcome.cancelled;
    return SafeArea(
      child: Padding(
        key: const Key('nfc-sheet'),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
            if (_waiting) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (retry || _outcome == NfcWriteOutcome.written)
                  FilledButton.tonal(
                    key: const Key('nfc-again'),
                    onPressed: _start,
                    child: Text(retry ? l10n.retry : l10n.nfcWriteAnother),
                  ),
                TextButton(
                  key: const Key('nfc-close'),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    _waiting
                        ? MaterialLocalizations.of(context).cancelButtonLabel
                        : MaterialLocalizations.of(context).closeButtonLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
