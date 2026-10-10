import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../support/support_facts.dart' show supportDetailsProvider;
import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../panels/widgets/device_tile_panel.dart' show ltr;
import '../../../core/router/last_dashboard_store.dart';
import '../../../core/router/routes.dart';
import '../../../data/database/database.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../l10n/app_localizations.dart';
import '../../../mqtt/mqtt_status.dart';
import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../providers/settings_controller.dart';
import 'language_screen.dart';

/// App version + build number, e.g. "1.3.2 (10)".
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

/// Whether the platform offers wallpaper colors (Android 12 and later).
/// Unknown (no plugin, e.g. in tests) counts as available.
final dynamicColorAvailableProvider = FutureProvider<bool>((ref) async {
  try {
    return await DynamicColorPlugin.getCorePalette() != null;
  } catch (_) {
    return true;
  }
});

/// The published privacy policy: the same page the Play listing links.
/// (The GitHub Pages address was never enabled and returned 404.)
final privacyPolicyUrl =
    Uri.parse('https://github.com/giladtamam/zigdash/blob/main/store/PRIVACY.md');

/// ZigDash's package on Google Play. Fixed, so test builds with a suffixed
/// package (`.dev`) still open the real listing.
const playPackage = 'com.giladtamam.zigdash';

/// The Play Store app's page for ZigDash, and the web page as a fallback.
final playStoreAppUrl = Uri.parse('market://details?id=$playPackage');
final playStoreWebUrl =
    Uri.https('play.google.com', '/store/apps/details', {'id': playPackage});

/// Opens ZigDash on Google Play so the user can rate it.
///
/// Not the in-app review dialog: Play rations it and gives no signal when it
/// shows nothing, so a Rate button that relies on it often does nothing at
/// all, and Google advises against calling it from a button. The automatic
/// prompt (lib/core/review) still uses it.
Future<void> openPlayListing() async {
  try {
    if (await launchUrl(playStoreAppUrl,
        mode: LaunchMode.externalApplication)) {
      return;
    }
  } catch (_) {
    // No Play Store app (or no handler for market://): use the web page.
  }
  await launchUrl(playStoreWebUrl, mode: LaunchMode.externalApplication);
}

/// Where feature requests and problem reports go: a GitHub issue (public, votable) or an email to
/// the developer (private). The app only opens a browser or mail app; it
/// sends nothing itself.
const featureRequestEmail = 'giladtamam1@gmail.com';

/// A new GitHub issue from the feature-request template, with the app version
/// filled in.
Uri featureRequestGithubUrl(String version) =>
    _githubIssueUrl('feature_request.yml', version);

/// A new GitHub issue from the bug-report template, with the app version
/// filled in.
Uri problemReportGithubUrl(String version, {String? details}) =>
    _githubIssueUrl('bug_report.yml', version, details: details);

Uri _githubIssueUrl(String template, String version, {String? details}) =>
    Uri.https(
      'github.com',
      '/giladtamam/zigdash/issues/new',
      {
        'template': template,
        'version': version,
        if (details != null) 'details': details,
      },
    );

/// A new email to [featureRequestEmail] with [subject] and a body that asks
/// [prompt] and ends with the app version, or with Support [details] when
/// given (problem reports).
Uri feedbackMailUrl({
  required String version,
  required String subject,
  required String prompt,
  String? details,
}) =>
    Uri(
      scheme: 'mailto',
      path: featureRequestEmail,
      // Uri's queryParameters encode spaces as '+', which mail apps show.
      query: 'subject=${Uri.encodeComponent(subject)}'
          '&body=${Uri.encodeComponent('$prompt\n\n\n${details == null ? '— ZigDash $version' : '— Support details —\n$details'}')}',
    );

