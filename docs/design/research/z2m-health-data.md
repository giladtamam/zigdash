# Zigbee2MQTT 2.x: device-health data published over MQTT

Researched 2026-09-27 from primary sources only. Z2M source was read at `master` = **2.14.1**
(commit `3c3d8c1a`). Source links are pinned to that commit. Docs links point to zigbee2mqtt.io.

Shorthand used below:
- `SRC` = `https://github.com/Koenkk/zigbee2mqtt/blob/3c3d8c1a71cabb31f1b97ad268681dd3f747ce19`
- `ZHC` = `https://github.com/Koenkk/zigbee-herdsman-converters/blob/401910d972d8443f057f25cc24aa96dfc9427a27`
- `ZH` = `https://github.com/Koenkk/zigbee-herdsman/blob/48809a944f5ff19a5ab2d5b9ed286b9b844e409e`

## 1. Availability

- **Enabling:** set `availability: {enabled: true}` globally. The default is `false`. It can also be set per device: `devices.<ieee>.availability: true` enables it for that device only, and `false` disables it for one device. Per-device timeouts look like `availability: {timeout: 3}`.
  https://www.zigbee2mqtt.io/guide/configuration/device-availability.html
- **Resolution logic (source):** a disabled device always counts as off. Otherwise the per-device `availability` wins if it is set. If not, the global `availability.enabled` applies. A group has availability only if every member device has it.
  `SRC/lib/util/utils.ts#L249-L269`
- **Timeouts (defaults):**
  - `availability.active.timeout` = 10 min. When a device misses it, Z2M pings the device and marks it offline if the ping fails. Other options: `max_jitter` 30000 ms, `backoff: true` (x1.5, x3, x6…), and `pause_on_backoff_gt: 0`.
  - `availability.passive.timeout` = 1500 min (25 h). Passive devices can't be pinged, so they are marked offline as soon as the timeout passes.
  - A "check-in" is any Zigbee message from the device. Timeouts persist across Z2M restarts.
  https://www.zigbee2mqtt.io/guide/configuration/device-availability.html
- **Active vs passive (source):** a device is "active" if it is a Router not on battery, or if its power source is known and is not `Battery`/`Unknown`. Every other device is passive.
  `SRC/lib/extension/availability.ts#L71-L75`
