import 'package:flutter/foundation.dart';

import '../discovery/models/z2m_device.dart';
import '../../core/analytics/analytics.dart';
import 'ha_auth.dart';
import 'ha_client.dart';
import 'ha_import_apply.dart';
import 'ha_registry.dart';

/// Reads Home Assistant at an address with a token.
typedef HaReader = Future<HaReadResult> Function(Uri base, String token);

/// The Zigbee2MQTT devices the home has now, or null when the home is not
/// connected.
typedef Z2mDevicesLoader = Future<List<Z2mDevice>?> Function();

/// Signs in at Home Assistant's login page; see [signInToHa].
typedef HaSignIn = Future<HaSignInResult> Function(Uri base);

/// Ends a sign-in; see [revokeHaSignIn].
typedef HaRevoke = Future<void> Function(Uri base, String refreshToken);

/// Whether anything answers at [base] before the browser opens (3.2.9):
/// null when it does, else [HaImportProblem.unreachable] or
/// [HaImportProblem.certificate].
typedef HaImportReach = Future<HaImportProblem?> Function(Uri base);

/// Writes a plan into the home.
typedef HaImportWriter =
    Future<HaImportResult> Function(
      ImportPlan plan, {
      required bool makeDashboards,
      required Set<String?> skipRooms,
    });

/// Why the import is back on its first step.
enum HaImportProblem {
  noAddress,
  noToken,
  unreachable,
  notHomeAssistant,
  badToken,
  certificate,
  failed,

  /// The home is not connected, so ZigDash cannot see its devices.
  noDevices,

  /// Home Assistant did not accept the sign-in (often: no internet to read
  /// ZigDash's page). The token is the way then.
  signInRefused,

  /// The browser came back without signing in (3.2.9): closed, or a page
  /// that never became Home Assistant's login. Until then this went back
  /// in silence, and people tapped Sign in again and again.
  signInUnfinished,
}

sealed class HaImportState {
  const HaImportState();
}

/// Where Home Assistant is and the token; [problem] after a failed try.
class HaImportAsk extends HaImportState {
  const HaImportAsk({required this.address, this.problem});
  final String address;
  final HaImportProblem? problem;
}

class HaImportReading extends HaImportState {
  const HaImportReading();
}

/// What the import would do. [skip] holds unticked rooms (null is the
/// devices in no room); [makeDashboards] adds dashboards from the floors and
/// rooms, besides renaming tiles.
class HaImportPreview extends HaImportState {
  const HaImportPreview({
    required this.plan,
    this.skip = const {},
    this.makeDashboards = true,
  });
  final ImportPlan plan;
  final Set<String?> skip;
  final bool makeDashboards;

  /// Nothing to import: no Zigbee2MQTT device is in Home Assistant (or only
  /// ZHA devices are, [ImportPlan.zhaOnly]).
  bool get empty => plan.matched == 0;
}

class HaImportApplying extends HaImportState {
  const HaImportApplying();
}

class HaImportDone extends HaImportState {
  const HaImportDone(this.result);
  final HaImportResult result;
}

/// The import, one step at a time (docs/design/ha-import.md, "The flow").
/// The token passes through [read] to Home Assistant and is never kept in
/// a state, logged or stored (Q2: import once).
class HaImportController extends ValueNotifier<HaImportState> {
  HaImportController({
    required String address,
    required HaReader reader,
    required Z2mDevicesLoader devices,
    required HaImportWriter writer,
    HaSignIn? signIn,
    HaRevoke? revoke,
    HaImportReach? reach,
    this.onEvent,
  }) : _reader = reader,
       _reach = reach,
       _devices = devices,
       _writer = writer,
       _signIn = signIn,
       _revoke = revoke,
       _address = address,
       super(HaImportAsk(address: address));

  final HaReader _reader;
  final Z2mDevicesLoader _devices;
  final HaImportWriter _writer;
  final HaSignIn? _signIn;
  final HaRevoke? _revoke;
  final HaImportReach? _reach;
  String _address;

  /// Usage events only the controller can see (2.9.7): how the sign-in
  /// ended, which no state shows (a cancelled login just goes back).
  final void Function(HaImportEvent event)? onEvent;

  void _signedIn(HaSignInMethod method, HaSignInOutcome outcome) =>
      onEvent?.call(
        HaImportEvent(HaImportStep.signIn, method: method, outcome: outcome),
      );

  /// Whether this build can sign in at Home Assistant's login page.
  bool get canSignIn => _signIn != null;

