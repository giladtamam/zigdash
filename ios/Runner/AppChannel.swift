import AudioToolbox
import Flutter
import UIKit

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
