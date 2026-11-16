import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/review/review_prompt_controller.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../l10n/app_localizations.dart';
import '../../chat/chat_linker.dart' show ChatRowState, chatRowStateProvider;
import '../../chat/chat_screen.dart' show chatRowAction;
import '../../onboarding/demo_service.dart' show isDemoConnection;
import '../../pro/pro.dart' show proFlavor;
import '../../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import '../../support/early_access_client.dart';
import 'poll_card.dart' show pollAfterSessions;

/// "1" once the person joined or said "Not for me": the card asks once.
const chatEarlyDoneKey = 'chat_early_done';

/// "1" once a Pro owner tapped Set up or Not now on "Chat is here" (3.7).
const chatHereDoneKey = 'chat_here_done';

/// "1" once `chat_early shown` was sent: the read's denominator is
/// installs, not sessions (assistant-early-access.md §6).
const chatEarlyShownKey = 'chat_early_shown';

/// Only the Play build offers the early-access list in 3.5.4: the foss
/// builds keep to their no-network-service promise and have no usage data
/// to count it, and iOS is in its first App Review (plan §2).
bool chatEarlyOfferedFor(String flavor) => flavor == 'play';

final chatEarlyOfferedProvider = Provider<bool>(
  (_) => chatEarlyOfferedFor(proFlavor),
);

/// "Chat with your home" (3.5.4, docs/design/assistant-early-access.md): a
/// one-time card on a real Home's dashboard from the [pollAfterSessions]th
/// day, after the usage-data question, in the slot the poll card had. The
/// same choices stay in Settings ([showChatEarlySheet]).
class ChatEarlyCard extends ConsumerStatefulWidget {
  const ChatEarlyCard({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<ChatEarlyCard> createState() => _ChatEarlyCardState();
}

class _ChatEarlyCardState extends ConsumerState<ChatEarlyCard> {
  bool _done = false;

  Future<void> _finish() async {
    setState(() => _done = true);
    await ref.read(sharedPreferencesProvider).setString(chatEarlyDoneKey, '1');
  }

  void _markShown() {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getString(chatEarlyShownKey) != null) return;
    prefs.setString(chatEarlyShownKey, '1');
    ref
        .read(analyticsProvider)
        .track(const ChatEarly(ChatEarlyStep.shown, ChatEarlyFrom.card));
  }

  @override
  Widget build(BuildContext context) {
    // 3.7: Chat exists for Pro owners, so they hear it's here (once),
    // not "we're building it", whatever they answered to the list.
    final chat = ref.watch(chatRowStateProvider(widget.connectionId));
    if (chat != ChatRowState.hidden && chat != ChatRowState.noPro) {
      return _ChatHereCard(connectionId: widget.connectionId, state: chat);
    }
    final prefs = ref.watch(sharedPreferencesProvider);
    final consent = ref.watch(analyticsConsentProvider);
    final available = ref.watch(analyticsAvailableProvider);
    final host = ref
        .watch(connectionByIdProvider(widget.connectionId))
        .valueOrNull
        ?.host;
    final sessions = prefs.getInt(ReviewPromptController.kSessions) ?? 0;
    if (_done ||
        !ref.watch(chatEarlyOfferedProvider) ||
        prefs.getString(chatEarlyDoneKey) != null ||
        sessions < pollAfterSessions ||
        host == null ||
        isDemoConnection(host) ||
        // The usage-data question comes first; the cards don't stack.
        (available && consent == AnalyticsConsent.unasked)) {
      return const SizedBox.shrink();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _markShown();
    });
    return Card(
      key: const Key('chat-early-card'),
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 8),
        child: ChatEarlyOffer(
          from: ChatEarlyFrom.card,
          onDone: _finish,
          // Joined: the card stays for the answer and the price question,
          // and is not offered again.
          onJoined: () => ref
              .read(sharedPreferencesProvider)
              .setString(chatEarlyDoneKey, '1'),
        ),
      ),
    );
  }
}

