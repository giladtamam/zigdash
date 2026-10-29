import 'dart:async';

import '../../../core/analytics/analytics_events.dart' show SetupVia;
import '../../../data/database/tables/connections.dart';
import '../../../mqtt/broker_config.dart';
import '../../../mqtt/ha_address.dart';
import '../../connections/diagnostics/connect_diagnostics.dart';
import '../../connections/discovery/address_check.dart';
import '../../connections/discovery/broker_probe.dart';
import '../../connections/discovery/broker_scan_service.dart';
import '../../connections/discovery/hub_probe.dart';
import '../../connections/discovery/no_network.dart';
import '../../connections/discovery/z2m_frontend.dart';
import '../../discovery/models/z2m_device.dart';
import 'recommendation_policy.dart';
import 'setup_candidate.dart';
import 'setup_creator.dart';
import 'setup_error_guidance.dart';

/// The outcome of fetching the device list during verification: whether
/// Zigbee2MQTT topics verified on the endpoint at all, and the parsed devices.
class Z2mFetchResult {
  const Z2mFetchResult({
    required this.detected,
    required this.devices,
    this.otherBases = const [],
    this.devicesMissing = false,
  });

  /// Zigbee2MQTT answered (state or info) but its retained `bridge/devices`
  /// never came (3.1.13): a broker that lost its retained messages, which
  /// Zigbee2MQTT before 2.14.2 doesn't republish until it restarts.
  final bool devicesMissing;

  /// True only after `$base/bridge/...` topics verified Zigbee2MQTT — the UI
  /// may not claim Z2M was found before this.
  final bool detected;
  final List<Z2mDevice> devices;

  /// Other base topics with a Zigbee2MQTT bridge on the same broker (their
  /// `<base>/bridge/state`), for a Zigbee2MQTT set up with its own base
  /// topic (2.9.2, a German user on 2026-10-17).
  final List<String> otherBases;
}

typedef DeviceIpProvider = Future<String?> Function();

/// Why there is no home address, when [DeviceIpProvider] found none (2.9.4).
typedef NoNetworkProvider = Future<NoNetwork> Function();

/// Starts a scan; [hubs] are the hub kinds to look for when the phone's /24
/// has no broker (the user's platform answer adds the SMLIGHT pass).
typedef ScanRunFactory = ScanRun Function(String deviceIp, Set<HubKind> hubs);

/// Where the user says Zigbee2MQTT runs, asked while the scan runs (2.5).
/// Not an answer and [notSure] both mean the plain scan; the others add a
/// pass or change what the empty result says.
/// The answer to "where does Zigbee2MQTT run?". [zha] (3.1.3) is Home
/// Assistant's own Zigbee with no Zigbee2MQTT, which ZigDash can't serve;
/// counted to size a move from ZHA (wayfinder map "ZHA to ZigDash").
enum SetupPlatform { homeAssistant, smlight, piOrDocker, zha, notSure }

/// The hub kinds a platform answer makes the scan look for, on top of the
/// default ones (Home Assistant and the Zigbee2MQTT frontend).
Set<HubKind> hubsForPlatform(SetupPlatform? platform) => {
  ...BrokerScanService.defaultHubs,
  if (platform == SetupPlatform.smlight) HubKind.smlight,
};

/// What Zigbee2MQTT's web page at host:port says about its broker; see
/// [z2mBrokerSetting].
typedef Z2mBrokerLookup =
    Future<Z2mBrokerSetting?> Function(String host, int port);

/// Whether Zigbee2MQTT's web page answers at [host]:[port] without a token
/// (3.2): then setup connects through it and never asks for a broker login.
typedef Z2mPagePresent = Future<bool> Function(String host, int port);

/// Reads Zigbee2MQTT's device list from its web page on [host] (3.1.13),
/// which sends the list on connect even when the broker lost it. Null when
/// the page doesn't answer, is locked, or sends no list.
typedef Z2mPageDevices = Future<List<Z2mDevice>?> Function(String host);

/// Probes one host:port for an MQTT broker.
typedef BrokerPortProbe = Future<ProbeResult?> Function(String host, int port);

/// Names the machine at a host from its web pages; see [identifyHost].
typedef HubIdentifier = Future<HubKind?> Function(String host);

/// How far a scan has come, for the progress bar.
typedef ScanProgressValue = ({int checked, int total});

/// What a finished scan tried, for the empty result's analytics: whether it
/// widened, how many hosts it tried and how many answered at all (2.6.2),
/// and how many only to the second, slower look (2.9.3).
typedef ScanTried = ({
  bool widened,
  int hostsTried,
  int aliveHosts,
  int lateHosts,
});

/// The network the scan ran on, for the empty result's analytics (2.6.2):
/// the interface kind as Support details names it ("Wi-Fi", "Ethernet",
/// "other") and whether a VPN was up. Never an address.
typedef NetworkFacts = ({String? kind, bool vpn});
typedef NetworkFactsProvider = Future<NetworkFacts> Function();

