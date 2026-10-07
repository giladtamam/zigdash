import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
              _SectionHeader(l10n.settingsAbout),
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: Text(l10n.settingsRateApp),
                subtitle: Text(l10n.settingsRateAppSubtitle),
                onTap: () async {
                  final review = InAppReview.instance;
                  if (await review.isAvailable()) {
                    await review.requestReview();
                  } else {
                    await review.openStoreListing();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(l10n.settingsHelp),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.help),
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
