import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Choosing a device (Edit Widget)

/// A dashboard device, as Edit Widget lists it.
struct DeviceEntity: AppEntity {
  static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Device")
  static var defaultQuery = DeviceQuery()

  let id: String
  let name: String
  let home: String

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(name)", subtitle: "\(home)")
  }
}

struct DeviceQuery: EntityQuery {
  private func all() -> [DeviceEntity] {
    (WidgetStore.shared()?.devices ?? []).map {
      DeviceEntity(id: $0.id, name: $0.name, home: $0.home)
    }
  }

  func entities(for identifiers: [String]) async throws -> [DeviceEntity] {
    all().filter { identifiers.contains($0.id) }
  }

  func suggestedEntities() async throws -> [DeviceEntity] { all() }

  func defaultResult() async -> DeviceEntity? { all().first }
}

struct DeviceWidgetConfig: WidgetConfigurationIntent {
  static var title: LocalizedStringResource = "Device"
  static var description = IntentDescription("Switch a light or plug, or move a shutter.")

  @Parameter(title: "Device")
  var device: DeviceEntity?
}

// MARK: - Taps

/// A tap on a device widget: switch it, or a shutter's open, stop or close.
struct DeviceTapIntent: AppIntent {
  static var title: LocalizedStringResource = "Control device"
  static var isDiscoverable = false

  @Parameter(title: "Device") var deviceId: String
  @Parameter(title: "Action") var action: String

  init() {}

  init(deviceId: String, action: String) {
    self.deviceId = deviceId
    self.action = action
  }

  func perform() async throws -> some IntentResult {
    guard let device = WidgetStore.shared()?.devices.first(where: { $0.id == deviceId }) else {
      return .result()
    }
    let a: DeviceCommand.Action = switch action {
    case "open": .open
    case "close": .close
    case "stop": .stop
    default: .toggle
    }
    await DeviceCommand.run(a, on: device)
    return .result()
  }
}

// MARK: - Timeline

struct DeviceEntry: TimelineEntry {
  let date: Date
  let device: WidgetStore.Device?
  let direct: Bool
  let state: WidgetStore.State?
}

struct DeviceProvider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> DeviceEntry {
    DeviceEntry(date: .now, device: nil, direct: true, state: nil)
  }

  func snapshot(for configuration: DeviceWidgetConfig, in context: Context) async -> DeviceEntry {
    entry(for: configuration)
  }

  func timeline(for configuration: DeviceWidgetConfig, in context: Context) async -> Timeline<DeviceEntry> {
    // Redrawn after each tap and whenever the app shares new data.
    Timeline(entries: [entry(for: configuration)], policy: .never)
  }

  private func entry(for configuration: DeviceWidgetConfig) -> DeviceEntry {
    let shared = WidgetStore.shared()
    let id = configuration.device?.id
    let device = shared?.devices.first { $0.id == id }
    let direct = device.flatMap { shared?.homes[$0.connectionId]?.direct } ?? false
    return DeviceEntry(date: .now, device: device, direct: direct,
                       state: device.flatMap { WidgetStore.state(of: $0.id) })
  }
}

// MARK: - View

struct DeviceWidgetView: View {
  let entry: DeviceEntry
  @Environment(\.widgetFamily) private var family

  var body: some View {
    if let device = entry.device {
      VStack(alignment: .leading, spacing: 6) {
        HStack(alignment: .top) {
          Image(systemName: symbol(device))
            .font(.title2)
            .foregroundStyle(entry.state?.on == true ? Color.orange : Color.secondary)
          Spacer()
        }
        Spacer(minLength: 0)
        Text(device.name)
          .font(.headline)
          .lineLimit(2)
        Text(entry.state?.line ?? " ")
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(1)
        controls(device)
      }
      .widgetURL(URL(string: "zigdash://open/connections/\(device.connectionId)/devices/\(device.ieee)"))
    } else {
      Text(WidgetStore.string("chooseDevice", "Choose a device"))
        .font(.footnote)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
  }

  @ViewBuilder
  private func controls(_ d: WidgetStore.Device) -> some View {
    if !entry.direct {
      // Home Assistant, WebSocket and relay Homes: no buttons; a tap opens
      // the device in the app (widgetURL).
      EmptyView()
    } else if d.isCover {
      HStack(spacing: 6) {
        tap(d, "open", "chevron.up")
        tap(d, "stop", "stop.fill")
        tap(d, "close", "chevron.down")
      }
    } else if d.controllable {
      tap(d, "toggle", "power")
    }
  }

  private func tap(_ d: WidgetStore.Device, _ action: String, _ icon: String) -> some View {
    Button(intent: DeviceTapIntent(deviceId: d.id, action: action)) {
      Image(systemName: icon)
        .frame(maxWidth: .infinity, minHeight: 28)
    }
    .buttonStyle(.bordered)
    .tint(.orange)
  }

  private func symbol(_ d: WidgetStore.Device) -> String {
    switch d.class {
    case "cover": return "blinds.horizontal.closed"
    case "light", "colorLight": return "lightbulb.fill"
    case "switchPlug": return "powerplug.fill"
    case "contact": return "door.left.hand.closed"
    case "leakSmoke": return "drop.fill"
    case "climate": return "thermometer.medium"
    case "motion": return "figure.walk"
    default: return "square.grid.2x2.fill"
    }
  }
}

struct DeviceWidget: Widget {
  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: "ZigDashDevice", intent: DeviceWidgetConfig.self, provider: DeviceProvider()) { entry in
      DeviceWidgetView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("ZigDash device")
    .description("Switch a light or plug, or move a shutter, from the home screen.")
    .supportedFamilies([.systemSmall])
  }
}

@main
struct ZigDashWidgets: WidgetBundle {
  var body: some Widget {
    DeviceWidget()
  }
}
