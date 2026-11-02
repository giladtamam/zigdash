import Flutter
import UIKit
import CryptoKit
import CommonCrypto

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private var appChannel: AppChannel?
  private var proBilling: ProBilling?

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let messenger = engineBridge.pluginRegistry.registrar(forPlugin: "ZigDash")!.messenger()
    appChannel = AppChannel(messenger: messenger)
    proBilling = ProBilling(messenger: messenger)
  }
}

// AES-256-GCM and PBKDF2 for Dart over FFI (lib/core/crypto/aead.dart):
// the App Store build encrypts only with Apple's CryptoKit and CommonCrypto,
// so its export compliance answer is "Apple's encryption only". Dart finds
// these by name: the Runner target exports exactly these three
// (OTHER_LDFLAGS -exported_symbol), which also keeps dead stripping off them.

/// Seals [plainLen] bytes with a 32-byte key and 12-byte nonce, writing
/// ciphertext then the 16-byte tag to [out] (plainLen + 16 bytes). 0 on success.
@_cdecl("zd_gcm_seal")
public func zdGcmSeal(
  _ key: UnsafePointer<UInt8>, _ iv: UnsafePointer<UInt8>,
  _ plain: UnsafePointer<UInt8>, _ plainLen: Int, _ out: UnsafeMutablePointer<UInt8>
) -> Int32 {
  do {
    let box = try AES.GCM.seal(
      Data(bytes: plain, count: plainLen),
      using: SymmetricKey(data: Data(bytes: key, count: 32)),
      nonce: AES.GCM.Nonce(data: Data(bytes: iv, count: 12)))
    (box.ciphertext + box.tag).copyBytes(to: out, count: plainLen + 16)
    return 0
  } catch {
    return -1
  }
}

/// Opens ciphertext + tag ([sealedLen] bytes), writing sealedLen - 16 bytes
/// to [out]. 0 on success, -1 when the key or the bytes are wrong.
@_cdecl("zd_gcm_open")
public func zdGcmOpen(
  _ key: UnsafePointer<UInt8>, _ iv: UnsafePointer<UInt8>,
  _ sealed: UnsafePointer<UInt8>, _ sealedLen: Int, _ out: UnsafeMutablePointer<UInt8>
) -> Int32 {
  guard sealedLen >= 16 else { return -1 }
  do {
    let box = try AES.GCM.SealedBox(
      nonce: AES.GCM.Nonce(data: Data(bytes: iv, count: 12)),
      ciphertext: Data(bytes: sealed, count: sealedLen - 16),
      tag: Data(bytes: sealed + (sealedLen - 16), count: 16))
    let plain = try AES.GCM.open(box, using: SymmetricKey(data: Data(bytes: key, count: 32)))
    plain.copyBytes(to: out, count: sealedLen - 16)
    return 0
  } catch {
    return -1
  }
}

/// PBKDF2-HMAC-SHA256 into [out] ([outLen] bytes). 0 on success.
@_cdecl("zd_pbkdf2_sha256")
public func zdPbkdf2Sha256(
  _ password: UnsafePointer<UInt8>, _ passwordLen: Int,
  _ salt: UnsafePointer<UInt8>, _ saltLen: Int, _ rounds: UInt32,
  _ out: UnsafeMutablePointer<UInt8>, _ outLen: Int
) -> Int32 {
  let status = password.withMemoryRebound(to: Int8.self, capacity: passwordLen) {
    CCKeyDerivationPBKDF(
      CCPBKDFAlgorithm(kCCPBKDF2), $0, passwordLen, salt, saltLen,
      CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256), rounds, out, outLen)
  }
  return status == kCCSuccess ? 0 : -1
}
