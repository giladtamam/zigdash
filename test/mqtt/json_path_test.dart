import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/mqtt/json_path.dart';

void main() {
  group('extractByPath', () {
    test('null path returns raw payload', () {
      expect(extractByPath('hello', null), 'hello');
      expect(extractByPath('{"a":1}', null), '{"a":1}');
    });

    test('empty path returns raw payload', () {
      expect(extractByPath('hello', ''), 'hello');
    });

    test('non-JSON payload with non-null path returns raw payload', () {
      // Per the contract — we want `state` path on payload `ON` to give `ON`.
      expect(extractByPath('ON', 'state'), 'ON');
    });

    test('top-level key', () {
      expect(extractByPath('{"state":"ON"}', 'state'), 'ON');
    });

    test('nested dot path', () {
      expect(extractByPath('{"a":{"b":{"c":42}}}', 'a.b.c'), 42);
    });

    test('numeric brightness value', () {
      expect(
        extractByPath('{"state":"ON","brightness":127}', 'brightness'),
        127,
      );
    });

    test('missing key returns null', () {
      expect(extractByPath('{"state":"ON"}', 'brightness'), isNull);
    });

    test('list indexing', () {
      expect(extractByPath('[10,20,30]', '1'), 20);
    });

    test('list out of bounds returns null', () {
      expect(extractByPath('[10,20]', '5'), isNull);
    });

    test('type mismatch (path through scalar) returns null', () {
      expect(extractByPath('{"a":1}', 'a.b'), isNull);
    });

    test('z2m mixed payload — color sub-object', () {
      const payload =
          '{"state":"ON","brightness":127,"color":{"x":0.45,"y":0.41}}';
      expect(extractByPath(payload, 'color.x'), 0.45);
    });
  });
}