/// How the address check (2.6.2) is going on the empty result, and the host
/// it was given, for the message. A broker outcome leaves this state (setup
/// verifies the broker); a hub outcome is also recorded in
/// [SetupScanEmpty.hubs].
enum AddressCheckStatus {
  checking,
  hub,
  nothing,
  notResolved,
  notLocal,
  invalid,
}

typedef AddressCheckState = ({AddressCheckStatus status, String host});
typedef DeviceListFetcher =
    Future<Z2mFetchResult> Function(
      BrokerConfig config,
      String password,
      String base,
    );

// --- States ---------------------------------------------------------------

sealed class SetupState {
  const SetupState();
}

/// The welcome screen — nothing running yet.
class SetupIdle extends SetupState {
  const SetupIdle();
}

/// Scanning the local network; [candidates] grow progressively and [done]
/// flips true when the scan completes. [hubs] are the hubs seen so far,
/// [progress] how far the scan is, [platform] the user's answer, [kinds]
/// what the candidates' machines are.
class SetupScanning extends SetupState {
  const SetupScanning(
    this.candidates, {
    this.done = false,
    this.hubs = const [],
    this.progress,
    this.platform,
    this.kinds = const {},
  });
  final List<SetupCandidate> candidates;
  final bool done;
  final List<HubFound> hubs;
  final ScanProgressValue? progress;
  final SetupPlatform? platform;

  /// What each candidate's machine is, by host, once the scan has found more
  /// than one broker and looked at their web pages (2.7.1).
  final Map<String, HubKind> kinds;
}

/// The scan finished without a single usable candidate. [hubs] are the hubs
/// it saw instead, [platform] the user's answer, [tried] what it covered,
/// [deviceIp] the phone's address and [network] what it ran on, for the
/// result screen and its analytics. [address] is the address check's state
/// once the user typed one (2.6.2). [z2m] is what Zigbee2MQTT's web page
/// said about its broker, once asked (2.7.2).
class SetupScanEmpty extends SetupState {
  const SetupScanEmpty({
    this.hubs = const [],
    this.platform,
    this.tried,
    this.deviceIp,
    this.network,
    this.address,
    this.z2m,
  });
  final List<HubFound> hubs;
  final SetupPlatform? platform;
  final ScanTried? tried;
  final String? deviceIp;
  final NetworkFacts? network;
  final AddressCheckState? address;
  final Z2mAnswer? z2m;

  SetupScanEmpty copyWith({
    List<HubFound>? hubs,
    SetupPlatform? platform,
    AddressCheckState? address,
    bool clearAddress = false,
    Z2mAnswer? z2m,
    bool clearZ2m = false,
  }) => SetupScanEmpty(
    hubs: hubs ?? this.hubs,
    platform: platform ?? this.platform,
    tried: tried,
    deviceIp: deviceIp,
    network: network,
    address: clearAddress ? null : (address ?? this.address),
    z2m: clearZ2m ? null : (z2m ?? this.z2m),
  );

  /// The hub the result speaks about: Home Assistant first (it hosts the
  /// broker), then the Zigbee2MQTT frontend, then an SMLIGHT hub.
  HubFound? get hub {
    for (final kind in HubKind.values) {
      for (final h in hubs) {
        if (h.kind == kind) return h;
      }
    }
    return null;
  }
}

/// Asking Zigbee2MQTT's web page where its broker is (2.7.2), and what came
/// of it. [broker] leaves the empty result for verification; the others stay
/// on it.
enum Z2mAnswerStatus {
  asking,
  broker,
  localOnly,

  /// The server is a bare name only Zigbee2MQTT's machine knows (2.10.4).
  nameOnly,
  unreachable,

  /// The page is protected by a token, so it could not be asked (2.10.4).
  tokenRequired,
  noAnswer,
}

/// [server] is the broker as Zigbee2MQTT names it (`mqtt://localhost:1883`),
/// empty while asking or when nothing answered.
typedef Z2mAnswer = ({Z2mAnswerStatus status, String server});

/// Running the diagnostic ladder against [candidate].
class SetupVerifying extends SetupState {
  const SetupVerifying(this.candidate, {this.lateHosts});
  final SetupCandidate candidate;

  /// For a broker the scan found: how many hosts answered only to its
  /// second look (2.9.3), so analytics can tell whether that look found it.
  final int? lateHosts;
}

/// The broker requires credentials. [rejected] is true when credentials were
/// already tried and refused — the UI shows "wrong password" guidance instead
/// of the first-time prompt.
/// The broker refused anonymous access. [platform] is the user's answer so
/// far, so the prompt can say where that platform keeps its MQTT login.
class SetupNeedsAuth extends SetupState {
  const SetupNeedsAuth(
    this.candidate, {
    this.rejected = false,
    this.platform,
    this.suggestedUser,
  });
  final SetupCandidate candidate;
  final bool rejected;
  final SetupPlatform? platform;

