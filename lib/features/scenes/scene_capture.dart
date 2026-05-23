import 'dart:convert';

import '../discovery/models/z2m_device.dart';
import 'models/scene.dart';

/// Returns the subset of [currentState] whose keys are *settable* on [device]
/// — i.e. the device exposes that property with the SET access bit. Read-only
/// fields the device reports (e.g. `battery`, `linkquality`, `last_seen`) and
/// keys the device doesn't expose at all are dropped, so the captured payload
/// is safe to publish back to `<device>/set`.
Map<String, dynamic> captureSettableState(
  Z2mDevice device,
  Map<String, dynamic> currentState,
) {
  final settable = <String>{
    for (final e in device.exposes)
      if (e.isSettable) e.property!,
  };
  return {
    for (final entry in currentState.entries)
      if (settable.contains(entry.key)) entry.key: entry.value,
  };
}

/// Builds a [SceneAction] for one device from its settable state snapshot.
/// [base] is the connection/dashboard topic prefix (e.g. `zigbee2mqtt`).
/// Returns null when there's nothing settable to publish.
SceneAction? buildSceneAction({
  required String base,
  required String friendlyName,
  required Map<String, dynamic> settableState,
}) {
  if (settableState.isEmpty) return null;
  return SceneAction(
    setTopic: '$base/$friendlyName/set',
    payload: jsonEncode(settableState),
  );
}

/// Convenience: capture a device's settable state from its raw retained state
/// JSON and turn it into a [SceneAction]. Returns null when the state is
/// malformed or nothing is settable.
SceneAction? captureDeviceAction({
  required String base,
  required Z2mDevice device,
  required String rawStateJson,
}) {
  Map<String, dynamic> state;
  try {
    final decoded = jsonDecode(rawStateJson);
    if (decoded is! Map<String, dynamic>) return null;
    state = decoded;
  } catch (_) {
    return null;
  }
  final settable = captureSettableState(device, state);
  return buildSceneAction(
    base: base,
    friendlyName: device.friendlyName,
    settableState: settable,
  );
}
