import 'dart:io';

import '../../../core/net/mdns_lookup.dart';

import 'address_check.dart';
import 'broker_probe.dart';
import 'broker_prober.dart';
import 'hub_probe.dart';
import 'hub_prober.dart';
import 'subnet.dart';

/// The real address check: resolve the name to an IPv4 address, refuse
/// anything that is not a home address, then probe that one host for a
/// broker (1883, 8883) and for the hub pages (8123, 8080, 80, or the port
/// the user typed) at the same time. A broker wins over a hub page.
AddressChecker createAddressChecker({
  HostProber? prober,
  HubProber? hubProber,
  List<int> brokerPorts = const [1883, 8883],
}) {
  final broker = prober ?? createHostProber();
  final hubs = hubProber ?? createHubProber();
  return (host, webPort) async {
    final String ip;
    if (isIpv4Literal(host)) {
      ip = host;
    } else {
      // 3.2: a `.local` name is asked on the network first; Android
      // resolves those on some phones only (65 failed checks in 17 days).
      final viaMdns = host.toLowerCase().endsWith('.local') ? await mdnsLookup(host) : null;
      if (viaMdns != null) {
        ip = viaMdns.address;
      } else {
        try {
          final found = await InternetAddress.lookup(
            host,
            type: InternetAddressType.IPv4,
          ).timeout(const Duration(seconds: 4));
          if (found.isEmpty) {
            return const AddressCheckResult(AddressOutcome.notResolved);
          }
          ip = found.first.address;
        } catch (_) {
          return const AddressCheckResult(AddressOutcome.notResolved);
        }
      }
    }
    if (!isPrivateIpv4(ip)) {
      return const AddressCheckResult(AddressOutcome.notLocal);
    }
    final webPorts = webPort != null && !brokerPorts.contains(webPort)
        ? [webPort]
        : hubPorts.values.toList();
    final brokerProbes = [for (final p in brokerPorts) broker.probe(ip, p)];
    final hubProbes = [
      for (final p in webPorts)
        hubs.probe(ip, p).then((kind) => (kind: kind, port: p)),
    ];
    final brokers = await Future.wait(brokerProbes);
    final found = brokers.whereType<ProbeResult>().firstOrNull;
    if (found != null) {
      return AddressCheckResult(AddressOutcome.broker, broker: found);
    }
    final pages = await Future.wait(hubProbes);
    for (final kind in HubKind.values) {
      for (final page in pages) {
        if (page.kind == kind) {
          return AddressCheckResult(
            AddressOutcome.hub,
            hub: HubFound(kind: kind, host: ip, port: page.port),
          );
        }
      }
    }
    return const AddressCheckResult.nothing();
  };
}
