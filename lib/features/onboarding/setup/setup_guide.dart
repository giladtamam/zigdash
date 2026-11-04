part of 'setup_screen.dart';

/// How far the guide on an empty result has come (3.3.2): the steps passed
/// and whether Zigbee2MQTT isn't set up yet. Kept across scans, so "Try
/// again" from a step that didn't help moves on instead of starting over;
/// cleared when setup starts again from the welcome screen.
class GuideProgress {
  const GuideProgress({this.passed = const {}, this.notYet = false});
  final Set<GuideRung> passed;
  final bool notYet;

  GuideProgress pass(GuideRung rung) =>
      GuideProgress(passed: {...passed, rung}, notYet: notYet);
  GuideProgress back(GuideRung rung) =>
      GuideProgress(passed: {...passed}..remove(rung), notYet: notYet);
}

final setupGuideProvider = StateProvider<GuideProgress>(
  (_) => const GuideProgress(),
);

/// The guide's steps for an empty result, in order (3.3.2). 3.3.1's empty
/// result showed every way on at once (hints, a question, the Zigbee2MQTT
/// page, guides, an address field and up to seven buttons); in 391 setup
/// sessions (Oct 19-Nov 3) 55% reached it and 10% ended connected. Now:
/// the network first (a VPN in 10% of empty scans, five or fewer devices
/// seen in 36%), then the way that fits the user's answer, then the whole
/// network and the address, and always help last.
List<GuideRung> guideRungsFor(SetupScanEmpty s, {bool notYet = false}) {
  final hub = s.hub;
  final p = s.platform;
  return [
    if (s.network?.vpn ?? false)
      GuideRung.vpn
    else if (hub == null && (s.tried?.aliveHosts ?? 99) <= 5)
      GuideRung.isolated,
    if (hub != null)
      GuideRung.hub
    else if (notYet)
      GuideRung.notYet
    else ...[
      ...switch (p) {
        null || SetupPlatform.notSure => [GuideRung.which],
        SetupPlatform.homeAssistant => [GuideRung.homeAssistant],
        SetupPlatform.zha => [GuideRung.zha],
        SetupPlatform.piOrDocker => [GuideRung.running, GuideRung.z2mPage],
        SetupPlatform.smlight => const <GuideRung>[],
      },
      if (p != SetupPlatform.zha && !(s.tried?.widened ?? true))
        GuideRung.wider,
      if (p != SetupPlatform.zha) GuideRung.address,
    ],
    GuideRung.help,
  ];
}

/// The empty result as a guide (3.3.2): one step at a time, each with one
/// thing to do, "That didn't help" to move on, and help as the last step,
/// so nobody is left on a screen with nothing more to try.
class _EmptyGuide extends ConsumerWidget {
  const _EmptyGuide({
    required this.state,
    required this.onZ2mPage,
    required this.onWiden,
    required this.onRetry,
    required this.onPlatform,
    required this.onManual,
    required this.onCheckAddress,
    required this.onRunning,
    required this.onManualTo,
    required this.onManualPort,
    required this.onDemo,
    required this.onConnectViaHa,
  });
  final SetupScanEmpty state;
  final VoidCallback onZ2mPage;
  final VoidCallback onWiden;
  final VoidCallback onRetry;
  final ValueChanged<SetupPlatform?> onPlatform;
  final VoidCallback onManual;
  final ValueChanged<String> onCheckAddress;
  final ValueChanged<Z2mRunning> onRunning;
  final ValueChanged<HubFound> onManualTo;
  final ValueChanged<int> onManualPort;
  final VoidCallback onDemo;
  final void Function(String? host, HaSignInFrom from) onConnectViaHa;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final progress = ref.watch(setupGuideProvider);
    final rungs = guideRungsFor(state, notYet: progress.notYet);
    final index = rungs.indexWhere((r) => !progress.passed.contains(r));
    final current = index < 0 ? GuideRung.help : rungs[index];
    final step = index < 0 ? rungs.length : index + 1;

    void track(GuideRung rung, GuideAction action) => ref
        .read(analyticsProvider)
        .track(
          SetupStep(
            SetupStepKind.guide,
            choice: rung,
            result: action,
            platform: state.platform,
          ),
        );

    void update(GuideProgress Function(GuideProgress) f) =>
        ref.read(setupGuideProvider.notifier).update(f);

