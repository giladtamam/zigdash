import Foundation
import Network

/// Just enough MQTT 3.1.1 for a widget tap (docs/design/ios.md, iOS 3):
/// connect, subscribe, publish at QoS 0 and read what arrives, over one
/// short-lived socket. A widget's process lives for seconds, so there is no
/// keep-alive, no retry and no QoS 1.
final class MiniMqtt {
  enum Failure: Error { case unreachable, refused(UInt8), closed }

  private let connection: NWConnection
  private let queue = DispatchQueue(label: "zigdash.minimqtt")
  private var buffer = Data()
  private var waiters: [(String, Data) -> Bool] = []
  private var connack: CheckedContinuation<Void, Error>?
  private var nextId: UInt16 = 1

  init(host: String, port: Int, tls: Bool) {
    let params: NWParameters = tls ? .tls : .tcp
    connection = NWConnection(
      host: NWEndpoint.Host(host),
      port: NWEndpoint.Port(rawValue: UInt16(clamping: port)) ?? 1883,
      using: params)
  }

  /// Opens the socket and logs in; throws when the broker can't be reached
  /// within [timeout] or refuses the login.
  func connect(clientId: String, username: String?, password: String?, timeout: TimeInterval = 6) async throws {
    try await withCheckedThrowingContinuation { (c: CheckedContinuation<Void, Error>) in
      queue.async { [self] in
        connack = c
        connection.stateUpdateHandler = { [weak self] state in
          guard let self else { return }
          switch state {
          case .ready:
            self.send(Self.connectPacket(clientId: clientId, username: username, password: password))
            self.receive()
          case .failed, .cancelled:
            self.finishConnect(.failure(Failure.unreachable))
          case .waiting:
            // No route (e.g. away from home): don't wait for one.
            self.finishConnect(.failure(Failure.unreachable))
          default:
            break
          }
        }
        connection.start(queue: queue)
        queue.asyncAfter(deadline: .now() + timeout) { [weak self] in
          self?.finishConnect(.failure(Failure.unreachable))
        }
      }
    }
  }

  func subscribe(_ topic: String) {
    queue.async { [self] in
      var body = Data()
      body.append(contentsOf: [UInt8(nextId >> 8), UInt8(nextId & 0xff)])
      nextId &+= 1
      body.append(Self.string(topic))
      body.append(0) // QoS 0
      send(Self.packet(0x82, body))
    }
  }

  func publish(_ topic: String, _ payload: Data) {
    queue.async { [self] in
      var body = Self.string(topic)
      body.append(payload)
      send(Self.packet(0x30, body))
    }
  }

  /// The first message on [topic] for which [match] is true, or nil after
  /// [timeout].
  func next(on topic: String, within timeout: TimeInterval, where match: @escaping (Data) -> Bool = { _ in true }) async -> Data? {
    await withCheckedContinuation { (c: CheckedContinuation<Data?, Never>) in
      queue.async { [self] in
        var done = false
        waiters.append { t, p in
          guard !done, t == topic, match(p) else { return false }
          done = true
          c.resume(returning: p)
          return true
        }
        queue.asyncAfter(deadline: .now() + timeout) {
          guard !done else { return }
          done = true
          c.resume(returning: nil)
        }
      }
    }
  }

  func close() {
    queue.async { [self] in
      send(Data([0xe0, 0x00])) // DISCONNECT
      connection.cancel()
    }
  }

  // MARK: - Wire

  private func finishConnect(_ result: Result<Void, Error>) {
    guard let c = connack else { return }
    connack = nil
    c.resume(with: result)
  }

  private func send(_ data: Data) {
    connection.send(content: data, completion: .contentProcessed { _ in })
  }

  private func receive() {
    connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, complete, error in
      guard let self else { return }
      if let data { self.buffer.append(data); self.parse() }
      if complete || error != nil {
        self.finishConnect(.failure(Failure.closed))
        return
      }
      self.receive()
    }
  }

  private func parse() {
    while let (type, body, used) = Self.frame(buffer) {
      buffer.removeFirst(used)
      switch type >> 4 {
      case 2: // CONNACK
        let code = body.count > 1 ? body[body.startIndex + 1] : 0xff
        finishConnect(code == 0 ? .success(()) : .failure(Failure.refused(code)))
      case 3: // PUBLISH (QoS 0 from our subscription)
        guard body.count >= 2 else { continue }
        let len = Int(body[body.startIndex]) << 8 | Int(body[body.startIndex + 1])
        guard body.count >= 2 + len else { continue }
        let topic = String(decoding: body.dropFirst(2).prefix(len), as: UTF8.self)
        var payload = body.dropFirst(2 + len)
        if (type >> 1) & 0x3 > 0 { payload = payload.dropFirst(2) } // packet id
        waiters.removeAll { $0(topic, Data(payload)) }
      default:
        break // SUBACK, PINGRESP
      }
    }
  }

  /// One whole packet at the start of [data]: its type byte, body and size.
  private static func frame(_ data: Data) -> (UInt8, Data, Int)? {
    guard data.count >= 2 else { return nil }
    let bytes = [UInt8](data)
    var length = 0, multiplier = 1, i = 1
    while true {
      guard i < bytes.count else { return nil }
      let b = bytes[i]
      length += Int(b & 0x7f) * multiplier
      i += 1
      if b & 0x80 == 0 { break }
      multiplier *= 128
      if multiplier > 128 * 128 * 128 { return nil }
    }
    guard bytes.count >= i + length else { return nil }
    return (bytes[0], Data(bytes[i..<(i + length)]), i + length)
  }

  private static func string(_ s: String) -> Data {
    let utf8 = Data(s.utf8)
    var d = Data([UInt8(utf8.count >> 8), UInt8(utf8.count & 0xff)])
    d.append(utf8)
    return d
  }

  private static func packet(_ type: UInt8, _ body: Data) -> Data {
    var d = Data([type])
    var n = body.count
    repeat {
      var b = UInt8(n % 128)
      n /= 128
      if n > 0 { b |= 0x80 }
      d.append(b)
    } while n > 0
    d.append(body)
    return d
  }

  static func connectPacket(clientId: String, username: String?, password: String?) -> Data {
    var flags: UInt8 = 0x02 // clean session
    if username != nil { flags |= 0x80 }
    if password != nil { flags |= 0x40 }
    var body = string("MQTT")
    body.append(contentsOf: [0x04, flags, 0x00, 0x1e]) // 3.1.1, keep-alive 30 s
    body.append(string(clientId))
    if let username { body.append(string(username)) }
    if let password { body.append(string(password)) }
    return packet(0x10, body)
  }
}
