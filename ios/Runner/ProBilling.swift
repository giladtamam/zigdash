import Flutter
import StoreKit

/// The App Store side of `zigdash/billing` (ProBilling.kt on Play), with
/// StoreKit 2: the same methods and answers, so lib/features/pro/pro.dart
/// doesn't know which store it talks to.
///
/// status → "unlocked" | "locked" | "pending" | "unavailable"
/// buy → the status after the purchase sheet
/// restore → the status after syncing with the App Store
/// price → the localized price, or nil
/// token → the signed transaction (JWS) of the owned Pro, for the relay
final class ProBilling {
  static let product = "zigdash_pro"

  private let channel: FlutterMethodChannel
  private var updates: Task<Void, Never>?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "zigdash/billing", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      Task { @MainActor in result(await self.handle(call.method)) }
    }
    // Purchases finished outside the sheet (Ask to Buy, another device).
    updates = Task {
      for await update in Transaction.updates {
        if case .verified(let t) = update { await t.finish() }
      }
    }
  }

  deinit { updates?.cancel() }

  private func handle(_ method: String) async -> Any? {
    switch method {
    case "status": return await status()
    case "buy": return await buy()
    case "restore":
      try? await AppStore.sync()
      return await status()
    case "price": return try? await Product.products(for: [Self.product]).first?.displayPrice
    case "token": return await owned()?.jws
    default: return FlutterMethodNotImplemented
    }
  }

  private func owned() async -> (transaction: Transaction, jws: String)? {
    guard let result = await Transaction.currentEntitlement(for: Self.product),
      case .verified(let t) = result, t.revocationDate == nil
    else { return nil }
    return (t, result.jwsRepresentation)
  }

  private func status() async -> String {
    if await owned() != nil { return "unlocked" }
    guard AppStore.canMakePayments,
      (try? await Product.products(for: [Self.product]).first) != nil
    else { return "unavailable" }
    return "locked"
  }

  private func buy() async -> String {
    guard let product = try? await Product.products(for: [Self.product]).first else {
      return "unavailable"
    }
    do {
      switch try await product.purchase() {
      case .success(.verified(let t)):
        await t.finish()
        return "unlocked"
      case .pending:
        return "pending"
      default:
        return await status()
      }
    } catch {
      return await status()
    }
  }
}
