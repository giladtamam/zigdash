# wayfinder:research — Classify Zigbee2MQTT devices from their exposes

> Ticket: "Classify Zigbee2MQTT devices from their exposes" on the 1.12 Dashboard design map; applied in [dashboard-1.12.md](../dashboard-1.12.md)
> Run 2026-09-26 against the Zigbee2MQTT 2.x docs, a read-only websocket capture of the user's SMHUB (Z2M 2.13.0, converters 26.90.0, `ws://192.168.68.55:8080/api`, nothing sent), and the current discovery code. **FACT** = quoted from a doc URL or the captured payload; **INFERENCE** = derived design rule.

## Answer

Classify on the **composite type** first (`light`, `cover`, `switch`, from `bridge/devices[].definition.exposes`), then on **exact `property` names** of top-level binary and numeric exposes (`water_leak`/`smoke`/`gas`, `contact`, `occupancy`/`presence`, `temperature`/`humidity`), and ignore every expose whose `category` is `config` or `diagnostic` when choosing a class. A light is a *color light* when its features include a `color_xy` or `color_hs` composite. Read values from the device state topic `<base>/<friendly_name>` using each feature's `property` (which carries the endpoint suffix, for example `state_l1`), send commands as JSON to `<base>/<friendly_name>/set`, and trust the `access` bits (1 = in state, 2 = settable, 4 = gettable) over the class when deciding whether a control is interactive. On the user's hub the bulbs expose only `color_xy` but report `color: {hue, saturation}` with `color_mode: "color_temp"`. So a tile must read whichever color keys actually arrive, not the keys the exposes promise. Today's code gives a light a brightness slider only and never shows a numeric reading. It also drops the endpoint, the category and nested color features.

## Protocol facts the table relies on

