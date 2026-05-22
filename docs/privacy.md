---
title: ZigDash — Privacy Policy
---

# ZigDash — Privacy Policy

**Effective date:** 22 May 2026

ZigDash ("the app") is a client for controlling [Zigbee2MQTT](https://www.zigbee2mqtt.io/)
devices through MQTT brokers that **you** configure. This policy explains what
the app does and does not do with your data.

## Summary

ZigDash does **not** collect, transmit, or share any personal data with the
developer or any third party. There are no analytics, no advertising, no
tracking, and no user accounts. The app has no backend server operated by the
developer.

## Data stored on your device

All data stays on your device:

- **Connection settings** — the MQTT broker host, port, protocol, and optional
  username you enter.
- **Passwords** — any broker password you enter is stored in the operating
  system's secure storage (Android Keystore / iOS Keychain), not in plain text.
- **Dashboards and panels** — your dashboard layouts and panel configuration are
  stored in a local on-device database.
- **App preferences** — theme, Material You setting, and language.

This data is never uploaded to the developer. You can remove it at any time by
deleting a connection (which removes its dashboards, panels, and saved password)
or by uninstalling the app.

## Network communication

ZigDash communicates **only** with the MQTT broker(s) you configure, using the
address and credentials you provide. MQTT messages flow directly between your
device and your broker. The developer neither operates an intermediary server
nor receives any of this traffic.

The app requests the **INTERNET** permission solely to connect to your broker.

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
