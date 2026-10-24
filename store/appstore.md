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

- TLS for MQTT, Home Assistant and the relay API comes from Dart's own TLS
  library (BoringSSL inside the Flutter engine), not iOS's.
- AES-256-GCM, a standard algorithm, implemented in the app with
  pointycastle, seals relay messages end to end between hub and phones
  (lib/remote, hub/src/engine.js).
- No proprietary algorithms. The app's full source is public (MIT, GitHub).

Apple's table ([export compliance documentation](https://developer.apple.com/help/app-store-connect/reference/export-compliance-documentation-for-encryption))
puts that in the middle row, "an industry standard algorithm, not provided
within the Apple operating system": no US document (no CCATS) is needed, but
**a French encryption declaration is required if the app is offered in
France**. France is ZigDash's largest Android country, so the choice is:

1. File the declaration with ANSSI (France's cybersecurity agency) and upload
   it in App Store Connect; France opens when it's accepted.
2. Launch without France (Pricing and Availability), add it once the
   declaration is in.

Either way the questionnaire answers are: uses encryption — yes; qualifies
for an exemption — no; standard algorithms instead of or in addition to the
OS's — yes. Not legal advice; ANSSI's own page is the authority. Once
decided, `ITSAppUsesNonExemptEncryption` (true) in ios/Runner/Info.plist,
with the code App Store Connect issues, records it so each build doesn't ask.

## Review notes

`fastlane/metadata/ios/review_information/notes.txt`: the demo home needs no
hardware; where Pro and Restore purchase are; why Local Network is asked.
Contact: the developer's name, phone and email go in App Store Connect.
