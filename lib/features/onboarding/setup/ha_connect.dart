// Connecting a home through Home Assistant (docs/design/ha-route.md,
// route A): the address the user opens Home Assistant with, a sign-in,
// and a check that Home Assistant's MQTT is usable; then the setup
// coordinator reads and reviews the devices like any other candidate.
//
// The sign-in is kept: a refresh token from the login page (stored as
// `refresh:<token>`) or a pasted long-lived token, in the same secure
// storage as broker passwords, under the home's row.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../core/analytics/analytics.dart';
import '../../../mqtt/endpoint.dart';
import '../../../mqtt/ha_address.dart';
import '../../../mqtt/ha_mqtt_client.dart';
import '../../../mqtt/ha_token.dart';
import '../../ha_import/ha_auth.dart';
import '../../ha_import/ha_import_controller.dart' show HaSignIn;
import 'ha_address_shape.dart';
import 'ha_discovery.dart';

/// Why connecting stopped, for the screen.
enum HaConnectProblem {
  noAddress,
  noToken,
  unreachable,
  notHomeAssistant,
  certificate,
  signInRefused,
  signInFailed,
  badToken,
  notAdmin,
  noMqtt,
}

/// How a try ended, for usage data (`setup_step` ha_connect).
enum HaConnectOutcome {
  ok,
  noAddress,
  unreachable,
  notHomeAssistant,
  certificate,
  signInCancelled,
  signInRefused,
  signInFailed,
  badToken,
  notAdmin,
  noMqtt,
}

sealed class HaConnectState {
  const HaConnectState();
}

/// Waiting for the address and a sign-in; [problem] after a failed try,
/// and the [shape] of the address it went to (3.1.12).
class HaConnectAsk extends HaConnectState {
  const HaConnectAsk({required this.address, this.problem, this.shape});
  final String address;
  final HaConnectProblem? problem;
  final HaAddressShape? shape;
}

/// Signing in, or checking Home Assistant.
class HaConnectChecking extends HaConnectState {
  const HaConnectChecking();
}

/// Home Assistant accepted the sign-in and its MQTT is usable; the
/// coordinator took over (devices, review).
class HaConnectDone extends HaConnectState {
  const HaConnectDone();
}

/// Connects once to Home Assistant with [stored] (the stored form of the
/// sign-in) and says what is wrong, or null when it is usable.
typedef HaProbe = Future<HaConnectProblem?> Function(Uri base, String stored);

/// Looks for Home Assistant on the network (3.1.8); see [findHomeAssistant].
typedef HaFind = Future<List<HaFound>> Function();

/// The phone's own IPv4 on the home network, or null.
typedef HaPhoneIp = Future<String?> Function();

/// Hands the checked home to the setup coordinator.
typedef HaAdopt = Future<void> Function(Uri address, String signIn);

/// Whether anything answers at [base], before the browser opens; null
/// when it does.
typedef HaReach = Future<HaConnectProblem?> Function(Uri base);

/// The real reach (3.1.4): one request to Home Assistant's sign-in
/// providers. Only silence or a bad certificate stops the sign-in: a page
/// that answers in any way goes on to the browser, which shows it.
Future<HaConnectProblem?> reachHomeAssistant(Uri base) async {
  // The same budget as connecting through Home Assistant: a remote
  // address over mobile data can be slow, and must not read as down.
  const budget = Duration(milliseconds: homeAssistantConnectTimeoutMs);
  final client = HttpClient()..connectionTimeout = budget;
  try {
    final request = await client
        .getUrl(base.replace(path: '/auth/providers'))
        .timeout(budget);
    final response = await request.close().timeout(budget);
    await response.drain<void>().catchError((_) {});
    return null;
  } on HandshakeException {
    return HaConnectProblem.certificate;
  } catch (_) {
    return HaConnectProblem.unreachable;
  } finally {
    client.close(force: true);
  }
}

/// The real probe: a [HaMqttClient] connect, then disconnect.
Future<HaConnectProblem?> probeHomeAssistant(Uri base, String stored) async {
  final client = HaMqttClient(haWebSocketUri(base), 'zd-check')
    ..connectTimeoutPeriod = 12000
    ..keepAlivePeriod = 0;
  try {
    await client.connect(null, stored);
  } on TimeoutException {
    return HaConnectProblem.unreachable;
  } on HandshakeException {
    return HaConnectProblem.certificate;
  } on WebSocketException {
    // Something answered HTTP but refused the upgrade: not Home Assistant.
    return HaConnectProblem.notHomeAssistant;
  } catch (_) {
    return HaConnectProblem.unreachable;
  } finally {
    client.disconnect();
  }
  return switch (client.problem) {
    null => null,
    HaClientProblem.signInRejected => HaConnectProblem.badToken,
    HaClientProblem.notAdmin => HaConnectProblem.notAdmin,
    HaClientProblem.noMqtt => HaConnectProblem.noMqtt,
    HaClientProblem.unreachable => HaConnectProblem.unreachable,
  };
}

