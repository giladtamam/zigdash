import 'broker_probe.dart';
import 'broker_prober_stub.dart'
    if (dart.library.io) 'broker_prober_io.dart' as impl;

/// Builds the platform's [HostProber] (real socket+MQTT prober on
/// mobile/desktop; a no-op on web).
HostProber createHostProber() => impl.createHostProber();
