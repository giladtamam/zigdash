import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:go_router/go_router.dart';

import '../../../mqtt/ha_token.dart';
import '../../../mqtt/ha_address.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shortcuts/shortcut_service.dart' show appChannel;
import '../../ha_import/ha_auth.dart';
import '../../connections/discovery/network_info.dart';
import '../../connections/discovery/subnet.dart';
import 'ai_help.dart';
import 'ha_address_shape.dart';
import 'ha_connect.dart';
import 'ha_discovery.dart';
import 'ha_handover.dart';
import 'setup_coordinator.dart' show SetupPlatform;
import 'setup_providers.dart';
import 'setup_waiting.dart';

/// "Connect through Home Assistant" (docs/design/ha-route.md): the address,
/// a sign-in (Home Assistant's login page, or a pasted token), a check,
/// then back to setup, which reviews the devices.
class HaConnectScreen extends ConsumerStatefulWidget {
  const HaConnectScreen({
    super.key,
    this.initialHost,
    this.shared = false,
    this.controller,
    this.again,
    this.offWifi = false,
  });

  /// Opened by text shared to ZigDash from another app
  /// (ha-share-paste.md): [initialHost] is the address it held, or null
  /// when it held none.
  final bool shared;

  /// The Home Assistant the scan saw, if any.
  final String? initialHost;

  /// Signing in again for this existing home (2.10.1): the new sign-in
  /// replaces the stored one, and the screen returns to the home's form.
  final String? again;

  /// Opened from the no-Wi-Fi screen (3.1.9): no network to look on, so
  /// the address is typed (a remote one, on mobile data).
  final bool offWifi;

  /// Tests pass one; the screen builds its own otherwise.
  final HaConnectController? controller;

  @override
  ConsumerState<HaConnectScreen> createState() => _HaConnectScreenState();
}

