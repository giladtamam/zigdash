# App Store Connect: ZigDash answers

What to enter for the iOS app (docs/design/ios.md). The listing text and
review notes are in `fastlane/metadata/ios/`; screenshots come from
`tool/store/capture_ios.sh` (store/captures-ios/).

## App record

| Field | Value |
|---|---|
| Platform | iOS |
| Name | ZigDash for Zigbee2MQTT |
| Primary language | English (U.S.) |
| Bundle ID | com.giladtamam.zigdash |
| SKU | zigdash-ios |
| User access | Full access |
| Category | Utilities (primary), Lifestyle (secondary) |
| Price | Free |
| Age rating | 4+ (every questionnaire answer "None"/"No"; no web browsing, no user-generated content shared with others) |
| Copyright | 2026 Gilad Tamam |
| Support URL | https://zigdash.app/help/ |
| Marketing URL | https://zigdash.app/ |
| Privacy policy URL | https://github.com/giladtamam/zigdash/blob/main/store/PRIVACY.md |

## In-app purchase

| Field | Value |
|---|---|
| Type | Non-consumable |
| Reference name | ZigDash Pro |
| Product ID | zigdash_pro (the same as Play; ProBilling.swift and the relay expect it) |
| Price | the tier nearest 7.99 EUR |
| Display name / description | ZigDash Pro / Unlimited automations, remote control, longer history and the wall tablet's extras. One payment. |
| Family Sharing | Off (Play has none either) |
| Review screenshot | the Pro screen (Settings › ZigDash Pro) on an iPhone |

Apple reviews the first in-app purchase together with an app version: attach
it to the first submission, built with `ZIGDASH_PRO_LIVE=1`.

## App Privacy ("nutrition labels")

Data collected, all **not linked to the user** and **not used for tracking**:

| Data type | What it is | Purpose |
|---|---|---|
| Usage Data › Product Interaction | Aptabase events: setup steps, features used (PRIVACY.md, Anonymous usage data). On by default, off in Settings | Analytics, App Functionality |
| Diagnostics › Other Diagnostic Data | The setup error kind and scan counts inside those events | Analytics |
| Purchases › Purchase History | Only when remote control is turned on: the relay checks the App Store transaction of Pro and keeps a hash of its original transaction id | App Functionality |

Not collected: contact info, location, identifiers, user content (device
names, addresses and MQTT traffic never leave the phone and the user's own
broker; the relay carries only sealed messages). Support emails are written
by the user in their own mail app, outside ZigDash.

## Export compliance (encryption) — the developer's answer

Facts for the questionnaire:

- HTTPS/TLS through the OS and Dart's TLS (MQTT over TLS, Home Assistant,
  the relay API).
- AES-256-GCM, a standard algorithm, implemented in the app with
  pointycastle, for the remote relay: messages between the user's hub and
  phones are sealed end to end (lib/remote, hub/src/engine.js).
- The app's full source, including that encryption, is public (MIT, GitHub).

So the app does use encryption beyond the OS's, with standard algorithms
only, and its source is publicly available. Answering is the developer's
call; once decided, `ITSAppUsesNonExemptEncryption` in ios/Runner/Info.plist
can record the answer so each build doesn't ask again.

## Review notes

`fastlane/metadata/ios/review_information/notes.txt`: the demo home needs no
hardware; where Pro and Restore purchase are; why Local Network is asked.
Contact: the developer's name, phone and email go in App Store Connect.
