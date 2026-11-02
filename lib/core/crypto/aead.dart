import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:pointycastle/export.dart';

/// AES-256-GCM (16-byte tag, no associated data) and PBKDF2-HMAC-SHA256,
/// the two pieces of cryptography ZigDash does itself: relay seals, hub
/// backups, remote-key backup files.
///
/// The App Store build calls Apple's CryptoKit and CommonCrypto over FFI
/// (ios/Runner/AppDelegate.swift), so it encrypts only with the operating
/// system's encryption and its export compliance answer stays "exempt"
/// (docs/design/ios.md). The choice is a compile-time constant, so
/// pointycastle is not compiled into that build at all. Same bytes either
/// way.
const _apple = String.fromEnvironment('ZIGDASH_FLAVOR') == 'appstore';

/// [plain] sealed with [key] (32 bytes) and [iv] (12 bytes): ciphertext
/// followed by the tag.
Uint8List gcmSeal(Uint8List key, Uint8List iv, Uint8List plain) {
  if (_apple) return _Apple.seal(key, iv, plain);
  final cipher = GCMBlockCipher(AESEngine())
    ..init(true, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
  return cipher.process(plain);
}

/// The plaintext inside [sealed] (ciphertext then tag), or null when [key]
/// or [iv] is wrong or the bytes were changed.
Uint8List? gcmOpen(Uint8List key, Uint8List iv, Uint8List sealed) {
  if (sealed.length < 16) return null;
  if (_apple) return _Apple.open(key, iv, sealed);
  try {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(false, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
    return cipher.process(sealed);
  } catch (_) {
    return null;
  }
}

/// A [length]-byte key from [password] with PBKDF2-HMAC-SHA256.
Uint8List pbkdf2Sha256(
  Uint8List password,
  Uint8List salt,
  int iterations,
  int length,
) {
  if (_apple) return _Apple.pbkdf2(password, salt, iterations, length);
  final kdf = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
    ..init(Pbkdf2Parameters(salt, iterations, length));
  return kdf.process(password);
}

typedef _GcmNative =
    Int32 Function(
      Pointer<Uint8>,
      Pointer<Uint8>,
      Pointer<Uint8>,
      IntPtr,
      Pointer<Uint8>,
    );
typedef _Gcm =
    int Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, Pointer<Uint8>);
typedef _Pbkdf2Native =
    Int32 Function(
      Pointer<Uint8>,
      IntPtr,
      Pointer<Uint8>,
      IntPtr,
      Uint32,
      Pointer<Uint8>,
      IntPtr,
    );
typedef _Pbkdf2 =
    int Function(Pointer<Uint8>, int, Pointer<Uint8>, int, int, Pointer<Uint8>, int);

/// The Runner's `zd_*` functions, looked up on first use only.
abstract final class _Apple {
  static final _lib = DynamicLibrary.process();
  static final _seal = _lib.lookupFunction<_GcmNative, _Gcm>('zd_gcm_seal');
  static final _open = _lib.lookupFunction<_GcmNative, _Gcm>('zd_gcm_open');
  static final _pbkdf2 = _lib.lookupFunction<_Pbkdf2Native, _Pbkdf2>(
    'zd_pbkdf2_sha256',
  );

  static Uint8List seal(Uint8List key, Uint8List iv, Uint8List plain) {
    final out = _run(_seal, key, iv, plain, plain.length + 16);
    if (out == null) throw StateError('CryptoKit could not seal');
    return out;
  }

  static Uint8List? open(Uint8List key, Uint8List iv, Uint8List sealed) =>
      _run(_open, key, iv, sealed, sealed.length - 16);

  static Uint8List? _run(
    _Gcm f,
    Uint8List key,
    Uint8List iv,
    Uint8List input,
    int outLength,
  ) => using((arena) {
    final k = _copy(arena, key), n = _copy(arena, iv);
    final i = _copy(arena, input);
    // At least one byte: an empty message still needs a valid pointer.
    final out = arena<Uint8>(outLength < 1 ? 1 : outLength);
    if (f(k, n, i, input.length, out) != 0) return null;
    return Uint8List.fromList(out.asTypedList(outLength));
  });

  static Uint8List pbkdf2(
    Uint8List password,
    Uint8List salt,
    int iterations,
    int length,
  ) => using((arena) {
    final out = arena<Uint8>(length);
    final status = _pbkdf2(
      _copy(arena, password),
      password.length,
      _copy(arena, salt),
      salt.length,
      iterations,
      out,
      length,
    );
    if (status != 0) throw StateError('CommonCrypto PBKDF2 failed');
    return Uint8List.fromList(out.asTypedList(length));
  });

  static Pointer<Uint8> _copy(Arena arena, Uint8List bytes) {
    final p = arena<Uint8>(bytes.isEmpty ? 1 : bytes.length);
    p.asTypedList(bytes.length).setAll(0, bytes);
    return p;
  }
}