  /// The username Zigbee2MQTT logs in with, when its web page said (2.7.2).
  final String? suggestedUser;
}

/// A categorized failure. [failedAtCreation] marks save failures: retry then
/// resumes at creation instead of re-verifying.
class SetupFailed extends SetupState {
  const SetupFailed(
    this.kind, {
    this.candidate,
    this.failedAtCreation = false,
    this.noNetwork,
  });
  final SetupErrorKind kind;
  final SetupCandidate? candidate;
  final bool failedAtCreation;

  /// Why the phone had no home address, on [SetupErrorKind.scanFailed]
  /// (2.9.4). Setup starts again by itself once Wi-Fi is back.
  final NoNetwork? noNetwork;
}

/// Devices verified — the user reviews the grouped, preselected rows.
class SetupReview extends SetupState {
  const SetupReview(this.candidate, this.rows);
  final SetupCandidate candidate;
  final List<ReviewRow> rows;

  int get selectedCount => rows.where((r) => r.selected).length;
}

/// Saving connection + dashboard + panels. Carries the [review] so the list
/// stays on screen with a busy button instead of a separate screen.
class SetupCreating extends SetupState {
  const SetupCreating(this.review);
  final SetupReview review;
}

/// Done — the dashboard is ready.
class SetupComplete extends SetupState {
  const SetupComplete(this.result, {this.via = SetupVia.scan});
  final SetupResult result;

  /// The scan's review, or Home Assistant's sign-in (3.1.3, analytics).
  final SetupVia via;
}

// --- Coordinator ----------------------------------------------------------

/// Owns the discovery-first setup state machine:
///
///   idle → scanning → verifying → (needsAuth →) review → creating → complete
///
/// The UI renders [state] and sends intents; it never performs network work
/// or persists partial setup itself. Valid values (credentials, selections)
/// survive retries within the session; [cancel] releases scans and timers and
/// returns to a safe initial state.
class SetupCoordinator {
  SetupCoordinator({
    required ScanRunFactory scan,
    required DeviceIpProvider deviceIp,
    required ConnectDiagnostics diagnostics,
    required DeviceListFetcher fetchDevices,
    required SetupStore creator,
    AddressChecker? checkAddress,
    HubIdentifier? identifyHub,
    Z2mBrokerLookup? askZ2m,
    Z2mPageDevices? pageDevices,
    Z2mPagePresent? pagePresent,
    BrokerPortProbe? probeBroker,
    NetworkFactsProvider? networkFacts,
    NoNetworkProvider? noNetwork,
    this.networkRecheck = const Duration(seconds: 2),
    String base = 'zigbee2mqtt',
    this.onCreated,
  }) : _base = base,
       _scan = scan,
       _deviceIp = deviceIp,
       _diagnostics = diagnostics,
       _fetchDevices = fetchDevices,
       _creator = creator,
       _checkAddress = checkAddress,
       _identifyHub = identifyHub,
       _askZ2m = askZ2m,
       _pageDevices = pageDevices,
       _pagePresent = pagePresent,
       _probeBroker = probeBroker,
       _networkFacts = networkFacts,
       _noNetwork = noNetwork;

  final ScanRunFactory _scan;
  final DeviceIpProvider _deviceIp;
  final ConnectDiagnostics _diagnostics;
  final DeviceListFetcher _fetchDevices;
  final SetupStore _creator;

  /// The address check (2.6.2); null where the platform cannot probe (web),
  /// and then [checkAddress] reports nothing found.
  final AddressChecker? _checkAddress;

  /// Names the machine behind each broker when the scan finds several, so
  /// the cards say "Home Assistant" instead of two identical "Possible
  /// connection found" (2.7.1). Null where the platform cannot probe.
  final HubIdentifier? _identifyHub;

  /// Asks Zigbee2MQTT's web page where its broker is, when the scan saw the
  /// page but no broker (2.7.2), and probes the answer. Null where the
  /// platform cannot.
  final Z2mBrokerLookup? _askZ2m;
  final Z2mPageDevices? _pageDevices;
  final Z2mPagePresent? _pagePresent;

  /// 3.2: the first Zigbee2MQTT page in [pages] that answers; setup then
  /// goes through it. False when none does (or the platform can't look),
  /// and the broker path carries on as before.
  Future<bool> _tryPages(List<(String, int)> pages) async {
    final present = _pagePresent;
    if (present == null) return false;
    final op = _op;
    for (final (host, port) in {...pages}) {
      bool ok;
      try {
        ok = await present(host, port);
      } catch (_) {
        ok = false;
      }
      if (op != _op) return true; // cancelled or moved on: stop here
      if (ok) {
        await adoptZ2mPage(host: host, port: port);
        return true;
      }
    }
    return false;
  }

