# ZigDash 2.3: alerts (build spec)

Decided with the user on 2026-10-10 in two question rounds. Words follow [CONTEXT.md](../../CONTEXT.md): **Alert**, **Notification**, **Recent alerts**, **Alerts paused**, Home, Device page. Research: branch `research/reliable-alerts` (`research/reliable-alerts.md`, 2026-10-08), which this spec follows.

**Branch:** `release/2.3` (from `release/2.2.1`). **Version:** 2.3.0.

## Scope

In:
- Alerts for leak, smoke, door/window opened (optionally within set hours) and low battery.
- The hub's Node-RED as the alert engine, set up from ZigDash.
- Notifications through ntfy (default) or Pushover (optional, for smoke and leak).
- An Alerts screen with Recent alerts, a "Notify me" shortcut on device pages, and Alerts paused warnings.
- The Android local-network permission.
- Privacy policy, store listing, 11 languages.

Out (phase 2 or later):
- Notifications delivered into ZigDash itself (UnifiedPush). They need a prototype first: does delivery reach a closed Flutter app?
- "Device stopped responding" alerts.
- Value thresholds (temperature above X).
- An "armed" mode.
- Alerts without Node-RED (a background connection on the phone is rejected; see "Why the hub" below).
- iOS.

## Why the hub, not the phone

A phone that keeps its own connection to the broker is killed by Samsung, Xiaomi and others unless the user changes battery settings, drains the battery, needs a special Play review with a demo video, and only works when the phone can reach home. Every app that does this carries those complaints (Home Assistant, MQTT Alert, Gotify).

Instead, Node-RED on the always-on hub watches the devices and sends each alert to a push service that Android lets through even in Doze. ZigDash only configures it, the same way it configures schedules today.

## 1. The hub side

### The alerts flow

- A Node-RED flow, `node-red/alerts-flow.json`, in core nodes only. The only outside call is an HTTP request to ntfy or Pushover.
- It reads one retained config per Home from `zigdash/alerts/config` (contract below).
- It subscribes to `zigbee2mqtt/+` and fires on these values:
  - `water_leak` → leak;
  - `smoke` → smoke;
  - `contact: false` → opened;
  - `battery_low: true`, or `battery` at or below the alert's threshold (default 20%) → low battery.
- **When it notifies:**
  - **Leak and smoke:** once when it starts, and once when it clears ("Kitchen sensor is dry again").
  - **Door or window:** once per opening, only inside the alert's hours if set (hub local time, crossing midnight allowed).
  - **Low battery:** once per device until the battery is back above the threshold.
- **Priority:** ntfy priority 5 for leak and smoke (long vibration; can override Do Not Disturb if the user allows it in ntfy), 4 for the others. Pushover: priority 2 (repeats until acknowledged) for leak and smoke, 1 for the others.
- **Recent alerts:** it publishes the last 20 fired alerts, retained at QoS 1, to `zigdash/alerts/recent`, as a JSON list of `{at, kind, device, cleared}`.
- **Health:** it publishes retained `zigdash/alerts/bridge/state` = `online` on start and every 30 s, with a Last-Will of `offline`. This is the same pattern as the schedules flow.
- **Test:** `zigdash/alerts/test` (not retained) sends a test notification through the configured service, and the result goes to `zigdash/alerts/test/result`.

### The config contract (retained, QoS 1)

```json
{
  "version": 1,
  "home": "My Home",
  "delivery": {
    "service": "ntfy",
    "server": "https://ntfy.sh",
    "topic": "zd-<22 random characters>",
    "pushover": null
  },
  "hideNames": false,
  "alerts": [
    { "id": "…", "kind": "leak", "devices": ["0x00158d…"], "names": {"0x00158d…": "Kitchen sensor"} },
    { "id": "…", "kind": "opened", "devices": ["…"], "names": {…}, "from": "23:00", "to": "06:00" },
    { "id": "…", "kind": "battery", "devices": ["…"], "names": {…}, "threshold": 20 }
  ]
}
```

- The device name is sent in the config because the flow speaks only MQTT and doesn't read Zigbee2MQTT's device list. ZigDash republishes the config when a device is renamed.
- An empty retained payload removes the config, which turns alerts off for that Home.
- **Pushover:** `delivery.pushover` holds `{user, token}`. These are the user's own Pushover keys, kept in the retained config on their own broker. The setup screen says so.

### Installing the flow

- **One button: "Set up alerts on the hub".** ZigDash finds Node-RED at the broker's address on port 1880 and calls Node-RED's admin API: `GET /settings` to detect it, then `POST /flow` to add the flow as its own tab, or update it if one is already there.
- **Fallback.** If Node-RED asks for a login, or isn't reachable, the screen shows short steps and copies the flow JSON: open Node-RED, Import, paste, Deploy.
- **Node-RED not installed** (port 1880 refused): the screen explains that alerts need Node-RED on the hub. It links to Get help, which gets a new tip, "Install Node-RED", with SMHUB steps (Apps → Node-RED → Install) and a pointer for a Raspberry Pi. *Observed on the user's SMHUB, 2026-10-10: Node-RED is offered in SMHUB → Apps (5.0.1, beta) and not installed.*
- **The broker node in the imported flow** must point at the Home's broker. ZigDash fills it in from the Connection (address, port, username) before posting the flow; the password is never written into the flow. If the broker needs a password, the flow's broker node asks for it in Node-RED, and the fallback steps say so.

