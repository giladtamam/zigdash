import 'dart:async';

import 'broker_probe.dart';
import 'hub_probe.dart';
import 'subnet.dart';

/// What a finished (or cancelled) scan tried, for Support details.
/// [aliveHosts] is how many probed hosts answered at all (connected or
/// refused), the difference between an empty network and a hub elsewhere.
/// [lateHosts] answered only to the slower second look (2.9.3).
typedef ScanStats = ({
  bool widened,
  int hostsTried,
  int brokersFound,
  int aliveHosts,
  int lateHosts,
});

/// A scan in progress: its [events], and a way to add the answer-gated hub
/// pass while it runs. Cancelling the [events] subscription stops it.
class ScanRun {
  ScanRun({required this.events, required void Function(HubKind) addHub})
    : _addHub = addHub;

  final Stream<ScanEvent> events;
  final void Function(HubKind) _addHub;

  /// Also look for [kind]'s web page on the phone's `/24` (the SMLIGHT pass
  /// on port 80 runs only when the user said they have one). No effect once
  /// the scan has finished; start a new run with it instead.
  void addHub(HubKind kind) => _addHub(kind);
}

/// Scans the phone's `/24` for MQTT brokers, probing each candidate host on a
/// set of [ports] with bounded [concurrency]. Emits each confirmed broker as
/// it's found, deduped by `host:port`. If the `/24` has no broker, it goes on
/// to the rest of the surrounding `/22` ([widerCandidateHosts]), so a phone and
/// hub in different blocks of a mesh network still find each other; a normal
/// network that has a broker never pays for the wider pass.
///
/// [run] also looks for hubs (2.5): when the `/24` has no broker, it probes
/// the `/24` for Home Assistant and the Zigbee2MQTT frontend (and an SMLIGHT
/// hub when asked) before the wider pass, so the empty result can say what
/// was found. Hub hits never count as brokers and never stop the widening.
/// When all of that finds no broker, the `/24` hosts that never answered get
/// a second, slower look on [ports]' first port with [patientProber] (and
/// the hubs with [patientHubProber] on those that answer it) (2.9.3). A
/// phone must first find each machine on the Wi-Fi, and a quick first try
/// can give up before that: two users whose scan found nothing typed their
/// broker's address and connected at once.
///
/// The stream closes when every candidate has been probed; cancelling the
/// subscription stops further probing.
class BrokerScanService {
  BrokerScanService({
    required this.prober,
    HubProber? hubProber,
    this.patientProber,
    this.patientHubProber,
    this.ports = const [1883, 8883],
    this.concurrency = 48,
  }) : hubProber = hubProber ?? const _NoHubs();

  final HostProber prober;
  final HubProber hubProber;

  /// The second look's probers; without [patientProber] there is none.
  final HostProber? patientProber;
  final HubProber? patientHubProber;
  final List<int> ports;
  final int concurrency;

  /// The hub kinds every run looks for; SMLIGHT only on request.
  static const defaultHubs = {HubKind.homeAssistant, HubKind.zigbee2mqtt};

  /// Brokers only, as the manual form's "Find brokers" sheet wants it.
  /// [onDone] runs once, when the scan finishes or is cancelled.
  Stream<ProbeResult> scan(
    String deviceIp, {
    void Function(ScanStats stats)? onDone,
  }) => run(
    deviceIp,
    hubs: const {},
    onDone: onDone,
  ).events.where((e) => e is BrokerFound).map((e) => (e as BrokerFound).broker);

  /// The full scan: brokers, hubs and progress. [hubs] are looked for after
  /// an empty `/24` broker pass; [ScanRun.addHub] adds one while running.
  ScanRun run(
    String deviceIp, {
    Set<HubKind> hubs = defaultHubs,
    void Function(ScanStats stats)? onDone,
    bool widen = true,
  }) {
    final engine = _Engine(this, deviceIp, hubs.toSet(), onDone, widen: widen);
    return ScanRun(events: engine.stream, addHub: engine.addHub);
  }
}

class _NoHubs implements HubProber {
  const _NoHubs();
  @override
  Future<HubKind?> probe(String host, int port) async => null;
}

sealed class _Task {
  const _Task(this.host, this.port);
  final String host;
  final int port;
}

class _BrokerTask extends _Task {
  const _BrokerTask(super.host, super.port);
}

class _HubTask extends _Task {
  const _HubTask(super.host, super.port, this.kind);
  final HubKind kind;
}

/// The second look at a host that never answered: the broker port, slowly,
/// then the hub pages if it answers now.
class _LateTask extends _Task {
  const _LateTask(super.host, super.port);
}

/// One scan: a task queue pumped at the service's concurrency, in phases.
/// Phase A probes the `/24` for brokers. If none answered, phase B probes
/// the `/24` for hubs and phase C the rest of the `/22` for brokers. If
/// still none, phase D takes the second look at the `/24`'s silent hosts.
class _Engine {
  _Engine(this.service, this.deviceIp, this.hubs, this.onDone, {bool widen = true}) {
    final local = candidateHosts(deviceIp);
    _localHosts = local;
    _tasks.addAll(_brokerTasks(local));
    _phaseAEnd = _tasks.length;
    // 3.2: setup scans the phone's own /24 first and widens on request.
    _wider = widen ? _brokerTasks(widerCandidateHosts(deviceIp)) : [];
    // Phase D counts as every local host until it starts, then shrinks to
    // the silent ones, so the bar never moves backwards.
    _total =
        _tasks.length +
        local.length * hubs.length +
        _wider.length +
        (service.patientProber == null ? 0 : local.length);
    _controller = StreamController<ScanEvent>(
      onListen: _pump,
      onCancel: () {
        _cancelled = true;
        _report();
      },
    );
  }