  /// Where Zigbee2MQTT's page may be for [candidate]: on the same machine,
  /// and any page the scan saw.
  List<(String, int)> _pagesFor(SetupCandidate candidate) => [
    (candidate.host, hubPorts[HubKind.zigbee2mqtt]!),
    for (final h in switch (_state) {
      SetupScanning(:final hubs) || SetupScanEmpty(:final hubs) => hubs,
      _ => const <HubFound>[],
    })
      if (h.kind == HubKind.zigbee2mqtt) (h.host, h.port),
  ];
  final BrokerPortProbe? _probeBroker;

  /// The username Zigbee2MQTT logs in with, from its web page, for the login
  /// step.
  String? _z2mUser;

  /// Home Assistant answered during this setup (a scan card, a hub page).
  bool _haSeen = false;

  /// The broker's host once the home is saved, for [homeAssistantSeen].
  String? _createdOn;

  /// Whether this home has Home Assistant, for offering the import after
  /// setup (docs/design/ha-import.md): seen by the scan, answered by the
  /// user, or found on the broker's machine now (the scan skips web pages
  /// when one broker answers at once).
  Future<bool> homeAssistantSeen() async {
    if (_haSeen || _platform == SetupPlatform.homeAssistant) return true;
    final host = _createdOn;
    final identify = _identifyHub;
    if (host == null || identify == null) return false;
    try {
      return await identify(host) == HubKind.homeAssistant;
    } catch (_) {
      return false;
    }
  }

  final NetworkFactsProvider? _networkFacts;
  final NoNetworkProvider? _noNetwork;

  /// How often the no-network screen looks for Wi-Fi again (2.9.4). Quiet:
  /// it emits nothing until there is an address, so the scan_failed count
  /// stays one per attempt.
  final Duration networkRecheck;
  Timer? _recheck;

  /// Runs once after a successful setup, before [SetupComplete] is emitted
  /// (the app clears demo mode, finishes first run and remembers the new
  /// dashboard). Its failures never undo the saved setup.
  final Future<void> Function(SetupResult result)? onCreated;

  /// The Zigbee2MQTT base topic for this session; [retryWithBase] changes it.
  String get base => _base;
  String _base;

  /// The base topic was switched to one found on the broker (2.9.2); only
  /// once per verification, so two bridges can't bounce between each other.
  bool _triedOtherBase = false;

  final _states = StreamController<SetupState>.broadcast();
  SetupState _state = const SetupIdle();

  StreamSubscription<ScanEvent>? _scanSub;
  ScanRun? _run;
  SetupPlatform? _platform;
  String? _username;
  String? _password;
  List<ReviewRow>? _rows;
  var _op = 0;

  SetupState get state => _state;
  Stream<SetupState> get states => _states.stream;

  /// The user's platform answer, kept for the session.
  SetupPlatform? get platform => _platform;

  void _emit(SetupState s) {
    if (s is SetupScanning &&
            (s.hubs.any((h) => h.kind == HubKind.homeAssistant) ||
                s.kinds.containsValue(HubKind.homeAssistant)) ||
        s is SetupScanEmpty &&
            s.hubs.any((h) => h.kind == HubKind.homeAssistant)) {
      _haSeen = true;
    }
    _state = s;
    if (!_states.isClosed) _states.add(s);
  }

  // --- Intents ---

  /// The platform came from the welcome's question (3.2): the scan then
  /// doesn't ask it again.
  bool answeredFirst = false;

  /// Whether the running scan covers the whole /22 (3.2: only after
  /// "Look on the whole network"; the phone's own /24 first).
  bool get widen => _widen;
  var _widen = false;

