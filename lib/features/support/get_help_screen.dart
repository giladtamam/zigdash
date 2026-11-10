import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/router/routes.dart';
import '../../shortcuts/shortcut_service.dart';
import '../onboarding/setup/setup_error_guidance.dart';
import 'community.dart';
import 'help_tips.dart';
import 'support_details.dart';
import 'support_facts.dart';
import 'support_sender.dart';

/// Where Support requests went until 3.4.7, and still the address shown
/// when nothing else works (docs/design/support.md §1).
const supportEmail = 'giladtamam1@gmail.com';

/// A new email to [supportEmail]: [subject], a [prompt] to answer, and the
/// Support details [details] at the bottom, where the user can read or
/// delete any line before sending. Kept for the share sheet's mail apps and
/// for tests; the screen itself sends in-app since 3.4.8.
Uri supportMailUrl({
  required String subject,
  required String prompt,
  required String details,
}) =>
    Uri(
      scheme: 'mailto',
      path: supportEmail,
      // Uri's queryParameters encode spaces as '+', which mail apps show.
      query: 'subject=${Uri.encodeComponent(subject)}'
          '&body=${Uri.encodeComponent('$prompt\n\n\n— Support details —\n$details')}',
    );

/// Opens a mailto URL; replaced in tests.
@visibleForTesting
Future<bool> Function(Uri url) openMailApp =
    (url) => launchUrl(url, mode: LaunchMode.externalApplication);

/// Opens Android's share sheet with [text]; false where there is none.
/// Replaced in tests.
@visibleForTesting
Future<bool> Function(String text, String title) shareText =
    (text, title) async =>
        await appChannel.invokeMethod<bool>('shareText', {
          'text': text,
          'title': title,
        }) ??
        false;

/// What Send is doing or did.
enum _SendState { idle, sending, sent, failed }

/// The one screen every help link opens (CONTEXT.md: Get help). Since 3.4.8
/// (help-and-review-2026-11.md) it is built around sending: the promise, a
/// message field, Send, then Share details and the Telegram group, with the
/// tips last. Opened from the empty scan's warm button it first asks whether
/// Zigbee2MQTT runs at all, since most empty scans are people without a hub,
/// and a message from them is one nobody can answer.
class GetHelpScreen extends ConsumerStatefulWidget {
  const GetHelpScreen({
    super.key,
    required this.from,
    this.connectionId,
    this.error,
  });

  final HelpFrom from;

  /// The home it was opened for, if any; adds its connection and
  /// Zigbee2MQTT facts to Support details.
  final String? connectionId;

  /// The setup error the user saw, when [from] is a setup error.
  final SetupErrorKind? error;

  @override
  ConsumerState<GetHelpScreen> createState() => _GetHelpScreenState();
}

class _GetHelpScreenState extends ConsumerState<GetHelpScreen> {
  final _ticked = <int>{};
  final _message = TextEditingController();
  final _email = TextEditingController();
  var _send = _SendState.idle;

  /// The triage answer on the empty-scan path: null until answered.
  Z2mRunning? _running;

  SupportQuery get _query => (
        openedFrom: openedFromLabel(widget.from, widget.error),
        connectionId: widget.connectionId,
      );

