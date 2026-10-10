import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/support/support_facts.dart';

void main() {
  test('z2mVersionOf reads only the version', () {
    expect(
        z2mVersionOf('{"version":"2.6.1","config":{"mqtt":'
            '{"server":"mqtt://192.168.1.20","user":"gilad"}}}'),
        '2.6.1');
    expect(z2mVersionOf('{"config":{}}'), isNull);
    expect(z2mVersionOf('not json'), isNull);
    expect(z2mVersionOf('{"version":${'"${'x' * 40}"'}}'), isNull);
  });

  test('bridgeOnlineOf handles text and JSON state', () {
    expect(bridgeOnlineOf('online'), isTrue);
    expect(bridgeOnlineOf('offline'), isFalse);
    expect(bridgeOnlineOf('{"state":"online"}'), isTrue);
    expect(bridgeOnlineOf('{"state":"offline"}'), isFalse);
    expect(bridgeOnlineOf('{"x":1}'), isNull);
  });
}
