import Foundation

/// A widget tap, like ShortcutCommander on Android: connect to the Home's
/// broker, send the device's command and wait for its state to confirm.
/// The commands themselves were worked out by the app.
enum DeviceCommand {
  enum Action { case toggle, open, close, stop }

  /// Runs [action] on [device] and records the outcome as its state line.
  static func run(_ action: Action, on device: WidgetStore.Device) async {
    let id = device.id
    var state = WidgetStore.state(of: id) ?? .init()
    guard let home = WidgetStore.shared()?.homes[device.connectionId], home.direct,
          let host = home.host else { return }

    let command: JSONValue? = {
      switch action {
      case .open: return device.open
      case .close: return device.close
      case .stop: return device.stop
      case .toggle:
        // The target value when the state is known, so only a reply holding
        // it confirms; TOGGLE when it isn't.
        switch state.on {
        case true?: return device.off
        case false?: return device.on
        default: return device.toggle
        }
      }
    }()
    guard let command else { return }

    let pw = WidgetStore.password(for: device.connectionId)
    var reached = false
    for address in [host, home.remoteHost].compactMap({ $0 }) {
      let mqtt = MiniMqtt(host: address, port: home.port ?? 1883, tls: home.tls ?? false)
      do {
        try await mqtt.connect(clientId: "zigdash-widget-\(UUID().uuidString.prefix(8))",
                               username: home.username, password: pw)
      } catch {
        continue
      }
      reached = true
      mqtt.subscribe(device.sub)
      try? await Task.sleep(nanoseconds: 150_000_000)
      mqtt.publish(device.pub, command.data)
      let expect = expected(after: command, device)
      let reply = await mqtt.next(on: device.sub, within: 5) { data in
        guard let expect, let v = try? JSONDecoder().decode(JSONValue.self, from: data) else { return true }
        return v[expect.key].map { $0.same(as: expect.value) } ?? false
      }
      mqtt.close()
      if let reply, let v = try? JSONDecoder().decode(JSONValue.self, from: reply) {
        state = describe(v, device)
        state.payload = String(decoding: reply, as: UTF8.self)
      } else {
        state.line = WidgetStore.string("notConfirmed", "Not confirmed")
      }
      break
    }
    if !reached { state.line = WidgetStore.string("cantReach", "Can't reach home") }
    state.at = Date().timeIntervalSince1970 * 1000
    WidgetStore.setState(state, of: id)
  }

  /// The property and value a confirming reply holds: the switch's new
  /// value; a shutter's state just has to arrive (it reports moving first).
  private static func expected(after command: JSONValue, _ d: WidgetStore.Device) -> (key: String, value: JSONValue)? {
    guard !d.isCover, let p = d.property, let v = command[p] else { return nil }
    // A toggle value isn't a state; any reply will do.
    if let t = d.toggle?[p], t == v, d.on?[p] != v, d.off?[p] != v { return nil }
    return (p, v)
  }

  /// The state line, as the tile words it: On/Off, Open/Closed and the
  /// position.
  static func describe(_ v: JSONValue, _ d: WidgetStore.Device) -> WidgetStore.State {
    var s = WidgetStore.State()
    if d.isCover {
      var parts: [String] = []
      if case .string(let st)? = v["state"] {
        let up = st.uppercased()
        parts.append(up == "OPEN" ? WidgetStore.string("opened", "Open")
          : (up == "CLOSE" || up == "CLOSED") ? WidgetStore.string("closed", "Closed") : st)
      }
      if let p = d.positionProperty, case .number(let n)? = v[p] {
        parts.append("\(Int(n))%")
        s.on = n > 0
      }
      s.line = parts.joined(separator: " · ")
    } else if let p = d.property, let value = v[p], let onValue = d.onValue {
      s.on = value.same(as: onValue)
      s.line = s.on! ? WidgetStore.string("on", "On") : WidgetStore.string("off", "Off")
    }
    return s
  }
}
