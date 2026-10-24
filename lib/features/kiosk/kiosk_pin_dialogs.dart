import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/l10n_ext.dart';
import 'kiosk.dart';

/// Asks for a new kiosk PIN twice; returns it, or null when dismissed.
Future<String?> askNewKioskPin(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => const _NewPinDialog(),
  );
}

class _NewPinDialog extends StatefulWidget {
  const _NewPinDialog();

  @override
  State<_NewPinDialog> createState() => _NewPinDialogState();
}

class _NewPinDialogState extends State<_NewPinDialog> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final pin = _first.text;
    if (!isValidKioskPin(pin)) {
      setState(() => _error = l10n.kioskPinHint);
      return;
    }
    if (pin != _second.text) {
      setState(() => _error = l10n.kioskPinMismatch);
      return;
    }
    Navigator.pop(context, pin);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.kioskPinSetTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PinField(
            controller: _first,
            hint: l10n.kioskPinHint,
            autofocus: true,
          ),
          const SizedBox(height: 12),
          _PinField(
            controller: _second,
            hint: l10n.kioskPinConfirmHint,
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.kioskPinSet)),
      ],
    );
  }
}

/// Asks for the kiosk PIN until [check] accepts it or the dialog is
/// dismissed. Returns true when accepted. "Forgot the PIN?" explains the
/// only way out (clearing the app's data) rather than offering a bypass.
Future<bool> askKioskPin(
  BuildContext context,
  Future<bool> Function(String pin) check,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => _EnterPinDialog(check: check),
  );
  return ok ?? false;
}

class _EnterPinDialog extends StatefulWidget {
  const _EnterPinDialog({required this.check});
  final Future<bool> Function(String pin) check;

  @override
  State<_EnterPinDialog> createState() => _EnterPinDialogState();
}

class _EnterPinDialogState extends State<_EnterPinDialog> {
  final _pin = TextEditingController();
  bool _wrong = false;
  bool _forgot = false;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await widget.check(_pin.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      _pin.clear();
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l10n.kioskPinEnterTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PinField(
            controller: _pin,
            hint: l10n.kioskPinHint,
            autofocus: true,
            onSubmitted: (_) => _submit(),
          ),
          if (_wrong) ...[
            const SizedBox(height: 8),
            Text(
              l10n.kioskPinWrong,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 8),
          if (_forgot)
            Text(
              Platform.isIOS
                  ? l10n.kioskPinForgotBodyIos
                  : l10n.kioskPinForgotBody,
              style: theme.textTheme.bodySmall,
            )
          else
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => setState(() => _forgot = true),
                child: Text(l10n.kioskPinForgot),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.kioskLeave)),
      ],
    );
  }
}

class _PinField extends StatelessWidget {
  const _PinField({
    required this.controller,
    required this.hint,
    this.autofocus = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    autofocus: autofocus,
    obscureText: true,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ],
    decoration: InputDecoration(hintText: hint),
    onSubmitted: onSubmitted,
  );
}
