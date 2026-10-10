import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../onboarding/setup/setup_error_guidance.dart';
import 'help_tips.dart';
import 'support_details.dart';
import 'support_facts.dart';

/// Where Support requests go: the developer's existing address, kept on
/// 2026-10-10 instead of a dedicated one (docs/design/support.md §1).
const supportEmail = 'giladtamam1@gmail.com';

/// A new email to [supportEmail]: [subject], a [prompt] to answer, and the
/// Support details [details] at the bottom, where the user can read or
/// delete any line before sending.
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

/// The one screen every help link opens (CONTEXT.md: Get help): the tips for
/// the place it came from, the support promise, what Support details
/// contains, then Contact support or Copy details.
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

  SupportQuery get _query => (
        openedFrom: openedFromLabel(widget.from, widget.error),
        connectionId: widget.connectionId,
      );

  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).track(HelpOpened(widget.from));
  }

  Future<void> _contact(String details) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    ref
        .read(analyticsProvider)
        .track(SupportContact(widget.from, ContactVia.email));
    var opened = false;
    try {
      opened = await openMailApp(supportMailUrl(
        subject: l10n.getHelpEmailSubject,
        prompt: l10n.getHelpEmailPrompt,
        details: details,
      ));
    } catch (_) {}
    if (!opened) {
      messenger.showSnackBar(SnackBar(
          content: Text(l10n.getHelpNoEmailApp(supportEmail))));
    }
  }

  Future<void> _copy(String details) async {
    final messenger = ScaffoldMessenger.of(context);
    final copied = context.l10n.getHelpCopied;
    ref
        .read(analyticsProvider)
        .track(SupportContact(widget.from, ContactVia.copy));
    await Clipboard.setData(ClipboardData(text: details));
    messenger.showSnackBar(SnackBar(content: Text(copied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tips = tipsFor(l10n, widget.from, widget.error);
    final details = ref.watch(supportDetailsProvider(_query));
    // If gathering fails, still let the user reach support with the basics.
    final text = details.hasError
        ? SupportDetails(
                appVersion: '?', build: '?', openedFrom: _query.openedFrom)
            .format()
        : details.valueOrNull?.format();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.getHelpTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 4, 8),
                child: Semantics(
                  header: true,
                  child: Text(l10n.getHelpTryFirst,
                      style: theme.textTheme.titleMedium),
                ),
              ),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < tips.length; i++)
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _ticked.contains(i),
                        onChanged: (on) => setState(() =>
                            on == true ? _ticked.add(i) : _ticked.remove(i)),
                        title: Text(tips[i].title),
                        subtitle: Text(tips[i].body),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                child: Text(l10n.getHelpPromise,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ),
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
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: text == null ? null : () => _contact(text),
                icon: const Icon(Icons.mail_outline),
                label: Text(l10n.getHelpContact),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: text == null ? null : () => _copy(text),
                icon: const Icon(Icons.copy),
                label: Text(l10n.getHelpCopy),
              ),
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