class _HaConnectScreenState extends ConsumerState<HaConnectScreen>
    with WidgetsBindingObserver {
  late final HaConnectController _controller = widget.controller ?? _make();

  /// The "couldn't find it" card (3.5.2, ha-nothing-found.md): whether the
  /// Home Assistant app can be opened (Android, checked on the phone and
  /// never sent), whether the phone is on Wi-Fi now, whether this look's
  /// "shown" was counted, and whether Look again is running (the card
  /// stays in place meanwhile).
  var _haApp = false;
  bool? _onWifi;
  var _noneCounted = false;
  var _retrying = false;

  bool get _nothingFound =>
      widget.again == null &&
      (_retrying || (_controller.looked && _controller.found.isEmpty));

  Future<void> _checkHaApp() async {
    if (!Platform.isAndroid) return;
    var installed = false;
    try {
      installed =
          await appChannel.invokeMethod<bool>('haAppInstalled') ?? false;
    } catch (_) {}
    if (mounted && installed != _haApp) setState(() => _haApp = installed);
  }

  Future<bool> _checkWifi() async {
    final onWifi = await _controller.onHomeNetwork();
    if (mounted && onWifi != _onWifi) setState(() => _onWifi = onWifi);
    return onWifi;
  }

  /// Someone who left to join Wi-Fi or to copy the address comes back to
  /// the right line and the right button.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_nothingFound) return;
    _checkWifi();
    _checkHaApp();
  }

  void _none(HaNoneChoice choice, {String? network}) => ref
      .read(analyticsProvider)
      .track(SetupStep(SetupStepKind.haNone, choice: choice, network: network));

  Future<void> _openHaApp() async {
    _none(HaNoneChoice.openApp);
    var opened = false;
    try {
      opened = await appChannel.invokeMethod<bool>('openHaApp') ?? false;
    } catch (_) {}
    // Disabled since the check: the browser lines show instead.
    if (!opened && mounted) setState(() => _haApp = false);
  }

  Future<void> _lookAgain() async {
    _none(HaNoneChoice.lookAgain);
    setState(() {
      _retrying = true;
      _noneCounted = false;
    });
    await _controller.lookAgain();
    if (mounted) setState(() => _retrying = false);
  }

  void _askAssistant() {
    _none(HaNoneChoice.assistant);
    context.push(
      Routes.getHelpFrom(HelpFrom.haConnect.name, platform: 'home_assistant'),
    );
  }

  final _address = TextEditingController();
  final _token = TextEditingController();

  /// The address as it was last put into the field for the user (found,
  /// pasted or shared); once the field says anything else, it was typed.
  var _filled = '';

  /// The Paste button found no address in what was copied.
  var _pasteNothing = false;

  /// Puts [address] in the field and remembers how it got there.
  void _fill(String address, HaAddressFrom from) {
    _filled = address;
    _controller.addressFrom = from;
    _address.text = address;
  }

  void _edited() {
    if (_address.text == _filled) return;
    _filled = '';
    _controller.addressFrom = HaAddressFrom.typed;
    if (_pasteNothing) setState(() => _pasteNothing = false);
  }

  /// The Paste button (ha-share-paste.md): the clipboard is read here, on
  /// the tap, and nowhere else. Only the address in it is kept.
  Future<void> _paste() async {
    String? text;
    try {
      text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    } catch (_) {}
    if (!mounted) return;
    final address = haAddressIn(text ?? '');
    ref
        .read(analyticsProvider)
        .track(
          SetupStep(
            SetupStepKind.haPaste,
            result: address == null ? HaHandover.noAddress : HaHandover.address,
          ),
        );
    setState(() {
      if (address != null) _fill(address, HaAddressFrom.pasted);
      _pasteNothing = address == null;
    });
  }

  @override
  void initState() {
    super.initState();
    final initial = switch (_controller.value) {
      HaConnectAsk(:final address) when address.isNotEmpty => address,
      _ => widget.initialHost ?? '',
    };
    if (initial.isNotEmpty) {
      // Shared from another app, or seen by the scan.
      _fill(
        initial,
        widget.shared ? HaAddressFrom.shared : HaAddressFrom.found,
      );
    }
    _address.addListener(_edited);
    _controller.addListener(_onState);
    WidgetsBinding.instance.addObserver(this);
    _checkHaApp();
    // 3.1.8: nothing to go on, so look for Home Assistant on the network.
    if (_address.text.trim().isEmpty &&
        widget.again == null &&
        !widget.offWifi) {
      _controller.look();
    }
  }

  HaConnectController _make() => HaConnectController(
    address: widget.initialHost ?? '',
    onEvent: (event) => ref.read(analyticsProvider).track(event),
    adopt: (address, signIn) => widget.again == null
        ? ref
              .read(setupCoordinatorProvider)
              .adoptHomeAssistant(address: address, signIn: signIn)
        : _replaceSignIn(widget.again!, address, signIn),
    reach: reachHomeAssistant,
    confirm: confirmHomeAssistant,
    find: findHomeAssistant,
    phoneIp: () async => (await homeIpv4())?.ip,
    signIn: (base) => signInToHa(
      base,
      browser: (url) => FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: haCallbackScheme,
      ),
    ),
  );

  /// The new sign-in replaces the stored one; the old refresh token is
  /// ended at Home Assistant (best effort) and the live connection, if
  /// any, is rebuilt with the new token.
  Future<void> _replaceSignIn(String id, Uri address, String signIn) async {
    final repo = ref.read(connectionRepoProvider);
    final old = await repo.readPassword(id);
    final home = await repo.getById(id);
    final oldBase = home == null ? null : haBaseUri(home.host);
    if (old != null && isHaRefresh(old) && oldBase != null && old != signIn) {
      try {
        await revokeHaSignIn(
          oldBase,
          old.substring(haRefreshPrefix.length),
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
    await repo.setHomeAssistantSignIn(id, address: address, signIn: signIn);
    ref.invalidate(mqttManagerProvider(id));
  }

  void _onState() {
    if (!mounted) return;
    if (_controller.value is HaConnectDone) {
      if (widget.again != null) {
        // Back to the home's form.
        Navigator.of(context).maybePop();
        return;
      }
      // Setup shows the review (or why it failed) from here, whether this
      // screen was opened from the empty result or from manual entry.
      context.go(Routes.setup);
      return;
    }
    // 3.5.2: each look that found nothing is counted once, with whether
    // the phone is on Wi-Fi, which also picks the card's why line.
    if (_controller.looked &&
        _controller.found.isEmpty &&
        !_noneCounted &&
        widget.again == null) {
      _noneCounted = true;
      _checkWifi().then((onWifi) {
        if (mounted) {
          _none(HaNoneChoice.shown, network: onWifi ? 'Wi-Fi' : 'other');
        }
      });
    }
    // What the look found, or the address a try went to, fills an empty
    // field; a typed address is never replaced.
    if (_address.text.trim().isEmpty) {
      final state = _controller.value;
      final found = _controller.found;
      if (state is HaConnectAsk && state.address.isNotEmpty) {
        _fill(state.address, HaAddressFrom.found);
      } else if (found.length == 1) {
        _fill(found.single.address, HaAddressFrom.found);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onState);
    if (widget.controller == null) _controller.dispose();
    _address.removeListener(_edited);
    _address.dispose();
    _token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = _controller.value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.haConnectTitle)),
      body: SafeArea(
        child: switch (state) {
          HaConnectAsk() => _Ask(
            state: state,
            address: _address,
            token: _token,
            canSignIn: _controller.canSignIn,
            looking: _controller.looking,
            looked: _controller.looked,
            nothingFound: _nothingFound
                ? _NothingFound(
                    onWifi: _onWifi,
                    haApp: _haApp,
                    retrying: _retrying,
                    onOpenApp: _openHaApp,
                    onLookAgain: _lookAgain,
                    onAssistant: _askAssistant,
                  )
                : null,
            found: _controller.found,
            phoneIp: _controller.phoneIp,
            onPick: (address) =>
                setState(() => _fill(address, HaAddressFrom.found)),
            onPaste: _paste,
            pasteNothing: _pasteNothing,
            // What a share brought: its address, still in the field, or
            // nothing usable.
            shared: !widget.shared
                ? null
                : widget.initialHost == null
                // Said only while the field is still empty: the look may
                // find Home Assistant by itself.
                ? (_address.text.trim().isEmpty ? HaHandover.noAddress : null)
                : _address.text == _filled && _filled.isNotEmpty
                ? HaHandover.address
                : null,
            shareTarget: ref.watch(haShareTargetProvider).value ?? false,
            onWhere: (where) => ref
                .read(analyticsProvider)
                .track(SetupStep(SetupStepKind.haWhere, choice: where)),
            onSignIn: () => _controller.signInAndConnect(_address.text),
            onToken: () =>
                _controller.connectWithToken(_address.text, _token.text),
          ),
          HaConnectChecking() => SetupWaiting(
            title: l10n.haConnectChecking,
            onCancel: _controller.cancel,
          ),
          HaConnectDone() => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.haConnectChecking),
              ],
            ),
          ),
        },
      ),
    );
  }
}