  Future<void> startScan({bool widen = false}) async {
    _widen = widen;
    _triedOtherBase = false;
    final op = ++_op;
    _cancelScan();
    _z2mUser = null;
    _haSeen = false;
    _emit(SetupScanning(const [], platform: _platform));
    final ip = await _deviceIp();
    if (op != _op) return;
    if (ip == null) {
      NoNetwork why;
      try {
        why = await _noNetwork?.call() ?? NoNetwork.unknown;
      } catch (_) {
        why = NoNetwork.unknown;
      }
      if (op != _op) return;
      _emit(SetupFailed(SetupErrorKind.scanFailed, noNetwork: why));
      _watchForNetwork(op);
      return;
    }
    NetworkFacts? network;
    try {
      network = await _networkFacts?.call();
    } catch (_) {
      // Diagnostics only; the scan runs without them.
    }
    if (op != _op) return;
    final buffer = <ProbeResult>[];
    final hubs = <HubFound>[];
    ScanProgressValue? progress;
    ScanTried? tried;
    final run = _scan(ip, hubsForPlatform(_platform));
    _run = run;
    void emitScanning({bool done = false}) => _emit(
      SetupScanning(
        mergeCandidates(buffer),
        done: done,
        hubs: List.unmodifiable(hubs),
        progress: progress,
        platform: _platform,
      ),
    );
    _scanSub = run.events.listen(
      (event) {
        if (_state is! SetupScanning) return;
        switch (event) {
          case BrokerFound(:final broker):
            buffer.add(broker);
            emitScanning();
          case HubSeen(:final hub):
            hubs.add(hub);
            emitScanning();
          case ScanProgress(:final checked, :final total):
            progress = (checked: checked, total: total);
            // Coarse steps keep the UI from rebuilding a thousand times.
            if (checked == total || checked % 16 == 0) emitScanning();
          case ScanTriedEvent(
            :final widened,
            :final hostsTried,
            :final aliveHosts,
            :final lateHosts,
          ):
            tried = (
              widened: widened,
              hostsTried: hostsTried,
              aliveHosts: aliveHosts,
              lateHosts: lateHosts,
            );
        }
      },
      onDone: () {
        if (_state is! SetupScanning) return;
        final merged = mergeCandidates(buffer);
        if (merged.isEmpty) {
          _emit(
            SetupScanEmpty(
              hubs: List.unmodifiable(hubs),
              platform: _platform,
              tried: tried,
              deviceIp: ip,
              network: network,
            ),
          );
          unawaited(_askZigbee2Mqtt());
        } else if (merged.length == 1) {
          // One broker found: continue without asking the user to pick it.
          unawaited(_verify(merged.single, lateHosts: tried?.lateHosts));
        } else {
          emitScanning(done: true);
          unawaited(_nameCandidates(merged, op));
        }
      },
      onError: (_) {
        if (_state is SetupScanning) {
          _emit(
            SetupScanEmpty(
              hubs: List.unmodifiable(hubs),
              platform: _platform,
              deviceIp: ip,
              network: network,
            ),
          );
        }
      },
    );
  }

  /// The scan (or the address check) saw Zigbee2MQTT's web page but no
  /// broker: ask the page where its broker is (2.7.2). A broker that answers
  /// there is verified like a found one, with Zigbee2MQTT's username ready
  /// for the login step; otherwise the empty result says why: the broker
  /// listens only on its own machine (Mosquitto 2's default), or it did not
  /// answer at the address Zigbee2MQTT uses. An SMLIGHT hub serves the page
  /// on the Zigbee2MQTT port too. Home Assistant's add-on page opens only
  /// inside Home Assistant, so it is not asked.
  Future<void> _askZigbee2Mqtt() async {
    final ask = _askZ2m;
    final probe = _probeBroker;
    final s = _state;
    if (ask == null || probe == null || s is! SetupScanEmpty || s.z2m != null) {
      return;
    }
    final pages = [
      for (final h in s.hubs)
        if (h.kind == HubKind.zigbee2mqtt)
          (h.host, h.port)
        else if (h.kind == HubKind.smlight)
          (h.host, hubPorts[HubKind.zigbee2mqtt]!),
    ];
    if (pages.isEmpty) return;
    _emit(s.copyWith(z2m: (status: Z2mAnswerStatus.asking, server: '')));
    // 3.2: the page itself is the way in; its broker only when it is locked.
    if (await _tryPages(pages)) return;
    final op = ++_op;
    var locked = false;
    for (final (host, port) in pages) {
      Z2mBrokerSetting? setting;
      try {
        setting = await ask(host, port);
      } on Z2mPageLocked {
        locked = true;
      } catch (_) {}
      if (op != _op) return;
      if (setting == null) continue;
      for (final target in setting.hosts) {
        ProbeResult? found;
        try {
          found = await probe(target, setting.port);
        } catch (_) {}
        if (op != _op) return;
        if (found == null) continue;
        _z2mUser = setting.user;
        final candidate = SetupCandidate(
          host: found.host,
          port: found.port,
          protocol: setting.tls ? MqttProtocol.tcpSsl : MqttProtocol.tcp,
          needsAuth: found.needsAuth,
        );
        _emit(SetupVerifying(candidate));
        await _verify(candidate);
        return;
      }
      final current = _state;
      if (current is! SetupScanEmpty) return;
      _emit(
        current.copyWith(
          z2m: (
            status: setting.sameMachine
                ? Z2mAnswerStatus.localOnly
                : setting.bareName
                ? Z2mAnswerStatus.nameOnly
                : Z2mAnswerStatus.unreachable,
            server: setting.server,
          ),
        ),
      );
      return;
    }
    final current = _state;
    if (current is SetupScanEmpty) {
      _emit(
        current.copyWith(
          z2m: (
            status: locked
                ? Z2mAnswerStatus.tokenRequired
                : Z2mAnswerStatus.noAnswer,
            server: '',
          ),
        ),
      );
    }
  }

