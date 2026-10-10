# ZigDash after 2.0: roadmap, and the 2.1 build spec

The releases after 2.0, in order, decided on 2026-10-08 to 2026-10-10 in the "Post-2.0 roadmap" map and accepted by the user. Release 2.1 is specced to hand-off depth below; later releases stay at roadmap resolution and get their own spec when they start. Words follow [CONTEXT.md](../../CONTEXT.md) (Home, Device tile, Last-known value, Not responding, **Shortcut**).

**Ranking rule:** user demand first, effort second. The demand evidence is thin and mostly from rival MQTT apps' reviews, so 2.2 carries a one-time poll that may reorder 2.3–2.5.

## Releases

| Release | Scope | Why this order |
|---|---|---|
| **2.1** | Shortcuts: Quick Settings tiles, Android Device Controls, rename a device. Reconnect-immediately fix. | Live on Play since 2026-10-10. Tiles and controls are asked for second most (about 34 rival-app reviews) and are measured feasible. |
| **2.2** | Home-screen widgets (one device, scene, group). "What next?" poll. | Moved from 2.1 (user, 2026-10-10) so tiles and controls shipped first; same engine. Built on `release/2.2` (2026-10-10); widgets are added from the launcher's list or from a device's page (Add shortcut) and a device or scene tile's Edit-mode menu. |
| **2.3** | Push notifications (leak, door open, low battery). Android 17 local-network permission. | Most requested (about 25 reviews plus a dedicated rival app). The permission changes setup and must land well before targetSdk 37 is required (expected August 2027). |
| **2.4** | History graphs (temperature, humidity, power over a day or a week). | Medium demand; needs a recorder, which Node-RED on the hub provides. |
| **2.5** | Kiosk mode: PIN or guest lock on a wall tablet, building on Wall display. | Medium demand, mostly lock and fullscreen. |
| Later, if asked | Zigbee groups, firmware (OTA) updates, Zigbee network map. | Low demand; all possible over Zigbee2MQTT 2.x MQTT. |
| Dropped | Voice (needs Home Assistant's Assist), energy dashboard (low demand, only after history), conditional tiles (no demand). | |

**Constraint for every release:** ZigDash has no server of its own. It's a phone app speaking MQTT to the user's broker, with optional Node-RED on the hub for anything that must run while the phone is off.

## 2.3 to 2.5 at roadmap resolution

- **2.3 Push notifications.** Node-RED on the hub is the alert engine; ZigDash configures an alerts flow over retained MQTT, the same way it configures schedules. Delivery starts with ntfy (high-priority FCM through Doze, no account, free up to 250 messages a day); UnifiedPush for native notifications is a later phase. Background MQTT on the phone is rejected (battery, `dataSync` limits, OEM killers). Node-RED republishes alerts retained at QoS 1 on `zigdash/alerts/...` so the app catches up. Research: branch `research/reliable-alerts`.
- **2.3 Local-network permission.** At targetSdk 37, LAN connections need `ACCESS_LOCAL_NETWORK`; without it, connecting to the broker times out. Setup explains the permission before asking.
- **2.4 History.** Zigbee2MQTT keeps no history, so a Node-RED flow on the hub records chosen readings; the app draws them. Retention and storage size are decided when 2.4 starts.
- **2.5 Kiosk.** Scope (PIN lock in the app, OS lock task, ambient features) decided when 2.5 starts.

## 2.1 build spec: shortcuts

**Branch:** `release/2.1` from `main`. **Base research:** branch `research/android-widgets` (feasibility, plugins, effort) and branch `spike/headless-command` (`docs/spike/headless-command-latency.md`, measured tap latency).

### Scope

In: widgets (one device, group), Quick Settings tiles, Device Controls, one shared headless command engine, adding shortcuts from the home screen and from inside ZigDash, the reconnect-immediately fix, a one-time poll card, analytics events for shortcuts and the poll, store listing and screenshots for shortcuts, 11 languages.

Out: a whole-dashboard widget, background refresh of shortcuts, Zigbee groups, iOS.

### 1. The command engine

One cached headless `FlutterEngine` runs a Dart entrypoint on ZigDash's own `lib/mqtt` (`MqttManager`), shared by all three shortcut kinds. No persistent foreground service, and no WorkManager for taps.

Measured on a Galaxy S24 FE (Android 16) against the user's SMHUB, tap to Zigbee2MQTT's reply: tile cold median 212 ms, warm 92–117 ms; widget path cold 280 ms, warm 185 ms. Engine start 67–151 ms cold. The Dart engine stays; no native MQTT port.

Rules the measurement set:

- **Reconnect immediately on a tap.** A connection that died while the app idled must not wait for the reconnect backoff (measured 2.2 s). A tap calls the no-backoff reconnect; if nothing has arrived for longer than the keep-alive, treat the connection as dead and reconnect at once. The same applies when the app itself returns to the foreground.
- **Each connect attempt has its own deadline,** so an attempt that hung while Android blocked the network can't wedge the next one.
- **Widget taps run as a short user-initiated foreground task** (widget `PendingIntent` → `shortService` foreground service), because Android 16 can block network for idle apps (`blocked=APP_BACKGROUND`, seen on the emulator). Tiles and Device Controls are bound by SystemUI and don't need this.
- **Tiles pre-warm the engine** when the Quick Settings panel opens (`onStartListening`).
- **Endpoints:** same order as the app: the local address, then the remote address (Tailscale or other).

### 2. How a shortcut behaves

- **Home:** each shortcut is tied to one device (or one group) in one Home, chosen when it's added. Switching Homes in the app doesn't change it. If the device or Home is deleted, the shortcut shows "Removed" and opens ZigDash when tapped.
- **After a tap:** show "working…" and change state only when the device confirms its new state. No optimistic flip. No confirmation within 5 s → show that it wasn't confirmed.
- **Hub unreachable:** try on every tap. On failure, keep the Last-known value with its age and show "Can't reach home" for about 10 s.
- **Not responding device:** send anyway; without confirmation show "Not responding".
- **Freshness:** refresh only after a tap or while the app runs. Otherwise show the Last-known value with its age ("40 min ago"). No background refresh.
- **Sensors and contacts** in a widget show their reading; tapping opens ZigDash on that device.
- **Shutters have a position, not on/off** (user, 2026-10-10). A shutter's tile, and its widget's name, open the **shutter pop-up**: live state line, a position slider (0–100%) and Open / Stop / Close. A widget also shows the position as a bar with ▲ ■ ▼ buttons (widgets can't hold sliders). Device Controls use Android's own slider. A shutter command is confirmed when its motor starts, and the engine follows it until it stops.

### 3. Widgets

Prototype: branch `prototype/shortcuts`, `docs/design/prototypes/shortcuts-prototype.html`.

- **One device:** 2×2 square or 4×1 strip. Icon, name, state line (value, "working…", age, or problem). Amber when on, Signal theme, light and dark following the system.
- **Scene button:** a one-device-sized widget that runs a scene; its state line shows "sent" then "confirmed".
- **Group:** 4×2 to 4×4, a title (the group's name), up to five devices as rows, and a row of up to three scene buttons.
- Native layouts (RemoteViews); `home_widget` may be used for data and update plumbing only, not for its WorkManager tap path.

### 4. Quick Settings tiles and Device Controls

- **Tiles:** one device per tile, toggled on and off; a shutter's tile opens the shutter pop-up instead. Label = device name, subtitle = state line. Unavailable devices (sensors) can't be tiles. Long-press opens ZigDash on the device. On a locked phone a tap asks for the unlock first (user, 2026-10-10); Device Controls follow Android's own "control from locked device" setting. Android limits how many tiles one app can offer; ZigDash declares a fixed set of tile slots that the user assigns to devices.
- **Device Controls** (Android 11+): one control per device in a "ZigDash · <Home>" structure. Lights, plugs and switches toggle; dimmable lights and covers get a slider (Android draws it); sensors are status-only. Android decides the look.

### 5. Adding shortcuts

- **From the home screen:** Widgets › ZigDash › drag a widget; ZigDash's picker opens: choose the Home, then the device, scene or group. Reconfigure by long-press (Android 12+).
- **From inside ZigDash:** "Add shortcut" on a device's page and in a tile's Edit-mode menu: choose widget, tile or control, then Android's own pin-widget or add-tile prompt confirms. Groups are created in the picker from a dashboard section or a hand-picked list.

### 6. Poll card

A one-time card on the dashboard after the user has used the app on three different days: "What should ZigDash do next?" with four choices (notifications, history graphs, kiosk mode, Zigbee groups) and "Not now". Shown once. The answer is sent as an opt-in analytics event (`poll_answer`, choice as an enum); users who haven't opted in see a line pointing to Request a feature instead.

### 7. Analytics (ADR 0006)

- `shortcut_added`: kind (widget, group_widget, scene_widget, tile, control).
- `shortcut_used`: kind, once per session per kind.
- `poll_answer`: choice.
The privacy policy lists them.

### 8. Effort

From the research: latency spike done; widgets about 1–1.5 weeks, tiles 3–5 days, Device Controls 1–2 weeks, plus the poll, analytics, store assets and translations.

### 9. Exit checks

- A cold tap under 3 s on the Galaxy S24 FE and on one slower, older phone; warm under 1 s.
- Every behaviour in section 2 checked on a real hub: confirmed, not confirmed, can't reach home (broker off), not responding (device unplugged), remote over Tailscale.
- Widgets in light and dark at each size; Hebrew right to left.
- After a month: at least 15% of opted-in active users have added a shortcut; the crash rate hasn't risen.

### Risks

- OEM skins may hide or restyle Device Controls, and few users add the Device Controls tile.
- Some launchers handle widget reconfiguration poorly; removing and re-adding stays the fallback.
- Android may tighten background network further; the foreground-task rule in section 1 is the mitigation.