class _Ask extends StatefulWidget {
  const _Ask({
    required this.state,
    required this.address,
    required this.token,
    required this.canSignIn,
    required this.onSignIn,
    required this.onToken,
    this.looking = false,
    this.looked = false,
    this.nothingFound,
    this.found = const [],
    this.phoneIp,
    this.onPick,
    this.onWhere,
    this.onPaste,
    this.pasteNothing = false,
    this.shared,
    this.shareTarget = false,
  });
  final HaConnectAsk state;

  /// The Paste button (ha-share-paste.md), and whether its last tap found
  /// no address in what was copied.
  final VoidCallback? onPaste;
  final bool pasteNothing;

  /// What a share from another app brought, while it is still what the
  /// field says; null when the screen was opened another way.
  final HaHandover? shared;

  /// Whether ZigDash is in other apps' share sheets now: the help then
  /// says to share, otherwise to copy and paste.
  final bool shareTarget;

  /// The phone's own address, for "that address is on another network".
  final String? phoneIp;

  /// The "couldn't find it" card (3.5.2), when the last look found nothing.
  final _NothingFound? nothingFound;

  /// Looking for Home Assistant on the network (3.1.8), and what it found.
  final bool looking;
  final bool looked;
  final List<HaFound> found;
  final ValueChanged<String>? onPick;

  /// A chip under "where do you open Home Assistant?" was tapped (3.3.4).
  final ValueChanged<HaWhere>? onWhere;
  final TextEditingController address;
  final TextEditingController token;
  final bool canSignIn;
  final VoidCallback onSignIn;
  final VoidCallback onToken;

  @override
  State<_Ask> createState() => _AskState();
}