/// "Chat with your home is here": for a Pro owner, once, on a real Home.
/// Set up goes where the Chat row goes (the Chat screen, or what the Home
/// still needs first).
class _ChatHereCard extends ConsumerStatefulWidget {
  const _ChatHereCard({required this.connectionId, required this.state});

  final String connectionId;
  final ChatRowState state;

  @override
  ConsumerState<_ChatHereCard> createState() => _ChatHereCardState();
}

class _ChatHereCardState extends ConsumerState<_ChatHereCard> {
  bool _done = false;

  void _finish() {
    setState(() => _done = true);
    ref.read(sharedPreferencesProvider).setString(chatHereDoneKey, '1');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prefs = ref.watch(sharedPreferencesProvider);
    final consent = ref.watch(analyticsConsentProvider);
    final available = ref.watch(analyticsAvailableProvider);
    final host = ref.watch(connectionByIdProvider(widget.connectionId)).valueOrNull?.host;
    if (_done ||
        prefs.getString(chatHereDoneKey) != null ||
        host == null ||
        isDemoConnection(host) ||
        (available && consent == AnalyticsConsent.unasked)) {
      return const SizedBox.shrink();
    }
    final setUp = chatRowAction(context, widget.state, widget.connectionId);
    final theme = Theme.of(context);
    return Card(
      key: const Key('chat-here-card'),
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.chatHereTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Text(l10n.chatHereBody, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    key: const Key('chat-here-not-now'),
                    onPressed: _finish,
                    child: Text(l10n.chatHereNotNow),
                  ),
                  FilledButton(
                    key: const Key('chat-here-set-up'),
                    onPressed: setUp == null
                        ? null
                        : () {
                            _finish();
                            setUp();
                          },
                    child: Text(l10n.chatHereSetUp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The same choices in a sheet, from Settings › Chat with your home.
Future<void> showChatEarlySheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            24,
            0,
            16,
            16 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: ChatEarlyOffer(
            from: ChatEarlyFrom.settings,
            onDone: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );

const _privacyUrl =
    'https://github.com/giladtamam/zigdash/blob/main/store/PRIVACY.md#chat-with-your-home-early-access';

enum _Stage { offer, email, sending, joined }

/// The pitch and its choices: Join on Telegram, Join by email (a field,
/// then the place on the list and one price question), or Not for me.
class ChatEarlyOffer extends ConsumerStatefulWidget {
  const ChatEarlyOffer({
    super.key,
    required this.from,
    required this.onDone,
    this.onJoined,
  });

  final ChatEarlyFrom from;
  final VoidCallback onDone;
  final VoidCallback? onJoined;

  @override
  ConsumerState<ChatEarlyOffer> createState() => _ChatEarlyOfferState();
}

class _ChatEarlyOfferState extends ConsumerState<ChatEarlyOffer> {
  final _email = TextEditingController();
  final _nonce = earlyNonce();
  _Stage _stage = _Stage.offer;
  EarlyJoin? _joined;
  bool _failed = false;
  bool _badEmail = false;
  bool _priced = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _track(ChatEarlyStep step) =>
      ref.read(analyticsProvider).track(ChatEarly(step, widget.from));

  /// Counted in the read only from the card with usage data on, so joins
  /// and `shown` describe the same people (plan §6).
  bool get _counted =>
      widget.from == ChatEarlyFrom.card &&
      ref.read(analyticsAvailableProvider) &&
      ref.read(analyticsConsentProvider) == AnalyticsConsent.granted;

  Future<void> _telegram() async {
    _track(ChatEarlyStep.telegram);
    await launchUrl(
      earlyTelegramLink(counted: _counted),
      mode: LaunchMode.externalApplication,
    );
    widget.onDone();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email) ||
        email.length > 254) {
      setState(() => _badEmail = true);
      return;
    }
    setState(() {
      _badEmail = false;
      _failed = false;
      _stage = _Stage.sending;
    });
    final joined = await ref.read(earlyJoinerProvider)(
      email: email,
      lang: Localizations.localeOf(context).languageCode,
      counted: _counted,
      nonce: _nonce,
    );
    if (!mounted) return;
    if (joined == null) {
      _track(ChatEarlyStep.emailFailed);
      setState(() {
        _failed = true;
        _stage = _Stage.email;
      });
      return;
    }
    _track(ChatEarlyStep.emailSent);
    widget.onJoined?.call();
    setState(() {
      _joined = joined;
      _stage = _Stage.joined;
    });
  }

  Future<void> _price(String answer, ChatEarlyStep step) async {
    _track(step);
    setState(() => _priced = true);
    await ref.read(earlyPricerProvider)(
      email: _email.text.trim(),
      token: _nonce,
      answer: answer,
    );
  }

  String _place(AppLocalizations l10n, EarlyJoin j) {
    final position = j.position;
    if (position == null) return l10n.chatEarlyListed;
    return j.free
        ? l10n.chatEarlyInFirst(position, earlyFreePlaces)
        : l10n.chatEarlyAfterFirst(position, earlyFreePlaces);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = widget.from == ChatEarlyFrom.settings;
    final children = <Widget>[
      Text(l10n.chatEarlyTitle, style: theme.textTheme.titleMedium),
      const SizedBox(height: 8),
    ];
    switch (_stage) {
      case _Stage.offer:
        children.addAll([
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Text(
              l10n.chatEarlyBody(earlyFreePlaces),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  key: const Key('chat-early-not-for-me'),
                  onPressed: () {
                    if (!settings) _track(ChatEarlyStep.notForMe);
                    widget.onDone();
                  },
                  child: Text(
                    settings ? l10n.chatEarlyClose : l10n.chatEarlyNotForMe,
                  ),
                ),
                TextButton(
                  key: const Key('chat-early-email'),
                  onPressed: () => setState(() => _stage = _Stage.email),
                  child: Text(l10n.chatEarlyEmail),
                ),
                FilledButton(
                  key: const Key('chat-early-telegram'),
                  onPressed: _telegram,
                  child: Text(l10n.chatEarlyTelegram),
                ),
              ],
            ),
          ),
        ]);
      case _Stage.email:
      case _Stage.sending:
        final sending = _stage == _Stage.sending;
        children.addAll([
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: TextField(
              key: const Key('chat-early-email-field'),
              controller: _email,
              enabled: !sending,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.chatEarlyEmailHint,
                errorText: _badEmail
                    ? l10n.chatEarlyBadEmail
                    : (_failed ? l10n.chatEarlyFailed : null),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Text(
              l10n.chatEarlyEmailUse,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse(_privacyUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(l10n.chatEarlyPrivacy),
                ),
                FilledButton(
                  key: const Key('chat-early-send'),
                  onPressed: sending ? null : _send,
                  child: Text(l10n.chatEarlySend),
                ),
              ],
            ),
          ),
        ]);
      case _Stage.joined:
        final joined = _joined!;
        children.addAll([
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Text(
              _place(l10n, joined),
              key: const Key('chat-early-place'),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          if (!joined.listed && !_priced) ...[
            Text(l10n.chatEarlyPrice, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  key: const Key('chat-early-price-yes'),
                  label: Text(l10n.chatEarlyYes),
                  onPressed: () => _price('yes', ChatEarlyStep.priceYes),
                ),
                ActionChip(
                  key: const Key('chat-early-price-maybe'),
                  label: Text(l10n.chatEarlyMaybe),
                  onPressed: () => _price('maybe', ChatEarlyStep.priceMaybe),
                ),
                ActionChip(
                  key: const Key('chat-early-price-no'),
                  label: Text(l10n.chatEarlyNo),
                  onPressed: () => _price('no', ChatEarlyStep.priceNo),
                ),
              ],
            ),
          ] else if (_priced)
            Text(l10n.chatEarlyThanks, style: theme.textTheme.bodyMedium),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              key: const Key('chat-early-done'),
              onPressed: widget.onDone,
              child: Text(l10n.chatEarlyClose),
            ),
          ),
        ]);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
