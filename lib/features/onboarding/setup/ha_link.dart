import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../../../mqtt/ha_address.dart';
import '../../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import '../onboarding_provider.dart';

/// A ZigDash connect link (docs/design/ha-link.md):
/// `https://zigdash.app/c#ha=<address>&src=<site|ha_integration>`, made on
/// zigdash.app/connect or by the ZigDash integration in Home Assistant. It
/// hands the phone Home Assistant's address, and nothing else: the sign-in
/// stays Home Assistant's own.
class HaLink {
  const HaLink(this.addresses, this.src);

  /// Home first, as the link lists them; only the first is used for now.
  final List<String> addresses;
  final HaLinkSrc src;

  String? get address => addresses.firstOrNull;
}

/// `ha=…&src=…`, as in the link's fragment, the "Open in ZigDash" button's
/// query and the install referrer. Each address goes through [haAddressIn],
/// which keeps scheme, host and port only: a login, a path or a token never
/// gets in. `ha` may repeat.
HaLink haLinkFromParams(String params) {
  final addresses = <String>[];
  var src = HaLinkSrc.site;
  for (final pair in params.split('&')) {
    final i = pair.indexOf('=');
    if (i <= 0) continue;
    final String value;
    try {
      value = Uri.decodeQueryComponent(pair.substring(i + 1)).trim();
    } catch (_) {
      continue;
    }
    switch (pair.substring(0, i)) {
      case 'ha':
        final address = haAddressIn(value);
        if (address != null && !addresses.contains(address)) {
          addresses.add(address);
        }
      case 'src' when value == 'ha_integration':
        src = HaLinkSrc.haIntegration;
    }
  }
  return HaLink(addresses, src);
}

/// The link's fragment; the query when the fragment holds nothing, which
/// is how the zigdash.app page's intent:// button carries it.
HaLink parseHaLink(Uri uri) =>
    haLinkFromParams(_inFragment(uri) ? uri.fragment : uri.query);

HaLinkOpened openedBy(Uri uri) =>
    !_inFragment(uri) && uri.query.contains('ha=')
    ? HaLinkOpened.intent
    : HaLinkOpened.appLink;

bool _inFragment(Uri uri) => uri.fragment.contains('ha=');

/// How the sign-in says where its address came from.
HaAddressFrom addressFromOf(HaLinkOpened opened) =>
    opened == HaLinkOpened.referrer
    ? HaAddressFrom.referrer
    : HaAddressFrom.link;

const _pendingKey = 'ha_link_pending';
const _srcKey = 'ha_link_src';
const _atKey = 'ha_link_at';
const _usedKey = 'ha_link_used';
const _referrerReadKey = 'referrer_read';

/// A link's source is kept this long for the setup it may finish.
const haLinkKeep = Duration(days: 14);

/// A link that arrived before the first home: it waits on the Welcome
/// question, with its event, until the usage-data answer is given.
class PendingHaLink {
  const PendingHaLink({
    required this.address,
    required this.src,
    required this.opened,
    this.counted = false,
  });

  final String? address;
  final HaLinkSrc src;
  final HaLinkOpened opened;

  /// Its `ha_link` event went out (or was offered to analytics).
  final bool counted;

  SetupStep get event => SetupStep(
    SetupStepKind.haLink,
    choice: opened,
    result: address == null ? HaHandover.noAddress : HaHandover.address,
    linkSrc: src,
  );

  Map<String, Object?> toJson() => {
    'a': address,
    's': src.name,
    'o': opened.name,
    'c': counted,
  };

  static PendingHaLink? fromJson(Object? j) {
    if (j is! Map) return null;
    final src = HaLinkSrc.values.asNameMap()[j['s']];
    final opened = HaLinkOpened.values.asNameMap()[j['o']];
    if (src == null || opened == null) return null;
    return PendingHaLink(
      address: j['a'] as String?,
      src: src,
      opened: opened,
      counted: j['c'] == true,
    );
  }
}

class PendingHaLinkController extends Notifier<PendingHaLink?> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  PendingHaLink? build() {
    try {
      final at = _prefs.getInt(_atKey);
      if (at != null &&
          DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(at)) >
              haLinkKeep) {
        _clear(_prefs);
        return null;
      }
      final raw = _prefs.getString(_pendingKey);
      return raw == null ? null : PendingHaLink.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> set(PendingHaLink? link) async {
    state = link;
    if (link == null) {
      await _prefs.remove(_pendingKey);
    } else {
      await _prefs.setString(_pendingKey, jsonEncode(link.toJson()));
    }
  }

