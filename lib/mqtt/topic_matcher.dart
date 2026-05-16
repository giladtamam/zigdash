/// MQTT wildcard matcher.
///
/// `+` matches exactly one topic segment; `#` matches all remaining segments
/// (and must appear only as the terminal segment of the pattern).
bool topicMatches(String pattern, String topic) {
  final p = pattern.split('/');
  final t = topic.split('/');
  for (var i = 0; i < p.length; i++) {
    if (p[i] == '#') return true;
    if (i >= t.length) return false;
    if (p[i] == '+') continue;
    if (p[i] != t[i]) return false;
  }
  return p.length == t.length;
}
