# Community launch posts — ZigDash

Ready-to-paste copy for the manual (spike) channels. Post these under your
own account; they're written to read as a maintainer sharing work, not an ad.

---

## 1. Reddit — r/selfhosted (primary)

**Title:** I built ZigDash: a Zigbee2MQTT dashboard that builds itself (auto-discovers your devices, MIT, no cloud)

**Body:**

> I got tired of opening the Zigbee2MQTT web UI on my phone every time I
> wanted to close a shutter, so I built ZigDash — an Android dashboard that
> scans your Z2M bridge and creates a panel for every device with one tap.
> No manual topic wiring.
>
> * 16 panel types: covers (open/stop/close + presets), dimmers, toggles,
>   scenes, multi-state, text log, node status, and more
> * Schedules and auto-close rules run on your hub (Node-RED, flows included),
>   so they keep working when your phone is off
> * Any MQTT broker — TCP/TLS/WS/WSS, LAN broker scan, Tailscale remote access
> * Material You, phone + tablet, English + Hebrew (RTL)
> * No cloud, no account, no ads, no analytics. MIT.
>
> Just shipped 1.9.1, which makes connection problems visible: last-known
> values stay on screen with a "stale" badge, and controls that depend on
> live data lock until a fresh value arrives.
>
> Play: https://play.google.com/store/apps/details?id=com.giladtamam.zigdash
> GitHub (APK on releases): https://github.com/giladtamam/zigdash
> F-Droid / IzzyOnDroid: in progress.
>
> Feedback very welcome — which panel or broker feature should I add next?

**Cross-post (adjust intro per sub):** r/homeassistant, r/homeautomation,
r/zigbee. On r/homeassistant add one line: "works alongside Home Assistant —
it's just MQTT, no HA required (or interfered with)."

---

## 2. Home Assistant community — bump the existing thread

Thread: https://community.home-assistant.io/t/android-app-zigdash-free-open-source-material-3-dashboard-for-zigbee2mqtt/1018963

**Reply:**

> What's new in ZigDash 1.9:
> * Connection problems are now visible, not mysterious — last-known values
>   stay on screen with a "last known" badge and dimmed tiles when the broker
>   drops, and controls that depend on live data lock until a fresh value
>   arrives.
> * Guided setup: it finds your Zigbee2MQTT broker on the LAN automatically
>   and walks you through the connection step by step.
> * Auto-close rules (turn a device off N seconds after it turns on) and
>   schedules — both run on your hub via Node-RED, even when the phone is off.
> * 5 new languages: German, Dutch, Swedish, Norwegian, Spanish.
>
> APK is now on GitHub releases for sideloading; F-Droid and IzzyOnDroid are
> in the works. Still no cloud, no account, no ads — MIT.

---

## 3. Zigbee2MQTT Discord — `#dashboards` / showcase

> ZigDash 1.9 is out — the Android dashboard that auto-discovers your Z2M
> devices (one tap per device, no topic wiring). 16 panel types, hub-side
> schedules + auto-close via Node-RED, Tailscale remote access, Material You.
> New in 1.9: stale-value indicators so you can see when a device went quiet.
> MIT, no cloud, no ads. GitHub: https://github.com/giladtamam/zigdash

---

## 4. Awesome lists — honest status

* **awesome-selfhosted**: zigdash is a mobile *client*, not self-hostable
  software, so a listing is likely to be declined on scope. Not worth the PR.
* **awesome-home-assistant** (frenck): the `Dashboards` section is for
  Lovelace frameworks, not standalone Android apps. Doesn't fit.
* **Better bet**: a "Zigbee2MQTT ecosystem" list — ask in the Z2M Discord if
  one exists, or propose zigdash on the Z2M GitHub Discussions "Showcase".
