# ZigDash for iOS

Decided 2026-10-24, the day the Apple Developer Program was bought (activation
takes up to two business days). The user chose **full parity**, **Pro the same
as on Play** (free app, one-time in-app purchase) and **iOS 16 as the
minimum**. Words follow [CONTEXT.md](../../CONTEXT.md).

## Where it starts

ZigDash 3.1.2 builds for the iOS simulator from main with no Dart changes and
opens on the welcome screen. Everything written in Dart works: setup, the scan,
MQTT, dashboards, the Home Assistant connect and import, history, the wall
display, backups, the remote relay, usage data and the review prompt. What
does not is the native Android layer: three method channels
(`zigdash/app`, `zigdash/billing`, `zigdash/shortcuts`) and the UnifiedPush
distributor. On iOS each call throws `MissingPluginException`, and almost
every caller already falls back to null.

## Decisions

1. **One App Store flavor.** `ZIGDASH_FLAVOR=appstore`, built from an Xcode
   scheme named `appstore`. The pubspec's `default-flavor: foss` applies to
   iOS too, so the iOS project also gets `foss` and `play` schemes (identical
   to `appstore` apart from the define) to keep `flutter run` working without
   flags; Android is unchanged. The scheme name selects the Xcode
   configuration; the dart-define decides behaviour, as on Android.
2. **Pro is not free on iOS by accident.** Today `proStatusProvider` unlocks
   everything when the flavor is not `play`. `appstore` is treated like `play`:
   `unavailable` until StoreKit answers, `locked`/`unlocked` after. The Swift
   side answers the same `zigdash/billing` methods (`status`, `buy`, `price`,
   `token`) with StoreKit 2, product id `pro`, a non-consumable at the price
   tier nearest 7.99 EUR. Restore is free in StoreKit 2
   (`Transaction.currentEntitlements`); Settings gets a Restore purchase row
   on iOS, which Apple review requires.
3. **The relay accepts Apple purchases.** Remote control checks Pro with the
   Play purchase token. On iOS `token` returns the signed transaction (JWS);
   the relay verifies it against Apple's certificate chain and the bundle id.
   The token carries a `store` field so the relay knows which check to run.
4. **iOS 16 minimum, newer features gated.** Interactive widgets need iOS 17
   and Control Center controls need iOS 18; on older versions they are simply
   absent, the way Add tile is absent on Android before 13.
5. **Parity, feature by feature:**

   | Android | iOS | Min iOS |
   |---|---|---|
   | Home-screen widgets (device, scene, group) | WidgetKit widgets with App Intents buttons | 17 (16: read-only) |
   | Quick Settings tiles (4 slots) | Control Center controls (`ControlWidget`) | 18 |
   | Device Controls (power menu) | No equivalent; Control Center controls and Siri/Shortcuts App Intents cover it | — |
   | Shutter pop-up | App Intent opening the device page | 16 |
   | Alerts through UnifiedPush/FCM | APNs through Firebase Cloud Messaging; the hub flow sends to FCM, which it already can | 16 |
   | Setup reminder notification | Same plugin with Darwin settings and a permission ask | 16 |
   | Kiosk screen pinning | Guided Access can't be started by an app; the switch is hidden and the kiosk sheet tells the user how to turn Guided Access on | — |
   | Material You | Hidden; the fixed theme | — |
   | Rate ZigDash → Play | App Store listing (`appStoreId`) | 16 |

   The widgets and controls talk to the broker from the extension itself:
   MQTT over a short-lived socket in Swift, with the home's connection details
   shared through an App Group and the Keychain access group. A headless
   Flutter engine is not allowed in an extension, so the Android design
   (ShortcutEngine) does not carry over; the Swift side needs a small MQTT
   client (CocoaMQTT) and the topic logic for toggle, level, cover position
   and scene.
6. **Local network.** The scan needs `NSLocalNetworkUsageDescription`; iOS asks
   once, on the first probe, and has no API to read the answer. If it was
   denied the scan finds nothing, so on iOS an empty scan's help leads with
   "Allow Local Network for ZigDash in Settings". `.local` names resolve on
   iOS, unlike Android.
7. **Usage data** sends `platform: ios` through Aptabase's own OS field; no
   new events. The privacy policy names Apple next to Google for Pro and
   push, and App Store Connect's privacy labels mirror it.

## Releases

| Release | Contents | Needs the developer account |
|---|---|---|
| iOS 1 (TestFlight, then App Store) | Flavor and schemes, Info.plist, iOS 16, the small `zigdash/app` methods in Swift (time zone, brightness, alarm sound, settings), hiding what has no iOS side, App Store rating link, setup reminder, local-network help, StoreKit Pro and relay check | Signing, App Store Connect record, in-app product |
| iOS 2 | Alerts over APNs/FCM | APNs key, Firebase iOS app |
| iOS 3 | Widgets and Control Center controls, App Intents | App Group id |

Full parity is the goal; it ships in three steps so the App Store listing
exists early and the review notes stay small.

## Known traps

- The Keychain survives an uninstall, the database and preferences don't: a
  reinstalled app finds broker passwords with no homes. Clear stale Keychain
  items on first launch (a flag in preferences).
- Apple review needs a working demo without hardware: the review notes point
  to Try the demo home.
- Review rejects an app that mentions other platforms' stores; the iOS build
  must never show Google Play text (Rate, Pro, support details).
- `device_info_plus` calls are Android-only in support details and alerts;
  iOS reads `iosInfo` (model, system version).

## Status (2026-10-24)

iOS 1 is ready for signing. Done on `ios/prep`: everything in the iOS 1 row
above, the share sheet for Ask your AI, a privacy manifest
(ios/Runner/PrivacyInfo.xcprivacy), Apple in store/PRIVACY.md, the App Store
listing and review notes in 13 languages (fastlane/metadata/ios), the App
Store Connect answers (store/appstore.md) and screenshots for iPhone 6.9" and
iPad 13" (store/captures-ios, from tool/store/capture_ios.sh).
integration_test/ios_smoke_test.dart passes on a simulator with
`--flavor appstore`.

Left for the developer account: Xcode signing (team), the App Store Connect
record (its id becomes ZIGDASH_APPSTORE_ID), the zigdash_pro in-app purchase,
the export-compliance answer, a TestFlight build with the relay allowing
Sandbox, then the first submission with ZIGDASH_PRO_LIVE=1.