  Future<void> _nameCandidates(List<SetupCandidate> found, int op) async {
    final identify = _identifyHub;
    if (identify == null) return;
    final kinds = <String, HubKind>{};
    await Future.wait([
      for (final host in {for (final c in found) c.host})
        identify(host).then((kind) {
          if (kind != null) kinds[host] = kind;
        }, onError: (_) {}),
    ]);
    final s = _state;
    if (op != _op || s is! SetupScanning || kinds.isEmpty) return;
    _emit(
      SetupScanning(
        s.candidates,
        done: s.done,
        hubs: s.hubs,
        progress: s.progress,
        platform: s.platform,
        kinds: Map.unmodifiable(kinds),
      ),
    );
  }

  /// The user's answer to "where does Zigbee2MQTT run?". While scanning, an
  /// SMLIGHT answer adds that pass to the running scan; on the empty result
  /// the answer retags it (Try again scans with it).
  void setPlatform(SetupPlatform? platform) {
    _platform = platform;
    final s = _state;
    if (s is SetupScanning) {
      if (platform == SetupPlatform.smlight) _run?.addHub(HubKind.smlight);
      _emit(
        SetupScanning(
          s.candidates,
          done: s.done,
          hubs: s.hubs,
          progress: s.progress,
          platform: platform,
          kinds: s.kinds,
        ),
      );
    } else if (s is SetupScanEmpty) {
      // Not copyWith: deselecting a chip sets the answer back to null.
      _emit(
        SetupScanEmpty(
          hubs: s.hubs,
          platform: platform,
          tried: s.tried,
          deviceIp: s.deviceIp,
          network: s.network,
          address: s.address,
          z2m: s.z2m,
        ),
      );
    }
  }

  /// The address check (2.6.2): from the empty result, check the one
  /// machine the user named. A broker there goes straight to verification
  /// (and the login step if it asks); a hub page without a broker becomes
  /// the "found X, but no broker" result; anything else is said on the
  /// field. The typed address never leaves the coordinator.
  Future<void> checkAddress(String input) async {
    final s = _state;
    if (s is! SetupScanEmpty) return;
    final parsed = hostFromAddressInput(input);
    if (parsed == null) {
      _emit(
        s.copyWith(address: (status: AddressCheckStatus.invalid, host: '')),
      );
      return;
    }
    final op = ++_op;
    _emit(
      s.copyWith(
        address: (status: AddressCheckStatus.checking, host: parsed.host),
      ),
    );
    AddressCheckResult result;
    try {
      result =
          await _checkAddress?.call(parsed.host, parsed.port) ??
          const AddressCheckResult.nothing();
    } catch (_) {
      result = const AddressCheckResult.nothing();
    }
    if (op != _op || _state is! SetupScanEmpty) return;
    final current = _state as SetupScanEmpty;
    switch (result.outcome) {
      case AddressOutcome.broker:
        final candidate = SetupCandidate.fromProbe(result.broker!);
        // Leave the empty result through a verifying state even when the
        // broker asks for a login first, so the check is counted as found
        // before the login step is.
        _emit(SetupVerifying(candidate));
        await _verify(candidate);
      case AddressOutcome.hub:
        _emit(
          current.copyWith(
            hubs: [result.hub!],
            address: (status: AddressCheckStatus.hub, host: parsed.host),
            clearZ2m: true,
          ),
        );
        await _askZigbee2Mqtt();
      case AddressOutcome.nothing:
      case AddressOutcome.notResolved:
      case AddressOutcome.notLocal:
      case AddressOutcome.invalid:
        _emit(
          current.copyWith(
            address: (
              status: switch (result.outcome) {
                AddressOutcome.notResolved => AddressCheckStatus.notResolved,
                AddressOutcome.notLocal => AddressCheckStatus.notLocal,
                AddressOutcome.invalid => AddressCheckStatus.invalid,
                _ => AddressCheckStatus.nothing,
              },
              host: parsed.host,
            ),
          ),
        );
    }
  }

  Future<void> selectCandidate(SetupCandidate candidate) async {
    _triedOtherBase = false;
    // A card the scan named answers "where does Zigbee2MQTT run?" when the
    // user has not, so the login step's hint fits (2.7.1).
    final s = _state;
    if (_platform == null && s is SetupScanning) {
      _platform = switch (s.kinds[candidate.host]) {
        HubKind.homeAssistant => SetupPlatform.homeAssistant,
        HubKind.smlight => SetupPlatform.smlight,
        _ => null,
      };
    }
    _cancelScan();
    await _verify(candidate);
  }

