import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/crypto/aead.dart';
import 'package:zigdash/remote/remote_home.dart';
import 'package:zigdash/remote/remote_pairing.dart';

/// Known answers from Node's crypto (the hub's engine.js side), so both
/// builds are checked against the hub rather than against each other:
/// pointycastle on the host (aead_test.dart), CryptoKit and CommonCrypto on
/// the iOS simulator (integration_test/aead_ios_test.dart).
final key = Uint8List.fromList(List<int>.generate(32, (i) => i));
final iv = Uint8List.fromList(List<int>.generate(12, (i) => 0xa0 + i));
const plain = '{"topic":"zigbee2mqtt/lamp","payload":{"state":"ON"}}';
const sealedHex =
    '9d3a084235a2619d5847fdba6018a5bb42c12864e6982e0df17e04aa5ddb1478be19269b'
    '8d18281f2ce865bc6c58b9db085564351fa118ab28a4126792f2ed74109ab993c1';
const emptySealedHex = '5c699625af4b93a0f8220a2a6119c5d0';
const pbkdf2Hex =
    '2f71e7b51475eb2fbf298965949daec6ffe6fbf89428434de5c52e97ef33927c';

Uint8List hex(String s) => Uint8List.fromList([
  for (var i = 0; i < s.length; i += 2) int.parse(s.substring(i, i + 2), radix: 16),
]);

String toHex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

void aeadVectorTests() {
  test('seals as the hub does', () {
    final sealed = gcmSeal(key, iv, Uint8List.fromList(utf8.encode(plain)));
    expect(toHex(sealed), sealedHex);
  });

  test('opens what the hub sealed', () {
    expect(utf8.decode(gcmOpen(key, iv, hex(sealedHex))!), plain);
  });

  test('an empty message', () {
    expect(toHex(gcmSeal(key, iv, Uint8List(0))), emptySealedHex);
    expect(gcmOpen(key, iv, hex(emptySealedHex)), isEmpty);
  });

  test('a changed byte or the wrong key opens nothing', () {
    final tampered = hex(sealedHex)..[3] ^= 1;
    expect(gcmOpen(key, iv, tampered), isNull);
    final tag = hex(sealedHex);
    tag[tag.length - 1] ^= 1;
    expect(gcmOpen(key, iv, tag), isNull);
    final other = Uint8List.fromList(key.reversed.toList());
    expect(gcmOpen(other, iv, hex(sealedHex)), isNull);
    expect(gcmOpen(key, iv, Uint8List(15)), isNull);
  });

  test('PBKDF2-SHA256 as Node derives it', () {
    final dk = pbkdf2Sha256(
      Uint8List.fromList(utf8.encode('correct horse')),
      Uint8List.fromList(utf8.encode('zigdash-salt-16b')),
      1000,
      32,
    );
    expect(toHex(dk), pbkdf2Hex);
  });

  test('a remote-key backup round-trips through its passphrase', () {
    final home = RemoteHome.fromJson({
      'homeId': 'h1',
      'url': 'wss://relay.zigdash.app',
      'username': 'u',
      'password': 'p',
      'key': base64.encode(key),
    })!;
    final file = RemotePairing.backup(home, 'pass phrase');
    expect(RemotePairing.restore(file, 'pass phrase')?.toJson(), home.toJson());
    expect(RemotePairing.restore(file, 'wrong'), isNull);
  });
}
