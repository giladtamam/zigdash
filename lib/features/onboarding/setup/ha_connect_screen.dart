import 'package:flutter/material.dart';
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
import '../../ha_import/ha_auth.dart';
import '../../connections/discovery/network_info.dart';
import '../../connections/discovery/subnet.dart';
import 'ai_help.dart';
import 'ha_address_shape.dart';
import 'ha_connect.dart';
import 'ha_discovery.dart';
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
    this.controller,
    this.again,
    this.offWifi = false,
  });

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

class _HaConnectScreenState extends ConsumerState<HaConnectScreen> {
  late final HaConnectController _controller = widget.controller ?? _make();
  final _address = TextEditingController();
  final _token = TextEditingController();

  @override
  void initState() {
    super.initState();
    _address.text = switch (_controller.value) {
      HaConnectAsk(:final address) when address.isNotEmpty => address,
      _ => widget.initialHost ?? '',
    };
    _controller.addListener(_onState);
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
    // What the look found, or the address a try went to, fills an empty
    // field; a typed address is never replaced.
    if (_address.text.trim().isEmpty) {
      final state = _controller.value;
      final found = _controller.found;
      if (state is HaConnectAsk && state.address.isNotEmpty) {
        _address.text = state.address;
      } else if (found.length == 1) {
        _address.text = found.single.address;
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onState);
    if (widget.controller == null) _controller.dispose();
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
            found: _controller.found,
            phoneIp: _controller.phoneIp,
            onPick: (address) => setState(() => _address.text = address),
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
    this.found = const [],
    this.phoneIp,
    this.onPick,
  });
  final HaConnectAsk state;

  /// The phone's own address, for "that address is on another network".
  final String? phoneIp;

  /// Looking for Home Assistant on the network (3.1.8), and what it found.
  final bool looking;
  final bool looked;
  final List<HaFound> found;
  final ValueChanged<String>? onPick;
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final problem = widget.state.problem;
    // The token opens by itself when it is the way forward.
    final tokenOpen =
        _tokenOpen ||
        !widget.canSignIn ||
        problem == HaConnectProblem.signInRefused ||
        problem == HaConnectProblem.badToken ||
        problem == HaConnectProblem.noToken ||
        problem == HaConnectProblem.notAdmin;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.haConnectIntro, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        TextField(
          controller: widget.address,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: l10n.haImportAddress,
            helperText: l10n.haConnectAddressHelp,
            helperMaxLines: 5,
            errorText: problem == HaConnectProblem.noAddress
                ? l10n.haImportNoAddress
                : null,
          ),
        ),
        if (widget.looking) ...[
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
        if (widget.looked && widget.found.isEmpty) ...[
          const SizedBox(height: 12),
          Text(l10n.haFindNone, style: theme.textTheme.bodyMedium),
        ],
        // 3.1.4: an empty address was every try on 3.1.3's first night.
        if (problem == HaConnectProblem.noAddress ||
            (widget.looked && widget.found.isEmpty)) ...[
          const SizedBox(height: 12),
          Text(l10n.haConnectWhereAddress, style: theme.textTheme.bodyMedium),
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
            onPressed: widget.onSignIn,
            icon: const Icon(Icons.login),
            label: Text(l10n.haImportSignIn),
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