  /// A home reached through Home Assistant (2.10): [address] is the Home
  /// Assistant address, [signIn] the stored form of the sign-in
  /// (`ha_token.dart`), both already checked by the connect screen. Goes on
  /// to read the devices and review them as any other candidate.
  Future<void> adoptHomeAssistant({
    required Uri address,
    required String signIn,
  }) async {
    _username = null;
    _password = signIn;
    final candidate = SetupCandidate(
      host: haAddressText(address),
      port: address.hasPort
          ? address.port
          : (address.scheme == 'https' ? 443 : 80),
      protocol: address.scheme == 'https' ? MqttProtocol.wss : MqttProtocol.ws,
      transport: ConnectionTransport.homeAssistant,
    );
    await _verify(candidate);
  }

  /// Setup through Zigbee2MQTT's own web page (3.2 spike): no broker, no
  /// MQTT login; [token] only when the page has one.
  Future<void> adoptZ2mPage({required String host, int port = 8080, String? token}) async {
    _username = null;
    _password = token;
    await _verify(SetupCandidate(host: host, port: port, protocol: MqttProtocol.ws, transport: ConnectionTransport.z2mPage));
  }

  Future<void> submitCredentials(String username, String password) async {
    final s = _state;
    if (s is! SetupNeedsAuth) return;
    _username = username.isEmpty ? null : username;
    _password = password;
    await _verify(s.candidate);
  }

  void toggleDevice(String friendlyName) {
    final s = _state;
    if (s is! SetupReview) return;
    final rows = [
      for (final r in s.rows)
        r.device.friendlyName == friendlyName && r.selectable
            ? r.copyWith(selected: !r.selected)
            : r,
    ];
    _rows = rows;
    _emit(SetupReview(s.candidate, rows));
  }

  Future<void> createDashboard() async {
    final rows = _rows;
    final candidate = _candidate;
    if (rows == null || candidate == null) return;
    final op = ++_op;
    _emit(SetupCreating(SetupReview(candidate, rows)));
    try {
      final result = await _creator.create(
        host: candidate.host,
        port: candidate.port,
        protocol: candidate.protocol,
        username: _username,
        password: _password,
        base: base,
        selected: rows.where((r) => r.selected).toList(),
        notSelected: rows.where((r) => !r.selected).toList(),
        transport: candidate.transport,
      );
      if (op != _op) return;
      _createdOn = candidate.host;
      try {
        await onCreated?.call(result);
      } catch (_) {
        // The connection and dashboard are saved; follow-up bookkeeping
        // failing must not turn a working setup into an error.
      }
      if (op != _op) return;
      _emit(
        SetupComplete(
          result,
          via: switch (candidate.transport) {
            ConnectionTransport.homeAssistant => SetupVia.homeAssistant,
            ConnectionTransport.z2mPage => SetupVia.z2mPage,
            ConnectionTransport.mqtt => SetupVia.scan,
          },
        ),
      );
    } catch (_) {
      if (op != _op) return;
      _emit(
        SetupFailed(
          SetupErrorKind.saveFailed,
          candidate: candidate,
          failedAtCreation: true,
        ),
      );
    }
  }

  /// Resumes at the failed stage: rescan, re-verify, or re-create — never
  /// restarts successful work.
  Future<void> retry() async {
    final s = _state;
    if (s is SetupScanEmpty) {
      await startScan(widen: _widen);
    } else if (s is SetupFailed) {
      if (s.failedAtCreation) {
        await createDashboard();
      } else if (s.kind == SetupErrorKind.scanFailed) {
        await startScan();
      } else if (s.candidate != null) {
        await _verify(s.candidate!);
      }
    }
  }

  /// From "broker found, no Zigbee2MQTT": check [newBase] on the same broker.
  /// Blank input keeps the current base topic.
  Future<void> retryWithBase(String newBase) async {
    final s = _state;
    if (s is! SetupFailed || s.candidate == null) return;
    final trimmed = newBase.trim();
    if (trimmed.isNotEmpty) _base = trimmed;
    await _verify(s.candidate!);
  }

  /// Leaves setup: cancels the scan and every in-flight operation, drops the
  /// session's preserved values, and returns to a safe initial state.
  Future<void> cancel() async {
    _op++;
    _cancelScan();
    _username = null;
    _password = null;
    _rows = null;
    _platform = null;
    answeredFirst = false;
    _emit(const SetupIdle());
  }

  Future<void> dispose() async {
    _op++;
    _cancelScan();
    await _states.close();
  }

  /// Cancels the active scan without awaiting the subscription teardown —
  /// awaiting it can stall behind a still-open stream, and the listener
  /// already drops events once the state leaves [SetupScanning].
  void _cancelScan() {
    _recheck?.cancel();
    _recheck = null;
    unawaited(_scanSub?.cancel());
    _scanSub = null;
    _run = null;
  }

  // --- Internals ---