- FACT: access is a bitmask. "Bit 1: property appears in published state; Bit 2: settable via `/set`; Bit 3: retrievable via `/get`." Examples: 1 read-only, 2 write-only, 5 read/get, 7 all. ([exposes](https://www.zigbee2mqtt.io/guide/usage/exposes.html))
- FACT: generic types are binary (`value_on`, `value_off`, optional `value_toggle`), numeric (`value_min`/`value_max`/`value_step`/`unit`/`presets`), enum (`values`), text, composite (`features`) and list. Specific types are light, switch, fan, cover, lock and climate, each with `features`. (same)
- FACT: "When a device exposes capabilities on specific endpoints, the `endpoint` field is included. The property becomes formatted as `name_endpoint` (e.g., `state_l1`)." (same)
- FACT: `category` is `config` (settings), `diagnostic` (read-only diagnostics) or absent (normal use). (same)
- FACT: the state topic is `zigbee2mqtt/FRIENDLY_NAME` and its payloads are "always in a JSON format". `.../set` takes JSON such as `{"state":"ON","brightness":255,"color_temp":325,"color":{"x":0.123,"y":0.123}}`. Per-attribute `.../set/state` with the raw payload `ON` equals `{"state":"ON"}`. `.../get` takes `{"state": ""}`. ([MQTT topics](https://www.zigbee2mqtt.io/guide/usage/mqtt_topics_and_messages.html))
- FACT: availability is **disabled by default**. When it is enabled, Z2M publishes a retained `zigbee2mqtt/FRIENDLY_NAME/availability` with `{"state":"online"}` or `{"state":"offline"}`. The timeouts are 10 min for mains-powered (active) devices and 1500 min for battery-powered (passive) ones. ([availability](https://www.zigbee2mqtt.io/guide/configuration/device-availability.html)) Captured: this hub has `availability.enabled: false` and `last_seen: "disable"`.

## Class table

| Class | Detection rule (from exposes) | Required properties | Optional properties | Command topic and payload | Notes and edge cases |
|---|---|---|---|---|---|
| **Color light** | `type:"light"` whose features include a composite named `color_xy` or `color_hs` (both have `property:"color"`) | `state` (binary, access has 2) | `brightness` (numeric; `value_max` is usually 254), `color_temp` (mired, with `value_min`/`value_max` and `presets`), `color`, `color_mode`, `linkquality` | `/set` `{"state":"ON\|OFF\|TOGGLE"}`, `{"brightness":N}`, `{"color_temp":N}`, `{"color":{"x":X,"y":Y}}` or `{"color":{"hue":H,"saturation":S}}` (FACT, [9290022166](https://www.zigbee2mqtt.io/devices/9290022166.html)). `{"color":{"hex":"#547CFF"}}` and `{"color":{"r":..,"g":..,"b":..}}` are also accepted (FACT, [CK-BL702-AL-01](https://www.zigbee2mqtt.io/devices/CK-BL702-AL-01.html)). | Send the xy form when only `color_xy` is exposed and hs only when `color_hs` is exposed. INFERENCE: hex is the safe cross-device form for a picker. Read the displayed color from `color_mode` (see edge cases). |
| **Light** | `type:"light"` with no color composite | `state` | `brightness`, `color_temp` (tunable white), `linkquality` | `/set` `{"state":..}`, `{"brightness":N}`, `{"color_temp":N}`. Optional `"transition":secs` (FACT, CK-BL702 page). | The quick action is a toggle using `value_toggle` (`TOGGLE`). If the light has no `brightness` feature it is on/off only, and the tile hides the slider. |
| **Switch / plug** | `type:"switch"` composite, **or** a top-level binary `state` with access containing 2 (the current code's `hasBinaryState`) | the composite's `state` feature `property`, which may be `state_l1` | `power` (W), `energy` (kWh), `voltage`, `current` as numeric readings with no category (INFERENCE); `linkquality` | `/set` `{"<property>":"ON\|OFF\|TOGGLE"}` using `value_on`/`value_off`/`value_toggle` from the expose | A device with N `switch` composites that each carry `endpoint` becomes N toggles in one tile, or N tiles (see edge cases). TS0002 uses `state_l1`/`state_l2` ([TS0002](https://www.zigbee2mqtt.io/devices/TS0002.html)); TS0012 uses `state_left`/`state_right` ([TS0012](https://www.zigbee2mqtt.io/devices/TS0012.html)). |
| **Cover / blind** | `type:"cover"` | `state` (settable enum or binary) | `position` 0–100, `tilt` 0–100, `moving`, `linkquality` | `/set` `{"state":"OPEN\|CLOSE\|STOP"}`, `{"position":N}` (FACT, [TS130F](https://www.zigbee2mqtt.io/devices/TS130F.html)) | `invert_cover` swaps open=100 and close=0 ("false: open=100,close=0"). Whether `position` is readable depends on the device, so check the `access` bits on `position` before drawing the current position. With no position, the tile shows only open, stop and close. |
| **Leak / smoke** | a top-level binary with `property` in {`water_leak`, `smoke`, `gas`}, no category, access 1 or 5 (`gas` is INFERENCE) | that property (true = alarm) | `battery` (%), `battery_low`, `tamper`, `voltage` (mV), `device_temperature` | none (read-only) | FACT: water_leak true = "detected a water leak" ([SJCGQ11LM](https://www.zigbee2mqtt.io/devices/SJCGQ11LM.html)). FACT: smoke is read-only on [TS0205](https://www.zigbee2mqtt.io/devices/TS0205.html). Compare against `value_on` rather than assuming `true`. |
| **Contact / door** | a top-level binary with `property:"contact"` | `contact` | `battery`, `battery_low`, `voltage`, `device_temperature` | none | FACT: "Indicates if the contact is closed (= true) or open (= false)" ([MCCGQ11LM](https://www.zigbee2mqtt.io/devices/MCCGQ11LM.html)). The UI inverts it: `false` shows as **Open**. |
| **Motion / occupancy** | a top-level binary with `property` in {`occupancy`, `presence`} (`presence` is INFERENCE) | that property | `illuminance` (lx), `battery`, and `last_seen` only if the hub has last_seen enabled | none | FACT: occupancy cannot be read with `/get` or written with `/set`, and it returns to false after the `occupancy_timeout` option ([RTCGQ11LM](https://www.zigbee2mqtt.io/devices/RTCGQ11LM.html)). `illuminance` is an optional reading, not a class. |
| **Climate sensor** | a numeric with `property` exactly `temperature` or `humidity`, no category, no `climate` composite | at least one of `temperature` (°C), `humidity` (%) | `pressure` (hPa), `battery`, `voltage` | none | FACT: units °C, %, hPa, read-only ([WSDCGQ11LM](https://www.zigbee2mqtt.io/devices/WSDCGQ11LM.html)). `device_temperature` (on contact and leak sensors) must **not** match. A `climate` composite (TRV) is out of scope for 1.12 and goes to generic. |
| **Generic fallback** | anything else | none | every expose with no `category` and access containing 1 is listed as a reading (value plus `unit`); the first one with no category and access containing 2 that is a binary becomes the quick action | `/set` `{"<property>":value}` | INFERENCE: hide `config` and `diagnostic` exposes behind "More". Never offer a write-only (access 2 without 1) enum such as `effect` as a stateful control. |

## Precedence when a device matches several classes (INFERENCE)

1. Composite kind wins over sensor properties: **light (color before plain) > cover > switch**. A light never also becomes a switch, even though its `state` feature is a binary named `state`.
2. Then binary sensor properties, most urgent first: **leak/smoke/gas > contact > motion/occupancy**.
3. Then **climate** by numeric `temperature`/`humidity`.
4. Otherwise **generic**.

Secondary matches become optional properties on the winning tile rather than second tiles: a plug with `power`/`energy` stays a switch with a power line, a motion sensor with `temperature` stays motion with a temperature reading, and every class shows `battery`/`battery_low` when present. Evaluate only exposes with no `category`. A config binary such as the SONOFF's `turbo_mode` (access 7) must never make a device a switch.

## Edge cases

- **Multi-endpoint switches.** FACT: each endpoint's composite has `endpoint` and its `state` feature's `property` is `state_<endpoint>` while `name` stays `state` (exposes doc). The state payload carries `state_l1`, `state_l2`. INFERENCE: build one tile with one toggle per endpoint, labeled by endpoint (`l1` → "1", `left` → "Left"), and make the quick action act on the first endpoint only. Always read and write `property`, never `name`.
- **Lights without brightness.** These are on/off lights, so hide the slider. INFERENCE: still class them as lights (icon and color), not switches.
- **`color_mode` hs vs xy vs color_temp.** FACT (captured): the bulbs report `color_mode: "color_temp"` together with `color_temp: 500` and a `color: {hue:25, saturation:95}` object, while their exposes offer only `color_xy`. INFERENCE (not seen on this hub): `color_mode` can also be `xy` or `hs`. The tile should draw the swatch from `color_temp` when the mode is `color_temp`, from `color.x/y` when it is `xy`, and from `color.hue/saturation` when it is `hs`, and fall back to whatever keys are present. INFERENCE: the hs object is probably filled in by the device option `color_sync` (listed in the bulbs' `options`). Never infer the state shape from the exposes.
- **Access bits.** Draw a control only when access includes 2. Show the current value only when access includes 1. Access 2 alone (`effect`, the SONOFF's `inching_control_set`) is fire-and-forget: a button with no state. Access 4 means a `/get` refresh is possible (FACT). INFERENCE: ZigDash should not poll.
- **Availability.** It is off by default and off on this hub. INFERENCE: subscribe to `<device>/availability` and treat a missing message as "unknown", not "offline". Parse the JSON `{"state":...}` form. When no availability arrives, fall back to showing the last-known value.
- **State not yet reported.** A fresh pairing, or a battery sensor that has not woken up, produces state payloads that lack some properties. INFERENCE: every required property renders as "—" until its key first appears, and a toggle stays disabled (or optimistic, with no confirmation) until then. Correction to the ticket's premise: the SONOFF **does** report `"state":"OFF"` in this capture.
- **Friendly names.** FACT (captured): all three devices still have their IEEE address as friendly name (`0xc4d7fdbbfeba0000`), so topics are `zigbee2mqtt/0xc4d7fdbbfeba0000/set`. The tile title needs a user rename or a vendor/model label.
- **Nested composites.** `color_xy` is a composite inside `light.features`, with `x`/`y` one level deeper. The SONOFF also has a top-level composite `inching_control_set`. Parsers must recurse.

## Worked examples from the user's hub (FACT, captured 2026-09-26)

**1. Tuya CK-BL702-AL-01 bulbs `0xc4d7fdbbfeba0000` and `0xe8ca50de0db10000` → Color light.** Exposes are identical for both (trimmed):
```json
[{"type":"enum","property":"power_on_behavior","access":7,"category":"config","values":["off","on","toggle","previous"]},
 {"type":"light","features":[
   {"type":"binary","property":"state","access":7,"value_on":"ON","value_off":"OFF","value_toggle":"TOGGLE"},
   {"type":"numeric","property":"brightness","access":7,"value_min":0,"value_max":254},
   {"type":"numeric","property":"color_temp","access":7,"unit":"mired","value_min":142,"value_max":500,"presets":["coolest 142","cool 250","neutral 370","warm 454","warmest 500"]},
   {"type":"composite","name":"color_xy","property":"color","access":7,"features":[{"property":"x"},{"property":"y"}]}]},
 {"type":"enum","property":"effect","access":2,"values":["blink","breathe","okay","channel_change","finish_effect","stop_effect","colorloop","stop_colorloop"]},
 {"type":"binary","property":"do_not_disturb","access":3,"category":"config","value_on":true,"value_off":false},
 {"type":"enum","property":"color_power_on_behavior","access":3,"category":"config"},
 {"type":"numeric","property":"linkquality","access":1,"category":"diagnostic","unit":"lqi"}]
```
State: `{"brightness":253,"color":{"hue":25,"saturation":95},"color_mode":"color_temp","color_temp":500,"linkquality":68,"state":"ON"}`. Options: `transition`, `color_sync`, `state_action`.
Tile: toggle; brightness 0–254; color temperature 142–500 mired with presets; xy color picker; `effect` as a one-shot action; `do_not_disturb` and the power-on settings under More. Today's code gives: a brightness slider only.

**2. SONOFF MINI-ZBD `0x6ce4a4fffe6d2f80` → Switch.**
```json
[{"type":"switch","features":[{"type":"binary","property":"state","access":7,"value_on":"ON","value_off":"OFF","value_toggle":"TOGGLE"}]},
 {"type":"enum","property":"power_on_behavior","access":7,"category":"config"},
 {"type":"binary","property":"network_indicator","access":7,"category":"config"}, "turbo_mode (config, 7)",
 "delayed_power_on_state (config, 7)", "delayed_power_on_time (numeric, config, 7, seconds 0.5-3599.5)",
 "detach_relay_mode (config, 7)", "external_trigger_mode (enum, config, 7: edge|pulse|following(off)|following(on))",
 {"type":"composite","property":"inching_control_set","access":2,"features":["inching_control ENABLE/DISABLE","inching_time s","inching_mode ON/OFF"]},
 {"type":"enum","property":"action","access":1,"category":"diagnostic","values":["toggle"]},
 {"type":"numeric","property":"linkquality","access":1,"category":"diagnostic","unit":"lqi"}]
```
State: `{"state":"OFF","linkquality":60,"network_indicator":true,"turbo_mode":false,"delayed_power_on_state":false,"delayed_power_on_time":22,"detach_relay_mode":false,"external_trigger_mode":"edge","update":{"installed_version":4096,"latest_version":4096,"state":"idle"}}`.
Notes: no `endpoint` (single channel), no power metering. Seven config exposes would clutter a generic tile. `update` shows up in state but is not an expose. Today's code gives: a correct toggle (rule 3).

## Gaps in today's discovery code

`lib/features/discovery/models/device_panel_suggestion.dart`, `lib/features/discovery/models/z2m_device.dart`:

1. **Light → brightness slider only** (rule 1), with no on/off, no color_temp and no color. The slider also hard-codes 0–254 instead of reading `value_max`.
2. **One level of flattening.** `_flattenExposes` adds `color_xy` but not its `x`/`y`, and it merges top-level and feature exposes into one list. So a light's `state` feature also satisfies rule 3's `hasBinaryState`, and a nested binary is indistinguishable from a top-level one.
3. **Dropped fields.** `endpoint`, `name`, `category`, `value_off`, `value_toggle`, `values`, `value_min`/`value_max`/`value_step`, `presets` and `features` nesting are all lost. `valueOn` is stringified, which loses the bool-versus-"ON" distinction.
4. **Multi-endpoint broken.** Rule 3 fires on `hasSwitch` but hard-codes `jsonPath: 'state'`. A TS0002 gets a toggle bound to a key that never appears (`state_l1`), and only one endpoint is offered.
5. **No numeric readings.** A climate sensor has no binary in the sensor set, so it falls to rule 5a (battery progress) or 5b (linkquality progress). `temperature` and `humidity` are never shown.
6. **Sensor order.** Rule 4 takes the first matching binary in expose order, so a leak sensor whose `battery_low` comes first shows `battery_low`. Urgency ordering (leak > contact > occupancy) is absent, and `tamper`/`battery_low` should never be the primary.
7. **Category ignored.** Rule 6 would turn `power_on_behavior` (config) or `effect` (write-only, no state) into a combo. A config binary with access 7 (for example `turbo_mode`) would not trigger rule 3 because its property is not `state`, but a device whose only settable binary is config would fall to a misleading combo or text log.
8. **Access unused.** `isSettable` exists but no rule consults it. Leds and toggles are chosen by type only, and publish suffixes are hard-coded.
9. **Availability and friendly-name fallback** are not modeled (no `availability` topic, IEEE names shown raw).