/// Settings (devices-tablet-1.13.md §6): Homes, Appearance and About on one
/// page. Homes are listed here; each opens its own page.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider);
    final ctrl = ref.read(settingsControllerProvider.notifier);
    final homes =
        ref.watch(connectionsStreamProvider).valueOrNull ?? const <Connection>[];
    final current = ref.watch(lastDashboardStoreProvider).lastConnectionId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            children: [
              _SectionHeader(l10n.connectionsTitle),
              for (final h in homes)
                _HomeRow(home: h, current: h.id == current),
              ListTile(
                leading: Icon(Icons.add,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(l10n.homeAdd,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
                onTap: () => context.push(Routes.setup),
              ),
              const Divider(),
              _SectionHeader(l10n.settingsAppearance),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                        value: ThemeMode.system, label: Text(l10n.themeSystem)),
                    ButtonSegment(
                        value: ThemeMode.light, label: Text(l10n.themeLight)),
                    ButtonSegment(
                        value: ThemeMode.dark, label: Text(l10n.themeDark)),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (s) => ctrl.setThemeMode(s.first),
                ),
              ),
              if (ref.watch(dynamicColorAvailableProvider).valueOrNull ?? true)
                SwitchListTile(
                  title: Text(l10n.settingsDynamicColor),
                  subtitle: Text(l10n.settingsDynamicColorSubtitle),
                  value: settings.dynamicColor,
                  onChanged: ctrl.setDynamicColor,
                ),
              ListTile(
                leading: const Icon(Icons.translate),
                title: Text(l10n.settingsLanguage),
                subtitle: Text(languageLabel(settings.locale, l10n)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.settingsLanguage),
              ),
              const Divider(),
              _SectionHeader(l10n.settingsHelpSupport),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(l10n.settingsHelp),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.help),
              ),
              ListTile(
                leading: const Icon(Icons.support_agent),
                title: Text(l10n.settingsGetHelp),
                subtitle: Text(l10n.settingsGetHelpSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.getHelpFrom(
                    HelpFrom.settings.name,
                    home: current)),
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: Text(l10n.settingsReportProblem),
                subtitle: Text(l10n.settingsReportProblemSubtitle),
                onTap: () => _sendFeedback(context, ref,
                    problem: true, connectionId: current),
              ),
              ListTile(
                leading: const Icon(Icons.lightbulb_outline),
                title: Text(l10n.settingsFeatureRequest),
                subtitle: Text(l10n.settingsFeatureRequestSubtitle),
                onTap: () => _sendFeedback(context, ref, problem: false),
              ),
              const Divider(),
              _SectionHeader(l10n.settingsAbout),
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: Text(l10n.settingsRateApp),
                subtitle: Text(l10n.settingsRateAppSubtitle),
                onTap: openPlayListing,
              ),
              if (ref.watch(analyticsAvailableProvider))
                SwitchListTile(
                  secondary: const Icon(Icons.insights_outlined),
                  title: Text(l10n.settingsAnalytics),
                  subtitle: Text(l10n.settingsAnalyticsSubtitle),
                  value: ref.watch(analyticsConsentProvider) ==
                      AnalyticsConsent.granted,
                  onChanged: (on) =>
                      ref.read(analyticsConsentProvider.notifier).set(on),
                ),
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: Text(l10n.settingsPrivacy),
                subtitle: Text(ref.watch(analyticsAvailableProvider)
                    ? l10n.settingsPrivacySubtitleOptIn
                    : l10n.settingsPrivacySubtitle),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => launchUrl(privacyPolicyUrl,
                    mode: LaunchMode.externalApplication),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.settingsVersion),
                trailing: Text(
                  ltr(ref.watch(appVersionProvider).valueOrNull ?? '…'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks where to send a feature request or a problem report ([problem]),
/// then opens GitHub or the mail app.
Future<void> _sendFeedback(
  BuildContext context,
  WidgetRef ref, {
  required bool problem,
  String? connectionId,
}) async {
  final l10n = context.l10n;
  final version = ref.read(appVersionProvider).valueOrNull ?? '';
  // A problem report carries the same Support details as Get help.
  String? details;
  if (problem) {
    try {
      details = (await ref.read(supportDetailsProvider((
        openedFrom: 'Settings › Report a problem',
        connectionId: connectionId,
      )).future))
          .format();
    } catch (_) {}
    if (!context.mounted) return;
  }
  final url = await showModalBottomSheet<Uri>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.forum_outlined),
            title: Text(l10n.featureRequestGithub),
            subtitle: Text(l10n.featureRequestGithubSubtitle),
            onTap: () => Navigator.pop(
                ctx,
                problem
                    ? problemReportGithubUrl(version, details: details)
                    : featureRequestGithubUrl(version)),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(l10n.featureRequestEmail),
            subtitle: Text(l10n.featureRequestEmailSubtitle),
            onTap: () => Navigator.pop(
                ctx,
                feedbackMailUrl(
                  version: version,
                  subject: problem
                      ? l10n.reportProblemEmailSubject
                      : l10n.featureRequestEmailSubject,
                  prompt: problem
                      ? l10n.reportProblemEmailPrompt
                      : l10n.featureRequestEmailPrompt,
                  details: details,
                )),
          ),
        ],
      ),
    ),
  );
  if (url == null) return;
  await launchUrl(url, mode: LaunchMode.externalApplication);
}

/// One home: name, address, and for the current home its connection state.
class _HomeRow extends ConsumerWidget {
  const _HomeRow({required this.home, required this.current});

  final Connection home;
  final bool current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final address = ltr('${home.host}:${home.port}');
    final status = current
        ? ref.watch(connectionStatusProvider(home.id)).valueOrNull
        : null;
    return ListTile(
      leading: Icon(current ? Icons.home : Icons.home_outlined,
          color: current ? scheme.primary : null),
      title: Text(home.name),
      subtitle: Text(status == null
          ? address
          : '$address · ${homeStatusLabel(status, l10n)}'),
      trailing: current
          ? Icon(Icons.check, color: scheme.primary, semanticLabel: l10n.homeCurrent)
          : const Icon(Icons.chevron_right),
      onTap: () => context.push(Routes.settingsHome(home.id)),
    );
  }
}

String homeStatusLabel(MqttStatus s, AppLocalizations l10n) => switch (s) {
      MqttStatus.connected => l10n.statusConnected,
      MqttStatus.connecting => l10n.statusConnecting,
      _ => l10n.statusCantReach,
    };

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: scheme.primary)),
      ),
    );
  }
}