    // Taking a step's action that scans again passes the step: if the next
    // scan is empty too, the guide goes on instead of repeating it.
    void done(GuideRung rung, VoidCallback action, {bool pass = false}) {
      track(rung, GuideAction.done);
      if (pass) update((g) => g.pass(rung));
      action();
    }

    void next() {
      track(current, GuideAction.next);
      update((g) => g.pass(current));
    }

    void back() {
      final previous = rungs
          .take(index < 0 ? rungs.length : index)
          .lastWhere((r) => progress.passed.contains(r), orElse: () => current);
      update((g) => g.back(previous));
    }

    void skipToHelp() {
      track(current, GuideAction.next);
      update(
        (g) => GuideProgress(
          passed: {...g.passed, ...rungs.where((r) => r != GuideRung.help)},
          notYet: g.notYet,
        ),
      );
    }

    final card = _GuideStep(
      key: ValueKey('setup-guide-${current.name}'),
      rung: current,
      onReached: current == GuideRung.help
          ? () => track(GuideRung.help, GuideAction.reached)
          : null,
      child: _rung(context, ref, current, done, update),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            state.hub == null ? l10n.setupNoCandidatesTitle : _hubTitle(l10n),
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 4),
        Text(l10n.guideIntro, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        Text(
          l10n.guideStep(step, rungs.length),
          key: const Key('setup-guide-step'),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        card,
        const SizedBox(height: 8),
        Row(
          children: [
            if (step > 1)
              TextButton.icon(
                key: const Key('setup-guide-back'),
                onPressed: back,
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.guideBack),
              ),
            const Spacer(),
            if (current != GuideRung.help)
              OutlinedButton(
                key: const Key('setup-guide-next'),
                onPressed: next,
                child: Text(l10n.guideNotHelped),
              ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(),
        // The ways that were always on the empty result stay, out of the
        // guide's way: help, the broker form and the demo.
        Wrap(
          spacing: 4,
          runSpacing: 0,
          children: [
            if (current != GuideRung.help)
              TextButton(
                key: const Key('setup-guide-skip'),
                onPressed: skipToHelp,
                child: Text(l10n.guideSkipToHelp),
              ),
            TextButton(
              onPressed: onManual,
              child: Text(l10n.setupManualEntryAdvanced),
            ),
            TextButton(onPressed: onDemo, child: Text(l10n.onboardingDemo)),
          ],
        ),
      ],
    );
  }

  String _hubTitle(AppLocalizations l10n) => switch (state.hub!.kind) {
    HubKind.homeAssistant => l10n.setupNoBrokerHaTitle,
    HubKind.zigbee2mqtt => l10n.setupNoBrokerZ2mTitle,
    HubKind.smlight => l10n.setupNoBrokerSmlightTitle,
  };

  Widget _rung(
    BuildContext context,
    WidgetRef ref,
    GuideRung rung,
    void Function(GuideRung, VoidCallback, {bool pass}) done,
    void Function(GuideProgress Function(GuideProgress)) update,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyMedium;
    Widget primary(String label, IconData icon, VoidCallback onPressed) =>
        FilledButton.icon(
          key: const Key('setup-guide-action'),
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        );
    final hub = state.hub;

    return switch (rung) {
      GuideRung.vpn => _GuideBody(
        title: l10n.guideVpnTitle,
        icon: Icons.vpn_lock,
        children: [
          Text(l10n.setupVpnHint, style: body),
          primary(
            l10n.setupTryAgain,
            Icons.refresh,
            () => done(rung, onRetry, pass: true),
          ),
        ],
      ),
      GuideRung.isolated => _GuideBody(
        title: l10n.guideIsolatedTitle,
        icon: Icons.wifi_find,
        children: [
          Text(l10n.setupIsolatedHint, style: body),
          primary(
            l10n.setupOpenWifiSettings,
            Icons.wifi,
            () => done(rung, _NoNetwork._openWifi),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => done(rung, onRetry, pass: true),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.setupTryAgain),
            ),
          ),
        ],
      ),
      GuideRung.hub => _GuideBody(
        title: l10n.guideHubTitle,
        icon: Icons.hub_outlined,
        children: [
          // Once Zigbee2MQTT has said where its broker is (2.7.2), its
          // answer replaces the general guess.
          if (state.z2m case final z?
              when z.status == Z2mAnswerStatus.localOnly ||
                  z.status == Z2mAnswerStatus.nameOnly ||
                  z.status == Z2mAnswerStatus.unreachable)
            _Z2mAnswerNote(answer: z, onManualPort: onManualPort)
          else ...[
            Text(switch (hub!.kind) {
              HubKind.homeAssistant => l10n.setupNoBrokerHaBody(hub.host),
              HubKind.zigbee2mqtt => l10n.setupNoBrokerZ2mBody(hub.host),
              HubKind.smlight => l10n.setupNoBrokerSmlightBody(hub.host),
            }, style: body),
            if (state.z2m case final z?)
              _Z2mAnswerNote(answer: z, onManualPort: onManualPort),
          ],
          if (hub!.kind == HubKind.homeAssistant) ...[
            primary(
              l10n.haConnectButton,
              Icons.home_outlined,
              () => done(
                rung,
                () => onConnectViaHa(hub.host, HaSignInFrom.haFound),
              ),
            ),
            // 2.6.6 and 3.2.6: ZHA users and Home Assistant Container have
            // no broker for the scan to find.
            Text(l10n.setupNoBrokerHaZha, style: body),
            Text(l10n.setupNoBrokerHaDocker, style: body),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  key: const Key('setup-ha-docker-manual'),
                  onPressed: onManual,
                  child: Text(l10n.setupManualEntryAdvanced),
                ),
                TextButton(
                  onPressed: () => done(rung, () => onManualTo(hub)),
                  child: Text(l10n.setupConnectTo(hub.host)),
                ),
              ],
            ),
          ] else
            primary(
              l10n.setupConnectTo(hub.host),
              Icons.login,
              () => done(rung, () => onManualTo(hub)),
            ),
        ],
      ),
      GuideRung.which => _GuideBody(
        title: l10n.guideWhichTitle,
        icon: Icons.help_outline,
        children: [
          for (final (key, label, icon, onTap) in [
            (
              'ha',
              l10n.guideWhichHa,
              Icons.home_outlined,
              () => onPlatform(SetupPlatform.homeAssistant),
            ),
            (
              'z2m',
              l10n.guideWhichZ2m,
              Icons.language,
              () => onPlatform(SetupPlatform.piOrDocker),
            ),
            (
              'smlight',
              l10n.guideWhichSmlight,
              Icons.router_outlined,
              () => onPlatform(SetupPlatform.smlight),
            ),
            (
              'nothing',
              l10n.guideWhichNothing,
              Icons.add_circle_outline,
              () {
                onRunning(Z2mRunning.notYet);
                update((g) => GuideProgress(passed: g.passed, notYet: true));
              },
            ),
          ])
            OutlinedButton.icon(
              key: Key('setup-guide-which-$key'),
              style: OutlinedButton.styleFrom(
                alignment: AlignmentDirectional.centerStart,
              ),
              onPressed: () {
                done(rung, onTap);
                update((g) => g.pass(rung));
              },
              icon: Icon(icon),
              label: Text(label),
            ),
        ],
      ),
      GuideRung.homeAssistant => _GuideBody(
        title: l10n.guideHaTitle,
        icon: Icons.home_outlined,
        children: [
          Text(l10n.guideHaBody, style: body),
          primary(
            l10n.haConnectButton,
            Icons.home_outlined,
            () =>
                done(rung, () => onConnectViaHa(null, HaSignInFrom.emptyCard)),
          ),
        ],
      ),
      GuideRung.zha => _GuideBody(
        title: l10n.guideZhaTitle,
        icon: Icons.info_outline,
        children: [
          Text(l10n.setupZhaNote, style: body),
          primary(
            l10n.onboardingDemo,
            Icons.play_circle_outline,
            () => done(rung, onDemo),
          ),
        ],
      ),
      GuideRung.running => _GuideBody(
        title: l10n.guideRunningTitle,
        icon: Icons.help_outline,
        children: [
          Text(l10n.setupRunningNotSureNote(l10n.setupRunningYes), style: body),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                key: const Key('setup-guide-running-yes'),
                onPressed: () {
                  done(rung, () => onRunning(Z2mRunning.yes));
                  update((g) => g.pass(rung));
                },
                child: Text(l10n.setupRunningYes),
              ),
              OutlinedButton(
                key: const Key('setup-guide-running-not-yet'),
                onPressed: () {
                  done(rung, () => onRunning(Z2mRunning.notYet));
                  update((g) => GuideProgress(passed: g.passed, notYet: true));
                },
                child: Text(l10n.setupRunningNotYet),
              ),
            ],
          ),
        ],
      ),
      GuideRung.notYet => _GuideBody(
        title: l10n.guideNotYetTitle,
        icon: Icons.add_circle_outline,
        children: [
          Text(l10n.setupRunningNotYetNote, style: body),
          // 3.4: what to get is a screen in the app, not the web page.
          primary(l10n.setupRunningWhatToGet, Icons.chevron_right, () {
            done(
              rung,
              () => context.push(Routes.setupNoHubFrom(NoHubFrom.guide.name)),
            );
          }),
          _SetupGuides(only: state.platform),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: onDemo,
              icon: const Icon(Icons.play_circle_outline),
              label: Text(l10n.onboardingDemo),
            ),
          ),
        ],
      ),
      GuideRung.z2mPage => _GuideBody(
        title: l10n.guideZ2mPageTitle,
        icon: Icons.language,
        children: [
          // Once Zigbee2MQTT has said where its broker is (2.7.2), its
          // answer (often the fix itself) replaces the explanation.
          if (state.z2m case final z?)
            _Z2mAnswerNote(answer: z, onManualPort: onManualPort)
          else
            Text(l10n.guideZ2mPageBody, style: body),
          primary(
            l10n.setupZ2mPageEntry,
            Icons.language,
            () => done(rung, onZ2mPage),
          ),
        ],
      ),
      GuideRung.wider => _GuideBody(
        title: l10n.guideWiderTitle,
        icon: Icons.zoom_out_map,
        children: [
          Text(l10n.guideWiderBody, style: body),
          primary(
            l10n.setupLookWider,
            Icons.zoom_out_map,
            () => done(rung, onWiden, pass: true),
          ),
        ],
      ),
      GuideRung.address => _GuideBody(
        title: l10n.guideAddressTitle,
        icon: Icons.edit_location_alt_outlined,
        children: [
          // What was looked for, and what to check before typing an address.
          if (switch (state.platform) {
                SetupPlatform.homeAssistant => l10n.setupNotFoundHa,
                SetupPlatform.piOrDocker => l10n.setupNotFoundPi,
                SetupPlatform.smlight => l10n.setupNotFoundSmlight,
                _ => null,
              }
              case final note?)
            Text(note, style: body),
          _AddressField(
            platform: state.platform,
            check: state.address,
            onCheck: onCheckAddress,
          ),
          if (state.platform != SetupPlatform.homeAssistant)
            _SetupGuides(only: state.platform),
        ],
      ),
      // The login step's own guide, never on the empty result.
      GuideRung.login => const SizedBox.shrink(),
      GuideRung.help => _GuideBody(
        title: l10n.guideHelpTitle,
        icon: Icons.support_agent,
        children: [
          Text(l10n.guideHelpBody, style: body),
          AiHelpCard(
            facts: AiHelpFacts(
              from: AiHelpFrom.scanEmpty,
              platform: state.platform,
              network: state.network,
              phoneAddress: state.deviceIp,
              tried: state.tried,
              hubSeen: hub?.kind,
            ),
          ),
          GetHelpLink(
            onPressed: () =>
                context.push(Routes.getHelpFrom(HelpFrom.noConnection.name)),
          ),
          const CommunityLink(from: HelpFrom.noConnection),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.setupTryAgain),
          ),
        ],
      ),
    };
  }
}

/// The card holding the current step; tells [onReached] once when shown.
class _GuideStep extends StatefulWidget {
  const _GuideStep({
    super.key,
    required this.rung,
    required this.child,
    this.onReached,
  });
  final GuideRung rung;
  final Widget child;
  final VoidCallback? onReached;

  @override
  State<_GuideStep> createState() => _GuideStepState();
}

class _GuideStepState extends State<_GuideStep> {
  @override
  void initState() {
    super.initState();
    final reached = widget.onReached;
    if (reached != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => reached());
    }
  }

  @override
  Widget build(BuildContext context) => Card.outlined(
    margin: EdgeInsets.zero,
    child: Padding(padding: const EdgeInsets.all(16), child: widget.child),
  );
}

class _GuideBody extends StatelessWidget {
  const _GuideBody({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
          ],
        ),
        for (final c in children) ...[const SizedBox(height: 12), c],
      ],
    );
  }
}
