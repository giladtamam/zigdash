import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../shortcuts/shortcut_service.dart' show appChannel;
import '../../connections/discovery/hub_probe.dart';
import '../../support/support_details.dart';
import 'ha_connect.dart';
import 'setup_coordinator.dart';
import 'setup_error_guidance.dart';

/// Where "Ask your AI" was used (3.1.5): the empty scan, a setup failure,
/// a broker without Zigbee2MQTT, the login prompt, or Home Assistant
/// sign-in.
enum AiHelpFrom { scanEmpty, failed, noZigbee2mqtt, login, haConnect }

/// What was done with the write-up: the preview opened, then shared to an
/// app or copied.
enum AiHelpAction { opened, shared, copied }

/// Whether the write-up was shared or copied since setup last finished, so
/// `complete` can say whether "Ask your AI" came first (3.1.5).
final aiHelpUsedProvider = StateProvider<bool>((_) => false);

/// What setup knows when it is stuck, for the write-up. Never an address,
/// a device name or a login.
class AiHelpFacts {
  const AiHelpFacts({
    required this.from,
    this.platform,
    this.network,
    this.phoneAddress,
    this.tried,
    this.hubSeen,
    this.error,
    this.loginRejected = false,
    this.baseTopic,
    this.haProblem,
  });

  final AiHelpFrom from;
  final SetupPlatform? platform;
  final NetworkFacts? network;

  /// Only its shape is written ("a private address in 192.168.x").
  final String? phoneAddress;
  final ScanTried? tried;
  final HubKind? hubSeen;
  final SetupErrorKind? error;
  final bool loginRejected;
  final String? baseTopic;
  final HaConnectProblem? haProblem;
}

const _languages = {
  'cs': 'Czech',
  'de': 'German',
  'en': 'English',
  'es': 'Spanish',
  'fr': 'French',
  'he': 'Hebrew',
  'it': 'Italian',
  'nb': 'Norwegian',
  'nl': 'Dutch',
  'pl': 'Polish',
  'pt': 'Portuguese',
  'ru': 'Russian',
  'sv': 'Swedish',
};

/// The write-up for the user's own AI assistant (3.1.5). In English, which
/// every assistant reads best, asking for answers in [languageCode]. The
/// facts about ZigDash keep the assistant from guessing how it connects.
String aiHelpText(AiHelpFacts f, {String languageCode = 'en'}) {
  final language = _languages[languageCode] ?? 'English';
  final l = <String>[
    "I'm setting up ZigDash, an Android app that shows and controls my "
        'Zigbee devices through Zigbee2MQTT. Setup is stuck. Help me get it '
        'connected.',
    'Ask me one question at a time, keep each step short, and assume I '
        "am not technical. When we know the address and login, tell me "
        'exactly what to type in ZigDash.'
        '${language == 'English' ? '' : ' Please answer in $language.'}',
    '',
    'How ZigDash connects (facts about the app):',
    "- It connects to Zigbee2MQTT's MQTT broker (usually Mosquitto), "
        "normally on port 1883. Zigbee2MQTT's web page (port 8080) is not "
        'the connection, but it shows which machine runs Zigbee2MQTT.',
    '- At home the phone must be on the same network as the broker. No '
        'port forwarding is needed.',
    '- With Home Assistant there are two ways in: "Connect through Home '
        'Assistant" signs in with the address you open Home Assistant with '
        '(for example http://192.168.1.20:8123, or a Nabu Casa address) and '
        'needs an administrator account and the MQTT integration; or "Enter '
        "details manually\" with the Mosquitto broker add-on's address, "
        'port 1883, and a Home Assistant username and password.',
    "- ZigDash works only with Zigbee2MQTT. It can't see devices paired "
        "with ZHA, Home Assistant's built-in Zigbee.",
    "- Zigbee2MQTT's base topic is zigbee2mqtt unless it was changed.",
    '- Manual entry in ZigDash: Set up ZigDash > Enter details manually '
        '(address, port, username, password).',
    '',
    'What ZigDash found on my phone:',
    '- Where Zigbee2MQTT runs, my answer: ${_platform(f.platform)}.',
  ];
  final net = f.network;
  if (net != null || f.phoneAddress != null) {
    final kind = switch (net?.kind) {
      'Wi-Fi' => 'Wi-Fi',
      'Ethernet' => 'Ethernet',
      _ => 'a network',
    };
    final shape = f.phoneAddress == null
        ? ''
        : ', with ${addressShapeLabel(addressShape(f.phoneAddress!))}';
    l.add('- The phone is on $kind$shape.');
    if (net != null) l.add('- VPN: ${net.vpn ? 'on' : 'off'}.');
  }
  final tried = f.tried;
  if (tried != null) {
    l.add(
      '- The scan tried ${tried.hostsTried} addresses'
      '${tried.widened ? ', including the neighbouring range' : ''}; '
      '${tried.aliveHosts} devices answered at all.',
    );
  }
  l
    ..add('')
    ..add("Where I'm stuck: ${_stuck(f)}");
  return l.join('\n');
}

String _platform(SetupPlatform? p) => switch (p) {
  SetupPlatform.homeAssistant => 'Home Assistant',
  SetupPlatform.smlight => 'an SMLIGHT hub (SMHUB)',
  SetupPlatform.piOrDocker => 'a Raspberry Pi or Docker',
  SetupPlatform.zha =>
    "ZHA, Home Assistant's built-in Zigbee (I don't have Zigbee2MQTT)",
  SetupPlatform.notSure => "I'm not sure",
  null => 'not given',
};

