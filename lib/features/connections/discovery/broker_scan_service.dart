import 'dart:async';

import 'broker_probe.dart';
import 'subnet.dart';

/// Scans the phone's `/24` for MQTT brokers, probing each candidate host on a
/// set of [ports] with bounded [concurrency]. Emits each confirmed broker as
/// it's found, deduped by `host:port`. The stream closes when every candidate
/// has been probed; cancelling the subscription stops further probing.
class BrokerScanService {
  BrokerScanService({
    required this.prober,
    this.ports = const [1883, 8883],
    this.concurrency = 32,
  });

  final HostProber prober;
  final List<int> ports;
  final int concurrency;

  Stream<ProbeResult> scan(String deviceIp) {
    final tasks = <({String host, int port})>[
      for (final h in candidateHosts(deviceIp))
        for (final p in ports) (host: h, port: p),
    ];
    final seen = <String>{};
    final controller = StreamController<ProbeResult>();
    var index = 0;
    var active = 0;
    var cancelled = false;
    var closed = false;

    void finishIfDone() {
      if (!closed && active == 0 && (cancelled || index >= tasks.length)) {
        closed = true;
        controller.close();
      }
    }

    void pump() {
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
    }

    controller.onListen = pump;
    controller.onCancel = () {
      cancelled = true;
    };
    return controller.stream;
  }
}
