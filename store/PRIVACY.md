# ZigDash — Privacy Policy

**Effective date:** the day ZigDash 3.1.6 is published (replaces the policy published with ZigDash 3.1.5)

ZigDash ("the app") is a client for controlling [Zigbee2MQTT](https://www.zigbee2mqtt.io/)
devices through MQTT brokers that **you** configure. This policy explains what
the app does and does not do with your data.

## Summary

ZigDash does **not** collect or share personal data. Your broker settings,
passwords, devices, topics and their values stay on your device. There is no
advertising and no user account.

The developer runs one server, the ZigDash relay. It is used only if you turn
on **Remote control** (part of ZigDash Pro), and it carries your home's data
encrypted, so the developer cannot read it. See
[Remote control](#remote-control-from-31).

Unless you **opt out**, ZigDash sends a short list of **anonymous usage
events** (which setup steps fail, which features get used) to Aptabase, an
analytics service hosted in the EU. New installs see the choice on the first
setup screen before anything is sent, and you can turn it off at any time. See
[Anonymous usage data](#anonymous-usage-data).

## Data stored on your device

All data stays on your device:

- **Connection settings** — the MQTT broker host, port, protocol, and optional
  username you enter.
- **Passwords** — any broker password you enter is stored in the operating
  system's secure storage (Android Keystore / iOS Keychain), not in plain text.
- **Home Assistant sign-in** (from 2.10) — if you connect a home through Home
  Assistant, ZigDash keeps that sign-in (a refresh token from Home Assistant's
  login page, or the long-lived token you pasted) in the same secure storage,
  and uses it only to talk to Home Assistant's MQTT. It acts as your Home
  Assistant user, so that user must be an administrator. Deleting the home
  deletes the sign-in and tells Home Assistant to end it; you can also end it
  any time in Home Assistant under Profile › Security. It is not included in
  Android backups.
- **Dashboards and panels** — your dashboard layouts and panel configuration are
  stored in a local on-device database.
- **App preferences** — theme, Material You setting, and language.
- **Support details** — the kind of the last connection error and what the
  last hub scan tried (how many addresses, how many brokers found, Wi-Fi or
  Ethernet), kept only until the next successful connection. No addresses or
  names. They leave your device only if you send or copy them yourself from
  Get help or Report a problem. They are not included in Android backups.
- **Ask your AI** (from 3.1.5) — where setup is stuck, ZigDash can write up
  what it found for an AI assistant of your choice: how ZigDash connects, your
  answer to where Zigbee2MQTT runs, Wi-Fi or Ethernet, whether a VPN was on,
  the kind of address your phone has (for example "a private address in
  192.168.x"), how many addresses the scan tried, and what stopped setup. No
  addresses, names, usernames or passwords. You see the text first. It leaves
  your device only if you share it to an app or copy it yourself, and then
  that app's own privacy policy applies. ZigDash keeps no copy.

- **Alerts** — your alerts for each Home, the push keys and this phone's
  push address, kept in the app's own storage and, as described under
  Alerts below, as a retained message on your own broker. Not in Android
  backups.
- **Shortcuts** — which device each Quick Settings tile controls, which
  device, scene or group each home-screen widget shows, the devices and
  scenes offered to Android's Device Controls and to the widget pickers, and
  the last state each shortcut showed, kept in the app's own storage so the
  tiles, widgets and controls can show them. Android's Quick Settings, home
  screen and Device Controls display these names and states on your phone
  (including, if you allow it in Android's settings, on the lock screen);
  they are not sent anywhere.

- **Wall display** — per dashboard: the idle screen, the readings it
  shows, the sensors that wake the screen, the night hours and whether
  alarms take over, kept in the app's own storage on that tablet (2.9).

This data is never uploaded to the developer. You can remove it at any time by
deleting a connection (which removes its dashboards, panels, and saved password or Home Assistant sign-in)
or by uninstalling the app.

## Network communication

ZigDash communicates with the MQTT broker(s) you configure, using the
address and credentials you provide. MQTT messages flow directly between your
device and your broker. Only if you turn on Remote control does your hub also
connect to the ZigDash relay, and your phone uses it while you are away; what
passes through it is encrypted (see [Remote control](#remote-control-from-31)).

The app requests the **INTERNET** permission to connect to your broker and,
unless you opt out, to send the anonymous usage events described below. On
Android 17 it also asks for the **local network** permission, which Android
requires for talking to a hub on your home network.

## Alerts

Alerts are off until you set them up for a Home (Settings › Home › Alerts).
When you do:

- **Your hub does the watching.** ZigDash writes your alerts (which devices,
  which conditions, the hours) as a retained message on your own broker, and
  puts ZigDash Engine on your hub (before 3.0, a flow in Node-RED), which
  watches the devices. ZigDash itself never watches in the background and
  runs no server.
- **Notifications reach your phone through Google's push service.** Each one
  is encrypted end to end on your hub (Web Push, RFC 8291) with keys that
  exist only on your phone and your broker, so Google carries the message but
  cannot read it. Google does see that a push was sent to your phone, and
  when. Your phone's push address and the encryption keys are stored in the
  same retained message on your broker, so every phone of the household can
  receive the Home's alerts.
- **Sharing alerts (optional)** sends the alert text (the kind, the device's
  name and the Home's name) to the ntfy server you choose (ntfy.sh unless you
  pick your own) **unencrypted**, for people who follow the Home's link in the
  ntfy app. **Pushover (optional)** sends the same text to Pushover, with the
  Pushover keys you enter, which are kept in the retained message on your
  broker. "Hide device names" leaves the names out on both paths.
- **Recent alerts** (the last 20) are kept retained on your broker by the hub,
  not by any server of ours.

## Anonymous usage data

**On unless you opt out.** New installs see the choice once, as a ticked box
on the first setup screen; untick it to say no. Nothing is sent before you move
past that screen. People who installed an earlier version are asked once, on
their dashboard, and nothing is sent until they answer. You can change your
answer in **Settings › About › Share anonymous usage data**. Turning it off
deletes any events not yet sent and stops sending immediately. Builds without
an analytics key (for example F-Droid builds, or one you build yourself) send
nothing at all.

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
| `app_started` | Once each time the app starts | phone or tablet; theme (system, light, dark); Material You on or off; number of homes (0, 1, 2+); number of tiles (0, 1–10, 11–30, 31+); demo or not; from 2.9.7, how long ago ZigDash was installed on this phone, in ranges (first day, 1 day, 2–7 days, 8–30 days, more than 30 days, or unknown) |
| `setup_step` | Each step of first-run setup | the step (started, scan found, scan empty, needs login, login rejected, failed, review, complete, manual, demo); the type of setup error, if any; number of devices found (0, 1–5, 6–20, 21+); from 2.5, your answer to where Zigbee2MQTT runs, if you gave one (Home Assistant, SMLIGHT hub, Raspberry Pi or Docker, not sure; from 3.1.3 also ZHA, Home Assistant's own Zigbee); and for an empty scan, the kind of hub it saw instead (Home Assistant, Zigbee2MQTT frontend, SMLIGHT hub, or none), how many addresses it tried (0, 1–253, 254–1020, 1021+), whether it widened to the surrounding network, and which private range your phone is in (192.168, 10, 172.16, other); from 2.6.2, also how many addresses answered at all (0, 1–5, 6–20, 21+), whether a VPN was on, and the kind of network (Wi-Fi, Ethernet, other); and for the address check (the address you type on the empty result), only its outcome: a broker found, a hub page found, nothing answered, the name could not be looked up, not a home address, or nothing typed; from 2.7.2, for Test & connect on the broker form, only whether it connected or which step failed (name lookup, connection, MQTT handshake, login), the number of devices found (0, 1–5, 6–20, 21+), and whether the app tidied what you typed (for example a pasted browser link); and when the scan saw Zigbee2MQTT's web page but no broker, only what asking that page found: a broker, a broker that listens only on its own machine, one that didn't answer, or no answer; from 2.9.3, how many addresses answered only to the scan's second, slower look (0, 1–5, 6–20, 21+), and for Test & connect, whether the failure was a .local name, Home Assistant without a broker, or a Home Assistant login; from 2.9.4, when your phone had no home network address, only why: mobile data, no network, or unknown; from 2.9.6, for Test & connect, also whether the failure was an SMLIGHT hub not accepting connections from other devices or a Zigbee2MQTT machine whose broker accepts only local connections; from 2.9.6, on an empty scan, which of its three choices you tapped (no hub yet, Home Assistant, hub on another network); from 2.9.7, that you tapped Remind me tomorrow, and that the app was opened from that reminder; and on the first screen, that you tapped Try the demo home or Which hub to get; from 2.10, for Connect through Home Assistant, only how each try ended (connected, no address, nothing answered, not Home Assistant, certificate not trusted, sign-in cancelled, refused or failed, token refused, not an administrator, no MQTT integration); never the address; from 2.10.2, at the device review, how many devices were ticked in advance (0, 1–5, 6–20, 21+), and that you left the review without creating a dashboard, with how many devices were listed and ticked at that moment; from 2.10.4, when asking Zigbee2MQTT's web page, also whether it named its broker by a name only that machine knows, or whether the page is protected by a token; for Test & connect, the class of the port you typed (1883, 8883, a web port, other) and whether the failure was a Zigbee2MQTT machine whose settings name the broker elsewhere; never the address; from 3.1.3, your answer to where Zigbee2MQTT runs also at the moment you pick it, and that you opened Connect through Home Assistant during setup, and from where: while scanning, the card on an empty result, the note under "I use Home Assistant", Home Assistant found without a broker, the login prompt, or the broker form; and when setup is finished, which way it finished: the scan, Home Assistant sign-in, or the broker form; never the address; from 3.1.5, that you opened the "Ask your AI" write-up on a setup screen and whether you then shared or copied it, with which screen (empty scan, setup failure, broker without Zigbee2MQTT, login, Home Assistant sign-in), and when setup is finished, whether you had shared or copied it first; never the write-up; from 3.1.6, when you press back on the device list, which you chose: create the dashboard, start over, or stay, with how many devices were listed and ticked |
| `feature_used` | The first use of a feature in a session | Devices tab, device page, Scenes, Edit mode, Wall display, tile added (with the kind of tile, such as "light" or "toggle"), history (from 2.7), controlling a device from the app (from 2.9.2, with only the kind of device, such as "light" or "cover"; never which device or what it was set to), or kiosk (with whether a PIN is set, whether Android screen pinning is on, and the dim delay as one of off, 1, 5 or 15 minutes; from 2.9 also what the idle screen shows (dimmed, clock, clock and readings, or black) and whether wake on motion, the night schedule and alarm takeover are on), or, from 3.1.2, a scene created or run from the app (never which scene or what it does) |
| `ha_import` | From 2.8, the import from Home Assistant | the step (the offer after setup accepted or declined, a read that failed, the preview, the import done); for a failed read only why (no address, no token, nothing answered, not Home Assistant, token refused, certificate not trusted, read failed, home not connected); counts in buckets (0, 1–5, 6–20, 21+) of devices, rooms, renamed tiles; from 2.9.7, only whether you signed in on Home Assistant's login page or pasted a token, and how it ended (signed in, cancelled, refused by Home Assistant, failed); never the address or the token and added dashboards; and whether Home Assistant had only ZHA devices. Never the address, the token, or any device or room name |
| `help_opened` | Get help was opened | where from: no connection found, a setup error, manual connect, home can't be reached, device list missing, Settings, or the demo |
| `help_offered` | From 2.9.2: the "ask a person" card was shown after two failed checks on the broker form | where: the broker form |
| `support_contact` | A support request was started from Get help | where from (as above); email or copy |
| `community_opened` | The Telegram community link was opened | where from: Settings, the one-time dashboard card, or the place Get help was opened from (as above) |
| `shortcut_added` | A Quick Settings tile was given a device, a home-screen widget was added, or ZigDash's Device Controls were first shown | tile, control, widget, scene widget or group widget |
| `shortcut_used` | A tile, widget or Device Control was used (sent at most once per kind when the app next starts) | tile, control, widget, scene widget or group widget |
| `poll_answer` | The one-time "What should ZigDash do next?" card was answered | notifications, history graphs, kiosk mode or Zigbee groups |
| `alerts_setup` | A step of setting alerts up | the step (flow installed, flow installed by hand, no Node-RED, phone registered, no Google services, test sent, test failed); the channel (push, ntfy, Pushover) |
| `alert_added` | An alert was added | its kind: leak, smoke, door or window opened, or battery low |
| `alarm_shown` | From 2.9: alarm takeover filled a wall display | only the kind: leak, smoke, gas or carbon monoxide. Never the device or where it is |
| `history_setup` | From 2.7: setting up the history recorder on the hub ended | installed, updated, imported by hand (Node-RED asked for a login), no Node-RED found, or refused; from 2.9.1 also recording on this device instead |
| `engine_setup` | From 3.0: a step of putting ZigDash Engine on the hub | offered, installed, consent shown, given or declined, Zigbee2MQTT too old, failed, removed, started again, seen paused or stopped; which screen it came from (automations, alerts or history); Zigbee2MQTT's version as major.minor only |
| `automation_saved` | From 3.0: an automation was saved | its shape only: the kind of trigger (a device's state, a button, a reading, a clock time or the sun), how many conditions, a scene or a device, whether it turns off again, new or edited, and how many the home has, in ranges. Never a device, a name or a time |
| `pro` | From 2.7, Google Play version only: a step of ZigDash Pro | a locked view was shown, the Pro screen was opened (from 2.9.6), Unlock was tapped, or Pro became unlocked. Nothing about the payment |
| `review_prompt` | From 2.6.5: the app asked Google Play to show its "rate this app" dialog (after a device you control has answered on two different days) | whether the dialog was requested, or could not be because the Play review flow is not available on the device. Nothing about whether you rated, or what |

**Never sent:** broker addresses, ports, usernames or passwords; the address you type into setup; MQTT topics or
messages; device names or addresses; home or dashboard names; device states or
values; error messages.

Because nothing identifies you, the developer cannot find or delete "your"
events on request. To stop sending, turn the switch off.

## Support emails

If you contact support, your email (and the Support details you choose to
include) is used only to help you, is never shared, and is deleted within 6
months after the issue is closed.

## Automations and ZigDash Engine (from 3.0)

If you set up automations, alerts or history, ZigDash installs ZigDash Engine
on your hub: one JavaScript file that Zigbee2MQTT saves in its own data folder
and runs as an extension. ZigDash sends it through your own broker; nothing is
downloaded from anywhere else. ZigDash Engine runs your automations, alerts and
history recorder on your hub, inside your network. Your automations (which
devices, what they do, when), the Home's time zone and, if you use sunrise or
sunset, the name and coordinates of the town you picked from a list built into
the app (never your phone's location) are stored as retained messages on your
own broker, with the last 20 runs. Nothing of it is sent to the developer or
anyone else. On new Zigbee2MQTT installs, ZigDash asks before turning on
Zigbee2MQTT's "Allow external JavaScript" setting and restarting it. Remove
from hub deletes the file; your automations stay on your broker until you
delete them.

## Optional automation panels

If you create a "schedule" or "auto-close" panel, ZigDash publishes its
configuration as a retained MQTT message to your own broker, where a flow you
run (e.g. on Node-RED) executes it. This data also stays within your own
infrastructure. Automations from 3.0 are described above.

## History (from 2.7)

If you set up history, ZigDash puts ZigDash Engine on your own hub (before
3.0, a "ZigDash history" flow in Node-RED) and publishes, as a retained MQTT message on your own broker, the
list of readings shown on your dashboards (device addresses, state topics,
value names and units) and your phone's time zone. ZigDash Engine records those
values every 15 minutes as retained messages on your broker and deletes them
after 30 days. Nothing of it leaves your network: no copy is sent to the
developer or anyone else.

From 2.9.1, if your hub can't record, you can let ZigDash record on one phone or
tablet you choose (Record on this device). While ZigDash is open there, it
does what the hub does: it reads the same values from your broker and
writes the same 15-minute records back to your broker, retained, and
deletes them after 30 days. The choice is stored on that device only.

## Import from Home Assistant (from 2.8)

If you import from Home Assistant, ZigDash connects from your phone to the
Home Assistant address you give, with the access token you paste, and reads
its lists of devices, areas (rooms), floors and the rooms of entities. It
uses them on the phone to name tiles and add dashboards, and stores only
those names and rooms in your dashboards. The token is used for that one
read and is not stored; you can delete it in Home Assistant afterwards.
ZigDash never writes to Home Assistant, and nothing of it leaves your
network: no copy is sent to the developer or anyone else.

## ZigDash Pro (from 2.7)

ZigDash Pro is an optional one-time purchase in the Google Play version.
Google Play handles the payment under Google's privacy policy; ZigDash never
sees your payment details and stores nothing about the purchase on your device:
the app asks Google Play whether Pro was bought. If you turn on Remote control,
the relay keeps a one-way hash of the purchase token, as described there. Versions
from GitHub, IzzyOnDroid and F-Droid contain no billing code and have Pro
unlocked.

## Remote control (from 3.1)

Remote control is off until you turn it on for a Home (Settings › Home ›
Remote control). It is part of ZigDash Pro in the Google Play version. When
you turn it on:

- **How it works.** ZigDash Engine on your hub keeps one connection open to
  the ZigDash relay at relay.zigdash.app, a server the developer runs at
  netcup in Vienna, Austria (EU). Away from home, your phone reaches your hub
  through it. At home, your phone talks to your broker directly, as before.
- **Encrypted end to end.** Your hub and your phones seal every device state
  and every command with a key made on your phone (AES-256-GCM). The key is
  kept only on your hub and your phones, never on the relay. Device and topic
  names are replaced by ids that reveal nothing. The relay sees only the
  sealed data, its size and timing, and whether your hub is online.
- **Checking Pro.** When you turn it on, the app sends the Google Play
  purchase token of your Pro purchase to the relay, and the relay asks Google
  Play whether it is a completed purchase of Pro. The relay keeps only a
  one-way hash (SHA-256) of the token, so the same purchase brings back the
  same Home after a reinstall. It never receives your name, email address or
  payment details.
- **What the relay stores**, for each Home: a random Home ID, the hash of the
  purchase token and when the Home was created; logins for the hub and for up
  to five phones (random user names, with passwords kept only as salted
  hashes, and the date each phone was added); and the latest sealed state of
  each device and whether the hub is online, so a phone sees them at once.
- **Your IP address** reaches the relay while your hub or phone is connected,
  as with any internet connection. It is not stored. The relay keeps no
  connection or access logs, only its own error messages, which are capped
  at a few megabytes and overwritten. To stop abuse, attempts to turn remote
  control on are counted per IP address in memory for one hour.
- **Adding a phone** with the QR code passes the login straight from one of
  your phones to the other. A **key backup** is a file encrypted with your
  passphrase (PBKDF2, AES-256-GCM) that you save where you choose, for
  example Google Drive. Neither the relay nor the developer ever sees it.
- **Turning it off** deletes this phone's login, and your hub deletes all its
  sealed copies and its online flag from the relay. Removing a phone under
  "Phones with remote access" deletes that phone's login. The Home ID, the
  purchase-token hash and the hub's login stay, so you can turn remote
  control on again with the same purchase. Email us to have them deleted
  too; we do so within 30 days.
- **Why we may process it:** to provide the feature you bought (Art. 6(1)(b)
  GDPR). It is shared with no one; only the purchase check goes to Google
  Play, under Google's privacy policy.
- **Fair use.** Remote control is included with Pro while the relay runs, for
  one Home, up to five phones and normal household use. It may change or end
  with notice.

## Your rights

For the data on the relay, you can ask for access, correction, deletion or
a copy, or object, by email (below). Give the Home ID shown in the app, as
the relay holds nothing else that identifies you. You can also complain to a
data protection authority in the EU country where you live.

## The zigdash.app website

The website counts page views with [GoatCounter](https://www.goatcounter.com/help/privacy):
the page address, the site that linked to it, the screen size, the browser
and the country, plus clicks on the Google Play button. It sets no cookies and
stores nothing on your device. GoatCounter does not store your IP address; it
uses it, with the browser, to tell unique visits apart for a few hours. The
app itself sends nothing to GoatCounter.

## Children

ZigDash is a utility app and is not directed at children.

## Changes to this policy

If this policy changes, the updated version will be published at this URL with a
new effective date.

## Contact

The controller for the relay is the developer, Gilad Tamamski, Israel.

Questions about this policy: **giladtamam1@gmail.com**
