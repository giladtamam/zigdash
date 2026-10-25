import AudioToolbox
import Flutter
import UIKit
import WidgetKit

/// The iOS side of `zigdash/app` (MainActivity.kt on Android). Methods with
/// no iOS counterpart (tiles, widgets, screen pinning, VAPID keys) answer
/// notImplemented, which the Dart callers already treat as "not here".
final class AppChannel {
  private let channel: FlutterMethodChannel
  private var alarm: Timer?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "zigdash/app", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result)
    }
  }

  private func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    switch call.method {
    case "timeZoneId":
      result(TimeZone.current.identifier)
    case "isTestDevice":
      result(false)
    case "takeAction":
      result(nil)
    case "setBrightness":
      // -1 returns to the system's; iOS has no per-window brightness, so
      // the screen's is set and restored.
      let value = (args?["value"] as? Double) ?? -1
      Brightness.set(value < 0 ? nil : CGFloat(value))
      result(nil)
    case "alarmSound":
      setAlarm((args?["on"] as? Bool) ?? false)
      result(nil)
    case "shareText":
      result(share((args?["text"] as? String) ?? ""))
    case "shareWidgets":
      // ios_widgets.dart: the widgets' data and the direct Homes' passwords.
      WidgetStore.defaults.set(args?["data"] as? String, forKey: WidgetStore.dataKey)
      WidgetStore.setPasswords((args?["passwords"] as? [String: String]) ?? [:])
      WidgetCenter.shared.reloadAllTimelines()
      result(nil)
    case "findServices":
      // Kept alive by its own callback until the timeout.
      let finder = ServiceFinder()
      finder.find(type: (args?["type"] as? String) ?? "",
                  timeoutMs: (args?["timeoutMs"] as? Int) ?? 3000) { services in
        _ = finder
        result(services)
      }
    case "openWifiSettings":
      // iOS only opens the app's own page in Settings.
      if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// The share sheet for [text] (Ask your AI); false when there's no window
  /// to show it from, and the caller copies instead.
  private func share(_ text: String) -> Bool {
    guard let root = UIApplication.shared.connectedScenes
      .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController }).first
    else { return false }
    var top = root
    while let presented = top.presentedViewController { top = presented }
    let sheet = UIActivityViewController(activityItems: [text], applicationActivities: nil)
    // iPad shows it as a popover, which needs an anchor.
    if let popover = sheet.popoverPresentationController {
      popover.sourceView = top.view
      popover.sourceRect = CGRect(x: top.view.bounds.midX, y: top.view.bounds.maxY - 80, width: 0, height: 0)
      popover.permittedArrowDirections = []
    }
    top.present(sheet, animated: true)
    return true
  }

  /// The alert tone, repeated every two seconds while on (alarm takeover).
  private func setAlarm(_ on: Bool) {
    alarm?.invalidate()
    alarm = nil
    guard on else { return }
    AudioServicesPlayAlertSound(SystemSoundID(1005))
    alarm = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
      AudioServicesPlayAlertSound(SystemSoundID(1005))
    }
  }
}

/// Remembers the user's brightness before the wall display dims, so "the
/// system's" can be restored.
private enum Brightness {
  static var saved: CGFloat?

  static func set(_ value: CGFloat?) {
    guard let screen = UIApplication.shared.connectedScenes
      .compactMap({ ($0 as? UIWindowScene)?.screen }).first
    else { return }
    if let value {
      if saved == nil { saved = screen.brightness }
      screen.brightness = value
    } else if let restore = saved {
      screen.brightness = restore
      saved = nil
    }
  }
}
