# Community posts — ZigDash (refreshed 2026-09-26 for 1.9.2)

Ready-to-paste copy for the manual channels. Post under your own account; the
copy is written as a maintainer sharing work, not an ad. Facts below are true
as of 1.9.2 (in Play review). Do not claim the strict-broker connection fix
until 1.9.3 is live.

Status line to reuse everywhere: **F-Droid / IzzyOnDroid: in progress.**

---

## 1. Zigbee2MQTT GitHub Discussions — Show and tell (primary, new)

https://github.com/Koenkk/zigbee2mqtt/discussions (category: Show and tell)

**Title:** ZigDash: an open-source Android dashboard that builds itself from your Zigbee2MQTT devices

**Body:**

> I built ZigDash because I wanted to close a shutter from my phone without
> opening the Zigbee2MQTT frontend every time. It is a native Android app that
> connects straight to your MQTT broker, scans the Z2M bridge, and creates a
> panel for every device with one tap. No cloud, no account, no analytics, MIT.
>
> * 16 panel types: covers (open/stop/close + position presets), dimmers,
>   toggles, multi-state, scenes, node status, text log, progress, and more
> * Guided setup: finds your broker on the LAN and walks through the
>   connection step by step, with plain-language fixes when something fails
> * Schedules and auto-close rules run hub-side via Node-RED (flows included),
>   so they keep working when the phone is off
> * Any broker: TCP, TLS, WebSocket, WSS. Tailscale for remote access
> * Phone and tablet, light and dark, Material You. Eight languages: English,
>   French, German, Spanish, Dutch, Swedish, Norwegian, Hebrew (RTL)
>
> It complements the Z2M frontend rather than replacing it: the frontend is
> still where you pair and configure, ZigDash is the thing on the wall or in
> your pocket for day-to-day control.
>
> Play: https://play.google.com/store/apps/details?id=com.giladtamam.zigdash
> Source and APK: https://github.com/giladtamam/zigdash
> F-Droid / IzzyOnDroid: in progress.
>
> Which panel type or broker feature is missing for your setup? That is what
> drives the next release.

---

## 2. Reddit

### r/Zigbee2MQTT (new)

**Title:** Open-source Android dashboard that auto-discovers your Zigbee2MQTT devices (MIT, no cloud)

> Maintainer here. ZigDash scans your Z2M bridge and makes a panel per device
> in one tap, then talks MQTT directly to your broker. Covers, dimmers,
> scenes, sensors, node status. Hub-side schedules and auto-close rules via
> Node-RED. Works on phones and tablets, eight languages, no account and no
> analytics.
>
> Play: https://play.google.com/store/apps/details?id=com.giladtamam.zigdash
> GitHub (APK on releases): https://github.com/giladtamam/zigdash
>
> Happy to answer questions about the MQTT side. Feature requests welcome.

### r/selfhosted

**Title:** I built ZigDash: a Zigbee2MQTT dashboard that builds itself (auto-discovers your devices, MIT, no cloud)

> I got tired of opening the Zigbee2MQTT web UI on my phone every time I
> wanted to close a shutter, so I built ZigDash, an Android dashboard that
> scans your Z2M bridge and creates a panel for every device with one tap.
>
> * 16 panel types: covers with presets, dimmers, toggles, scenes, multi-state,
>   text log, node status, and more
> * Schedules and auto-close rules run on your hub (Node-RED, flows included),
>   so they keep working when your phone is off
> * Any MQTT broker: TCP/TLS/WS/WSS, LAN broker scan, Tailscale remote access
> * Phone and tablet, Material You, eight languages including French, German,
>   Spanish and Hebrew (RTL)
> * No cloud, no account, no ads, no analytics. MIT.
>
> Play: https://play.google.com/store/apps/details?id=com.giladtamam.zigdash
> GitHub (APK on releases): https://github.com/giladtamam/zigdash
> F-Droid / IzzyOnDroid: in progress.
>
> Feedback very welcome. Which panel or broker feature should I add next?

### Cross-posts

r/homeassistant and r/homeautomation: same body. On r/homeassistant add one
line up top: "Works alongside Home Assistant. It is just MQTT, no HA
dependency and nothing changes in HA."

French-speaking users are the largest install country right now. If you post
in r/domotique, lead with: "L'application est désormais disponible en
français."

---

## 3. Home Assistant Community — bump the existing thread

Thread: https://community.home-assistant.io/t/android-app-zigdash-free-open-source-material-3-dashboard-for-zigbee2mqtt/1018963

**Reply:**

> ZigDash 1.9.2 is rolling out. What changed since the last update here:
> * Eight languages now: English, French, German, Spanish, Dutch, Swedish,
>   Norwegian and Hebrew, with automatic RTL
> * Tablet layouts for wall-mounted use, light and dark
> * Guided setup that finds your broker on the LAN and explains failures in
>   plain language
> * Connection problems are visible instead of mysterious: last-known values
>   stay on screen with a badge, and live-dependent controls lock until the
>   broker is back
> * Still no cloud, no account, no ads, no analytics. MIT.
>
> APK is on GitHub releases for sideloading; F-Droid and IzzyOnDroid are in
> progress. Feedback and feature requests welcome.

---

## 4. Zigbee2MQTT Discord — showcase channel

> ZigDash 1.9.2: the open-source Android dashboard that auto-discovers your
> Z2M devices (one tap per device, no topic wiring). 16 panel types, hub-side
> schedules and auto-close via Node-RED, Tailscale remote access, tablets,
> eight languages. MIT, no cloud, no analytics.
> https://github.com/giladtamam/zigdash

---

## 5. SMLIGHT — email asking for a mention

To: SMLIGHT support / community contact (find the current address on
https://smlight.tech; the community forum or Telegram admin also works).

**Subject:** ZigDash: free open-source Android dashboard built around Zigbee2MQTT on SMHUB

> Hello,
>
> I am the author of ZigDash, a free, open-source (MIT) Android app for
> controlling a Zigbee2MQTT home directly over MQTT. A lot of ZigDash users run
> Zigbee2MQTT on SMLIGHT hardware, and the app was built with the SMHUB in
> mind: it discovers the hub's broker on the LAN, the in-app help explains
> where to find the broker settings in the SMLIGHT web UI, and it ships
> Node-RED flows for hub-side schedules and auto-close rules so automations
> keep running when the phone is off.
>
> I would like to ask whether you would consider mentioning ZigDash as a
> companion app in your documentation, community, or "works with" material.
> There is nothing commercial in it: no ads, no account, no analytics, and the
> code is public.
>
> Play: https://play.google.com/store/apps/details?id=com.giladtamam.zigdash
> Source: https://github.com/giladtamam/zigdash
>
> If there is anything you would like changed or added for SMLIGHT users, I am
> glad to do it.
>
> Best regards,
> Gilad Tamam

---

## 6. Awesome lists — honest status

* **awesome-selfhosted**: ZigDash is a mobile client, not self-hostable
  software, so a listing is likely to be declined on scope. Not worth the PR.
* **awesome-home-assistant**: the Dashboards section is for Lovelace
  frameworks, not standalone Android apps. Does not fit.
* **awesome-mqtt** (hobbyquaker): has a "Mobile apps" section for MQTT
  clients. ZigDash qualifies. One-line PR.
* **Zigbee2MQTT ecosystem**: no dedicated awesome list found; the Discussions
  Show-and-tell post above is the equivalent.
