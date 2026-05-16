import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/mqtt/topic_matcher.dart';

void main() {
  group('topicMatches', () {
    test('exact match', () {
      expect(topicMatches('zigbee2mqtt/living/light', 'zigbee2mqtt/living/light'), isTrue);
    });

    test('rejects different topic', () {
      expect(topicMatches('zigbee2mqtt/living/light', 'zigbee2mqtt/kitchen/light'), isFalse);
    });

    test('rejects longer topic without #', () {
      expect(topicMatches('a/b', 'a/b/c'), isFalse);
    });

    test('rejects shorter topic', () {
      expect(topicMatches('a/b/c', 'a/b'), isFalse);
    });

    test('+ matches one segment', () {
      expect(topicMatches('zigbee2mqtt/+/light', 'zigbee2mqtt/kitchen/light'), isTrue);
      expect(topicMatches('zigbee2mqtt/+/light', 'zigbee2mqtt/living/light'), isTrue);
    });

    test('+ does not match across segments', () {
      expect(topicMatches('a/+', 'a/b/c'), isFalse);
    });

    test('# matches all remaining segments including the parent itself', () {
      // Per MQTT-4.7.1-2, `parent/#` matches `parent`, `parent/x`, `parent/x/y`, etc.
      expect(topicMatches('zigbee2mqtt/#', 'zigbee2mqtt/kitchen/light'), isTrue);
      expect(topicMatches('zigbee2mqtt/#', 'zigbee2mqtt'), isTrue);
    });

    test('# matches zero-or-more after the slash in mid-pattern is not supported', () {
      // We treat # as "terminal multi-level". MQTT spec actually requires it to be terminal,
      // so a pattern like 'a/#/b' is invalid; we don't special-case it.
      expect(topicMatches('a/#', 'a/b'), isTrue);
      expect(topicMatches('a/#', 'a/b/c/d'), isTrue);
    });

    test('combination of + and trailing #', () {
      expect(topicMatches('+/devices/#', 'home/devices/kitchen/state'), isTrue);
      expect(topicMatches('+/devices/#', 'home/lights/kitchen/state'), isFalse);
    });

    test('root single-level pattern', () {
      expect(topicMatches('+', 'foo'), isTrue);
      expect(topicMatches('+', 'foo/bar'), isFalse);
    });

    test('empty segments are honored', () {
      expect(topicMatches('a//b', 'a//b'), isTrue);
      expect(topicMatches('a//b', 'a/x/b'), isFalse);
    });
  });
}
