import 'dart:async';

import 'broker_probe.dart';
import 'subnet.dart';

/// Scans the phone's `/24` for MQTT brokers, probing each candidate host on a
/// set of [ports] with bounded [concurrency]. Emits each confirmed broker as
/// it's found, deduped by `host:port`. If the `/24` has no broker, it goes on
/// to the rest of the surrounding `/22` ([widerCandidateHosts]), so a phone and
/// hub in different blocks of a mesh network still find each other; a normal
/// network that has a broker never pays for the wider pass. The stream closes
/// when every candidate has been probed; cancelling the subscription stops
/// further probing.
/// What a finished (or cancelled) scan tried, for Support details.
typedef ScanStats = ({bool widened, int hostsTried, int brokersFound});

class BrokerScanService {
  BrokerScanService({
    required this.prober,
    this.ports = const [1883, 8883],
    this.concurrency = 32,
  });

  final HostProber prober;
  final List<int> ports;
  final int concurrency;

  /// [onDone] runs once, when the scan finishes or is cancelled.
  Stream<ProbeResult> scan(String deviceIp,
      {void Function(ScanStats stats)? onDone}) {
    List<({String host, int port})> tasksFor(List<String> hosts) => [
          for (final h in hosts)
            for (final p in ports) (host: h, port: p),
        ];
    final tasks = tasksFor(candidateHosts(deviceIp));
    final seen = <String>{};
    final controller = StreamController<ProbeResult>();
    var index = 0;
    var active = 0;
    var cancelled = false;
    var closed = false;
    var widened = false;
    late final void Function() pump;
    var reported = false;
    void report() {
      if (reported) return;
      reported = true;
      onDone?.call((
        widened: widened,
        hostsTried: index ~/ ports.length,
        brokersFound: seen.length,
      ));
    }

    void finishIfDone() {
      if (closed || active != 0 || (!cancelled && index < tasks.length)) {
        return;
      }
      if (!cancelled && !widened && seen.isEmpty) {
        final wider = tasksFor(widerCandidateHosts(deviceIp));
        if (wider.isNotEmpty) {
          widened = true;
          tasks.addAll(wider);
          scheduleMicrotask(pump);
          return;
        }
      }
      closed = true;
      report();
      controller.close();
    }

    pump = () {
      while (!cancelled && active < concurrency && index < tasks.length) {
        final task = tasks[index++];
        active++;
        prober.probe(task.host, task.port).then((res) {
          if (res != null && !cancelled && seen.add(res.key)) {
            controller.add(res);
          }
        }).catchError((_) {}).whenComplete(() {
          active--;
          if (!cancelled) pump();
          finishIfDone();
        });
      }
      finishIfDone();
    };

    controller.onListen = pump;
    controller.onCancel = () {
      cancelled = true;
      report();
    };
    return controller.stream;
  }
}
