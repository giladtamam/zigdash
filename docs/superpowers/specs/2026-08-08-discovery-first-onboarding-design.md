# Discovery-First Onboarding Design

## Goal

Help a first-time ZigDash user with an existing Zigbee2MQTT installation create
a useful dashboard without manually entering an MQTT host, port, or protocol.
When automatic setup cannot finish, every failure must offer a specific,
plain-language recovery action.

The design preserves ZigDash's local-only privacy promise. No analytics,
telemetry, broker details, credentials, device information, or diagnostics leave
the device.

## Audience and supported setups

The flow gives equal treatment to:

- Home Assistant with Zigbee2MQTT;
- standalone Zigbee2MQTT on Raspberry Pi or Linux; and
- SMLIGHT/SMHUB installations.

ZigDash does not ask the user which setup they have unless automatic discovery
fails and setup-specific recovery guidance is needed.

## Product principles

1. Discover before asking users to configure networking.
2. State only facts ZigDash has verified; do not infer the host platform.
3. Reveal technical fields only as a fallback.
4. Preserve valid progress when a later step fails.
5. Recommend a useful starting dashboard while leaving the user in control.
6. Keep all setup, credentials, devices, and diagnostics local.

## First-run journey

### 1. Welcome

Explain that ZigDash controls an existing Zigbee2MQTT home and works locally.
The primary action is **Find my setup**. State that Zigbee2MQTT must already be
running, without presenting MQTT terminology or connection fields.

### 2. Find a connection

Search the local IP network for reachable MQTT endpoints using common MQTT
ports. The screen says **Looking for a connection...** and asks the user to keep
the device on the same local network as the Zigbee2MQTT host.

Show candidates as soon as they appear instead of waiting for the entire scan.
Keep **Enter details manually** available as a quiet secondary action for
experienced users.

### 3. Select a candidate

Display each result as **Possible connection found**, with only verified facts:
address, port, protocol, and reachability. Do not label a result Home Assistant,
Raspberry Pi, SMLIGHT, or Zigbee2MQTT before verification.

When multiple candidates exist, show one selectable card per endpoint. Test one
candidate at a time so failures remain attributable.

### 4. Verify Zigbee2MQTT

Connect to the selected MQTT endpoint and wait for Zigbee2MQTT bridge and device
information. Ask only for username and password when the broker rejects
anonymous access; preserve the detected address, port, and protocol.

The UI may claim Zigbee2MQTT was found only after its MQTT topics have verified
the service. The phone never scans or joins the Zigbee radio network directly.

### 5. Review devices

After verification, show the number of physical Zigbee devices and group each
device with its suggested controls. Preselect supported end devices with useful
controls, including lights, switches, covers, climate controls, buttons, and
meaningful sensors.

Leave coordinator/router diagnostics and duplicate technical entities
unselected under **Other devices**. Show unsupported devices explicitly rather
than silently discarding them.

The primary action states the result, for example **Create dashboard with 12**.
Users can change the selection now or add devices later.

### 6. Create the first dashboard

Create the saved connection, dashboard, and selected panels as one idempotent
operation. A retry must not create duplicates or leave a partially configured
connection.

The completion screen says **Your dashboard is ready**, reports how many local
controls were created, and provides **Open dashboard** as its primary action.
Renaming or rearranging the dashboard is secondary.

## Automatic-discovery failure path

If discovery finds no usable candidate, do not drop the user into a blank MQTT
form. First check local-network conditions and explain the most likely cause.
Then ask **Where does Zigbee2MQTT run?** and offer equal, tailored guidance for
Home Assistant, Raspberry Pi/Linux, and SMLIGHT/SMHUB.

Manual host, port, protocol, and credential entry remains an advanced fallback.
It uses the same diagnostic and verification path as automatically discovered
candidates.

## Architecture

### Setup coordinator

A focused setup coordinator owns this state machine:

`welcome -> scanning -> candidate selection -> authentication -> verification
-> device review -> dashboard creation -> complete`

The UI renders coordinator state and sends user intents. It does not perform
network operations or persist partial setup directly.

### Existing services