- **2.3.0** changed availability behaviour ("Availability improvements", PR #26811): https://github.com/Koenkk/zigbee2mqtt/releases/tag/2.3.0 , https://github.com/Koenkk/zigbee2mqtt/pull/26811
- **Topic and payload (2.x):** `<base>/<friendly_name>/availability` carries the JSON `{"state":"online"}` or `{"state":"offline"}`. It is published **retained, qos 1**. Z2M publishes it at startup for every enabled entity, and afterwards only when the value changes.
  `SRC/lib/extension/availability.ts#L241-L274`; docs: https://www.zigbee2mqtt.io/guide/configuration/device-availability.html
- **1.x vs 2.x:** 1.x had `advanced.legacy_availability_payload`, which published plain `online`/`offline` strings when set to true. **2.0 removed that option.** The 2.0 settings migration says: "Due to the removal of advanced.legacy_availability_payload, zigbee2mqtt/bridge/state will now always be a JSON object ({"state":"online"} or {"state":"offline"})". 2.x has no legacy string option; the source only ever does `JSON.stringify({state})`.
  `SRC/lib/util/settingsMigration.ts#L308-L312`; https://github.com/Koenkk/zigbee2mqtt/discussions/24198
- **Bridge itself:** `<base>/bridge/state` carries the JSON `{"state":"online"|"offline"}`. It is retained and also set as the MQTT Last Will.
  `SRC/lib/mqtt.ts#L62-L64`, `#L158-L162`
- **When availability is disabled:** nothing is published on `<name>/availability`. The extension always loads, but it skips entities where `isAvailabilityEnabledForEntity` is false (`SRC/lib/extension/availability.ts#L241-L246`). I found no code that clears retained availability messages when the feature is turned off; it only clears them on rename (`#L213-L216`). So **a stale retained `{"state":…}` from a time when availability was on can remain on the broker** (inference from source).
- **Opt-out of retain entirely:** `mqtt.force_disable_retain` (default false) turns off retain for all messages.
  https://www.zigbee2mqtt.io/guide/configuration/all-settings.html (force_disable_retain)

## 2. last_seen

- **Config:** `advanced.last_seen` accepts `disable` | `ISO_8601` | `ISO_8601_local` | `epoch`. The **default is `"disable"`**.
  https://www.zigbee2mqtt.io/guide/configuration/all-settings.html#last-seen ; `SRC/lib/util/settings.ts#L111`
- **Where it appears:** as a `last_seen` key added to the device state payload on `<base>/<friendly_name>`, formatted per the setting. It is added only for devices, and only if a last-seen time exists.
  `SRC/lib/controller.ts#L430-L434`
- **Extra publishes:** when last_seen is enabled, Z2M also publishes the device state whenever herdsman fires `lastSeenChanged`, even if no attribute changed. This makes last_seen tick on every check-in.
  `SRC/lib/util/utils.ts#L295-L307`
- **Retained?** It follows the device state message, and **the device state is not retained by default**. Retain is set per device or group via `retain` (default `false`), and can be set for all devices via `device_options.retain`.
  `SRC/lib/controller.ts#L393-L396`; https://www.zigbee2mqtt.io/guide/configuration/all-settings.html (devices → retain)
- A related option, `advanced.elapsed` (default false), adds `elapsed` = the number of ms since the device's previous message.
  https://www.zigbee2mqtt.io/guide/configuration/all-settings.html#elapsed
- Nothing on `bridge/devices` carries last_seen. It exists only in the state payload, and in the network map, which must be requested.

## 3. Battery

- These are standard exposes in zigbee-herdsman-converters:
  - `battery`: numeric, %, 0–100, category `diagnostic`. Description: "Remaining battery in %, can take up to 24 hours before reported".
  - `battery_low`: binary, true/false. "Indicates if the battery of this device is almost empty."
  - `voltage` (the battery_voltage expose): numeric, **mV**, "Voltage of the battery in millivolts".

  `ZHC/src/lib/exposes.ts#L998-L1010`
- **Name collision:** mains energy meters also expose a `voltage`, but in **V** ("Measured electrical potential value", `ZHC/src/lib/exposes.ts#L1335`). Don't treat every `voltage` as a battery value. Check the expose's unit or description in `bridge/devices → definition.exposes`.
- **Which devices expose which** depends on the device definition. The `battery()` modern extend defaults to `percentage: true`, `voltage: false`, `lowStatus: false`. So `battery` % is the common case, while `voltage` and `battery_low` appear only for certain devices (many Xiaomi/Tuya devices report voltage or low status instead of, or as well as, %).
  `ZHC/src/lib/modernExtend.ts#L392-L404`
- **Reporting frequency:** the default reporting config is `min: 1_HOUR`, `max: MAX`, `change: 10`. `MAX` = 65000 s, about 18 h. So battery % is typically reported every 1–18 h and on 10-unit changes. The expose text says "up to 24 hours".
  `ZHC/src/lib/modernExtend.ts#L400-L401`; `ZHC/src/lib/constants.ts#L7-L17`
- The reliable way to know whether a device has battery data is `bridge/devices[].definition.exposes`, which lists the expose names (`battery`, `battery_low`, `voltage`).

## 4. linkquality

- **Still present in 2.x and on by default.** For every device with a known LQI, `publishEntityState` adds `message.linkquality = device.zh.linkquality`. No setting turns this off; `filtered_attributes` is the only way to strip it.
  `SRC/lib/controller.ts#L436-L439`
- **Range and meaning:** Z2M appends a `linkquality` expose to every device definition: unit `lqi`, 0–255, "Link quality (signal strength)", category diagnostic. It is the LQI of the **last message received** from the device, measured at the neighbour hop that delivered it. It is not an end-to-end path metric.
  `SRC/lib/model/device.ts#L10-L15`, `#L63`
- **What did change (probably what you remembered):**
  - The Home Assistant discovery entity for linkquality is `enabled_by_default: false` (`SRC/lib/extension/homeassistant.ts#L235-L240`). That is an HA-side default only; the MQTT payload still carries the value.
  - In the **network map** response, `links[].linkquality` is marked `@deprecated 3.0` in favour of `lqi` (`SRC/lib/types/api.ts#L322-L326`).

  Neither change affects the device state payload. I found no 2.x release note removing linkquality from state (I searched all 2.x release bodies).

## 5. `bridge/devices` entries

Published **retained** on `<base>/bridge/devices` as a JSON array, and republished on join, leave, rename and similar events. Source: `SRC/lib/extension/bridge.ts#L829-L889`. Docs: https://www.zigbee2mqtt.io/guide/usage/mqtt_topics_and_messages.html#zigbee2mqtt-bridge-devices

| field | values | health use |
|---|---|---|
| `ieee_address`, `friendly_name`, `network_address` | | identity / key into `bridge/health` |
| `type` | `Coordinator` \| `Router` \| `EndDevice` \| `Unknown` \| `GreenPower` (`ZH/src/controller/tstype.ts#L38`) | skip Coordinator; Router vs EndDevice explains expected check-in cadence |
| `power_source` | `Unknown`, `Mains (single phase)`, `Mains (3 phase)`, `Battery`, `DC Source`, `Emergency mains …` (`ZH/src/zspec/zcl/definition/consts.ts#L2-L10`); may be absent | battery vs mains; mirrors Z2M's active/passive rule |
| `interview_state` | `PENDING` \| `IN_PROGRESS` \| `SUCCESSFUL` \| `FAILED` (`ZH/src/controller/model/device.ts#L53-L58`); added in **2.3.0** (#27163) | **`FAILED` = needs attention**; `PENDING`/`IN_PROGRESS` = "setting up" |
| `interview_completed`, `interviewing` | bool; `@deprecated`, derived from `interview_state` | fallback for Z2M < 2.3 |
| `supported` | bool; `true` for Coordinator or a non-`generated` definition (`SRC/lib/model/device.ts#L37-L39`) | `false` = "unsupported / generic" (limited exposes) |
| `disabled` | bool (`devices.x.disabled`) | disabled devices get no availability; show as disabled, not offline |
| `definition` | object `{source: native\|generated\|external, model, vendor, description, exposes, supports_ota, options, icon}`; **omitted** when no definition is resolved (e.g. not yet interviewed). The docs describe it as "null if unsupported". The source returns `undefined`, so the key is dropped from the JSON, and unsupported-but-interviewed devices usually have `source: "generated"` with `supported: false` | `definition.exposes` tells which health fields (battery, battery_low, voltage) to expect |
| `model_id`, `manufacturer`, `software_build_id`, `date_code`, `description`, `endpoints` | | informational |

The `definition.source` field was added in **2.6.0** (#28076). Release notes: https://github.com/Koenkk/zigbee2mqtt/releases

## 6. `bridge/info` → config

- `bridge/info` is **retained**. Its payload contains `config`, which is the full settings object deep-copied, with `advanced.network_key`, `mqtt.password` and `frontend.auth_token` deleted. It also contains `config_schema`.
  `SRC/lib/extension/bridge.ts#L794-L826`; https://www.zigbee2mqtt.io/guide/usage/mqtt_topics_and_messages.html#zigbee2mqtt-bridge-info
- So yes, a client can read:
  - `config.availability.enabled`, plus `.active.timeout` and `.passive.timeout`
  - `config.advanced.last_seen`, which is `"disable"` or a format name
  - `config.devices[<ieee>].availability`, `.retain` and `.disabled` for per-device overrides
  - `config.device_options.retain`
  - `config.mqtt.force_disable_retain`
  - `config.health.interval`
- Z2M republishes it when settings change.
- Caveat: `settings.get()` returns merged settings with defaults applied. So `availability.enabled` and `advanced.last_seen` should be present even when the user never set them. This is an inference from `settings.ts` defaults, not verified on a live bridge.

## 7. `bridge/health` (new in 2.5.0)

- Added in **2.5.0** ("New health extension & extras in `bridge/info`", #27164). It is always on and has no enable flag.
  https://github.com/Koenkk/zigbee2mqtt/releases/tag/2.5.0 ; `SRC/lib/controller.ts#L82`
- Z2M publishes **retained, qos 1** on `<base>/bridge/health` every `health.interval` minutes (default 10). The first publish comes one interval after startup, not immediately.
  `SRC/lib/extension/health.ts#L19`, `#L76`
- **Payload:**
  - `response_time` (ms epoch)
  - `os {load_average[3], memory_used_mb, memory_percent}`
  - `process {uptime_sec, memory_used_mb, memory_percent}`
  - `mqtt {connected, queued, published, received}`
  - `devices { "<ieee>": {messages, messages_per_sec, leave_count, network_address_changes} }`

  Stats count since Z2M start, or since the last check if `health.reset_on_check: true`. `devices` holds only devices that had events since then.
  https://www.zigbee2mqtt.io/guide/usage/health.html ; `SRC/lib/extension/health.ts#L38-L70`
- There is also the request/response pair `bridge/request/health_check` → `{"healthy": true}`. It is a liveness ping only, and it needs a publish, which a read-only app can't do.
  `SRC/lib/extension/bridge.ts#L287-L289`

## Implications for a read-only health list

1. **Retained data you can rely on at connect:**
   - `bridge/devices`: type, power_source, interview_state, supported, disabled, exposes
   - `bridge/info`: whether availability and last_seen are on, plus timeouts
   - `bridge/state`
   - `<name>/availability`, when enabled
   - `bridge/health`, on 2.5+ (per-device `leave_count` and `network_address_changes` are useful "flaky" signals)
2. **Not retained by default:** the device state, meaning `battery`, `battery_low`, `voltage`, `linkquality` and `last_seen`. A freshly connected phone sees these only when a device next reports, which for battery can take hours. The exception is devices or `device_options` with `retain: true`, which `bridge/info.config` reveals. The UI needs an "unknown / not yet reported" state and should not read a missing value as bad.
3. **Availability is off by default.** Read `config.availability.enabled` and the per-device overrides. If availability is off for a device, show no online/offline status, and ignore any retained `/availability` message for that device, since it may be stale.
4. **Parse availability as JSON `{"state":…}`** on 2.x. Also tolerate the plain `online`/`offline` strings that 1.x brokers may still have retained.
5. **"Needs attention" candidates:**
   - availability `offline`
   - `interview_state == FAILED`, or `interview_completed == false` on older versions
   - `battery_low == true`, or `battery` below a threshold
   - `supported == false` (informational)
   - rising `leave_count` in `bridge/health`
   - a stale `last_seen`, but only when last_seen is enabled, and judged against the active (10 min) or passive (25 h) timeout
6. **LQI is a weak signal.** It is the last-hop link quality of the last message. Show it as secondary info, not as a health verdict.
7. **Battery `voltage` is mV;** mains meters' `voltage` is V. Use the expose unit from `definition.exposes` to decide.