class HaConnectController extends ValueNotifier<HaConnectState> {
  HaConnectController({
    required String address,
    required HaAdopt adopt,
    HaProbe probe = probeHomeAssistant,
    HaSignIn? signIn,
    HaReach? reach,
    HaFind? find,
    HaPhoneIp? phoneIp,
    this.onEvent,
  }) : _adopt = adopt,
       _phoneIpOf = phoneIp,
       _probe = probe,
       _signIn = signIn,
       _reach = reach,
       _find = find,
       super(HaConnectAsk(address: address));

  final HaAdopt _adopt;
  final HaProbe _probe;
  final HaSignIn? _signIn;
  final HaReach? _reach;
  final HaFind? _find;
  final HaPhoneIp? _phoneIpOf;

  /// The phone's own address, once asked (3.1.12): what a typed private
  /// address is judged against. Shown on the screen, never sent.
  String? get phoneIp => _phoneIp;
  String? _phoneIp;
  Future<String?>? _askingPhone;

  Future<HaAddressShape> _shapeOf(String address) async {
    final ask = _phoneIpOf;
    if (ask != null) {
      _phoneIp = await (_askingPhone ??= ask().catchError((_) => null));
    }
    return haAddressShapeOf(address, phoneIp: _phoneIp);
  }

  /// The look for Home Assistant on the network, once started.
  Future<List<HaFound>>? _looking;

  /// What the look found; empty until it ends, or when nothing answered.
  List<HaFound> get found => _found;
  var _found = const <HaFound>[];

  /// Whether the look is under way.
  bool get looking => _looking != null && !_lookDone;

  /// Whether a look ended.
  bool get looked => _lookDone;
  var _lookDone = false;

  /// Bumped by [cancel] and [dispose]: a try that finds it changed stops
  /// where it is and hands nothing on.
  var _try = 0;
  var _disposed = false;

  /// The address of the try under way, for [cancel].
  var _tryAddress = '';

  /// Usage events: how each try ended. Never the address or a token.
  final void Function(AnalyticsEvent event)? onEvent;

  bool get canSignIn => _signIn != null;

  String get _address => switch (value) {
    HaConnectAsk(:final address) => address,
    _ => '',
  };

  void _ask(
    String address,
    HaConnectProblem? problem, [
    HaAddressShape? shape,
  ]) {
    if (_disposed) return;
    value = HaConnectAsk(address: address, problem: problem, shape: shape);
  }

  void _checking(String address) {
    _tryAddress = address;
    value = const HaConnectChecking();
  }

  void _count(HaConnectOutcome outcome, HaAddressShape shape, [Uri? base]) =>
      onEvent?.call(
        SetupStep(
          SetupStepKind.haConnect,
          result: outcome,
          shape: shape,
          portClass: base == null ? null : haPortClassOf(base),
        ),
      );

  /// Looks for Home Assistant on the network (3.1.8), once; the screen
  /// fills the address with what it finds.
  Future<List<HaFound>> look() {
    final find = _find;
    if (find == null) return Future.value(const []);
    return _looking ??= () async {
      List<HaFound> found;
      try {
        found = await find();
      } catch (_) {
        found = const [];
      }
      _found = found;
      _lookDone = true;
      onEvent?.call(
        SetupStep(
          SetupStepKind.haDiscovery,
          result: switch (found.length) {
            0 => HaDiscoveryOutcome.none,
            1 when found.single.byName => HaDiscoveryOutcome.byName,
            1 => HaDiscoveryOutcome.one,
            _ => HaDiscoveryOutcome.several,
          },
        ),
      );
      if (!_disposed) notifyListeners();
      return found;
    }();
  }

