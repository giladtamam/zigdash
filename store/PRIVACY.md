# ZigDash — Privacy Policy

**Effective date:** the day ZigDash 2.2 is published (replaces the policy published with ZigDash 2.1)

ZigDash ("the app") is a client for controlling [Zigbee2MQTT](https://www.zigbee2mqtt.io/)
devices through MQTT brokers that **you** configure. This policy explains what
the app does and does not do with your data.

## Summary

ZigDash does **not** collect or share personal data. Your broker settings,
passwords, devices, topics and their values stay on your device. There is no
advertising and no user account, and the developer runs no server of their own.

Only if you **opt in**, ZigDash sends a short list of **anonymous usage
events** (which setup steps fail, which features get used) to Aptabase, an
analytics service hosted in the EU. It is off unless you turn it on, and you
can turn it off at any time. See [Anonymous usage data](#anonymous-usage-data).

## Data stored on your device

All data stays on your device:

- **Connection settings** — the MQTT broker host, port, protocol, and optional
  username you enter.
- **Passwords** — any broker password you enter is stored in the operating
  system's secure storage (Android Keystore / iOS Keychain), not in plain text.
- **Dashboards and panels** — your dashboard layouts and panel configuration are
  stored in a local on-device database.
- **App preferences** — theme, Material You setting, and language.
- **Support details** — the kind of the last connection error and what the
  last hub scan tried (how many addresses, how many brokers found, Wi-Fi or
  Ethernet), kept only until the next successful connection. No addresses or
  names. They leave your device only if you send or copy them yourself from
  Get help or Report a problem. They are not included in Android backups.

- **Shortcuts** — which device each Quick Settings tile controls, which
  device, scene or group each home-screen widget shows, the devices and
  scenes offered to Android's Device Controls and to the widget pickers, and
  the last state each shortcut showed, kept in the app's own storage so the
  tiles, widgets and controls can show them. Android's Quick Settings, home
  screen and Device Controls display these names and states on your phone
  (including, if you allow it in Android's settings, on the lock screen);
  they are not sent anywhere.

This data is never uploaded to the developer. You can remove it at any time by
deleting a connection (which removes its dashboards, panels, and saved password)
or by uninstalling the app.

## Network communication

ZigDash communicates **only** with the MQTT broker(s) you configure, using the
address and credentials you provide. MQTT messages flow directly between your
device and your broker. The developer neither operates an intermediary server
nor receives any of this traffic.

The app requests the **INTERNET** permission to connect to your broker and,
only if you opt in, to send the anonymous usage events described below.

## Anonymous usage data

**Off unless you opt in.** New installs are asked once, with an unticked box on
the first setup screen. People who installed an earlier version are asked once,
on their dashboard. You can change your answer in **Settings › About › Share
anonymous usage data**. Turning it off deletes any events not yet sent and
stops sending immediately. Builds without an analytics key (for example F-Droid
builds, or one you build yourself) send nothing at all.

**Where it goes.** [Aptabase](https://aptabase.com/legal/privacy), EU region.
Data stays in the EU and is kept for up to 5 years.

**What is sent with every event:** the operating system name and version, your
phone's language setting, the ZigDash version and build number, whether it is a
debug build, and a random session ID that changes after an hour of inactivity.
No device ID, advertising ID, account, or install ID is sent. Aptabase's
server sees your IP address in order to receive the event; according to
Aptabase it does not store it, and only uses it with a salt that changes daily,
so visits cannot be linked across days.

**The events.** Every value is chosen from a fixed list in the app's code,
never from anything you typed or anything your broker sent.

| Event | When | Values |
|---|---|---|
| `app_started` | Once each time the app starts | phone or tablet; theme (system, light, dark); Material You on or off; number of homes (0, 1, 2+); number of tiles (0, 1–10, 11–30, 31+); demo or not |
| `setup_step` | Each step of first-run setup | the step (started, scan found, scan empty, needs login, login rejected, failed, review, complete, manual, demo); the type of setup error, if any; number of devices found (0, 1–5, 6–20, 21+) |
| `feature_used` | The first use of a feature in a session | Devices tab, device page, Scenes, Edit mode, Wall display, or tile added (with the kind of tile, such as "light" or "toggle") |
| `help_opened` | Get help was opened | where from: no connection found, a setup error, manual connect, home can't be reached, device list missing, Settings, or the demo |
| `support_contact` | A support request was started from Get help | where from (as above); email or copy |
| `shortcut_added` | A Quick Settings tile was given a device, a home-screen widget was added, or ZigDash's Device Controls were first shown | tile, control, widget, scene widget or group widget |
| `shortcut_used` | A tile, widget or Device Control was used (sent at most once per kind when the app next starts) | tile, control, widget, scene widget or group widget |
| `poll_answer` | The one-time "What should ZigDash do next?" card was answered | notifications, history graphs, kiosk mode or Zigbee groups |

**Never sent:** broker addresses, ports, usernames or passwords; MQTT topics or
messages; device names or addresses; home or dashboard names; device states or
values; error messages.

Because nothing identifies you, the developer cannot find or delete "your"
events on request. To stop sending, turn the switch off.

## Support emails

If you contact support, your email (and the Support details you choose to
include) is used only to help you, is never shared, and is deleted within 6
months after the issue is closed.

## Optional automation

If you create a "schedule" panel, ZigDash publishes the automation configuration
as a retained MQTT message to your own broker, where a flow you run (e.g. on
Node-RED) executes it. This data also stays within your own infrastructure.

## Children

ZigDash is a utility app and is not directed at children.

## Changes to this policy

If this policy changes, the updated version will be published at this URL with a
new effective date.

## Contact

Questions about this policy: **giladtamam1@gmail.com**