  /// Once the usage-data answer is given: the held event goes to
  /// analytics, which drops it when the answer was no.
  Future<void> countHeld() async {
    final link = state;
    if (link == null || link.counted) return;
    ref.read(analyticsProvider).track(link.event);
    await set(
      PendingHaLink(
        address: link.address,
        src: link.src,
        opened: link.opened,
        counted: true,
      ),
    );
  }
}

final pendingHaLinkProvider =
    NotifierProvider<PendingHaLinkController, PendingHaLink?>(
      PendingHaLinkController.new,
    );

/// Takes in a link and says where the app goes. A home exists: the
/// sign-in, with the address and a line saying where it came from. Before
/// the first real home (the demo home doesn't count): setup's Welcome,
/// where the link waits for the usage-data answer.
class HaLinks {
  HaLinks(this.ref);

  final Ref ref;

  String? _lastUri;
  DateTime? _lastAt;
  String? _lastTarget;

  /// The `/c` route's redirect. go_router may run a redirect again for
  /// the same navigation; the link is taken in once.
  String route(Uri uri) {
    final key = uri.toString();
    final now = DateTime.now();
    if (key == _lastUri &&
        _lastAt != null &&
        now.difference(_lastAt!) < const Duration(seconds: 5)) {
      return _lastTarget!;
    }
    _lastUri = key;
    _lastAt = now;
    return _lastTarget = accept(parseHaLink(uri), openedBy(uri));
  }

  String accept(HaLink link, HaLinkOpened opened) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (link.address != null) {
      prefs.setString(_srcKey, link.src.name);
      prefs.setInt(_atKey, DateTime.now().millisecondsSinceEpoch);
      prefs.remove(_usedKey);
    }
    final onboarding = ref.read(onboardingProvider);
    if (onboarding.needsOnboarding || onboarding.isDemo) {
      ref
          .read(pendingHaLinkProvider.notifier)
          .set(
            PendingHaLink(
              address: link.address,
              src: link.src,
              opened: opened,
            ),
          );
      return Routes.setup;
    }
    final pending = PendingHaLink(
      address: link.address,
      src: link.src,
      opened: opened,
    );
    ref.read(analyticsProvider).track(pending.event);
    return Routes.haConnectFrom(link.address, addressFromOf(opened));
  }

  /// Google Play's install referrer, read once on the first start of a
  /// Play build: a link opened before ZigDash was installed.
  Future<String?> takeReferrer() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getBool(_referrerReadKey) ?? false) return null;
    await prefs.setBool(_referrerReadKey, true);
    String? referrer;
    try {
      referrer = await _referrer.invokeMethod<String>('take');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
    if (referrer == null || !referrer.startsWith('ha=')) return null;
    final link = haLinkFromParams(referrer);
    if (link.address == null) return null;
    return accept(link, HaLinkOpened.referrer);
  }
}

const _referrer = MethodChannel('zigdash/referrer');

final haLinksProvider = Provider<HaLinks>(HaLinks.new);

/// The sign-in connected with the link's address, unchanged.
void markHaLinkUsed(SharedPreferences prefs) {
  if (prefs.getString(_srcKey) != null) prefs.setBool(_usedKey, true);
}

/// On a finished setup: where the link came from, when this setup used
/// its address over Home Assistant within [haLinkKeep]. Every finished
/// setup ends the link's part.
HaLinkSrc? takeHaLinkSrc(SharedPreferences prefs, {required bool viaHa}) {
  final src = HaLinkSrc.values.asNameMap()[prefs.getString(_srcKey)];
  final at = prefs.getInt(_atKey);
  final used = prefs.getBool(_usedKey) ?? false;
  _clear(prefs);
  if (src == null || at == null || !used || !viaHa) return null;
  final age = DateTime.now().difference(
    DateTime.fromMillisecondsSinceEpoch(at),
  );
  return age > haLinkKeep ? null : src;
}

void _clear(SharedPreferences prefs) {
  for (final k in [_srcKey, _atKey, _usedKey, _pendingKey]) {
    prefs.remove(k);
  }
}

/// The page that makes a connect link on a computer.
const haConnectPage = 'zigdash.app/connect';

/// "Use a computer" (ha-link.md): where to go, and the link to copy.
Future<void> showUseComputerSheet(BuildContext context) {
  final l10n = context.l10n;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.haComputerTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.haComputerBody),
            const SizedBox(height: 12),
            SelectableText(
              haConnectPage,
              key: const Key('ha-computer-page'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('ha-computer-copy'),
              onPressed: () async {
                await Clipboard.setData(
                  const ClipboardData(text: 'https://$haConnectPage'),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.dashExportCopied)));
              },
              icon: const Icon(Icons.copy),
              label: Text(l10n.haComputerCopy),
            ),
          ],
        ),
      ),
    ),
  );
}