  final BrokerScanService service;
  final String deviceIp;
  final Set<HubKind> hubs;
  final void Function(ScanStats stats)? onDone;

  late final StreamController<ScanEvent> _controller;
  Stream<ScanEvent> get stream => _controller.stream;

  final _tasks = <_Task>[];
  late final List<String> _localHosts;
  late final List<_BrokerTask> _wider;
  late final int _phaseAEnd;
  late int _total;
  final _seen = <String>{};
  final _hubsSeen = <String>{};
  final _alive = <String>{};
  final _late = <String>{};
  var _index = 0;
  var _active = 0;
  var _checked = 0;
  var _brokerTasksDone = 0;
  var _cancelled = false;
  var _closed = false;
  var _phaseAEmpty = false;
  var _lateQueued = false;
  var _widened = false;
  var _reported = false;

  List<_BrokerTask> _brokerTasks(List<String> hosts) => [
    for (final h in hosts)
      for (final p in service.ports) _BrokerTask(h, p),
  ];

  List<_HubTask> _hubTasks(HubKind kind) => [
    for (final h in _localHosts) _HubTask(h, hubPorts[kind]!, kind),
  ];

  void addHub(HubKind kind) {
    if (_closed || _cancelled || !hubs.add(kind)) return;
    if (_index < _phaseAEnd) return; // phase B, when it comes, includes it
    if (!_phaseAEmpty) return; // phase A found a broker: no hub passes at all
    // Mid-pass: run it next, ahead of what is left of the wider pass.
    final extra = _hubTasks(kind);
    _tasks.insertAll(_index, extra);
    _total += extra.length;
    scheduleMicrotask(_pump);
  }

  void _report() {
    if (_reported) return;
    _reported = true;
    onDone?.call((
      widened: _widened,
      hostsTried: _brokerTasksDone ~/ service.ports.length,
      brokersFound: _seen.length,
      aliveHosts: _alive.length,
      lateHosts: _late.length,
    ));
  }

  void _finishIfDone() {
    if (_closed || _active != 0 || (!_cancelled && _index < _tasks.length)) {
      return;
    }
    if (!_cancelled && !_phaseAEmpty && _seen.isEmpty) {
      // Phase A found nothing: hubs on the /24, then the rest of the /22.
      _phaseAEmpty = true;
      for (final kind in hubs) {
        _tasks.addAll(_hubTasks(kind));
      }
      if (_wider.isNotEmpty) {
        _widened = true;
        _tasks.addAll(_wider);
      }
      if (_index < _tasks.length) {
        scheduleMicrotask(_pump);
        return;
      }
    }
    if (!_cancelled &&
        !_lateQueued &&
        _seen.isEmpty &&
        service.patientProber != null) {
      _lateQueued = true;
      final silent = [
        for (final h in _localHosts)
          if (!_alive.contains(h)) _LateTask(h, service.ports.first),
      ];
      _total -= _localHosts.length - silent.length;
      _tasks.addAll(silent);
      if (silent.isNotEmpty) {
        scheduleMicrotask(_pump);
        return;
      }
    }
    _closed = true;
    _report();
    // The second look may have shrunk the total after the last probe.
    if (!_cancelled) _controller.add(ScanProgress(_checked, _total));
    _controller.add(
      ScanTriedEvent(
        widened: _widened,
        hostsTried: _brokerTasksDone ~/ service.ports.length,
        aliveHosts: _alive.length,
        lateHosts: _late.length,
      ),
    );
    _controller.close();
  }

  void _pump() {
    while (!_cancelled &&
        _active < service.concurrency &&
        _index < _tasks.length) {
      final task = _tasks[_index++];
      _active++;
      _probe(task).catchError((_) {}).whenComplete(() {
        _active--;
        _checked++;
        if (task is _BrokerTask) _brokerTasksDone++;
        if (!_cancelled && !_closed) {
          _controller.add(ScanProgress(_checked, _total));
          _pump();
        }
        _finishIfDone();
      });
    }
    _finishIfDone();
  }

  Future<void> _probe(_Task task) async {
    switch (task) {
      case _BrokerTask():
        final (:broker, :alive) = await service.prober.probeHost(
          task.host,
          task.port,
        );
        if (alive == true) _alive.add(task.host);
        if (broker != null && !_cancelled && _seen.add(broker.key)) {
          _controller.add(BrokerFound(broker));
        }
      case _HubTask():
        final kind = await service.hubProber.probe(task.host, task.port);
        _hubSeen(kind, task.host, task.port);
      case _LateTask():
        final (:broker, :alive) = await service.patientProber!.probeHost(
          task.host,
          task.port,
        );
        if (alive != true || _cancelled) return;
        _alive.add(task.host);
        _late.add(task.host);
        if (broker != null && _seen.add(broker.key)) {
          _controller.add(BrokerFound(broker));
          return;
        }
        final hubProber = service.patientHubProber;
        if (hubProber == null) return;
        for (final kind in hubs) {
          final port = hubPorts[kind]!;
          _hubSeen(await hubProber.probe(task.host, port), task.host, port);
        }
    }
  }

  void _hubSeen(HubKind? kind, String host, int port) {
    if (kind == null || _cancelled || _closed) return;
    final hub = HubFound(kind: kind, host: host, port: port);
    if (_hubsSeen.add(hub.key)) _controller.add(HubSeen(hub));
  }
}