## 2. The app

### Alerts screen

- **Where:** Settings → Home → **Alerts**, plus an icon in the dashboard header when alerts exist, so it's one tap from home.
- **What it shows, top to bottom:**
  1. **Status:** "Alerts are on", "Alerts are paused: Node-RED on the hub isn't running", or "Not set up".
  2. **Recent alerts** (up to 20, newest first, with age).
  3. **The alerts,** each as "Leak · Kitchen sensor, Bathroom sensor" with a switch.
  4. **Add alert**, **Notifications on this phone**, and **Send test notification**.
- **Add or edit an alert:**
  - pick the kind;
  - pick devices (only devices that report that value; for low battery, battery-powered devices);
  - for door/window, optional hours;
  - for battery, the threshold.
- **Pre-filled alerts:** offered once on the first visit, from the Home's devices: "Leak: 2 sensors", "Smoke: 1 sensor", "Battery low: all 14 battery devices". The user turns them on with one tap each.

### Notify me on device pages

A device page for a leak, smoke, contact or battery device shows **Notify me…**. It opens the alert editor pre-filled with that device, or shows the alert the device is already in.

### Getting notifications on this phone

- **ntfy (default):**
  - ZigDash creates the topic once per Home (random, 22 characters) and keeps it in the Home's settings.
  - **Get notifications on this phone** opens the ntfy app already subscribed to the topic (`ntfy://` link; verify the exact form), or opens ntfy on Play if it isn't installed.
  - An advanced field takes a self-hosted ntfy server instead of ntfy.sh.
- **Pushover (optional):** the user enters their user key and app token, and the help text links to Pushover's pricing ($4.99 once after a trial).
- **Send test notification** publishes to `zigdash/alerts/test` and shows the hub's result ("Sent", or the error from ntfy/Pushover). It is the only end-to-end proof, and the setup flow asks for it before finishing.

### Alerts paused

- If `zigdash/alerts/bridge/state` is `offline`, or has not updated for over 90 seconds while the Home is connected, alerts count as **paused**.
- The Alerts screen shows the reason.
- The dashboard shows a dismissible banner, "Alerts are paused: Node-RED on the hub isn't running", with a link to Get help. Dismissing it hides it until the state changes.

### Privacy

- **Before alerts are turned on,** the setup screen says what leaves the hub:
  - the alert text (kind, device name, Home name) goes to ntfy.sh (and Google's push service, which ntfy.sh uses to reach Android), or to Pushover;
  - nothing else does.
- **Hide device names** (off by default) sends "💧 Leak detected" without names; tapping the notification opens ZigDash.
- **The privacy policy** gains an "Alerts" section saying the same, and that ZigDash itself sends nothing: the hub does, and only when the user sets it up.

### Notification text

| Kind | Fired | Cleared |
|---|---|---|
| Leak | 💧 Leak — Kitchen sensor (My Home) | ✅ Kitchen sensor is dry again |
| Smoke | 🔥 Smoke — Hallway detector (My Home) | ✅ No more smoke at Hallway detector |
| Opened | 🚪 Front door opened (My Home) | — |
| Battery | 🔋 Battery low — Bedroom sensor, 12% (My Home) | — |

- **Language:** the text is written by the flow in the language ZigDash sends in the config (`"lang"`), using phrases ZigDash includes in the config for that language. The flow has no translations of its own.
- **Tapping** an ntfy notification opens ZigDash on the Device page via a `zigdash://` link carried in ntfy's click action.

## 3. Local-network permission

- At targetSdk 37, Android requires `ACCESS_LOCAL_NETWORK` for connections to the LAN. Without it, connecting to the broker times out.
- 2.3 declares the permission and asks for it where setup first connects. A short screen first says why ("to talk to your hub on your home network").
- If it's denied, the connection error says so and offers to ask again.
- Behind a version check, so nothing changes on Android 16 and older.

## 4. Analytics (ADR 0006, opt-in only)

- `alerts_setup`: step (flow installed, flow manual, no Node-RED, test sent, test failed), service (ntfy, pushover).
- `alert_added`: kind.
- The privacy policy lists both. No device or Home names, topics or keys are ever sent.

## 5. Risks to check first (spikes, before building the screens)

1. **Node-RED admin API on SMHUB:** `GET /settings` and `POST /flow` without a login. Does the SMHUB build need auth?
2. **ntfy deep link:** the exact `ntfy://` subscribe link and its behaviour when ntfy isn't installed. Also the click action that opens `zigdash://` from a notification.
3. **End to end on the user's phone with the screen off and Doze forced** (`adb shell dumpsys deviceidle force-idle`): a priority-5 ntfy message must arrive.
4. **The broker node in an API-posted flow:** how credentials are set, given Node-RED keeps them in a separate credentials file.

## 6. Effort

- Spikes: half a day.
- Flow and contract: 1–2 days.
- Install path: 1 day.
- Alerts screen, editor, Notify me, paused banner: 3–4 days.
- Local-network permission: half a day.
- Privacy, listing, 11 languages, tests: 1 day.

About 1.5–2 weeks.
