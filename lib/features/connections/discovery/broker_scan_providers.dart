import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'broker_prober.dart';
import 'broker_scan_service.dart';
import 'network_info.dart';

/// The device's Wi-Fi IPv4 address, used to derive the subnet to scan.
final deviceIpProvider = FutureProvider<String?>((ref) => wifiIpv4());

/// The broker scanner, wired to the platform prober.
final brokerScanServiceProvider = Provider<BrokerScanService>(
  (ref) => BrokerScanService(prober: createHostProber()),
);
