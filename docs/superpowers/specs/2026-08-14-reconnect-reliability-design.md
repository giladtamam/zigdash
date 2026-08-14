# Reconnect Reliability and Stale-State UX Design

## Goal

Make ZigDash trustworthy during ordinary MQTT interruptions. Users must be able
to distinguish current values from last-known values, understand when ZigDash
is reconnecting, and recover immediately without accidentally queuing or
silently dropping control actions.

This is the v1.9.1 reliability release. It builds on the existing exponential
backoff, foreground-resume reconnect, subscription restoration, and connection
status providers.

## Scope

The release includes:

- receive timestamps and MQTT connection generations;
- a shared freshness model for panel values;
- one dashboard-wide connection banner;
- individual stale-state treatment for panels;
- disabled control actions while offline or awaiting current state;
- a **Reconnect now** action;
- automated lifecycle, reconnect, freshness, and accessibility coverage; and
- real-broker and manual network-transition verification.

User-initiated diagnostics export, queued commands, connected-state timeouts,
new panel types, widgets, and QR transfer are excluded.

## Product decisions

1. Preserve the last-known value when MQTT disconnects.
2. Mark values stale immediately when the connection leaves `connected`.
3. Never queue control commands for later execution.
4. Disable controls that cannot safely publish.
5. Show one dashboard-wide banner plus an explicit stale marker per affected
   panel.
6. Include **Reconnect now** while automatic reconnect remains active.
7. Remove the dashboard-wide banner as soon as MQTT reconnects.
8. After reconnect, each subscribed panel remains stale until it receives a
   message from the new MQTT connection generation.
9. Do not mark a value stale merely because it has not changed for a fixed
   duration while MQTT remains connected.

## User experience

### Connected

When MQTT is connected and a subscribed panel has received a message during the
current connection generation, the panel appears normally and its controls are
enabled.

Publish-only controls such as buttons and text inputs do not need a current
value. They are enabled whenever MQTT is connected.

### Initial connection

Before the first successful connection, show one dashboard banner:

> **Connecting...**

Panels without a value continue to use their existing loading/unknown state.
Publish actions are disabled.

### Reconnecting after connection loss

When an established connection drops, show:

> **Reconnecting...**  
> Showing last known values  
> **Reconnect now**

Keep the dashboard visible. Every subscribed panel that has a previous value
shows that value with reduced emphasis, a visible **Last known** label, and
disabled control actions. Read-only values remain readable.

Do not show repeated snackbars or one connection error per panel.

### Connection attempt failed

When all endpoint candidates fail, show:

> **Connection failed**  
> Automatic retries will continue  
> **Reconnect now**

Keep last-known values visible and stale. The manual action starts one immediate
attempt and resets the backoff; it does not disable future automatic retries.

### Connected again

Remove the dashboard-wide banner as soon as MQTT establishes a connection.
Publish-only controls become available immediately.

Subscribed panels remain individually marked **Last known** and their controls
remain disabled until each receives a message belonging to the new connection
generation. Panels recover progressively; a quiet sensor cannot keep the
entire dashboard in a warning state.

## Freshness model

### Connection generation

`MqttManager` owns a monotonically increasing connection generation. Increment
it after a candidate establishes MQTT successfully and before restoring wire
subscriptions. Every received message is tagged with the active generation.
The update listener captures that generation when it is attached, so a late
callback from an obsolete client cannot be mislabeled with a newer generation.

The generation exists only for the manager's lifetime. It does not need to be
persisted or globally unique.

### Received messages

`MqttRxMessage` contains:

- MQTT topic;
- payload;
- local receive time; and
- connection generation.

Receive time uses an injectable clock for deterministic tests. It is metadata
for display, diagnostics, and future use; v1.9.1 does not make values stale by
age while connected.

### Panel value snapshot

The panel-value provider returns a snapshot containing:

- the JSON-path-extracted value;
- `receivedAt`;
- message generation; and
- freshness derived from the current MQTT status and generation.

A subscribed panel value is fresh only when:

1. MQTT status is `connected`; and
2. the value's generation equals the manager's current generation.

Any value that fails either condition is last-known/stale. A missing value
remains unknown/loading rather than stale.

### Publish-only controls

Panels without subscribed state do not wait for a current-generation message.
Their actions are available exactly when MQTT status is `connected`.

## Component boundaries

### `MqttManager`

Own connection generation, receive timestamps, status transitions,
resubscription, exponential backoff, and immediate reconnect. It must expose
the current generation alongside the existing status stream.

`reconnectNow()` remains idempotent: it is a no-op when disposed, explicitly
disconnected, already connecting, or already connected. Repeated UI taps must
never create parallel clients.

### Panel value provider

Translate raw MQTT messages into typed value snapshots and combine them with
connection status/current generation. Keep the last snapshot available across
temporary disconnects and connection-generation changes.

### Dashboard connection banner

Watch the existing connection status. Render exactly one banner above the
dashboard grid and invoke `MqttManager.reconnectNow()` from **Reconnect now**.
The banner owns no timers, backoff, or MQTT client lifecycle.

### `PanelTile` reliability boundary

Centralize shared stale behavior in `PanelTile`:

- visible **Last known** marker;
- reduced visual emphasis;
- accessibility semantics;
- suppression of publish interactions; and
- preservation of local edit/options interactions when the dashboard is
  unlocked.

Concrete panel widgets continue to render their panel-specific content. They
receive or watch the freshness/control-enabled state through one shared API
rather than reimplementing connection logic independently.

## Interaction rules

- No user action is queued during disconnection.
- No publish method is called while its control is disabled.
- The existing control-action connection check remains as defense in depth for
  races between rendering and a tap.
- Reconnect taps while a connection attempt is active have no effect.
- Long-press edit/options behavior remains available while offline.
- Local dashboard navigation, editing, backup, and settings remain available
  while MQTT is offline.

## Accessibility and localization

- The dashboard banner is a polite live region and announces meaningful state
  transitions once.
- A stale panel exposes semantics equivalent to: **Bedroom shutter, last known
  value: closed, controls unavailable**.
- Use text/icon semantics in addition to opacity or color.
- Disabled controls remain visually recognizable and meet existing touch-target
  requirements.
- Preserve logical focus order and keep edit/options actions reachable.
- Add strings to every supported locale: English, Hebrew, German, Dutch,
  Swedish, Norwegian Bokmal, and Spanish.
- Verify RTL banner layout and panel badges in Hebrew.

## Error handling

- Initial connection uses `connecting`; loss after a successful connection uses
  `reconnecting`; exhausted attempts use `error`.
- The dashboard emits one status surface. Individual panels do not show
  connection-failure snackbars merely because the broker is offline.
- Unexpected reconnect failures preserve the last-known values and leave
  automatic retry active.
- Subscription restoration must occur once per successful connection and must
  not multiply subscriptions after repeated reconnects.
- Late messages from an obsolete client/generation cannot make a panel fresh.
- Disposing a manager cancels reconnect timers, subscriptions, and late status
  updates as it does today.

## Testing

### MQTT manager unit tests

- Successful connections increment generation exactly once.
- Failed candidates and failed attempts do not increment generation.
- Received messages contain the injected receive time and active generation.
- Disconnect/reconnect resubscribes each active pattern exactly once.
- `reconnectNow()` resets backoff and starts one attempt.
- Repeated `reconnectNow()` calls while connecting create no parallel client.
- Messages from an obsolete client/generation do not become current.
- Dispose cancels pending retries and ignores late callbacks.

### Provider tests

- Unknown/loading to fresh after the first current-generation message.
- Fresh to stale immediately when MQTT leaves `connected`.
- Old value remains stale after MQTT reconnects.
- Stale to fresh only after a message from the new generation.
- JSON-path extraction and receive metadata remain correct.
- Publish-only action availability follows connection status without waiting
  for a value.

### Widget tests

- Initial connecting banner.
- Reconnecting banner, last-known subtitle, and **Reconnect now** action.
- Connection-failed banner while automatic retry remains active.
- No dashboard banner when connected.
- Stale marker and disabled controls on subscribed interactive panels.
- Read-only panels retain visible last-known values.
- Mixed fresh/stale panels during progressive post-reconnect recovery.
- Publish-only controls enable immediately on reconnect.
- Long-press edit/options remains available while offline.
- Deduplicated live-region announcements, semantics, RTL, and focus order.

### Lifecycle tests

- Background/resume invokes immediate reconnect for disconnected live managers.
- Resume while already connected/connecting does not create another client.

### Real-broker integration test

Against a controllable MQTT broker:

1. connect and receive retained panel state;
2. stop the broker and observe `reconnecting`, stale state, and disabled actions;
3. restart the broker;
4. observe automatic reconnection and banner removal;
5. verify subscriptions are restored once;
6. receive new/retained state and observe the panel become fresh; and
7. confirm no duplicate message delivery or queued control publish.

### Manual device matrix

- Disable and restore Wi-Fi.
- Leave the local network and return.
- Switch between the local endpoint and Tailscale fallback.
- Background the app long enough for Android to suspend the socket, then resume.
- Restart Mosquitto/Zigbee2MQTT while the dashboard is open.
- Verify a quiet non-retained sensor remains individually stale without keeping
  the dashboard banner visible.

## Success criteria

- Every previously displayed subscribed value becomes visibly stale as soon as
  MQTT leaves `connected`.
- Offline control taps cannot publish or queue commands.
- Exactly one dashboard connection banner is visible.
- **Reconnect now** starts at most one immediate attempt and automatic retry
  continues afterward.
- The banner disappears on successful MQTT connection.
- Each subscribed panel becomes fresh only after receiving a message from the
  current connection generation.
- Publish-only controls become usable immediately after connection succeeds.
- Resubscription and reconnect cannot produce duplicate message delivery.
- All behavior remains local; no telemetry or diagnostic data is transmitted.

## Out of scope

- Persisting last-known values across app restarts.
- Declaring values stale because of elapsed time while still connected.
- Queuing or replaying commands.
- Automatically publishing `/get` requests for every device.
- User-initiated diagnostics export or detailed logging UI.
- New widgets, charts, alarms, quick-settings controls, or QR sharing.