  bool get _asksFirst => widget.from == HelpFrom.scanEmpty && _running == null;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).track(HelpOpened(widget.from));
    _message.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _message.dispose();
    _email.dispose();
    super.dispose();
  }

  void _answer(Z2mRunning answer) {
    ref.read(analyticsProvider).track(SetupStep(
          SetupStepKind.z2mRunning,
          result: answer,
          addressFrom: HelpFrom.scanEmpty,
        ));
    if (answer == Z2mRunning.notYet) {
      // Nothing to fix: what a hub is and where to get one.
      context.pushReplacement(Routes.setupNoHubFrom(NoHubFrom.guide.name));
      return;
    }
    setState(() => _running = answer);
  }

  SupportMessage _messageFor(SupportDetails details) => SupportMessage(
        text: _message.text.trim(),
        email: _email.text.trim(),
        details: details.format(),
        appVersion: details.appVersion,
        build: details.build,
        locale: Localizations.localeOf(context).toLanguageTag(),
      );

  Future<void> _sendMessage(SupportDetails details) async {
    if (_message.text.trim().isEmpty || _send == _SendState.sending) return;
    setState(() => _send = _SendState.sending);
    final message = _messageFor(details);
    final ok = await ref.read(supportSenderProvider)(message);
    if (!mounted) return;
    ref.read(analyticsProvider).track(SupportSent(
          widget.from,
          ok ? SupportSendResult.sent : SupportSendResult.failed,
        ));
    setState(() => _send = ok ? _SendState.sent : _SendState.failed);
  }

  /// Share instead, after a failed Send: the same message, the user's way.
  Future<void> _shareAfterFailure(SupportDetails details) async {
    final shared = await _share(_messageFor(details).asText());
    if (shared) {
      ref
          .read(analyticsProvider)
          .track(SupportSent(widget.from, SupportSendResult.sharedAfterFailure));
    }
  }

  /// Share details on their own, with no message: the share sheet, or the
  /// clipboard where there is none.
  Future<void> _shareDetails(String text) async {
    final shared = await _share(text);
    ref.read(analyticsProvider).track(SupportContact(
          widget.from,
          shared ? ContactVia.share : ContactVia.copy,
        ));
  }

  Future<bool> _share(String text) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    var shared = false;
    try {
      shared = await shareText(text, l10n.getHelpShare);
    } catch (_) {}
    if (!shared) {
      await Clipboard.setData(ClipboardData(text: text));
      messenger.showSnackBar(SnackBar(content: Text(l10n.getHelpCopied)));
    }
    return shared;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tips = tipsFor(l10n, widget.from, widget.error);
    final loaded = ref.watch(supportDetailsProvider(_query));
    // If gathering fails, still let the user reach support with the basics.
    final details = loaded.hasError
        ? SupportDetails(
            appVersion: '?', build: '?', openedFrom: _query.openedFrom)
        : loaded.valueOrNull;
    final text = details?.format();
    final canSend = details != null &&
        _message.text.trim().isNotEmpty &&
        _send != _SendState.sending &&
        _send != _SendState.sent;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.getHelpTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (_asksFirst)
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.getHelpAskRunning,
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        FilledButton(
                          key: const Key('get-help-running-yes'),
                          onPressed: () => _answer(Z2mRunning.yes),
                          child: Text(l10n.setupRunningYes),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          key: const Key('get-help-running-not-yet'),
                          onPressed: () => _answer(Z2mRunning.notYet),
                          child: Text(l10n.setupRunningNotYet),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          key: const Key('get-help-running-not-sure'),
                          onPressed: () => _answer(Z2mRunning.notSure),
                          child: Text(l10n.setupRunningNotSure),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 4, 12),
                  child: Text(l10n.getHelpPromise,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ),
                if (_running == Z2mRunning.notSure)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                    child: Text(
                      l10n.setupRunningNotSureNote(l10n.setupRunningYes),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                if (_send == _SendState.sent)
                  Card(
                    key: const Key('get-help-sent'),
                    margin: EdgeInsets.zero,
                    color: scheme.primaryContainer,
                    child: ListTile(
                      leading: Icon(Icons.check_circle_outline,
                          color: scheme.onPrimaryContainer),
                      title: Text(l10n.getHelpSent,
                          style: TextStyle(color: scheme.onPrimaryContainer)),
                    ),
                  )
                else ...[
                  TextField(
                    key: const Key('get-help-message'),
                    controller: _message,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 2000,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: l10n.getHelpEmailPrompt,
                      hintMaxLines: 2,
                      border: const OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('get-help-email'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: l10n.getHelpEmailHint,
                      prefixIcon: const Icon(Icons.alternate_email),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_send == _SendState.failed) ...[
                    Text(l10n.getHelpSendFailedNote,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.error)),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      key: const Key('get-help-share-instead'),
                      onPressed: details == null
                          ? null
                          : () => _shareAfterFailure(details),
                      icon: const Icon(Icons.ios_share),
                      label: Text(l10n.getHelpSendFailed),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      key: const Key('get-help-retry'),
                      onPressed:
                          details == null ? null : () => _sendMessage(details),
                      child: Text(l10n.getHelpRetry),
                    ),
                  ] else
                    FilledButton.icon(
                      key: const Key('get-help-send'),
                      onPressed: canSend ? () => _sendMessage(details) : null,
                      icon: _send == _SendState.sending
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_outlined),
                      label: Text(_send == _SendState.sending
                          ? l10n.getHelpSending
                          : l10n.getHelpSend),
                    ),
                ],
                const SizedBox(height: 8),
                TextButton.icon(
                  key: const Key('get-help-share'),
                  onPressed: text == null ? null : () => _shareDetails(text),
                  icon: const Icon(Icons.ios_share),
                  label: Text(l10n.getHelpShare),
                ),
                TextButton.icon(
                  onPressed: () => openCommunity(ref, widget.from),
                  icon: const Icon(Icons.forum_outlined),
                  label: Text(l10n.getHelpCommunity),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: EdgeInsets.zero,
                  child: ExpansionTile(
                    key: const Key('get-help-tips'),
                    title: Text(l10n.getHelpTryFirst),
                    shape: const Border(),
                    initiallyExpanded: _running == Z2mRunning.notSure,
                    children: [
                      for (var i = 0; i < tips.length; i++)
                        CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          value: _ticked.contains(i),
                          onChanged: (on) => setState(() => on == true
                              ? _ticked.add(i)
                              : _ticked.remove(i)),
                          title: Text(tips[i].title),
                          subtitle: Text(tips[i].body),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: ExpansionTile(
                    title: Text(l10n.getHelpIncluded),
                    shape: const Border(),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedAlignment: Alignment.centerLeft,
                    children: [
                      if (text == null)
                        const LinearProgressIndicator()
                      else
                        Directionality(
                          // English, whatever the app language.
                          textDirection: TextDirection.ltr,
                          child: SelectableText(text,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontFamily: 'monospace')),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "Still stuck? Get help", the quiet link under a failure's main button.
class GetHelpLink extends StatelessWidget {
  const GetHelpLink({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        child: Text(context.l10n.getHelpLink),
      );
}

/// The warm way in on the empty scan (3.4.8): a button that promises help
/// rather than a quiet link, opening Get help from the scan_empty origin.
class GetHelpWarmButton extends StatelessWidget {
  const GetHelpWarmButton({super.key});

  @override
  Widget build(BuildContext context) => FilledButton.tonalIcon(
        key: const Key('get-help-warm'),
        onPressed: () =>
            context.push(Routes.getHelpFrom(HelpFrom.scanEmpty.name)),
        icon: const Icon(Icons.favorite_outline),
        label: Text(context.l10n.getHelpWarm),
      );
}
