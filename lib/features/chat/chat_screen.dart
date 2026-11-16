import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/router/routes.dart';
import '../../engine/engine_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../remote/founder.dart';
import '../../remote/founder_ui.dart';
import '../../remote/remote_setup.dart';
import '../devices/device_registry.dart' show linkedIeeesProvider;
import '../devices/devices_providers.dart' show homeBaseTopicProvider;
import '../discovery/providers/discovery_provider.dart' show bridgeDevicesStreamProvider;
import '../pro/pro_screen.dart' show openPro;
import 'chat_api.dart';
import 'chat_controls.dart';
import 'chat_hub.dart';
import 'chat_linker.dart';

/// The policy's Chat section.
final chatPolicyUrl = Uri.parse('https://github.com/giladtamam/zigdash/blob/main/store/PRIVACY.md#zigdash-chat-beta');

/// Opens a link outside the app (Telegram, the policy); replaced in tests.
final chatLaunchProvider = Provider<Future<bool> Function(Uri)>(
  (ref) => (uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  },
);

/// What a not-ready Home says instead of Chat.
String chatRowReason(AppLocalizations l10n, ChatRowState state) => switch (state) {
      ChatRowState.noPro => l10n.chatRowNoPro,
      ChatRowState.noRemote => l10n.chatRowNoRemote,
      ChatRowState.noEngine => l10n.chatRowNoEngine,
      ChatRowState.passEnded => l10n.chatRowPassEnded,
      _ => l10n.chatRowReady,
    };

/// One line of What Chat did: the Engine's `sent {"position":50}` read as
/// "set position 50"; refusals keep the Engine's reason.
String auditLine(AppLocalizations l10n, ChatAuditEntry e) {
  final who = e.device ?? e.tool;
  final sent = RegExp(r'^sent (\{.*\})$').firstMatch(e.result);
  if (sent != null) {
    try {
      final command = jsonDecode(sent[1]!) as Map<String, dynamic>;
      final what = [for (final c in command.entries) '${c.key.replaceAll('_', ' ')} ${c.value}'].join(', ');
      return '$who: ${l10n.chatAuditSent(what)}';
    } catch (_) {}
  }
  if (e.result == 'failed') return '$who: ${l10n.chatAuditNotSent}';
  return '$who: ${e.result}';
}

/// Where the Chat row (and the dashboard's "Chat is here" card) goes: the
/// Chat screen, or what the Home still needs first.
VoidCallback? chatRowAction(BuildContext context, ChatRowState state, String connectionId) => switch (state) {
      ChatRowState.ready || ChatRowState.passEnded => () => context.push(Routes.homeChat(connectionId)),
      ChatRowState.noRemote => () => context.push(Routes.homeRemote(connectionId)),
      ChatRowState.noEngine => () => context.go(Routes.homeAutomations(connectionId)),
      ChatRowState.noPro => () => openPro(context, from: ProFrom.settings),
      ChatRowState.hidden => null,
    };