- Reuse `BrokerScanService` to produce MQTT candidates.
- Reuse the diagnostic ladder for host reachability, socket access, MQTT
  authentication, Zigbee2MQTT topic verification, and device discovery.
- Reuse the discovery provider to produce physical devices and panel
  suggestions.
- Reuse the existing repositories for connection, dashboard, and panel
  persistence.

### New policies

A recommendation policy decides which panel suggestions are preselected. It is
independent of the preview UI and accepts discovered devices and suggestions as
input.

An error-guidance mapper converts diagnostic failures into localized titles,
explanations, and recovery actions. It contains no widget code.

An idempotent setup-creation operation saves the connection, dashboard, and
panels atomically from the user's approved selection.

## State and data rules

- Candidate identity is address, port, and protocol; merge duplicate scan
  results using that identity.
- Credentials are requested and stored only when required and continue to use
  secure storage.
- Valid values survive retries within the setup session.
- Leaving setup cancels active scans, MQTT clients, subscriptions, and timers.
- Leaving before creation saves no half-configured connection.
- Reopening setup begins from a safe initial state.
- No setup state is uploaded or sent to a developer-controlled service.

## Error handling

Map failures to these distinct user-facing categories:

- **Host unreachable:** check that this device and the Zigbee2MQTT host can
  reach each other on the local network.
- **MQTT port closed:** verify that the broker is running and that the selected
  port/protocol is correct.
- **Authentication required:** request username and password without losing the
  candidate.
- **Authentication rejected:** allow credential correction and retry.
- **MQTT connected, Zigbee2MQTT not detected:** explain that the endpoint may be
  an MQTT broker not used by Zigbee2MQTT; offer another candidate or manual
  help.
- **Zigbee2MQTT detected, no devices received:** explain that no devices were
  published during verification; allow a longer retry or setup-specific help.

Every error offers at least one direct action. Retrying resumes at the failed
stage rather than restarting successful work.

## Accessibility and responsive behavior

- Announce discovery, verification, and completion status changes to screen
  readers without announcing every scanned address.
- Give device-selection rows semantic selected/unselected state and meaningful
  labels.
- Maintain logical keyboard and screen-reader focus order.
- Use large touch targets and never rely on color alone.
- Support RTL and all existing ZigDash locales.
- On narrow phones, render candidates and devices in one column. On tablets,
  widen content or use a master/detail presentation without changing the flow.

## Testing

### Unit tests

- Candidate merging and ordering.
- Setup-coordinator transitions, retry behavior, and resource cancellation.
- Error-to-guidance mapping.
- Device recommendation rules.
- Idempotent setup creation and rollback behavior.

### Widget tests

- Searching, progressive candidate results, multiple candidates, and no-result
  recovery.
- Credential prompts that preserve discovered connection details.
- Each diagnostic failure and its recovery action.
- Device grouping, preselection, unsupported devices, and selection counts.
- Completion and retry states.
- RTL, narrow-phone, tablet, semantics, and focus behavior.

### Integration tests

Extend the existing real-broker guided-connect test through device selection
and first-dashboard creation. Verify that retrying creation does not produce
duplicate connections, dashboards, or panels.

Manually verify discovery and recovery against Home Assistant, standalone
Pi/Linux, and SMLIGHT/SMHUB because automated tests cannot reproduce every
network topology and broker configuration.

## Success criteria

- With a reachable, discoverable Zigbee2MQTT setup, a fresh user can create a
  useful first dashboard without entering host, port, or protocol.
- Authentication adds only the username/password step when required.
- ZigDash never identifies a candidate as Zigbee2MQTT before topic-level
  verification.
- Every supported failure category presents a specific recovery action.
- Retrying cannot create duplicate or partial setup data.
- The app remains telemetry-free and all setup data remains local.

## Out of scope

- Scanning or joining the Zigbee radio network from the phone.
- Installing or configuring Zigbee2MQTT, an MQTT broker, or a Zigbee
  coordinator for the user.
- Cloud-assisted discovery, remote access setup, analytics, or telemetry.
- Automatically inferring that an MQTT host is Home Assistant, Raspberry Pi,
  SMLIGHT, or another platform.
