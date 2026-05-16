import 'dart:convert';

/// Walks a JSON-encoded [payload] by simple dot notation [path].
///
/// `null`/empty path → the raw payload string is returned.
/// Numeric segments index into lists; string segments index into maps.
/// Returns `null` on any missing key or type mismatch.
/// If the payload isn't valid JSON, the raw string is returned (so a path
/// of `null` against an MQTT message of `"ON"` gives back `"ON"`).
Object? extractByPath(String payload, String? path) {
  if (path == null || path.isEmpty) return payload;
  Object? node;
  try {
    node = json.decode(payload);
  } catch (_) {
    return payload;
  }
  for (final seg in path.split('.')) {
    if (node is Map) {
      node = node[seg];
    } else if (node is List) {
      final idx = int.tryParse(seg);
      if (idx == null || idx < 0 || idx >= node.length) return null;
      node = node[idx];
    } else {
      return null;
    }
    if (node == null) return null;
  }
  return node;
}
