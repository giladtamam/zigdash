# Device tiles bind to a device's IEEE address, as one tile row

Until 1.11 every tile was a set of MQTT topics, and nothing in the database knew which device a tile belonged to. From 1.12 a device tile is a single `panels` row of the new type `device`, bound to the device's IEEE address. The friendly name used in topics is resolved at runtime from `bridge/devices` and cached, and the row also caches the device's class and the exposes it needs, so the tile renders offline. Custom MQTT tiles keep their topics and may carry an optional device link (`panels.deviceIeee`). That link is what "on no dashboard" is computed from.

The IEEE address is used because Zigbee2MQTT friendly names change on rename, and many users, including the reference hub, still have IEEE-looking names they will rename later. One row per device keeps editing, ordering, resizing and removal atomic.

## Considered options

- **A device tile composed of several panel rows** (a toggle row plus a slider row plus a sensor row). Rejected because editing, ordering and removal would split across rows, and every row would need to agree on the size and section.
- **Binding by friendly name.** Rejected because a rename in Zigbee2MQTT would orphan the tile.
- **Converting existing raw panels to device tiles in the migration.** Rejected: the migration has no network and cannot see `bridge/devices`, and silent conversion risks losing a tuned custom tile. Conversion is offered per tile instead.

Decided 2026-09-26. See `docs/design/dashboard-1.12.md`.
