import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../discovery/broker_probe.dart';
import '../discovery/broker_scan_providers.dart';
import '../discovery/subnet.dart';
import 'broker_help_sheet.dart';

/// Bottom sheet that scans the phone's Wi-Fi subnet for MQTT brokers and
/// returns the tapped [ProbeResult] via `Navigator.pop`.
class BrokerScanSheet extends ConsumerStatefulWidget {
  const BrokerScanSheet({super.key});

  static Future<ProbeResult?> show(BuildContext context) =>
      showModalBottomSheet<ProbeResult>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => const BrokerScanSheet(),
      );

  @override
  ConsumerState<BrokerScanSheet> createState() => _BrokerScanSheetState();
}

class _BrokerScanSheetState extends ConsumerState<BrokerScanSheet> {
  StreamSubscription<ProbeResult>? _sub;
  final List<ProbeResult> _found = [];
  bool _scanning = true;
  bool _noIp = false;
  String? _subnet;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await _sub?.cancel();
    setState(() {
      _found.clear();
      _scanning = true;
      _noIp = false;
    });
    final ip = await ref.read(deviceIpProvider.future);
    if (!mounted) return;
    if (ip == null) {
      setState(() {
        _scanning = false;
        _noIp = true;
      });
      return;
    }
    setState(() => _subnet = subnetBaseFromIp(ip));
    final service = ref.read(brokerScanServiceProvider);
    _sub = service.scan(ip).listen(
      (r) {
        if (!mounted) return;
        setState(() {
          _found.add(r);
          _found.sort((a, b) => _lastOctet(a.host).compareTo(_lastOctet(b.host)));
        });
      },
      onDone: () {
        if (mounted) setState(() => _scanning = false);
      },
    );
  }

  int _lastOctet(String host) => int.tryParse(host.split('.').last) ?? 0;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.connFindBrokers,
                      style: theme.textTheme.titleLarge),
                ),
                if (_scanning)
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.connRescan,
                    onPressed: _start,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _scanning && _subnet != null
                  ? l10n.connFindBrokersScanning('$_subnet.x')
                  : (_found.isEmpty
                      ? (_noIp
                          ? l10n.connFindBrokersNoIp
                          : l10n.connFindBrokersNone)
                      : l10n.connFindBrokersFound(_found.length)),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final r in _found)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.dns_outlined),
                      title: Text('${r.host}:${r.port}'),
                      subtitle: r.needsAuth
                          ? Text(l10n.connBrokerNeedsLogin)
                          : null,
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () => Navigator.pop(context, r),
                    ),
                  if (!_scanning && _found.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.connHelpSameNetwork,
                              style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.help_outline),
                            label: Text(l10n.connHowToFind),
                            onPressed: () => BrokerHelpSheet.show(context),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