  /// Scans again once the phone has a home address, while the no-network
  /// screen is up and nothing else started.
  void _watchForNetwork(int op) {
    var busy = false;
    _recheck = Timer.periodic(networkRecheck, (timer) async {
      if (busy) return;
      final s = _state;
      if (op != _op ||
          s is! SetupFailed ||
          s.kind != SetupErrorKind.scanFailed) {
        timer.cancel();
        return;
      }
      busy = true;
      String? ip;
      try {
        ip = await _deviceIp();
      } catch (_) {
        ip = null;
      }
      busy = false;
      if (ip == null || op != _op || !identical(_state, s)) return;
      timer.cancel();
      await startScan();
    });
  }

  SetupCandidate? get _candidate => switch (_state) {
    SetupVerifying(:final candidate) => candidate,
    SetupNeedsAuth(:final candidate) => candidate,
    SetupFailed(:final candidate) => candidate,
    SetupReview(:final candidate) => candidate,
    _ => null,
  };

  Future<void> _verify(SetupCandidate candidate, {int? lateHosts}) async {
    // 3.2: a broker that wants a login, and Zigbee2MQTT's page next to it:
    // the page needs none. 23 of 30 people at the login never tried one.
    if (candidate.needsAuth && _username == null && !candidate.notBroker && _pagePresent != null) {
      if (_state is! SetupVerifying) _emit(SetupVerifying(candidate, lateHosts: lateHosts));
      if (await _tryPages(_pagesFor(candidate))) return;
    }
    if (candidate.needsAuth && _username == null) {
      _emit(
        SetupNeedsAuth(candidate, platform: _platform, suggestedUser: _z2mUser),
      );
      return;
    }
    final op = ++_op;
    _emit(SetupVerifying(candidate, lateHosts: lateHosts));
    final config = BrokerConfig(
      id: 'setup-${DateTime.now().microsecondsSinceEpoch}',
      host: candidate.host,
      port: candidate.port,
      protocol: candidate.protocol,
      username: _username,
      transport: candidate.transport,
    );
    // Through Home Assistant the sign-in was checked before the candidate
    // existed (ha_connect.dart); the broker ladder is MQTT-shaped.
    final DiagnosticsReport? report;
    if (candidate.viaHomeAssistant || candidate.viaZ2mPage) {
      report = null;
    } else {
      try {
        report = await _diagnostics.run(
          config: config,
          password: _password ?? '',
          base: base,
        );
      } catch (_) {
        if (op != _op) return;
        _emit(SetupFailed(SetupErrorKind.unknown, candidate: candidate));
        return;
      }
      if (op != _op) return;
    }

    if (report != null && !report.connected) {
      final kind = mapLadderFailure(report);
      if (kind == SetupErrorKind.authRejected) {
        if (_username == null && await _tryPages(_pagesFor(candidate))) return;
        // No credentials yet → first-time prompt; tried already → rejected.
        _emit(
          SetupNeedsAuth(
            candidate,
            rejected: _username != null,
            platform: _platform,
            suggestedUser: _z2mUser,
          ),
        );
        return;
      }
      _emit(SetupFailed(kind, candidate: candidate));
      return;
    }

    final Z2mFetchResult fetch;
    try {
      fetch = await _fetchDevices(config, _password ?? '', base);
    } catch (_) {
      if (op != _op) return;
      _emit(SetupFailed(SetupErrorKind.notZigbee2Mqtt, candidate: candidate));
      return;
    }
    if (op != _op) return;
    if (!fetch.detected) {
      // Zigbee2MQTT under another base topic: use it and check again, once.
      final other = fetch.otherBases.where((b) => b != _base).firstOrNull;
      if (other != null && !_triedOtherBase) {
        _triedOtherBase = true;
        _base = other;
        await _verify(candidate);
        return;
      }
      // Signed in to Home Assistant, and its MQTT has no Zigbee2MQTT: ZHA,
      // or a stopped add-on; no broker to pick (3.1.13).
      _emit(
        SetupFailed(
          candidate.viaHomeAssistant
              ? SetupErrorKind.haNoZigbee2Mqtt
              : candidate.viaZ2mPage
              ? SetupErrorKind.pageNoAnswer
              : SetupErrorKind.notZigbee2Mqtt,
          candidate: candidate,
        ),
      );
      return;
    }
    var devices = fetch.devices;
    if (fetch.devicesMissing) {
      // The broker lost the list: Zigbee2MQTT's web page still has it.
      final page = _pageDevices;
      final fromPage = page == null || candidate.viaHomeAssistant || candidate.viaZ2mPage
          ? null
          : await page(candidate.host).catchError((_) => null);
      if (op != _op) return;
      if (fromPage == null) {
        _emit(
          SetupFailed(SetupErrorKind.devicesListMissing, candidate: candidate),
        );
        return;
      }
      devices = fromPage;
    }
    if (devices.isEmpty) {
      _emit(SetupFailed(SetupErrorKind.noDevices, candidate: candidate));
      return;
    }
    final rows = recommendDevices(devices, base: base);
    _rows = rows;
    _emit(SetupReview(candidate, rows));
  }
}
