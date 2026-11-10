# Facts about using ZigDash with a connected home

## Dashboards and tiles
- Five tabs: **Dashboards**, **Devices**, **Scenes**, **Automations**, **Settings**. A home's own settings: Settings › **Homes** › tap the home. A dashboard's ⋮ menu: **Wall display**, **Add dashboard**, **Export dashboards**, **Import dashboards** (the dashboards' backup).
- Add a tile: **Add tile** on the dashboard lists the home's devices (**Not on a dashboard** first, then **All devices**), plus **Reading** and **Custom MQTT tile**. Pick one, set **Name**, **Section**, **Size** (**Small**, **Wide**, **Full**), tap **Add**. The Devices tab has **Add to a dashboard** per device.
- Edit mode: the pencil (**Edit dashboard**); it does nothing while the dashboard's **Edit lock** is on. It shows **Add tile**, **Add section**, **Dashboard** (its form) and **Done**; tiles get **Move earlier** / **Move later**; sections **Rename section** / **Delete section**.
- Long-press a tile for **Tile options**: **Edit tile** (rename under **Name**, change size), **Move to section**, **Device details**, **Add to home screen**, **Add to Quick Settings**, **Write to NFC tag**, **Remove from dashboard** (with **Undo**).

## The Devices tab
- Every Zigbee2MQTT device, **Needs attention** first; filters **All**, **Needs attention**, **Not on a dashboard**. The tab's dot: new devices not on any dashboard, or a low battery.
- Needs attention: **Battery low** (20% or less), **Offline**, **Not responding**, **Pairing didn't finish**, **Not supported by Zigbee2MQTT**. A **Weak** link is shown but never counted.
- **Not responding**: the device has never sent a state and ZigDash's request for one went unanswered. **Online** / **Offline** come only from Zigbee2MQTT's availability feature, for devices it tracks; ZigDash never guesses them. Availability is turned on in Zigbee2MQTT's own settings, not in ZigDash; **How to turn it on** opens Get help.
- A device that shows wrong or does not respond: check it on Zigbee2MQTT's web page first, then **Link quality** and **Battery** under **Health** on its page. Works in Zigbee2MQTT but not in ZigDash: **Report a problem**.
- Pairing: **Add device** turns on Zigbee2MQTT's permit join ("Pairing — press the device's button", a countdown, **Stop**); then **Add tile**. ZigDash does not remove devices from the network; that happens on Zigbee2MQTT's page.
- Device page: **Rename** (in Zigbee2MQTT itself), **Control**, **Readings** (tap one for **History**), **Health**, **Notify me…** (an alert).

## Scenes
- Scenes tab › **New scene**: a **Scene name** and **Devices to capture**; the devices' current settable state is saved, so set them first. Tap a scene to activate it (home connected). Its menu: **Edit**, **Delete**, **Add to dashboard** (a **Scene button** tile). **All shutters** is built in (open, close or stop every shutter; **Which shutters…** unticks some).

## Automations and ZigDash Engine
- ZigDash Engine: one JavaScript file ZigDash puts inside Zigbee2MQTT on the hub as an extension (**Install on hub** / **Remove from hub** on the Automations tab; rules stay on the broker). It runs automations, alerts and the history recorder on the hub. Needs Zigbee2MQTT 2.4 or newer and a home connected to its MQTT broker.
- An automation: **When** (**A device changes**, or **A time comes**: clock time or sunrise/sunset with a **Town**, on chosen days), **Only if** (**Between hours**, **A device is…**), **Then** (**Run a scene** or **Set a device**, optionally **Turn off again** after some minutes), **Enabled**. Three per home are free. **Running on hub** is the good status.

## Alerts
- Settings › Homes › the home › **Alerts**, or a device's **Notify me…**. A notification for a leak, smoke, an opened door or window, or a low battery, with ZigDash closed; **Set up alerts on the hub** puts ZigDash Engine there. Needs Google services on the phone. An alert: **What**, **Devices**, **Only between** hours, **Battery below**; **Send test notification** checks the path. Before 3.0 alerts and history ran in a Node-RED flow; now in ZigDash Engine.

## History
- Tap a reading on a tile or device page: **24 hours** free, **7 days** and **30 days** Pro. **Set up on the hub** makes the Engine record every number on a dashboard every 15 minutes, 30 days on the broker. Without the Engine, **Record on this device** uses one phone or tablet that stays open.

## ZigDash Pro
- Settings › **ZigDash Pro**. Free forever: setup, dashboards, every device control, widgets, Quick Settings tiles, alerts, three automations per home, the wall tablet itself. Pro: unlimited automations, 7- and 30-day history, wall tablet extras, remote control through the relay (one home, up to five phones), every later Pro feature. Google Play version only; GitHub, IzzyOnDroid and F-Droid builds have Pro unlocked and no billing.

## Remote control
- Settings › Homes › the home › **Remote control**, or the globe on the dashboard. Two ways from away: **Your own address** (free: a Tailscale, VPN or forwarded-port address as the home's **Remote host (Tailscale)** under Connection), or the ZigDash relay (Pro).
- The relay needs ZigDash Engine (installed under Automations) and a home connected to its broker; **Turn on remote control** at home. **Your hub is connected to the relay** is the good status (else **Reconnect the hub** at home). **Add a phone** shows a code to scan at home; **Save a key backup** with a passphrase moves it to a new phone. Away, the chip reads **Connected · Away via ZigDash**. A Home Assistant home works away whenever its Home Assistant address does, no relay needed.

## Wall tablet and kiosk
- ⋮ › **Wall display**: **Keep the screen on and hide the bars**, **Fullscreen**, **When no one touches it** (**After** some minutes show **Dimmed**, **Clock**, **Black** or **Readings**), **Wake on motion**, **Alarms take over the screen**, **Night**, **Record history on this device**, and **Kiosk lock** with an optional 4-digit **PIN** and **Also pin ZigDash on Android**. Readings on the clock, wake on motion, night and alarms are Pro.

## Hub backup, Share this home, shortcuts
- Settings › Homes › the home › **Hub backup** (from 3.3): Zigbee2MQTT's settings, Zigbee network and device names, taken once a day at home and with **Back up now**; the last 7 kept on this phone, encrypted. **Save a copy** writes Zigbee2MQTT's own zip; **Restore** writes a backup back and restarts Zigbee2MQTT.
- Settings › Homes › the home › **Share with another phone**: a QR code for 2 minutes, scanned with the other phone's camera at home on the same Wi-Fi; it adds the home with its login and the dashboards.
- Long-press a light, plug or shutter tile: **Add to Quick Settings** (four ZigDash tiles) or **Add to home screen** (a widget). **Write to NFC tag** writes an NTAG213 or larger sticker that works with ZigDash closed; Settings › Homes › the home › **NFC tags** lists them. All need the phone to reach the home.

## Settings › Homes, and Get help
- Tap a home: **Name**, **Connection** (host, port, login, **Remote host (Tailscale)**, **Zigbee2MQTT base topic**; a Home Assistant home has **Sign in again**), **Share with another phone**, **Remote control**, **Automations**, **Alerts**, **NFC tags**, **Hub backup**, **Import from Home Assistant** (names and rooms), **Switch to this home**, **Delete home**. **Add a home** adds a second home.
- Settings › **Get help**: tips, then **Send** reaches the developer (email optional); **Report a problem** is in Settings too. **Talk to a person** under an assistant answer opens Get help with the conversation attached.

## What the assistant cannot do
- It cannot change any setting, add, rename or move a tile, create an automation, pair, rename or remove a device, restart Zigbee2MQTT, turn on remote control or buy Pro. It names the screen and button that does it.
- It does not see device names, dashboard names, addresses, logins, topics or any device's state. It knows only the facts line it is given (app version, Android, connection kind, Zigbee2MQTT version, bridge state, device count, last error, last scan); it must not claim a device is on, off, online or offline.
- It cannot read Zigbee2MQTT's page or logs, Home Assistant, the broker or the relay.