  /// Signs in at Home Assistant's own login page, reads once, then ends the
  /// sign-in (Q1, Q2). The tokens never reach a state.
  Future<void> signInAndRead(String address) async {
    _address = address.trim();
    final base = haBaseUri(_address);
    final signIn = _signIn;
    if (base == null) return _ask(HaImportProblem.noAddress);
    if (signIn == null) return;
    final z2m = await _devices();
    if (z2m == null) return _ask(HaImportProblem.noDevices);
    // 3.2.9: the address is filled in from the broker, which on an SMHUB
    // or a separate Mosquitto box is not Home Assistant; the browser then
    // showed an error page, closed as a cancel, six times in a row.
    final unreached = await _reach?.call(base);
    if (unreached != null) return _ask(unreached);
    final signed = await signIn(base);
    final access = signed.accessToken;
    _signedIn(HaSignInMethod.page, switch (signed.error) {
      _ when access != null => HaSignInOutcome.ok,
      HaSignInError.refused => HaSignInOutcome.refused,
      HaSignInError.failed => HaSignInOutcome.failed,
      HaSignInError.cancelled || null => HaSignInOutcome.cancelled,
    });
    if (access == null) {
      return switch (signed.error) {
        HaSignInError.cancelled ||
        null => _ask(HaImportProblem.signInUnfinished),
        HaSignInError.refused => _ask(HaImportProblem.signInRefused),
        HaSignInError.failed => _ask(HaImportProblem.failed),
      };
    }
    value = const HaImportReading();
    try {
      await _readWith(base, access, z2m);
    } finally {
      final refresh = signed.refreshToken;
      if (refresh != null) {
        try {
          await _revoke?.call(base, refresh);
        } catch (_) {}
      }
    }
  }

  Future<void> read(String address, String token) async {
    _address = address.trim();
    final base = haBaseUri(_address);
    if (base == null) return _ask(HaImportProblem.noAddress);
    if (token.trim().isEmpty) return _ask(HaImportProblem.noToken);
    value = const HaImportReading();
    final z2m = await _devices();
    if (z2m == null) return _ask(HaImportProblem.noDevices);
    await _readWith(base, token.trim(), z2m, pasted: true);
  }

  Future<void> _readWith(
    Uri base,
    String token,
    List<Z2mDevice> z2m, {
    bool pasted = false,
  }) async {
    final read = await _reader(base, token);
    final registry = read.registry;
    // A pasted token is only judged once Home Assistant answered: accepted
    // (read, or failed past the login), or refused.
    if (pasted) {
      switch (read.error) {
        case null || HaReadError.failed:
          _signedIn(HaSignInMethod.token, HaSignInOutcome.ok);
        case HaReadError.badToken:
          _signedIn(HaSignInMethod.token, HaSignInOutcome.failed);
        case HaReadError.unreachable ||
            HaReadError.notHomeAssistant ||
            HaReadError.certificate:
          break;
      }
    }
    if (registry == null) {
      return _ask(switch (read.error) {
        HaReadError.unreachable => HaImportProblem.unreachable,
        HaReadError.notHomeAssistant => HaImportProblem.notHomeAssistant,
        HaReadError.badToken => HaImportProblem.badToken,
        HaReadError.certificate => HaImportProblem.certificate,
        HaReadError.failed || null => HaImportProblem.failed,
      });
    }
    value = HaImportPreview(plan: planImport(registry, z2m));
  }

  void toggleRoom(String? room) {
    final s = value;
    if (s is! HaImportPreview) return;
    final skip = {...s.skip};
    if (!skip.remove(room)) skip.add(room);
    value = HaImportPreview(
      plan: s.plan,
      skip: skip,
      makeDashboards: s.makeDashboards,
    );
  }

  void setMakeDashboards(bool on) {
    final s = value;
    if (s is! HaImportPreview) return;
    value = HaImportPreview(plan: s.plan, skip: s.skip, makeDashboards: on);
  }

  Future<void> apply() async {
    final s = value;
    if (s is! HaImportPreview || s.empty) return;
    value = const HaImportApplying();
    try {
      value = HaImportDone(
        await _writer(
          s.plan,
          makeDashboards: s.makeDashboards,
          skipRooms: s.skip,
        ),
      );
    } catch (_) {
      value = s;
      rethrow;
    }
  }

  /// Back to the first step, keeping the address.
  void back() => value = HaImportAsk(address: _address);

  void _ask(HaImportProblem problem) =>
      value = HaImportAsk(address: _address, problem: problem);
}