String _stuck(AiHelpFacts f) => switch (f.from) {
  AiHelpFrom.scanEmpty => switch (f.hubSeen) {
    HubKind.homeAssistant =>
      'The scan found Home Assistant on my network, but no MQTT broker '
          'answered on port 1883.',
    HubKind.zigbee2mqtt =>
      "The scan found Zigbee2MQTT's web page on my network, but no MQTT "
          'broker answered on port 1883 there.',
    HubKind.smlight =>
      "The scan found an SMLIGHT hub's web page, but no MQTT broker "
          'answered on port 1883 there.',
    null =>
      'The scan found no MQTT broker on my network, and no Home Assistant '
          'or Zigbee2MQTT web page either.',
  },
  AiHelpFrom.login =>
    f.loginRejected
        ? 'ZigDash found my MQTT broker, but it rejected the username and '
              "password I typed. I'm not sure which login it wants."
        : 'ZigDash found my MQTT broker, and it asks for a username and '
              "password. I don't know which login to use.",
  AiHelpFrom.noZigbee2mqtt =>
    "ZigDash connected to my MQTT broker, but Zigbee2MQTT didn't answer "
        'on the base topic ${f.baseTopic ?? 'zigbee2mqtt'}.',
  AiHelpFrom.failed => switch (f.error) {
    SetupErrorKind.hostUnreachable =>
      "ZigDash found my broker's address, but can't reach it from the phone.",
    SetupErrorKind.portClosed =>
      'The machine answers, but no MQTT broker answered on its port.',
    SetupErrorKind.loginNoAnswer =>
      "ZigDash found my broker, but it didn't answer the username and "
          'password in time.',
    SetupErrorKind.noDevices =>
      'ZigDash reached Zigbee2MQTT, but it published no devices during the '
          'check.',
    _ => 'Setup stopped with an unexpected error.',
  },
  AiHelpFrom.haConnect => switch (f.haProblem) {
    HaConnectProblem.noAddress =>
      'ZigDash asks for the address I open Home Assistant with, and I '
          "don't know it.",
    HaConnectProblem.unreachable =>
      'I typed my Home Assistant address, but nothing answered at it.',
    HaConnectProblem.notHomeAssistant =>
      "Something answered at the address I typed, but ZigDash says it isn't "
          'Home Assistant.',
    HaConnectProblem.certificate =>
      "My phone doesn't trust my Home Assistant's certificate.",
    HaConnectProblem.notAdmin =>
      "ZigDash says my Home Assistant user isn't an administrator.",
    HaConnectProblem.noMqtt =>
      'ZigDash says my Home Assistant has no MQTT integration.',
    HaConnectProblem.signInRefused || HaConnectProblem.signInFailed =>
      "Signing in with Home Assistant didn't complete.",
    HaConnectProblem.badToken ||
    HaConnectProblem.noToken => 'Home Assistant refused the token I pasted.',
    null => "I can't get connected through Home Assistant.",
  },
};

/// The "Ask your AI" card on a screen where setup is stuck (3.1.5).
class AiHelpCard extends ConsumerWidget {
  const AiHelpCard({super.key, required this.facts});

  final AiHelpFacts facts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      key: const Key('setup-ai-help'),
      elevation: 0,
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.aiHelpTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(l10n.aiHelpBody, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => showAiHelp(context, ref, facts),
              icon: const Icon(Icons.auto_awesome_outlined),
              label: Text(l10n.aiHelpButton),
            ),
          ],
        ),
      ),
    );
  }
}

/// The write-up as it will leave the phone, then Share or Copy.
Future<void> showAiHelp(
  BuildContext context,
  WidgetRef ref,
  AiHelpFacts facts,
) {
  final analytics = ref.read(analyticsProvider);
  final used = ref.read(aiHelpUsedProvider.notifier);
  void count(AiHelpAction action) {
    analytics.track(
      SetupStep(
        SetupStepKind.aiHelp,
        choice: facts.from,
        result: action,
        platform: facts.platform,
      ),
    );
    if (action != AiHelpAction.opened) used.state = true;
  }

  final text = aiHelpText(
    facts,
    languageCode: Localizations.localeOf(context).languageCode,
  );
  count(AiHelpAction.opened);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheet) {
      final l10n = sheet.l10n;
      final theme = Theme.of(sheet);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.aiHelpPreviewTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(sheet).height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    text,
                    key: const Key('ai-help-text'),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(sheet);
                  final copied = l10n.aiHelpCopied;
                  bool shared;
                  try {
                    shared =
                        await appChannel.invokeMethod<bool>('shareText', {
                          'text': text,
                          'title': l10n.aiHelpButton,
                        }) ??
                        false;
                  } catch (_) {
                    shared = false;
                  }
                  if (!shared) {
                    // No share sheet (another platform): the clipboard.
                    await Clipboard.setData(ClipboardData(text: text));
                    messenger.showSnackBar(SnackBar(content: Text(copied)));
                  }
                  count(shared ? AiHelpAction.shared : AiHelpAction.copied);
                  if (sheet.mounted) Navigator.of(sheet).pop();
                },
                icon: const Icon(Icons.share_outlined),
                label: Text(l10n.aiHelpShare),
              ),
              TextButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(sheet);
                  final copied = l10n.aiHelpCopied;
                  await Clipboard.setData(ClipboardData(text: text));
                  messenger.showSnackBar(SnackBar(content: Text(copied)));
                  count(AiHelpAction.copied);
                  if (sheet.mounted) Navigator.of(sheet).pop();
                },
                child: Text(l10n.dashExportCopy),
              ),
            ],
          ),
        ),
      );
    },
  );
}
