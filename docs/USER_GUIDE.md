# ZigDash — User Guide

ZigDash turns your phone into a private, customizable control panel for a
[Zigbee2MQTT](https://www.zigbee2mqtt.io/) smart home. It talks directly to an
MQTT broker you control — no cloud account, no third‑party servers, no tracking.

This guide walks through everything: connecting to a broker, building dashboards,
each panel type, scheduled automation, scenes, remote access, settings, backup, and a FAQ.

---

## 1. Concepts at a glance

ZigDash is organized in three tabs (bottom bar):

| Tab | What it holds |
|---|---|
| **Brokers** | Your MQTT broker connections. Tap one to open its dashboards. |
| **Dashboards** | The dashboards belonging to the broker you opened. |
| **Settings** | Theme, Material You colors, and language. |

The hierarchy is: **Broker → Dashboards → Panels**.
- A **broker** is your MQTT server (e.g. the Mosquitto running on your hub).
- A **dashboard** is a screen/tab of controls under a broker.
- A **panel** is a single tile — a toggle, slider, shutter control, status light, etc. — bound to MQTT topics.

> Note: the name shown at the top of the dashboards view is your **broker's name**
> (e.g. "home"), not a dashboard. Dashboards appear as the tabs beneath it.

---

## 2. Connecting to a broker

1. Open the **Brokers** tab → tap **Add broker**.
2. Fill in:
   - **Name** — any label (e.g. "Home").
   - **Protocol** — `tcp` for a normal local broker (most common). `ws`/`wss` for WebSocket brokers (required if you ever run ZigDash on the web).
   - **Local host** — your broker's address on the home network, e.g. `192.168.7.210`.
   - **Port** — usually `1883` (plain MQTT) or `8883`/`9001` for TLS/WebSocket.
   - **Username / Password** — only if your broker requires auth. Passwords are stored in your device's secure keystore (encrypted), never in plain text.
   - **Auto‑connect on app start** — connect automatically when the app opens.
3. (Optional, **Advanced**) **Remote host (Tailscale)** and **Keep‑alive** — see §7 and below.
4. **Save.**

The broker row shows a live status dot: **Connecting**, **Connected**, **Reconnecting**, or **Error**. Tap the row to open its dashboards.

To **edit or delete** a broker, use the **⋮** menu on its row (or swipe to delete). Deleting a broker removes its dashboards, panels, and saved password.

---

## 3. Building dashboards

1. Open a broker → you'll see its dashboards as tabs (or an empty state if none).
2. **Add a dashboard:** the **+** in the top bar → give it a name, an optional
   **topic prefix**, a color seed, and an icon. Lock it to prevent accidental edits.
   - **Topic prefix** is prepended to panels' relative topics, so you can reuse panels across rooms (e.g. prefix `zigbee2mqtt/living-room`).
3. **Edit a dashboard:** the pencil ✏️ in the top bar. Delete is at the bottom of the edit form.
4. **Add a panel:** the **Add panel** button (bottom‑right) opens the panel picker.

### Editing & arranging panels
- Tap‑and‑hold or use a panel's **⋮ / options** to **Edit**, **Duplicate**, **Move up/down**, change **Width** (Full / Half / ⅓), or **Delete**.
- Panels lay out in a responsive grid based on their width.

---

## 4. Panel types

When you add a panel, you choose one of these. Every panel binds to a **publish
topic** (what it sends) and/or a **subscribe topic** (what it reads), with optional
**QoS**, **Retain**, and a **JSON path** to pull a value out of a JSON payload.

**Controls (send commands):**
- **Toggle** — on/off switch. Configure On/Off payloads and a JSON path + "on match" to read current state.
- **Button** — fires a single payload on tap (e.g. `PRESS`, a scene trigger).
- **Slider — Brightness / Position** — sends a numeric value (0–254 for brightness, 0–100 for position) via a value template like `{"brightness":value}`.
- **Cover** — shutter/blind control: **Open / Stop / Close** buttons, optional position presets (e.g. 0/25/50/100%) and a position slider.
- **Multi‑State / Combo / Radio** — pick from a list of options, each option sending its own payload (segmented buttons, a dropdown, or radio rows).
- **Text input** — type a value and send it.

**State (read‑only displays):**
- **LED indicator** — a colored dot reflecting a value (e.g. contact open/closed).
- **Node status** — online/offline/unknown of a device or service.
- **Progress** — a numeric value as a bar with a unit (e.g. battery %).
- **Text log** — a running log of messages on a topic.

**Automation:**
- **Schedule** — a daily open/close automation (see §5).

> Tip: For most Zigbee2MQTT devices, the **subscribe topic** is the device's
> friendly‑name topic (e.g. `zigbee2mqtt/lavi`) and the **JSON path** extracts the
> field you care about (e.g. `position`, `state`, `battery`). The **publish topic**
> is usually `zigbee2mqtt/<name>/set`.

---

## 5. Scheduled automation (shutters, etc.)

The **Schedule** panel sets a daily **open** and **close** time for a target (e.g. a
shutter). Crucially, the schedule is **executed by your always‑on hub, not the
phone** — ZigDash publishes the schedule as a retained MQTT message, and a flow on
your hub (e.g. Node‑RED) fires it at the right times. So it keeps running even when
your phone is off or away.

To use it you need the companion **Node‑RED flow** imported on your hub (see
`node-red/README.md` in the project). The panel shows the next action ("Next: open
at 06:30") and a warning if the scheduler hub appears offline.

---

## 6. Scenes

A **scene** saves how a group of devices should be set, and sets them all with one
tap. For example, "Evening": the living-room lamp on at 40%, the kitchen plug off,
the shutters at 30%.

### Create a scene

1. Open the **Scenes** tab in the bottom bar and tap **New scene**.
2. Give it a **Scene name**.
3. Under **Devices to capture**, tick the devices to include. Each one starts from
   its current state, which ZigDash reads live from Zigbee2MQTT.
4. Adjust the values: lights and switches have **Power** and **Brightness**, and
   shutters have **Position**. Anything else a device can set (colour, colour
   temperature…) is saved as it is right now.
5. Tap **Save**.

**Quickest way:** set your devices the way you want with their tiles first, then
create the scene. Everything is captured as it is, and you only tick the devices.

### Use a scene

- **Tap it** in the Scenes tab. ZigDash sends each device its saved values and
  shows "Activated …".
- **Put it on a dashboard:** ⋮ next to the scene → **Add to dashboard**. You get a
  scene tile that runs it with one tap, next to your other tiles.

### Edit or delete

⋮ next to the scene → **Edit** or **Delete**. Deleting a scene doesn't change your
devices.

### Good to know

- **Scenes run from the app.** Your phone has to be connected to the broker when
  you tap one; otherwise ZigDash says it can't activate the scene. Scenes don't
  run on a timer: for timed actions, use the **Schedule** panel (§5).
- **Read-only values are never saved** (battery, link quality and so on), so a
  scene only sends values the device accepts.
- **Scenes are stored on this phone, per home.** They are not part of the
  dashboards backup (§9) yet, so a new phone starts without them.
- ZigDash scenes are ZigDash's own. They don't use the scenes Zigbee2MQTT can
  store on devices (`scene_store` / `scene_recall`).

---

## 7. Remote access from outside home (Tailscale)

By default ZigDash reaches your broker over the LAN, so it only works at home.
To control your home while away, add a **remote host** using
[Tailscale](https://tailscale.com) (a free, encrypted mesh VPN):

1. Install Tailscale on your **hub/broker** and on your **phone**, signed into the same account. Note the hub's Tailscale IP (`tailscale ip -4`, e.g. `100.x.y.z`).
2. In ZigDash, edit the connection → **Advanced** → **Remote host (Tailscale)** → enter the hub's **Tailscale IP** (e.g. `100.x.y.z`). Leave **Local host** as your LAN address. (Prefer the `100.x` IP over a `.ts.net` name — it's stable and needs no DNS, which avoids MagicDNS-resolution issues in apps.)

ZigDash is **local‑first**: it tries the LAN first (instant, no VPN overhead at
home) and automatically falls back to the Tailscale address when you're away. The
status chip shows **Connected · Remote** when it's on the fallback. The remote leg
is encrypted end‑to‑end by Tailscale. Full setup steps: `docs/tailscale-remote.md`.

---

## 8. Settings

**Settings** (the gear in the header):
- **Homes** — every broker you use, as a home. Tap one to rename it, edit its connection, set its **Zigbee2MQTT base topic** (if yours is not `zigbee2mqtt`), switch to it, or delete it. **Add a home** runs setup again.
- **Appearance** — Theme: System / Light / Dark.
- **Use Material You colors** — on Android 12+, themes the app from your wallpaper palette; otherwise uses the app's brand color.
- **Language** — System, or one of the app's languages. Hebrew switches the whole UI to right‑to‑left.
- **About** — rate ZigDash, this guide, the privacy policy and the version.

All settings persist across restarts.

---

## 9. Backup & restore

From a broker's dashboards view, the **⋮ / backup menu** lets you **Export** your
setup (dashboards + panels; scenes aren't included yet) to a JSON file and **Import** it back later or onto
another device. Passwords are **not** included in the export (they live only in the
device's secure storage) — re‑enter them after importing.

---

## 10. FAQ

**Q: The broker shows "Connecting" forever / "Error". What do I check?**
- Is the **host/port** right and reachable from the phone's current network? (At home, the phone must be on the same Wi‑Fi/LAN as the broker.)
- Is the broker actually running and listening on that port (e.g. Mosquitto on `1883`)?
- If the broker requires auth, are the **username/password** correct?
- Plain‑MQTT brokers need **`tcp`** protocol; pick `ws`/`wss` only for WebSocket brokers.

**Q: It works at home but not when I'm away.**
That's expected without remote access — your LAN address isn't reachable from
outside. Set up **Tailscale** and add a **Remote host** (see §7). When away, the
chip should read **Connected · Remote**.

**Q: A panel shows "—" or no value.**
The panel isn't receiving the value it expects. Check the **subscribe topic** and
**JSON path** match your device's actual MQTT messages. Use a tool like MQTT
Explorer (or the project's `bin/smoke.dart`) to see the real topic/payload, then
set the JSON path to the right field (e.g. `state`, `position`, `battery`).

**Q: Why don't my devices show Online or Offline?**
Zigbee2MQTT only reports whether a device is online when its **availability**
feature is on, and it is off by default. Without it, ZigDash never guesses: a
device that ignores a state request shows **Not responding**, and battery devices
show their last report. To turn availability on:
- In the Zigbee2MQTT web interface: **Settings → Availability**, turn it on, save and restart Zigbee2MQTT; or
- in `configuration.yaml` add:
  ```yaml
  availability:
    enabled: true
  ```
  and restart Zigbee2MQTT.

Afterwards the **Devices** tab shows Offline devices under **Needs attention**,
and each device page shows its availability.

**Q: What does the dot on Devices mean?**
A new device joined your network and is not on a dashboard yet, or a battery
went low. Open the device (or add it to a dashboard, or dismiss it) and the dot
goes away.

**Q: Tapping a control doesn't do anything.**
- Confirm the connection is **Connected** (a control publish is dropped while disconnected).
- Check the **publish topic** (usually `zigbee2mqtt/<friendly-name>/set`) and the **payload/value template** match what your device expects.

**Q: My device/panel names are in Hebrew but the menus are in English (or vice‑versa).**
Panel and dashboard **names** are whatever you typed and stay as‑is. The app's
**interface** language is set in **Settings → Language**. Hebrew also flips the
layout to right‑to‑left.

**Q: Are my broker password and data sent anywhere?**
No. ZigDash stores everything **on your device** (settings/dashboards in a local
database, passwords in the OS secure keystore) and talks **only** to the broker you
configure. Your broker password, devices, topics and values never leave the phone.
There are no ads and no account. If you opt in (on the first setup screen, or in
Settings › About), ZigDash also sends anonymous usage data: which setup steps
fail and which features get used. You can turn it off any time; the privacy
policy lists exactly what is sent.

**Q: Does the schedule run when my phone is off?**
Yes — schedules are executed by your always‑on hub (e.g. Node‑RED), not the phone.
The phone only publishes the schedule configuration. (Requires the companion
Node‑RED flow on your hub.)

**Q: Can I run ZigDash in a web browser?**
The app can build for web, but browsers can't open raw TCP — your broker must
expose a **WebSocket** listener and you must use the `ws`/`wss` protocol. On a phone,
plain `tcp` works fine.

**Q: How do I move my setup to a new phone?**
Use **Export** (§9) to save the JSON, install ZigDash on the new phone, then
**Import** it. Re‑enter broker passwords afterward.

---

*Questions or issues: giladtamam1@gmail.com*
