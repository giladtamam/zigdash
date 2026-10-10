# ZigDash 2.3: alerts (build spec)

Decided with the user on 2026-10-10 in two question rounds, then changed after a prototype the same day. Words follow [CONTEXT.md](../../CONTEXT.md): **Alert**, **Notification**, **Recent alerts**, **Alerts paused**, Home, Device page. Research: branch `research/reliable-alerts` (`research/reliable-alerts.md`, 2026-10-08). Prototype: branch `prototype/in-app-push` (results in §5).

**Branch:** `release/2.3` (from `release/2.2.1`). **Version:** 2.3.0.

**How delivery was decided.** The research recommended ntfy, a second app. The user ruled that out ("I don't think many users will do that"). The prototype then showed that alerts can reach ZigDash itself through Google's push service, with no second app, no Firebase project and no ZigDash server, including when ZigDash is closed or the phone is in Doze. That is the 2.3 path; ntfy is the fallback for phones without Google services and the way to share alerts with people who don't use ZigDash.

## Scope

In:
- Alerts for leak, smoke, door/window opened (optionally within set hours) and low battery.
- The hub's Node-RED as the alert engine, set up from ZigDash.
- Notifications delivered into ZigDash (UnifiedPush, embedded FCM distributor), end-to-end encrypted.
- ntfy as the fallback and for household sharing; Pushover optional for smoke and leak (repeats until acknowledged).
- An Alerts screen with Recent alerts, a "Notify me" shortcut on device pages, and Alerts paused warnings.
- The Android local-network permission.
- Privacy policy, store listing, 11 languages.

Out (later):
- "Device stopped responding" alerts.
- Value thresholds (temperature above X).
- An "armed" mode.
- Alerts without Node-RED (a background connection on the phone is rejected; see "Why the hub" below).
- iOS.

## Why the hub, not the phone

A phone that keeps its own connection to the broker is killed by Samsung, Xiaomi and others unless the user changes battery settings, drains the battery, needs a special Play review with a demo video, and only works when the phone can reach home. Every app that does this carries those complaints (Home Assistant, MQTT Alert, Gotify).

Instead, Node-RED on the always-on hub watches the devices and sends each alert through Google's push service, which Android lets through even in Doze. ZigDash only configures it, the same way it configures schedules today.

## 1. The hub side

### The alerts flow

