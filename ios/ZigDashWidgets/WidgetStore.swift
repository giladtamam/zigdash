import Foundation
import Security

/// What the app shared for the widgets (lib/shortcuts/ios_widgets.dart,
/// AppChannel.swift `shareWidgets`): one JSON document in the App Group's
/// defaults, the direct Homes' passwords in the shared Keychain group, and
/// the states the widgets learn after a tap.
enum WidgetStore {
  static let group = "group.com.giladtamam.zigdash"
  static let dataKey = "widgets.data"
  static let statesKey = "widgets.states"

  static var defaults: UserDefaults { UserDefaults(suiteName: group) ?? .standard }

  struct Home: Decodable {
    let name: String
    let direct: Bool
    let host: String?
    let port: Int?
    let tls: Bool?
    let remoteHost: String?
    let username: String?
  }

  struct Device: Decodable {
    let connectionId: String
    let home: String
    let ieee: String
    let name: String
    let `class`: String
    let kind: String
    let pub: String
    let sub: String
    let property: String?
    let on: JSONValue?
    let off: JSONValue?
    let toggle: JSONValue?
    let onValue: JSONValue?
    let open: JSONValue?
    let close: JSONValue?
    let stop: JSONValue?
    let positionProperty: String?

    var id: String { "\(connectionId)/\(ieee)" }
    var isCover: Bool { kind == "cover" }
    var controllable: Bool { kind != "sensor" }
  }

  struct Shared: Decodable {
    let homes: [String: Home]
    let devices: [Device]
    let states: [String: State]?
    let strings: [String: String]
  }

  /// The last state the app or a widget saw: its line, on/off, when.
  struct State: Codable {
    var line: String?
    var on: Bool?
    var at: Double?
    var payload: String?
  }

  static func shared() -> Shared? {
    guard let raw = defaults.string(forKey: dataKey)?.data(using: .utf8) else { return nil }
    return try? JSONDecoder().decode(Shared.self, from: raw)
  }

  static func string(_ key: String, _ fallback: String) -> String {
    shared()?.strings[key] ?? fallback
  }

  /// A device's latest state: the widget's own (after a tap) when newer
  /// than the app's.
  static func state(of id: String) -> State? {
    let mine = (try? JSONDecoder().decode([String: State].self,
      from: defaults.data(forKey: statesKey) ?? Data()))?[id]
    let apps = shared()?.states?[id]
    switch (mine, apps) {
    case let (m?, a?): return (m.at ?? 0) >= (a.at ?? 0) ? m : a
    default: return mine ?? apps
    }
  }

  static func setState(_ state: State, of id: String) {
    var all = (try? JSONDecoder().decode([String: State].self,
      from: defaults.data(forKey: statesKey) ?? Data())) ?? [:]
    all[id] = state
    defaults.set(try? JSONEncoder().encode(all), forKey: statesKey)
  }

  // MARK: - Keychain

  static func password(for connectionId: String) -> String? {
    var query = keychainQuery(connectionId)
    query[kSecReturnData as String] = true
    var out: AnyObject?
    guard SecItemCopyMatching(query as CFDictionary, &out) == errSecSuccess,
          let data = out as? Data else { return nil }
    return String(data: data, encoding: .utf8)
  }

  static func setPasswords(_ passwords: [String: String]) {
    let all: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: "zigdash.widgets",
      kSecAttrAccessGroup as String: group,
    ]
    SecItemDelete(all as CFDictionary)
    for (id, pw) in passwords {
      var item = keychainQuery(id)
      item[kSecValueData as String] = Data(pw.utf8)
      item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
      SecItemAdd(item as CFDictionary, nil)
    }
  }

  private static func keychainQuery(_ id: String) -> [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: "zigdash.widgets",
      kSecAttrAccount as String: id,
      kSecAttrAccessGroup as String: group,
    ]
  }
}

/// Any JSON value, kept as it came, to send back unchanged.
enum JSONValue: Codable, Equatable {
  case string(String), number(Double), bool(Bool), object([String: JSONValue]), array([JSONValue]), null

  init(from decoder: Decoder) throws {
    let c = try decoder.singleValueContainer()
    if c.decodeNil() { self = .null }
    else if let b = try? c.decode(Bool.self) { self = .bool(b) }
    else if let n = try? c.decode(Double.self) { self = .number(n) }
    else if let s = try? c.decode(String.self) { self = .string(s) }
    else if let a = try? c.decode([JSONValue].self) { self = .array(a) }
    else { self = .object(try c.decode([String: JSONValue].self)) }
  }

  func encode(to encoder: Encoder) throws {
    var c = encoder.singleValueContainer()
    switch self {
    case .string(let s): try c.encode(s)
    case .number(let n): if n == n.rounded() && abs(n) < 1e15 { try c.encode(Int64(n)) } else { try c.encode(n) }
    case .bool(let b): try c.encode(b)
    case .object(let o): try c.encode(o)
    case .array(let a): try c.encode(a)
    case .null: try c.encodeNil()
    }
  }

  var data: Data { (try? JSONEncoder().encode(self)) ?? Data("{}".utf8) }

  subscript(key: String) -> JSONValue? {
    if case .object(let o) = self { return o[key] }
    return nil
  }

  /// Loose equality for state values: "ON" matches "on", 1 matches true.
  func same(as other: JSONValue) -> Bool {
    switch (self, other) {
    case let (.string(a), .string(b)): return a.caseInsensitiveCompare(b) == .orderedSame
    case let (.bool(a), .number(b)), let (.number(b), .bool(a)): return a == (b != 0)
    default: return self == other
    }
  }
}
