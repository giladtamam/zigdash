# F-Droid RFP — ZigDash

Paste into a new issue at https://gitlab.com/fdroid/rfp/-/issues/new
(choose the "Default" template, then replace the template body with the
content below).

---

- [x] The app complies with the [inclusion criteria](https://f-droid.org/docs/Inclusion_Policy/).
- [x] The app is not already listed in the repo or issue tracker.
- [x] The app has not already been requested.
- [x] The upstream app source code repo contains the app metadata in a [Fastlane](https://gitlab.com/snippets/1895688) folder structure (`fastlane/metadata/android/en-US/`).
- [x] The original app author has been notified, and does not oppose the inclusion. (I am the author.)
- [ ] Optionally [donated](https://f-droid.org/donate/).

#### APPLICATION ID: `com.giladtamam.zigdash`

```yaml
Categories:
 - Connectivity

License: MIT

AuthorName: Gilad Tamam
AuthorEmail: giladtamam1@gmail.com
AuthorWebSite: https://github.com/giladtamam

WebSite: https://github.com/giladtamam/zigdash
SourceCode: https://github.com/giladtamam/zigdash

IssueTracker: https://github.com/giladtamam/zigdash/issues

Donate:
Bitcoin:
LiberaPay:

AutoName: ZigDash

RepoType: git

Repo: https://github.com/giladtamam/zigdash
```

Why do you want this app added to F-Droid:

> ZigDash is the only MQTT dashboard that auto-discovers Zigbee2MQTT devices —
> your dashboard builds itself from the bridge with one tap, instead of
> hand-wiring every MQTT topic. It is local-only with no cloud, no account,
> no ads and no analytics, which is exactly F-Droid's audience. F-Droid today
> has generic MQTT clients but nothing tuned for the large Zigbee2MQTT /
> self-hosted home-automation community.

Summary:

> MQTT dashboard that auto-discovers Zigbee2MQTT devices

Description:

> ZigDash discovers your Zigbee devices automatically — no manual topic
> wiring — and controls lights, shutters, switches and sensors from a phone
> or a wall-mounted tablet.
>
> * Scan a Zigbee2MQTT bridge and create a panel for every device with one tap
> * 16 panel types: toggle, button, slider, cover with presets, multi-state,
>   combo, radio, LED, node status, progress, text input, text log, scene,
>   schedule, auto-close rule, and device discovery
> * JSON-path extraction, so real Zigbee2MQTT messages work out of the box
> * Schedules and auto-close rules run on your hub via Node-RED, even when
>   the phone is off
> * Any MQTT broker over TCP, TLS, WebSocket or WSS, with LAN broker scan,
>   automatic reconnect, and Tailscale for remote access
> * Material 3 with dynamic color; phone and tablet; English and Hebrew (RTL)
> * JSON backup and restore; multiple brokers with instant switching
>
> Data lives on your device and your broker — nowhere else.

---

## Build note (for the fdroiddata MR, not part of the RFP issue)

Flutter app; the F-Droid build recipe needs the Flutter SDK. Precedents exist
(e.g. other Flutter apps in F-Droid). The release build uses
`--no-tree-shake-icons` (required — panels resolve `IconData` at runtime).
The project's `tool/build_release.sh apk` reproduces the shipped APK.