/// Home settings › Chat (beta): only on the Play build, and only says why
/// when the Home can't link yet (chat-linking.md §3).
class ChatSettingsRow extends ConsumerWidget {
  const ChatSettingsRow({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(chatRowStateProvider(connectionId));
    if (state == ChatRowState.hidden) return const SizedBox.shrink();
    final onTap = chatRowAction(context, state, connectionId);
    return ListTile(
      key: const Key('home-chat'),
      leading: const Icon(Icons.chat_outlined),
      title: Text(l10n.chatTitle),
      subtitle: Text(chatRowReason(l10n, state)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// [founder]: a founder's Home, whose 402 is the pass, not a purchase.
String _fail(AppLocalizations l10n, ChatFail why, int? triesLeft, {bool founder = false}) => switch (why) {
      ChatFail.notAtHome => l10n.chatLinkAway,
      ChatFail.engineOld => l10n.chatEngineOld,
      ChatFail.unreachable => l10n.chatFailUnreachable,
      ChatFail.login => l10n.chatFailLogin,
      ChatFail.purchase => founder ? l10n.chatFailPassEnded : l10n.chatFailPurchase,
      ChatFail.passEnded => l10n.chatFailPassEnded,
      ChatFail.tooMany => l10n.chatFailTooMany,
      ChatFail.expired || ChatFail.ticket => l10n.chatFailExpired,
      ChatFail.wrongCode => triesLeft == null ? l10n.chatFailWrongCode : l10n.chatFailWrongCodeLeft(triesLeft),
      ChatFail.notClaimed => l10n.chatFailNotClaimed,
      ChatFail.refused => l10n.chatFailRefused,
    };

String _kind(AppLocalizations l10n, ChatKind kind) => switch (kind) {
      ChatKind.light => l10n.chatKindLight,
      ChatKind.cover => l10n.chatKindCover,
      ChatKind.thermostat => l10n.chatKindThermostat,
      _ => l10n.chatKindSwitch,
    };

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with WidgetsBindingObserver {
  late final ChatLinker _linker;
  late final Analytics _analytics;
  final _code = TextEditingController();

  List<ChatLinkInfo>? _links;
  /// Why the linked accounts didn't load; null while they load or loaded.
  ChatFail? _linksFail;
  String _scope = 'read';

  /// Switches the person moved; the rest keep their defaults.
  final _changed = <String, bool>{};
  PendingChatLink? _pending;
  bool _busy = false;
  ChatFail? _error;
  int? _triesLeft;
  String? _notice;
  List<ChatAuditEntry>? _audit;
  bool _auditLoading = false;
  bool _auditFailed = false;
  bool _counted = false;

  String get _id => widget.connectionId;

  @override
  void initState() {
    super.initState();
    _linker = ref.read(chatLinkerProvider);
    _analytics = ref.read(analyticsProvider);
    // Never while building: the first frame decides whether the Home is ready.
    Future.microtask(_load);
    WidgetsBinding.instance.addObserver(this);
    // The founder status is asked again whenever the screen opens; an
    // upgrade a lost connection left half done goes on.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final l10n = context.l10n;
      final messenger = ScaffoldMessenger.of(context);
      await ref.read(founderRefreshProvider)(_id);
      if (!mounted) return;
      await resumeFounderUpgrade(ref, _id, messenger, l10n);
    });
  }

  /// Back from Telegram (a link, or /unlink there): the list may have changed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_load());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Left before the code came back: the hub client goes (now, or at home).
    final pending = _pending;
    if (pending != null) unawaited(_linker.abandon(_id, pending));
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final row = ref.read(chatRowStateProvider(_id));
    if (row != ChatRowState.ready && row != ChatRowState.passEnded) return;
    if (!_counted && row == ChatRowState.ready) {
      _counted = true;
      _analytics.track(const ChatLinkEvent(ChatLinkStep.intro));
    }
    List<ChatLinkInfo>? links;
    ChatFail? why;
    try {
      links = await _linker.links(_id);
    } on ChatException catch (e) {
      why = e.why;
    }
    if (!mounted) return;
    setState(() {
      _links = links;
      _linksFail = why;
    });
    // Hub deletions owed are done at home; clients unlinked from the chat
    // (/unlink) are dropped here and deleted on the hub then.
    try {
      await _linker.tidy(_id, listed: links);
    } catch (_) {}
  }

  void _failed(ChatFail why, {int? triesLeft}) {
    // The pass ending is counted as the relay's purchase gate it is: no
    // new analytics value (founders-pass.md).
    _analytics.track(ChatLinkEvent(ChatLinkStep.failed,
        why: (why == ChatFail.passEnded ? ChatFail.purchase : why).wire));
    // The pass ended under the screen: the relay is asked, and the screen
    // turns manage-only.
    if (why == ChatFail.passEnded) unawaited(ref.read(founderRefreshProvider)(_id));
    setState(() {
      _error = why;
      _triesLeft = triesLeft;
    });
  }

  bool _engineReady() {
    final view = ref.read(engineViewProvider(_id)).valueOrNull;
    return engineHasChat(view?.report);
  }

  Future<void> _link(List<ChatControlItem> items) async {
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      final pending = await _linker.start(
        _id,
        scope: _scope,
        controls: [for (final i in items) if (_changed[i.ieee] ?? i.defaultOn) i.ieee],
        atHome: ref.read(atHomeProvider(_id)),
        engineReady: _engineReady(),
      );
      if (!mounted) {
        unawaited(_linker.abandon(_id, pending));
        return;
      }
      setState(() => _pending = pending);
      await ref.read(chatLaunchProvider)(pending.telegram);
    } on ChatException catch (e) {
      if (mounted) _failed(e.why);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final pending = _pending;
    if (pending == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final info = await _linker.confirm(_id, pending, _code.text);
      if (!mounted) return;
      _analytics.track(const ChatLinkEvent(ChatLinkStep.linked));
      _code.clear();
      setState(() {
        if (info != null && !(_links ?? const []).any((l) => l.clientId == info.clientId)) {
          _links = [...?_links, info];
          _linksFail = null;
        }
        _pending = null;
        _scope = 'read';
        _changed.clear();
        _notice = context.l10n.chatLinkedDone;
      });
      unawaited(_load());
    } on ChatException catch (e) {
      if (!mounted) return;
      // Wrong, not claimed yet or try again: the same link waits. The pass
      // ending is final: the service dropped the link.
      if (e.why == ChatFail.expired || e.why == ChatFail.ticket || e.why == ChatFail.passEnded) {
        unawaited(_linker.abandon(_id, pending));
        setState(() => _pending = null);
      }
      _failed(e.why, triesLeft: e.triesLeft);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final pending = _pending;
    if (pending == null) return;
    setState(() => _pending = null);
    _code.clear();
    await _linker.abandon(_id, pending);
  }

  Future<void> _remove(ChatLinkInfo link) async {
    final l10n = context.l10n;
    final name = link.telegramName.isEmpty ? 'Telegram' : link.telegramName;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chatRemoveTitle(name)),
        content: Text(l10n.chatRemoveBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
            key: const Key('chat-remove-ok'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.chatRemove),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      final hubDone = await _linker.remove(_id, link.clientId);
      if (!mounted) return;
      _analytics.track(const ChatLinkEvent(ChatLinkStep.removed));
      setState(() {
        _links = [for (final l in _links ?? const <ChatLinkInfo>[]) if (l.clientId != link.clientId) l];
        _notice = hubDone ? null : l10n.chatRemovedLater;
      });
    } on ChatException catch (e) {
      if (mounted) _failed(e.why);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loadAudit() async {
    setState(() {
      _auditLoading = true;
      _auditFailed = false;
    });
    List<ChatAuditEntry>? entries;
    try {
      entries = await _linker.audit(_id);
    } catch (_) {
      entries = null;
    }
    if (!mounted) return;
    setState(() {
      _auditLoading = false;
      _audit = entries;
      _auditFailed = entries == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(chatRowStateProvider(_id));
    // The founder status can come a moment after the screen opened (a
    // phone that never asked the relay): the list loads once it is known.
    ref.listen(chatRowStateProvider(_id), (prev, next) {
      if (prev != next && (next == ChatRowState.ready || next == ChatRowState.passEnded)) unawaited(_load());
    });
    final theme = Theme.of(context);
    final founder = ref.watch(founderStatusProvider(_id)).valueOrNull;
    final now = ref.read(founderNowProvider)();
    final isFounder = founder?.founder ?? false;
    final ended = state == ChatRowState.passEnded;
    if (state != ChatRowState.ready && !ended) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.chatTitle)),
        body: ListView(children: [
          ListTile(
            key: const Key('chat-not-ready'),
            title: Text(chatRowReason(l10n, state)),
            trailing: state == ChatRowState.noRemote ? const Icon(Icons.chevron_right) : null,
            onTap: state == ChatRowState.noRemote ? () => context.push(Routes.homeRemote(_id)) : null,
          ),
        ]),
      );
    }

    final atHome = ref.watch(atHomeProvider(_id));
    // At home this also brings an older Engine up to date, silently.
    final report = atHome ? ref.watch(engineViewProvider(_id)).valueOrNull?.report : null;
    final engineReady = !atHome || engineHasChat(report);
    final engineOld = atHome && report != null && !engineReady;
    var items = const <ChatControlItem>[];
    if (_scope == 'control' && _pending == null) {
      final base = ref.watch(homeBaseTopicProvider(_id)) ?? 'zigbee2mqtt';
      items = chatControlItems(
        ref.watch(bridgeDevicesStreamProvider((connectionId: _id, base: base))).valueOrNull ?? const [],
        onTiles: ref.watch(linkedIeeesProvider(_id)).valueOrNull ?? const {},
        tags: ref.watch(chatTileTagsProvider(_id)).valueOrNull ?? const {},
      );
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    String when(DateTime t) => DateFormat.MMMd(locale).add_Hm().format(t.toLocal());
    String scopeName(String s) => s == 'control' ? l10n.chatScopeControl : l10n.chatScopeRead;
    final links = _links;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              // 1. What it is, what it never does, who reads the messages.
              Card(
                key: const Key('chat-intro'),
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.chatIntroTitle, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(l10n.chatIntroBody),
                      const SizedBox(height: 8),
                      Text(l10n.chatIntroNever, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(l10n.chatIntroBeta),
                      const SizedBox(height: 8),
                      Text(l10n.chatIntroWho),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          key: const Key('chat-policy'),
                          onPressed: () => ref.read(chatLaunchProvider)(chatPolicyUrl),
                          child: Text(l10n.chatPolicy),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_notice != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(_notice!, key: const Key('chat-notice'), style: TextStyle(color: theme.colorScheme.primary)),
                ),
              // 5./6. Linked accounts, one per person.
              ListTile(title: Text(l10n.chatLinkedTitle, style: theme.textTheme.titleMedium)),
              if (links == null && _linksFail == null)
                const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
              else if (links == null)
                ListTile(
                    key: const Key('chat-links-failed'),
                    // The relay's login or the purchase says what to fix; only
                    // a network failure is about the connection.
                    title: Text(_linksFail == ChatFail.unreachable
                        ? l10n.chatLinkedLoadFailed
                        : _fail(l10n, _linksFail!, null, founder: isFounder)))
              else if (links.isEmpty)
                ListTile(key: const Key('chat-links-none'), title: Text(l10n.chatLinkedNone))
              else
                for (final link in links)
                  ListTile(
                    key: Key('chat-link-${link.clientId}'),
                    leading: const Icon(Icons.person_outline),
                    title: Text(link.telegramName.isEmpty ? 'Telegram' : link.telegramName),
                    subtitle: Text(link.lastUsed == null
                        ? l10n.chatLinkedNeverUsed(scopeName(link.scope))
                        : l10n.chatLinkedLine(scopeName(link.scope), when(link.lastUsed!))),
                    trailing: TextButton(
                      key: Key('chat-remove-${link.clientId}'),
                      onPressed: _busy ? null : () => _remove(link),
                      child: Text(l10n.chatRemove),
                    ),
                  ),
              if (links != null && links.isNotEmpty) ...[
                ListTile(
                  key: const Key('chat-audit'),
                  leading: const Icon(Icons.history),
                  title: Text(l10n.chatAuditTitle),
                  trailing: _auditLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : TextButton(onPressed: _loadAudit, child: Text(l10n.chatAuditShow)),
                ),
                if (_auditFailed)
                  ListTile(key: const Key('chat-audit-failed'), title: Text(l10n.chatAuditFailed))
                else if (_audit != null && _audit!.isEmpty)
                  ListTile(title: Text(l10n.chatAuditEmpty))
                else if (_audit != null)
                  for (final e in _audit!.take(50))
                    ListTile(
                      dense: true,
                      title: Text(auditLine(l10n, e)),
                      subtitle: Text(when(e.at)),
                    ),
              ],
              const Divider(height: 32),
              // After the pass: list and remove only; Link gives way to Pro.
              if (ended) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FounderProLine(
                    key: const Key('chat-pass-ended'),
                    connectionId: _id,
                    text: founder?.expiresAt == null
                        ? l10n.founderEndedNoDate
                        : l10n.founderEnded(founderDate(context, founder!.expiresAt!)),
                    from: ProFrom.settings,
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(_fail(l10n, _error!, _triesLeft, founder: isFounder),
                        key: const Key('chat-error'), style: TextStyle(color: theme.colorScheme.error)),
                  ),
              ] else if (_pending == null) ...[
                // The last 7 days of a founder's pass: the date and Get Pro.
                if (founder != null && founder.endsSoonAt(now) && founder.expiresAt != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: FounderProLine(
                      key: const Key('chat-founder-line'),
                      connectionId: _id,
                      text: l10n.founderEndsOn(founderDate(context, founder.expiresAt!)),
                      from: ProFrom.settings,
                    ),
                  ),
                ..._newLink(l10n, theme, items,
                    atHome: atHome,
                    engineReady: engineReady,
                    engineOld: engineOld,
                    another: links?.isNotEmpty ?? false,
                    founder: isFounder),
              ] else
                ..._finish(l10n, theme, _pending!, founder: isFounder),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _newLink(
    AppLocalizations l10n,
    ThemeData theme,
    List<ChatControlItem> items, {
    required bool atHome,
    required bool engineReady,
    required bool engineOld,
    required bool another,
    required bool founder,
  }) =>
      [
        ListTile(title: Text(another ? l10n.chatLinkAnother : l10n.chatLinkNew, style: theme.textTheme.titleMedium)),
        // 2. Scope; Read is pre-selected.
        RadioGroup<String>(
          groupValue: _scope,
          onChanged: (v) {
            if (!_busy && v != null) setState(() => _scope = v);
          },
          child: Column(children: [
            RadioListTile<String>(
              key: const Key('chat-scope-read'),
              value: 'read',
              title: Text(l10n.chatScopeRead),
              subtitle: Text(l10n.chatScopeReadHelp),
            ),
            RadioListTile<String>(
              key: const Key('chat-scope-control'),
              value: 'control',
              title: Text(l10n.chatScopeControl),
              subtitle: Text(l10n.chatScopeControlHelp),
            ),
          ]),
        ),
        // 3. The control list.
        if (_scope == 'control') ...[
          ListTile(
            title: Text(l10n.chatControlsTitle, style: theme.textTheme.titleSmall),
            subtitle: Text(l10n.chatControlsHelp),
          ),
          if (items.isEmpty)
            ListTile(key: const Key('chat-controls-none'), title: Text(l10n.chatControlsEmpty))
          else
            for (final i in items)
              SwitchListTile(
                key: Key('chat-control-${i.ieee}'),
                value: _changed[i.ieee] ?? i.defaultOn,
                onChanged: _busy ? null : (v) => setState(() => _changed[i.ieee] = v),
                title: Text(i.name),
                subtitle: Text(i.gate ? '${_kind(l10n, i.kind)} · ${l10n.chatGateNote}' : _kind(l10n, i.kind)),
              ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(l10n.chatAgeAndAccount, key: const Key('chat-age'), style: theme.textTheme.bodySmall),
        ),
        if (engineOld)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(l10n.chatEngineOld, key: const Key('chat-engine-old')),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(_fail(l10n, _error!, _triesLeft, founder: founder),
                key: const Key('chat-error'), style: TextStyle(color: theme.colorScheme.error)),
          ),
        // 4. Linking writes to the hub over the home network.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: FilledButton.icon(
            key: const Key('chat-link'),
            icon: _busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(atHome ? Icons.send_outlined : Icons.home_outlined),
            onPressed: atHome && engineReady && !_busy ? () => _link(items) : null,
            label: Text(atHome ? l10n.chatLinkButton : l10n.chatLinkAway, textAlign: TextAlign.center),
          ),
        ),
      ];

  List<Widget> _finish(AppLocalizations l10n, ThemeData theme, PendingChatLink pending, {required bool founder}) => [
        ListTile(
          key: const Key('chat-finish'),
          title: Text(l10n.chatCodeTitle, style: theme.textTheme.titleMedium),
          subtitle: Text(l10n.chatCodeBody),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            key: const Key('chat-code'),
            controller: _code,
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l10n.chatCodeHint),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _code.text.length == 4 && !_busy ? _confirm() : null,
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(_fail(l10n, _error!, _triesLeft, founder: founder),
                key: const Key('chat-error'), style: TextStyle(color: theme.colorScheme.error)),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton(
              key: const Key('chat-confirm'),
              onPressed: _code.text.length == 4 && !_busy ? _confirm : null,
              child: Text(l10n.chatCodeConfirm),
            ),
            TextButton(
              key: const Key('chat-open-telegram'),
              onPressed: () => ref.read(chatLaunchProvider)(pending.telegram),
              child: Text(l10n.chatOpenTelegram),
            ),
            TextButton(
              key: const Key('chat-cancel'),
              onPressed: _busy ? null : _cancel,
              child: Text(l10n.cancel),
            ),
          ]),
        ),
      ];
}