class _AskState extends State<_Ask> {
  var _tokenOpen = false;
  HaWhere? _where;

  @override
  void initState() {
    super.initState();
    widget.address.addListener(_typed);
  }

  @override
  void dispose() {
    widget.address.removeListener(_typed);
    super.dispose();
  }

  void _typed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final problem = widget.state.problem;
    // 3.3.1: with the field empty and no look under way, signing in can
    // only end in "type the address": 503 of 553 taps in the last week of
    // October, one user 38 times. So the button waits for an address, and
    // where to find it shows at once. 3.4.8: during the look too. A tap
    // then used to wait for what the look found, but 136 of 151 looks
    // (Nov 6-8) found nothing, so the tap was wasted: 79 of 118 sign-in
    // taps ended as "no address". The button now says it is looking.
    final noAddress = widget.address.text.trim().isEmpty;
    final looking = noAddress && widget.looking;
    // The token opens by itself when it is the way forward.
    final tokenOpen =
        _tokenOpen ||
        !widget.canSignIn ||
        problem == HaConnectProblem.signInRefused ||
        problem == HaConnectProblem.badToken ||
        problem == HaConnectProblem.noToken ||
        problem == HaConnectProblem.notAdmin;
    final none = widget.nothingFound;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.haConnectIntro, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        // 3.5.2: what to do when the look found nothing comes first, not in
        // the middle of the page (ha-nothing-found.md). It depends on the
        // look alone, so nothing above the field moves while typing.
        if (none != null) ...[
          _NothingFoundCard(card: none, shareTarget: widget.shareTarget),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: widget.address,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: none != null
                ? l10n.haNoneTypeLabel
                : l10n.haImportAddress,
            hintText: _where == null ? null : _whereExample[_where],
            helperText: none != null ? null : l10n.haConnectAddressHelp,
            helperMaxLines: 5,
            errorText: problem == HaConnectProblem.noAddress
                ? l10n.haImportNoAddress
                : null,
          ),
        ),
        if (widget.onPaste != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const Key('ha-paste'),
              onPressed: widget.onPaste,
              icon: const Icon(Icons.content_paste, size: 18),
              label: Text(l10n.haPaste),
            ),
          ),
        if (widget.pasteNothing)
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.haPasteNothing,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        if (widget.shared == HaHandover.address) ...[
          const SizedBox(height: 4),
          Text(l10n.haSharedNote, style: theme.textTheme.bodyMedium),
        ] else if (widget.shared == HaHandover.noAddress) ...[
          const SizedBox(height: 4),
          Text(
            l10n.haShareNothing,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (widget.looking && none == null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.haFindLooking,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ] else if (widget.found.length == 1 &&
            widget.address.text == widget.found.single.address) ...[
          const SizedBox(height: 12),
          Text(
            l10n.setupHubSeenHa(_hostOf(widget.found.single)),
            style: theme.textTheme.bodyMedium,
          ),
        ] else if (widget.found.length > 1) ...[
          const SizedBox(height: 12),
          Text(l10n.haFindSeveral, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in widget.found)
                ActionChip(
                  label: Text(
                    f.name == null ? _hostOf(f) : '${f.name} · ${_hostOf(f)}',
                  ),
                  onPressed: () => widget.onPick?.call(f.address),
                ),
            ],
          ),
        ],
        // 3.1.12: a look that found nothing says so at once, and points to
        // the remote address: the stuck 3.1.11 users were all on Wi-Fi with
        // Home Assistant out of the phone's sight, and many left right here.
        if (widget.looked && widget.found.isEmpty && none == null) ...[
          const SizedBox(height: 12),
          Text(l10n.haFindNone, style: theme.textTheme.bodyMedium),
        ],
        // 3.1.4: an empty address was every try on 3.1.3's first night.
        if (problem == HaConnectProblem.noAddress ||
            noAddress ||
            (widget.looked && widget.found.isEmpty)) ...[
          // The address can be handed over instead of typed
          // (ha-share-paste.md): the Home Assistant app shares or copies
          // its server's link, and a browser shares its page.
          if (widget.onPaste != null && none == null) ...[
            const SizedBox(height: 16),
            Text(
              widget.shareTarget ? l10n.haHandoverShare : l10n.haHandoverCopy,
              key: const Key('ha-handover-help'),
              style: theme.textTheme.bodyMedium,
            ),
          ],
          // 3.3.4: where they open Home Assistant decides what its
          // address looks like and where to find it.
          const SizedBox(height: 16),
          Text(l10n.haWhereAsk, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final where in HaWhere.values)
                ChoiceChip(
                  key: Key('ha-where-${where.name}'),
                  label: Text(_whereLabel(l10n, where)),
                  selected: _where == where,
                  onSelected: (_) {
                    setState(() => _where = where);
                    widget.onWhere?.call(where);
                  },
                ),
            ],
          ),
          // Until a chip is picked, the hand-over help above (or the card)
          // says where the address is; the older line said the same at more
          // length.
          if (_where != null || widget.onPaste == null) ...[
            const SizedBox(height: 12),
            Text(
              _where == null
                  ? l10n.haConnectWhereAddress
                  : _whereHelp(l10n, _where!),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
        if (problem != null &&
            problem != HaConnectProblem.noAddress &&
            problem != HaConnectProblem.noToken) ...[
          const SizedBox(height: 16),
          Text(
            problemText(
              l10n,
              problem,
              shape: widget.state.shape,
              phoneIp: widget.phoneIp,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (widget.canSignIn) ...[
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('ha-sign-in'),
            onPressed: noAddress ? null : widget.onSignIn,
            icon: looking
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: Text(looking ? l10n.haConnectLooking : l10n.haImportSignIn),
          ),
          const SizedBox(height: 8),
          Text(l10n.haConnectSignInHelp, style: theme.textTheme.bodySmall),
          if (!tokenOpen)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => setState(() => _tokenOpen = true),
                child: Text(l10n.haImportOrToken),
              ),
            ),
        ],
        if (tokenOpen) ...[
          const SizedBox(height: 16),
          // Plain, not obscured: a pasted 180-character token has to be
          // checkable before it is kept.
          TextField(
            controller: widget.token,
            autocorrect: false,
            enableSuggestions: false,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: l10n.haImportToken,
              helperText: l10n.haConnectTokenHelp,
              helperMaxLines: 12,
              errorText: problem == HaConnectProblem.noToken
                  ? l10n.haImportNoToken
                  : null,
            ),
            onSubmitted: (_) => widget.onToken(),
          ),
          const SizedBox(height: 16),
          widget.canSignIn
              ? OutlinedButton(
                  onPressed: widget.onToken,
                  child: Text(l10n.haConnectWithToken),
                )
              : FilledButton(
                  onPressed: widget.onToken,
                  child: Text(l10n.haConnectWithToken),
                ),
        ],
        // 3.1.5: after a failed try, the user's own AI assistant.
        if (problem != null) ...[
          const SizedBox(height: 24),
          AiHelpCard(
            facts: AiHelpFacts(
              from: AiHelpFrom.haConnect,
              platform: SetupPlatform.homeAssistant,
              haProblem: problem,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(l10n.haConnectKeeps, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// What the "couldn't find it" card needs from the screen (3.5.2).
class _NothingFound {
  const _NothingFound({
    required this.onWifi,
    required this.haApp,
    required this.retrying,
    required this.onOpenApp,
    required this.onLookAgain,
    required this.onAssistant,
  });

  /// Null until checked.
  final bool? onWifi;
  final bool haApp;
  final bool retrying;
  final VoidCallback onOpenApp;
  final VoidCallback onLookAgain;
  final VoidCallback onAssistant;
}

/// The look found nothing (ha-nothing-found.md): why, in one line; how to
/// get the address out of Home Assistant, as steps with a button; and two
/// quiet ways on. 66 of 81 people who reached this state never got an
/// address in, and 30 left right here.
class _NothingFoundCard extends StatelessWidget {
  const _NothingFoundCard({required this.card, required this.shareTarget});

  final _NothingFound card;

  /// ZigDash is in the share sheet (Android, before a home exists): the
  /// steps say to share; otherwise to copy and tap Paste.
  final bool shareTarget;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget step(int n, String text) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text('$n.', style: theme.textTheme.bodyMedium),
          ),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
    return Card(
      key: const Key('ha-none-card'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.haNoneTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Semantics(
              liveRegion: true,
              child: Text(
                card.retrying
                    ? l10n.haFindLooking
                    : card.onWifi == false
                    ? l10n.haNoneOffWifi
                    : l10n.haNoneOnWifi,
                key: const Key('ha-none-why'),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 14),
            Text(l10n.haNoneGetAddress, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (card.haApp) ...[
              FilledButton.icon(
                key: const Key('ha-none-open-app'),
                onPressed: card.onOpenApp,
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.haNoneOpenApp),
              ),
              const SizedBox(height: 4),
              step(1, l10n.haNoneAppStep1),
              step(
                2,
                shareTarget
                    ? l10n.haNoneAppStep2Share
                    : l10n.haNoneAppStep2Copy,
              ),
            ] else
              Text(
                shareTarget ? l10n.haNoneBrowserShare : l10n.haNoneBrowserCopy,
                key: const Key('ha-none-browser'),
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: [
                TextButton.icon(
                  key: const Key('ha-none-look-again'),
                  onPressed: card.retrying ? null : card.onLookAgain,
                  icon: card.retrying
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(l10n.haNoneLookAgain),
                ),
                TextButton.icon(
                  key: const Key('ha-none-assistant'),
                  onPressed: card.onAssistant,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l10n.haNoneAssistant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// What each [HaWhere]'s address looks like, as the field's hint.
const _whereExample = {
  HaWhere.home: '192.168.1.20:8123',
  HaWhere.nabuCasa: 'https://abcd1234.ui.nabu.casa',
  HaWhere.duckDns: 'myhome.duckdns.org:8123',
  HaWhere.ownDomain: 'ha.example.com',
};

String _whereLabel(AppLocalizations l10n, HaWhere where) => switch (where) {
  HaWhere.home => l10n.haWhereHome,
  HaWhere.nabuCasa => l10n.haWhereNabuCasa,
  HaWhere.duckDns => l10n.haWhereDuckDns,
  HaWhere.ownDomain => l10n.haWhereOwnDomain,
};

String _whereHelp(AppLocalizations l10n, HaWhere where) => switch (where) {
  HaWhere.home => l10n.haWhereHomeHelp,
  HaWhere.nabuCasa => l10n.haWhereNabuCasaHelp,
  HaWhere.duckDns => l10n.haWhereDuckDnsHelp,
  HaWhere.ownDomain => l10n.haWhereOwnDomainHelp,
};

/// Where a found Home Assistant is, as people read it: host and port.
String _hostOf(HaFound found) {
  final base = haBaseUri(found.address);
  return base == null ? found.address : '${base.host}:${base.port}';
}

/// What a failed try says, visible for tests. Nothing answering is told by
/// the [shape] of the address it went to (3.1.12).
String problemText(
  AppLocalizations l10n,
  HaConnectProblem p, {
  HaAddressShape? shape,
  String? phoneIp,
}) => switch (p) {
  HaConnectProblem.noAddress => l10n.haImportNoAddress,
  HaConnectProblem.noToken => l10n.haImportNoToken,
  HaConnectProblem.unreachable => _unreachableText(l10n, shape, phoneIp),
  HaConnectProblem.notHomeAssistant => l10n.haImportNotHa,
  HaConnectProblem.certificate => l10n.haImportCertificate,
  HaConnectProblem.signInRefused => l10n.haImportSignInRefused,
  HaConnectProblem.signInFailed => l10n.haConnectSignInFailed,
  HaConnectProblem.badToken => l10n.haImportBadToken,
  HaConnectProblem.notAdmin => l10n.haConnectNotAdmin,
  HaConnectProblem.noMqtt => l10n.haConnectNoMqtt,
};

String _unreachableText(
  AppLocalizations l10n,
  HaAddressShape? shape,
  String? phoneIp,
) {
  final phoneBase = phoneIp == null ? null : subnetBaseFromIp(phoneIp);
  return switch (shape) {
    HaAddressShape.otherNetwork when phoneBase != null =>
      l10n.haConnectOtherNetwork('$phoneBase.x'),
    HaAddressShape.localName => l10n.haConnectLocalNameUnreachable,
    HaAddressShape.nabuCasa ||
    HaAddressShape.remoteName ||
    HaAddressShape.publicIp => l10n.haConnectRemoteUnreachable,
    _ => l10n.haImportUnreachable,
  };
}
