# Broker discovery + guided help — design

**Date:** 2026-05-24
**Status:** Approved (proceed to implementation)

## Problem

Creating a broker connection requires the user to type the MQTT broker's IP
address. The connection form offers no help finding it. New users (running
Zigbee2MQTT in Docker, on a SMLIGHT SMHUB, or trying ZHA) frequently don't know
the IP — the single biggest onboarding friction.

## Goals

1. Let users **find** their broker's IP without leaving the app (auto-scan).
2. **Guide** users whose scan finds nothing, or who are on incompatible stacks
   (ZHA), with accurate per-setup instructions.

## Non-goals

- mDNS/zeroconf discovery (Z2M/Mosquitto don't advertise a standard service).
- Scanning subnets other than the phone's own `/24`.
- Editing/verifying credentials during the scan (only *detect* that auth is
  required).

## Key technical reality

- **Docker Z2M** and **SMHUB** run an MQTT broker → discoverable on the LAN.
- **ZHA** is Home Assistant's native Zigbee integration and has **no MQTT
  broker**. ZigDash cannot connect to a pure ZHA setup; the only fix is to run
  Zigbee2MQTT. Guidance must say this plainly rather than send the user hunting.

## Part A — Auto-scan ("Find brokers")

### Flow
1. Button under the host field: **Find brokers on my network**.
2. Opens a scan sheet. On open:
   - Resolve the phone's IPv4 via `dart:io NetworkInterface.list()` (Wi-Fi
     interface, non-loopback). No new dependency; no runtime permission.
   - Derive candidate hosts for the `/24` (assume `255.255.255.0`): `.1–.254`,
     excluding the phone's own address.
3. Probe each candidate on ports **1883** and **8883** with parallel
   `Socket.connect` (bounded concurrency, ~32 in flight; ~400 ms timeout).
4. For each host with an open port, attempt a short **MQTT CONNECT** (random
   client id, no credentials, 3 s timeout) to:
   - Confirm it's really a broker (CONNACK received, or refused with an
     MQTT-level return code).
   - Detect **auth required**: CONNACK return code `notAuthorized` /
     `badUsernameOrPassword` → needs login.
5. List confirmed brokers as `IP:port` with a **"needs login"** badge when
   applicable. Tap → fill `host`, `port`, and set protocol to `mqtts` for 8883;
   pop the sheet.
6. Empty state: "No brokers found" + a link to the guided help + tips
   (same Wi-Fi network, not guest/VLAN-isolated).

### Components
- `lib/features/connections/discovery/subnet.dart` — **pure**:
  - `String? subnetBaseFromIp(String ip)` → `"192.168.7"` for `192.168.7.42`.
  - `List<String> candidateHosts(String deviceIp)` → `.1–.254` minus self.
- `lib/features/connections/discovery/broker_probe.dart`:
  - `abstract class HostProber { Future<ProbeResult?> probe(String host, int port); }`
  - `ProbeResult { host, port, needsAuth }`.
  - `mqttConnackToAuth(MqttConnectReturnCode) → bool needsAuth` — **pure**, tested.
  - Real implementation: `SocketMqttProber` (TCP connect → MQTT confirm).
- `lib/features/connections/discovery/broker_scan_service.dart`:
  - `Stream<ProbeResult> scan({required String deviceIp, HostProber prober})`
    with bounded concurrency; emits results as found; dedupes by `host:port`.
- `lib/features/connections/discovery/network_info.dart`:
  - `Future<String?> wifiIpv4()` via `NetworkInterface.list()`.
- `lib/features/connections/screens/broker_scan_sheet.dart` — the UI sheet,
  consuming a `StreamProvider` over `broker_scan_service`.

### Testable core (TDD)
- `subnetBaseFromIp` / `candidateHosts`: valid IPs, self-exclusion, malformed
  input → null/empty.
- `mqttConnackToAuth`: accepted → false; notAuthorized/badUsernameOrPassword →
  true; other → false.
- `broker_scan_service` with a **fake prober**: concurrency cap respected,
  results deduped and surfaced.

## Part B — Guided help

- A **How do I find this?** text button under the host field opens a sheet with
  three sections (all strings localized EN/HE):
  - **Zigbee2MQTT in Docker** — broker IP = the IP of the machine running
    Docker (NAS/Pi). Find it in the router's device list, or `hostname -I` /
    `ip addr` on that machine. Port 1883 (Mosquitto). Use the host's LAN IP,
    not `127.0.0.1`, even when Mosquitto is also containerised.
  - **SMLIGHT SMHUB** — broker IP = the hub's IP, from the SMLIGHT web UI
    (Settings → Network) or the router. Port 1883, no auth by default.
  - **ZHA (Home Assistant)** — ⚠️ ZHA has no MQTT broker; ZigDash can't connect
    to it. Switch to Zigbee2MQTT (HA add-on or Docker) to use ZigDash.
  - Footer tip: the phone and the broker must be on the same Wi-Fi/LAN.

## Form wiring

Under the host field, a row with:
- `TextButton.icon(Icons.wifi_find, "Find brokers")` → scan sheet.
- `TextButton("How do I find this?")` → help sheet.

A scan result fills `_host` / `_port` / `_protocol`; the help sheet is
informational only.

## Testing summary

- Unit tests for the pure functions and the scan service (fake prober).
- `flutter analyze` clean; full suite green.
- Manual on-device check: scan finds the real broker (192.168.7.210:1883).

## Risks / mitigations

- **Phone on different subnet/VLAN than broker** → scan finds nothing; guided
  help + tip covers it.
- **Large/slow networks** → bounded concurrency + per-host timeout keep the
  scan a few seconds; show progress and allow cancel.
- **Some brokers refuse anonymous connects abruptly** → treat a TCP-open host
  that returns any MQTT-level CONNACK (even a refusal) as a broker; only drop
  hosts that fail the MQTT handshake entirely.
