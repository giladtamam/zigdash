# Local-first Remote Access via Tailscale — Design

**Date:** 2026-05-22
**Status:** Approved (brainstorm) → ready for implementation plan

## Problem

ZigDash connects the phone directly to an MQTT broker over the LAN (e.g. the
always-on SMHUB at `192.168.7.210:1883`). When the phone leaves the home network
(cellular / another Wi-Fi), that private address is unreachable, so the user
loses all control of the smart home.

## Goal

Make a connection work **local-first**: use the LAN address directly when home
(full speed, no VPN dependency), and **fall back to a Tailscale address** when
away — automatically, with no manual toggling. The remote leg is encrypted by
Tailscale (WireGuard), so the plaintext-MQTT broker is unchanged.

This is a reusable feature for all ZigDash users, not only the author's SMHUB.

## Chosen approach

Per connection, an optional **remote host** (a Tailscale MagicDNS name, e.g.
`smhub.tailnet.ts.net`) that reuses the connection's existing port, protocol,
username, and password. On connect, ZigDash tries the **LAN host first** with a
short probe timeout; if it fails (the user is away), it tries the **remote
host**. If no remote host is set, behavior is identical to today.

Rejected alternatives:
- **MagicDNS single host (zero code):** point the existing `host` at the
  Tailscale name. Works, but home traffic still rides the Tailscale interface and
  the phone's Tailscale must always be ON or *all* access is lost — not truly
  local-first.
- **Manual Home/Away toggle / two connections:** simplest logic but manual and
  easy to forget.

## Current state (code touchpoints)

- `lib/data/database/tables/connections.dart` — `Connections` Drift table; columns
  `id, name, host, port, protocol (MqttProtocol{tcp,tcpSsl,ws,wss}), username,
  keepAliveSeconds, autoConnect, homeDashboardId, createdAt, updatedAt`.
- `lib/mqtt/broker_config.dart` — `BrokerConfig {id, host, port, protocol,
  username, keepAliveSeconds, ...}` (the value object handed to the MQTT layer).
- `lib/mqtt/mqtt_manager.dart` — owns connect/disconnect; current single-host
  connect with a 5 s connect timeout, MQTT 3.1, defensive `_disposed` guards.
- `lib/mqtt/client_factory*.dart` — builds `MqttServerClient` (mobile) /
  `MqttBrowserClient` (web) from host/port/protocol.
- `lib/features/connections/screens/connection_form_screen.dart` — add/edit form.
- `lib/features/connections/widgets/status_badge.dart` — connection status chip
  (already localized: `statusConnected/Connecting/...`).
- `lib/data/repositories/connection_repo.dart` — persistence; passwords live in
  secure storage keyed by connection id (unchanged here).
- l10n: `lib/l10n/app_en.arb` + `app_he.arb` (+ generated `app_localizations*`).

## Design

### 1. Data model
- Add a nullable column `remoteHost TEXT?` to the `Connections` table.
- Drift schema version bump (current **v3** → **v4**) with a migration that
  `ALTER TABLE`-adds the column (Drift `m.addColumn`). Existing rows get `null`
  → unchanged behavior.
- Add `String? remoteHost` to `BrokerConfig` and thread it through the repo
  mapping and the form.
- Port / protocol / username / password are **shared**; there is no separate
  remote port/protocol/credentials (per the chosen approach).

### 2. Connection logic (local-first fallback)
- Introduce a pure helper that builds an ordered **endpoint candidate list** from
  a `BrokerConfig`:
  - `[host]` when `remoteHost` is null/empty.
  - `[host, remoteHost]` when `remoteHost` is set (LAN first).
- `MqttManager.connect()` iterates candidates:
  - Candidate 1 (LAN): attempt with a **short probe timeout (~3 s)**.
  - On failure (timeout / connection refused / unreachable): attempt the next
    candidate with the normal connect timeout (~5 s).
  - Record which endpoint succeeded as `activeEndpoint` (enum: `local | remote`),
    exposed alongside `MqttStatus`.
- On an unexpected disconnect, the reconnect path restarts the sequence from the
  **LAN host** so the app re-prefers local when the user returns home.
- Keep the existing `_disposed` guards, short client id, MQTT 3.1 settings, and
  UTF-8 publish fix intact. The candidate loop wraps the existing single-endpoint
  connect rather than replacing its internals.

### 3. UI
- `connection_form_screen.dart`: under the **Advanced** expander, add an optional
  **"Remote host (Tailscale)"** text field with helper text
  (e.g. "Used automatically when the local host can't be reached, e.g.
  `smhub.tailnet.ts.net`"). Relabel the existing host field **"Local host"**.
  No new validators beyond trimming (empty → null).
- `status_badge.dart`: when connected via the remote endpoint, render
  **"Connected · Remote"**; via LAN, the existing "Connected". New ARB keys
  (`statusConnectedRemote`, and a relabel key for the form), EN + HE.

### 4. Tailscale infrastructure (SMHUB + phone) — documented, part of deliverable
A short setup doc (e.g. `docs/tailscale-remote.md`) covering:
- Install Tailscale on the SMHUB (Linux): `curl -fsSL https://tailscale.com/install.sh | sh`
  then `sudo tailscale up`; enable **MagicDNS** in the admin console; note the
  device name → `smhub.tailnet.ts.net`.
- Install Tailscale on the phone, sign into the same tailnet, leave it running.
- (Optional) ACL/tag note to restrict who can reach the SMHUB.
- In ZigDash, set the connection's **Remote host** to the MagicDNS name. The
  broker already listens on `0.0.0.0:1883`, so no Mosquitto change is needed.

### 5. Security
- LAN leg: plaintext MQTT on the home network (unchanged from today).
- Remote leg: encrypted end-to-end by Tailscale (WireGuard); the broker stays
  no-auth/no-TLS. Documented as a known, accepted trade-off. No TLS work here.

## Testing

- **Unit:**
  - Endpoint-candidate builder: host-only → `[host]`; host+remote → `[host, remote]`;
    empty/whitespace remote → treated as null.
  - Fallback selector: LAN reachable → `local`; LAN fails → `remote`; no remote →
    no fallback (single attempt, failure surfaces as today).
- **Widget:**
  - Form round-trips `remoteHost` (save/load, empty → null).
  - Status badge shows "Connected · Remote" vs "Connected" per `activeEndpoint`,
    in EN and HE.
- **Manual (real device, REQUIRED before claiming done):**
  - At home: connects via LAN (`activeEndpoint == local`).
  - Wi-Fi off / cellular with Tailscale up: connects via remote
    (`activeEndpoint == remote`); a panel toggle controls a real device.

## Out of scope (YAGNI)
- Separate remote port/protocol/credentials.
- Manual home/away override toggle.
- Broker TLS/auth changes.
- Bundling/managing Tailscale from inside the app (it's a separate, user-installed
  service).
