part of 'setup_screen.dart';

/// "No MQTT login? Make one" on the login step (3.3.2): how to get a
/// broker login, step by step, for where the broker runs. 41 of 391 setup
/// sessions (Oct 19-Nov 3) reached the login and few had one; every
/// rejected login was a Home Assistant user's, whose Mosquitto app takes a
/// Home Assistant user they usually haven't made. Opens by itself after a
/// rejected login.
class _LoginGuide extends ConsumerStatefulWidget {
  const _LoginGuide({
    required this.platform,
    required this.rejected,
    required this.onTryAnonymous,
  });
  final SetupPlatform? platform;
  final bool rejected;
  final VoidCallback onTryAnonymous;

  @override
  ConsumerState<_LoginGuide> createState() => _LoginGuideState();
}

class _LoginGuideState extends ConsumerState<_LoginGuide> {
  // Where the broker runs, when the welcome's answer didn't say.
  late SetupPlatform _where = switch (widget.platform) {
    SetupPlatform.homeAssistant ||
    SetupPlatform.piOrDocker ||
    SetupPlatform.smlight => widget.platform!,
    _ => SetupPlatform.homeAssistant,
  };

  void _track(GuideAction action) => ref
      .read(analyticsProvider)
      .track(
        SetupStep(
          SetupStepKind.guide,
          choice: GuideRung.login,
          result: action,
          platform: widget.platform,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final known = switch (widget.platform) {
      SetupPlatform.homeAssistant ||
      SetupPlatform.piOrDocker ||
      SetupPlatform.smlight => true,
      _ => false,
    };
    final steps = switch (_where) {
      SetupPlatform.piOrDocker => <Widget>[
        _LoginStep(1, l10n.loginGuidePi1),
        _LoginStep(2, l10n.loginGuidePi2),
        const _Command('sudo mosquitto_passwd /etc/mosquitto/passwd zigdash'),
        _LoginStep(3, l10n.loginGuidePi3),
        const _Command('sudo systemctl restart mosquitto'),
        _LoginStep(4, l10n.loginGuidePi4),
        const _Command(
          'docker exec -it mosquitto mosquitto_passwd '
          '/mosquitto/config/passwd zigdash\n'
          'docker restart mosquitto',
        ),
      ],
      SetupPlatform.smlight => <Widget>[
        _LoginStep(1, l10n.loginGuideSmlight1),
        _LoginStep(2, l10n.loginGuideSmlight2),
        _LoginStep(3, l10n.loginGuideSmlight3),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            key: const Key('setup-login-anonymous'),
            onPressed: () {
              _track(GuideAction.done);
              widget.onTryAnonymous();
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.loginTryAnonymous),
          ),
        ),
      ],
      _ => <Widget>[
        _LoginStep(1, l10n.loginGuideHa1),
        _LoginStep(2, l10n.loginGuideHa2),
        _LoginStep(3, l10n.loginGuideHa3),
        _LoginStep(4, l10n.loginGuideHa4),
      ],
    };
    return Card.outlined(
      key: const Key('setup-login-guide'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: widget.rejected,
        leading: Icon(Icons.key_outlined, color: theme.colorScheme.primary),
        title: Text(l10n.loginGuideTitle, style: theme.textTheme.titleSmall),
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        onExpansionChanged: (open) {
          if (open) _track(GuideAction.reached);
        },
        children: [
          if (!known) ...[
            Text(l10n.loginGuidePick, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            SegmentedButton<SetupPlatform>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: SetupPlatform.homeAssistant,
                  label: Text(l10n.setupPlatformHa),
                ),
                ButtonSegment(
                  value: SetupPlatform.piOrDocker,
                  label: Text(l10n.setupPlatformPi),
                ),
                ButtonSegment(
                  value: SetupPlatform.smlight,
                  label: Text(l10n.setupPlatformSmlight),
                ),
              ],
              selected: {_where},
              onSelectionChanged: (s) => setState(() => _where = s.first),
            ),
            const SizedBox(height: 12),
          ],
          for (final (i, step) in steps.indexed) ...[
            if (i > 0) const SizedBox(height: 8),
            step,
          ],
        ],
      ),
    );
  }
}

/// One numbered step of the login guide: the steps are done in order.
class _LoginStep extends StatelessWidget {
  const _LoginStep(this.number, this.text);
  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Text(
            '$number',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

/// A shell command to run on the broker's machine, with a copy button.
class _Command extends StatelessWidget {
  const _Command(this.command);
  final String command;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 4, 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: SelectableText(
                command,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            IconButton(
              tooltip: context.l10n.loginCopied,
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: command));
                if (!context.mounted) return;
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  SnackBar(content: Text(context.l10n.loginCopied)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