- A Node-RED flow, `node-red/alerts-flow.json`, in core nodes only. The function node uses Node's built-in `crypto` (declared in its Setup tab; no npm module), and an `http request` node posts the push. Proven on the user's SMHUB.
- It reads one retained config per Home from `zigdash/alerts/config` (contract below).
- It subscribes to `<base>/#` (the Home's Zigbee2MQTT base topic, from the config) and looks at messages whose topic is one of the configured devices' state topics, ignoring `/set`, `/get` and `bridge/`. Zigbee2MQTT publishes state under the friendly name, not the IEEE address, so each configured device carries its topic.
- **It fires on changes, never on values.** A device's last seen value is kept per device; the first message after a (re)start only seeds it. Zigbee2MQTT republishes a device's whole state whenever anything asks (`/get`, a widget, an app start), and may retain it, so firing on `contact: false` would mean a "Front door opened" at every such republish.
  - `water_leak` false → true: leak; true → false: cleared.
  - `smoke` false → true: smoke; true → false: cleared.
  - `contact` true → false: opened.
  - `battery_low` false → true, or `battery` crossing down to the alert's threshold (default 20%): low battery; crossing back up clears the "reported" mark.
- **When it notifies:**
  - **Leak and smoke:** once when it starts, and once when it clears.
  - **Door or window:** once per opening, only inside the alert's hours if set. Hours are in the Home's time zone, sent in the config (`timeZone`, IANA name), since the hub's Node-RED most likely runs in UTC.
  - **Low battery:** once per device until the battery is back above the threshold.
- **What it sends** (to every phone in the config, and to ntfy/Pushover if set): one JSON object, `{"v":1, "kind":"leak", "connection":"<Home id>", "device":"0x00158d…", "name":"Kitchen sensor", "home":"My Home", "cleared":false, "value":null, "at":"2026-10-10T21:03:12+03:00"}`. The phone writes the notification text in its own language (§2), so the flow carries no wording. For ntfy and Pushover, which show raw text, the flow uses the English phrases in the config's `"text"` map, written by ZigDash in the app's language.
- **Push details:** Web Push, RFC 8291 `aes128gcm` to each phone's keys, VAPID ES256 with the key pair from the config, headers `Urgency: high` (required: normal urgency waits for the phone to wake), `TTL: 86400`. A `404`/`410` answer marks that phone `dead` in `zigdash/alerts/state`; ZigDash removes it from the config.
- **Memory:** the SMHUB's Node-RED keeps context in memory only, so the per-device memory (last values, "battery already reported") is also kept retained on `zigdash/alerts/state` and reloaded on start; it is republished only when something tracked changed.
- **Recent alerts:** it publishes the last 20 fired alerts, retained at QoS 1, to `zigdash/alerts/recent`, as a JSON list of the same objects.
- **Health:** retained `zigdash/alerts/bridge/state` = `online` on start and every 30 s, with a Last-Will of `offline` (the schedules flow's pattern).
- **Test:** a message on `zigdash/alerts/test` with `{"phone":"<id>"}` sends a test alert to that phone (or to all channels when no id), and the result goes to `zigdash/alerts/test/result`.

### The config contract (retained, QoS 1)

```json
{
  "version": 1,
  "connection": "<the Home's id in ZigDash, echoed in every event so a tap opens the right Home>",
  "home": "My Home",
  "base": "zigbee2mqtt",
  "timeZone": "Asia/Jerusalem",
  "vapid": { "publicKey": "BJ5D…", "privateJwk": { "kty": "EC", "crv": "P-256", "x": "…", "y": "…", "d": "…" } },
  "phones": [
    { "id": "a1b2…", "name": "Gilad's Galaxy", "endpoint": "https://fcm.googleapis.com/fcm/send/…", "p256dh": "BGpQ…", "auth": "b3tV…" }
  ],
  "ntfy": null,
  "pushover": null,
  "text": { "leak": "💧 Leak — {name} ({home})", "leakCleared": "✅ {name} is dry again", "smoke": "…", "smokeCleared": "…", "opened": "🚪 {name} opened ({home})", "battery": "🔋 Battery low — {name}, {value}% ({home})", "test": "ZigDash test alert" },
  "alerts": [
    { "id": "…", "kind": "leak", "devices": [{ "ieee": "0x00158d…", "topic": "zigbee2mqtt/Kitchen sensor", "name": "Kitchen sensor" }] },
    { "id": "…", "kind": "opened", "devices": [{ "ieee": "…", "topic": "zigbee2mqtt/Front door", "name": "Front door" }], "from": "23:00", "to": "06:00" },
    { "id": "…", "kind": "battery", "devices": [{ "ieee": "…", "topic": "…", "name": "Bedroom sensor" }], "threshold": 20, "enabled": true }
  ]
}
```

- **The VAPID key pair** is made by the first phone that sets up alerts and lives in the config, on the user's own broker, like the Pushover keys. Anyone who can read the broker can already control the home, so this adds no exposure; the privacy policy says it. A phone that joins later reads the public key from the retained config, registers with it, and adds itself to `phones`.
- **Several phones** share one config; each phone rewrites it from the retained value it last received (last writer wins; `phones` entries are merged by `id`). ZigDash re-registers at every start (the push library asks for this) and updates its entry if the endpoint changed.
- Each device carries its IEEE address (for the app), its state topic and its name, because the flow speaks only MQTT and doesn't read Zigbee2MQTT's device list. ZigDash republishes the config when a device is renamed (its topic changes too).
- An empty retained payload removes the config, which turns alerts off for that Home. An alert with `"enabled": false` (its switch off) is kept but ignored by the flow.
- **`ntfy`** holds `{server, topic}` when household sharing or the no-Google fallback is on. **`pushover`** holds `{user, token}`.

### Installing the flow

- **One button: "Set up alerts on the hub".** ZigDash finds Node-RED at the broker's address on port 1880 and calls Node-RED's admin API: `GET /settings` to detect it, `GET /flows` to find a tab labelled "ZigDash alerts", then `POST /flow` to add it or `PUT /flow/:id` to update it. Verified on SMHUB (§5).
- **Fallback.** If Node-RED asks for a login, or isn't reachable, the screen shows short steps and copies the flow JSON: open Node-RED, Import, paste, Deploy.
- **Node-RED not installed** (port 1880 refused): the screen explains that alerts need Node-RED on the hub. It links to Get help, which gets a new tip, "Install Node-RED", with SMHUB steps (Apps → Node-RED → Install) and a pointer for a Raspberry Pi.
- **The broker node** in the posted flow must use the Home's broker **address, never `localhost`** (on SMHUB, Node-RED can't reach the broker that way). ZigDash fills in address, port and username from the Connection; the password is never written into the flow. If the broker needs a password, the flow's broker node asks for it in Node-RED, and the fallback steps say so.

## 2. The app

### Alerts screen

- **Where:** Settings → Home → **Alerts**, plus an icon in the dashboard header when alerts exist, so it's one tap from home.
- **What it shows, top to bottom:**
  1. **Status:** "Alerts are on", "Alerts are paused: Node-RED on the hub isn't running", "This phone isn't getting notifications" (see below), or "Not set up".
  2. **Recent alerts** (up to 20, newest first, with age).
  3. **The alerts,** each as "Leak · Kitchen sensor, Bathroom sensor" with a switch.
  4. **Add alert**, **Notifications on this phone**, **Share alerts**, and **Send test notification**.
- **Add or edit an alert:**
  - pick the kind;
  - pick devices (only devices that report that value; for low battery, battery-powered devices);
  - for door/window, optional hours;
  - for battery, the threshold.
- **Pre-filled alerts:** offered once on the first visit, from the Home's devices: "Leak: 2 sensors", "Smoke: 1 sensor", "Battery low: all 14 battery devices". The user turns them on with one tap each.

### Notify me on device pages

A device page for a leak, smoke, contact or battery device shows **Notify me…**. It opens the alert editor pre-filled with that device, or shows the alert the device is already in.

### Notifications on this phone

- **Turning it on** (one switch, on by default when alerts are set up):
  1. Ask Android's notification permission.
  2. Register with the push library using the Home's VAPID public key; ZigDash is its own distributor, so nothing else is installed. On a phone without Google services ZigDash isn't offered as a distributor; the switch then explains and offers the ntfy fallback.
  3. Put this phone's endpoint and keys into the config.
- **Turning it off** removes the phone from the config and unregisters.
- **Notification channels:** "Alerts" (leak, smoke): max importance, its own sound, and a note that the user can let it override Do Not Disturb in Android's settings. "Notices" (door, battery): high importance.
- **Tapping** a notification opens ZigDash on the Device page.
- **Kept alive:** on Android 14+, a force-stopped app gets no pushes until it's opened. Samsung's "sleeping apps" does the same. So:
  - the Alerts screen shows "This phone isn't getting notifications" when Android reports background restrictions for ZigDash, with a button to Android's settings and, on Samsung, the words to look for ("Never sleeping apps");
  - Recent alerts shows what was missed the next time ZigDash opens;
  - the dashboard banner says the same when alerts are set up and the phone is restricted.
- **Send test notification** publishes to `zigdash/alerts/test` for this phone and shows the hub's result. The setup flow asks for it before finishing: it is the only end-to-end proof.

### Share alerts and the fallback (ntfy)

- **Share alerts** turns on an ntfy topic for the Home (random, 22 characters, kept in the config as `ntfy`), then shows the link (copy, or open on this phone; a QR code was dropped to avoid another package) `ntfy://ntfy.sh/<topic>?display=<Home name>`. Another phone gets the Home's notifications with only the ntfy app, no ZigDash needed. The screen says that anyone with the link gets the alerts, and that this text goes through ntfy.sh unencrypted; **New link** makes a fresh topic, which cuts off old subscribers. An advanced field takes a self-hosted ntfy server.
- **The no-Google fallback** uses the same topic from the Alerts screen: "Get notifications with ntfy" opens the link, or ntfy on Play (or F-Droid) if it isn't installed.
- **Pushover (optional):** the user enters their user key and app token; help text links to Pushover's pricing ($4.99 once after a trial). Smoke and leak go at priority 2 (repeats until acknowledged), the rest at 1.

### Alerts paused

- If `zigdash/alerts/bridge/state` is `offline`, or has not updated for over 90 seconds while the Home is connected, alerts count as **paused**.
- The Alerts screen shows the reason.
- The dashboard shows a dismissible banner, "Alerts are paused: Node-RED on the hub isn't running", with a link to Get help. Dismissing it hides it until the state changes.

### Privacy

- **Pushes to ZigDash are end-to-end encrypted** (Web Push, RFC 8291): Google's push service carries the message but can't read it. Only the fact that a push was sent, and when, is visible to Google.
- **ntfy and Pushover are not:** the alert text passes through ntfy.sh (and Google's push, which ntfy.sh uses) or Pushover in the clear. The Share alerts screen says so before the topic is made, and **Hide device names** (off by default) sends "💧 Leak detected" without names on those paths.
- **The privacy policy** gains an "Alerts" section saying the same, and that ZigDash itself sends nothing: the hub does, and only when the user sets it up.

### Notification text

Written by ZigDash from the push's JSON, in the app's language:

| Kind | Fired | Cleared |
|---|---|---|
| Leak | 💧 Leak — Kitchen sensor (My Home) | ✅ Kitchen sensor is dry again |
| Smoke | 🔥 Smoke — Hallway detector (My Home) | ✅ No more smoke at Hallway detector |
| Opened | 🚪 Front door opened (My Home) | — |
| Battery | 🔋 Battery low — Bedroom sensor, 12% (My Home) | — |

The Home name is left out when the app has one Home.

## 3. Local-network permission

- At targetSdk 37, Android requires `ACCESS_LOCAL_NETWORK` for connections to the LAN. Without it, connecting to the broker times out.
- 2.3 declares the permission and asks for it where setup first connects. A short screen first says why ("to talk to your hub on your home network").
- If it's denied, the connection error says so and offers to ask again.
- Behind a version check, so nothing changes on Android 16 and older.


## 4. Analytics (ADR 0006, opt-in only)

- `alerts_setup`: step (flow installed, flow manual, no Node-RED, phone registered, no Google services, test sent, test failed), channel (push, ntfy, pushover).
- `alert_added`: kind.
- The privacy policy lists both. No device or Home names, endpoints, topics or keys are ever sent.

## 5. Risks to check first (spikes, before building the screens)

1. **Node-RED admin API on SMHUB:** `GET /settings` and `POST /flow` without a login. Does the SMHUB build need auth?
2. **ntfy deep link:** the exact `ntfy://` subscribe link and its behaviour when ntfy isn't installed. Also the click action that opens `zigdash://` from a notification.
3. **End to end on the user's phone with the screen off and Doze forced** (`adb shell dumpsys deviceidle force-idle`): a high-urgency push must arrive. Done on the emulator (below); the user's Samsung is still to do.
4. **The broker node in an API-posted flow:** how credentials are set, given Node-RED keeps them in a separate credentials file.

### Results so far (2026-10-10, the user's SMHUB, Node-RED 4.1.10 from SMHUB → Apps)

1. **Admin API: passes.** No login (`/auth/login` returns `{}`). `GET /settings`, `GET /flows` (API v2), `POST /flow`, `PUT /flow/:id` and `DELETE /flow/:id` all work. A test tab was added, ran, and was removed.
4. **Broker node: passes, with one rule.** A flow posted through the API connects and publishes. On SMHUB, Node-RED **cannot reach the broker as `localhost`**; it must use the hub's address, so ZigDash writes the Connection's host into the broker node. `credentials: {user, password}` on the config node is accepted. Untested with a password-protected broker, since the user's broker has none.
   - **Also found:** Node-RED's context store is memory only, so the flow loses what it remembers (e.g. "battery already reported") on every restart. Keep that state retained on the broker too (`zigdash/alerts/state`), not only in flow context.
2. **ntfy links: answered from ntfy's docs.**
   - Subscribe with `ntfy://ntfy.sh/<topic>?display=<Home name>` (self-hosted: `ntfy://<host>/<topic>`, plus `?secure=false` for http).
   - The `Click` header accepts custom schemes, so a notification can open `zigdash://…`. ZigDash has no `zigdash://` scheme yet, so 2.3 adds one (Device page by Home and IEEE).
   - The no-ntfy-installed case is still to check on the phone.
3. **Doze delivery: not run yet.** It needs ntfy installed on the phone.

### Prototype results: delivery into ZigDash (2026-10-10, branch `prototype/in-app-push`)

**Setup:**
- `unifiedpush` 6.2.0 (`unifiedpush_android` 3.5.0) and `org.unifiedpush.android:embedded-fcm-distributor:3.1.0`.
- No Firebase project, no `google-services.json`, no second app, no ZigDash server.
- A release build on an Android 16 emulator with Google Play services.
- The sender was Web Push (RFC 8291 `aes128gcm` + VAPID ES256) using only `node:crypto`, run both from the Mac and from a throwaway Node-RED function node on the user's SMHUB (built-in `crypto` through the function node's Setup modules, posted by an `http request` node).

| Test | Result |
|---|---|
| Register | ZigDash lists itself as a distributor, gets an `https://fcm.googleapis.com/fcm/send/…` endpoint in ~5 s |
| App open | Delivered, decrypted, shown as a ZigDash notification, < 1 s |
| App process killed (swiped / reclaimed) | Google starts ZigDash in the background; Dart shows the notification ~0.16 s after the process starts |
| Forced Doze, screen off, app killed, `Urgency: high` | Delivered at once; the device stays in Doze |
| Forced Doze, `Urgency: normal` (control) | Held until the device woke. **Alerts must be sent with `Urgency: high`.** |
| Force-stopped app | Dropped (`GCM: broadcast … result=CANCELLED`) and not redelivered after reopening. Standard Android; ntfy would be hit the same way. The endpoint stayed the same after reopening. |
| Sent by Node-RED on the SMHUB | Delivered and decrypted |

**Build notes:**
- Tink classes clash (`tink` 1.23.0 from the push library versus `tink-android` 1.9.0 from secure storage). Fixed with the plugin README's `configurations.all { force tink-android 1.23.0 + substitute tink }`.
- `flutter_local_notifications` needs core-library desugaring.

**Decision: delivery into ZigDash is the 2.3 path.** Mitigations for the force-stop case:
- Recent alerts (kept on the hub) shows missed alerts when ZigDash opens.
- Setup checks whether Android has put ZigDash to sleep, and explains Samsung's "Never sleeping apps".

**Flow on the hub (2026-10-10, later):** `node-red/alerts-flow.json`, installed on the SMHUB through `POST /flow`, with a config naming a fake sensor topic: dry → wet sent a push that woke the closed ZigDash on the emulator; `zigdash/alerts/test` answered `{"ok":true}` on `test/result`; state and recent were retained as specified. The flow's 29-check harness (`node-red/alerts/test/harness.mjs`) passes.

**On the user's Samsung (Galaxy S24 FE, Android 16, 2026-10-11): passes.** ZigDash Dev joined the Home's existing setup (same keys as the emulator), a test push from the app arrived (hub answered 201), and with the app killed and the phone forced into Doze a push started the app and showed the notification. Samsung had not restricted the app (background: allow, standby bucket active). With the background restriction simulated (`appops RUN_ANY_IN_BACKGROUND ignore`) the Alerts screen shows the "Android may stop ZigDash" warning. Samsung's own "sleeping apps" list was not exercised (it needs days of non-use). Found and fixed on the way: a second phone saved the broker's copy under the writer's Home id (foreign-key failure) and never followed it before setting up.

**What changes in the spec:**
- **Delivery:** ntfy is no longer the default. It becomes the optional household-sharing path, and the fallback for phones without Google Play services (where ZigDash isn't listed as a distributor).
- **The keys:** the first phone makes the VAPID key pair and keeps it in the retained config, so later phones read the public key there (no Node-RED HTTP endpoint needed).
- **What each phone sends the hub:** its endpoint and keys, through the retained config (one entry per phone, so several phones get alerts).
- **Tapping a notification** opens ZigDash directly, so the `zigdash://` scheme is only needed for ntfy.


## 6. Effort

- Flow and contract (push, state kept retained, recent, test): 2 days.
- Install path: 1 day.
- Push registration, channels, background notification, restricted-phone check: 1.5 days.
- Alerts screen, editor, Notify me, paused banner: 3–4 days.
- Share alerts (ntfy) and Pushover: 1 day.
- Local-network permission: half a day.
- Privacy, listing, 11 languages, tests: 1 day.

About 2 weeks.

## 7. Progress (2026-10-11)

Built and verified on the user's SMHUB and an Android 16 emulator: the flow (§1), push registration and notifications, the Alerts screen, editor, Notify me, suggested alerts, the paused banner, one-button install, share alerts/Pushover sheet, the local-network permission (declared; asked for on Android 17), analytics events, 11 languages. Left: the privacy policy and store listing text, the Samsung test (real Doze and "sleeping apps"), release prep. The user wants to run 2.3 on their own phone for a few days before Play.

## 8. Build order

1. Flow + contract, tested against the prototype's sender on the emulator.
2. Push registration in the app (from the prototype), notification display, tap-to-open.
3. Install path.
4. Alerts screen, editor, Notify me, pre-filled alerts.
5. Paused and restricted-phone warnings, Recent alerts.
6. Share alerts, Pushover, local-network permission.
7. Privacy, listing, translations, Samsung test on the user's phone.