  /// Home Assistant's own login page in the browser, then the check.
  Future<void> signInAndConnect(String address) async {
    final signIn = _signIn;
    if (signIn == null) return;
    var base = haBaseUri(address);
    final typed = address;
    final t = ++_try;
    if (base == null && _looking != null) {
      // Signed in before the look ended, with nothing typed: wait for it.
      _checking(address);
      final found = await _looking!;
      if (t != _try) return;
      if (found.isNotEmpty) {
        address = found.first.address;
        base = haBaseUri(address);
      }
    } else if (base != null &&
        base.host.toLowerCase().endsWith('.local') &&
        _found.length == 1) {
      // A `.local` name Android may not resolve: the one Home Assistant
      // found, by its address.
      address = _found.single.address;
      base = haBaseUri(address);
    }
    if (base == null) {
      final shape = await _shapeOf(address);
      if (t != _try) return;
      _count(HaConnectOutcome.noAddress, shape);
      return _ask(address, HaConnectProblem.noAddress, shape);
    }
    if (_found.any((f) => haBaseUri(f.address) == base)) {
      onEvent?.call(
        const SetupStep(
          SetupStepKind.haDiscovery,
          result: HaDiscoveryOutcome.used,
        ),
      );
    }
    _checking(address);
    // A typed `.local` name swapped for the found Home Assistant is
    // counted as typed, and gets no advice by kind: it would be about
    // another address than the one in the field. An empty field took the
    // found address, which then fills the field.
    final swapped = address != typed && typed.trim().isNotEmpty;
    final shape = await _shapeOf(swapped ? typed : address);
    if (t != _try) return;
    final advice = swapped ? null : shape;
    // A Home Assistant that can't be reached would open the browser on an
    // error page, and closing it read as nothing happening (3.1.4).
    final unreached = await _reach?.call(base);
    if (t != _try) return;
    if (unreached != null) {
      _count(
        unreached == HaConnectProblem.certificate
            ? HaConnectOutcome.certificate
            : HaConnectOutcome.unreachable,
        shape,
        base,
      );
      return _ask(address, unreached, advice);
    }
    final signed = await signIn(base);
    if (t != _try) return;
    final access = signed.accessToken;
    if (access == null) {
      switch (signed.error) {
        case HaSignInError.cancelled || null:
          _count(HaConnectOutcome.signInCancelled, shape, base);
          return _ask(address, null, advice);
        case HaSignInError.refused:
          _count(HaConnectOutcome.signInRefused, shape, base);
          return _ask(address, HaConnectProblem.signInRefused, advice);
        case HaSignInError.failed:
          _count(HaConnectOutcome.signInFailed, shape, base);
          return _ask(address, HaConnectProblem.signInFailed, advice);
      }
    }
    // Kept as the refresh token when there is one: access tokens last
    // 30 minutes. Without one, the access token still connects for now.
    final refresh = signed.refreshToken;
    await _check(
      t,
      base,
      address,
      refresh != null ? haStoredRefresh(refresh) : access,
      shape,
    );
  }

  /// A pasted long-lived token.
  Future<void> connectWithToken(String address, String token) async {
    final base = haBaseUri(address);
    final t = ++_try;
    if (base == null) {
      final shape = await _shapeOf(address);
      if (t != _try) return;
      _count(HaConnectOutcome.noAddress, shape);
      return _ask(address, HaConnectProblem.noAddress, shape);
    }
    if (token.trim().isEmpty) return _ask(address, HaConnectProblem.noToken);
    _checking(address);
    final shape = await _shapeOf(address);
    if (t != _try) return;
    await _check(t, base, address, token.trim(), shape);
  }

  Future<void> _check(
    int t,
    Uri base,
    String address,
    String stored,
    HaAddressShape shape,
  ) async {
    final problem = await _probe(base, stored);
    if (t != _try) return;
    if (problem != null) {
      _count(switch (problem) {
        HaConnectProblem.unreachable => HaConnectOutcome.unreachable,
        HaConnectProblem.notHomeAssistant => HaConnectOutcome.notHomeAssistant,
        HaConnectProblem.certificate => HaConnectOutcome.certificate,
        HaConnectProblem.badToken => HaConnectOutcome.badToken,
        HaConnectProblem.notAdmin => HaConnectOutcome.notAdmin,
        HaConnectProblem.noMqtt => HaConnectOutcome.noMqtt,
        _ => HaConnectOutcome.unreachable,
      }, shape, base);
      return _ask(address, problem, shape);
    }
    _count(HaConnectOutcome.ok, shape, base);
    value = const HaConnectDone();
    await _adopt(base, stored);
  }

  void back() => _ask(_address, null);

  /// Stops the try under way (3.1.4): back to the address, nothing kept.
  void cancel() {
    if (value is! HaConnectChecking) return;
    _try++;
    _ask(_tryAddress, null);
  }

  @override
  void dispose() {
    _try++;
    _disposed = true;
    super.dispose();
  }
}
