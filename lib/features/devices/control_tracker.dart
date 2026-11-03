import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics.dart';
import '../../mqtt/mqtt_manager.dart';
import '../../mqtt/providers/mqtt_manager_provider.dart';
import '../discovery/models/z2m_device.dart';
import '../discovery/providers/discovery_provider.dart';
import 'device_profile.dart';
import 'devices_providers.dart';
import '../../shortcuts/shortcut_nudge.dart';

/// The friendly name a Zigbee2MQTT command topic is for:
/// `<base>/<name>/set` or `<base>/<name>/set/<attribute>`; null for anything
/// else (bridge requests, custom panel topics).
String? commandTarget(String topic, String base) {
  if (!topic.startsWith('$base/')) return null;
  final rest = topic.substring(base.length + 1);
  if (rest.startsWith('bridge/')) return null;
  if (rest.endsWith('/set')) return rest.substring(0, rest.length - 4);
  final i = rest.indexOf('/set/');
  return i > 0 ? rest.substring(0, i) : null;
}

/// Whether ZigDash is used to control things (2.9.2): the first command to a
/// device in a session sends `feature_used` with feature `control` and only
/// the kind of device (light, switch, cover…), never which one. Commands
/// from the app's screens only. Also counts, on the phone, the sessions each
/// device is switched in, for the shortcut offer ([maybeOfferShortcut]).
class ControlTracker extends ConsumerStatefulWidget {
  const ControlTracker({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<ControlTracker> createState() => _ControlTrackerState();
}

class _ControlTrackerState extends ConsumerState<ControlTracker> {
  StreamSubscription<String>? _sub;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  Future<void> _listen() async {
    final MqttManager mgr;
    try {
      mgr = await ref.read(mqttManagerProvider(widget.connectionId).future);
    } catch (_) {
      return; // No broker for this home (yet): nothing to watch.
    }
    if (!mounted) return;
    _sub = mgr.commandsSent.listen(_onCommand);
  }

  void _onCommand(String topic) {
    if (!mounted) return;
    final base = ref.read(homeBaseTopicProvider(widget.connectionId));
    if (base == null) return;
    final name = commandTarget(topic, base);
    if (name == null) return;
    final devices =
        ref
            .read(
              bridgeDevicesStreamProvider((
                connectionId: widget.connectionId,
                base: base,
              )),
            )
            .valueOrNull ??
        const <Z2mDevice>[];
    final device = devices.where((d) => d.friendlyName == name).firstOrNull;
    // 3.3.3: a device switched in a few sessions is offered as a widget or
    // a Quick Settings tile.
    final ieee = device?.ieeeAddress;
    if (ieee != null) {
      maybeOfferShortcut(context, ref,
          connectionId: widget.connectionId, ieee: ieee);
    }
    if (_sent) return;
    final kind = device == null
        ? DeviceClass.generic
        : classifyExposes(device.rawExposes).deviceClass;
    _sent = true;
    ref.read(analyticsProvider).track(FeatureUsed(Feature.control, tile: kind));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the device list warm so the first command finds its kind.
    final base = ref.watch(homeBaseTopicProvider(widget.connectionId));
    if (base != null) {
      ref.watch(
        bridgeDevicesStreamProvider((
          connectionId: widget.connectionId,
          base: base,
        )),
      );
    }
    return const SizedBox.shrink();
  }
}
