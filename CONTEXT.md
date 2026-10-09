# ZigDash — domain glossary

**Broker** — the user's MQTT server (e.g. Mosquitto on a Pi or SMLIGHT hub). ZigDash stores one **Connection** per broker: address, protocol, credentials.

**Home** — what users call a connection in everyday UI. The app shows one home at a time and switches between homes in the header. The word "broker" appears only in setup and connection settings; code says `Connection`.

**Zigbee2MQTT bridge** — the Zigbee2MQTT instance publishing under a base topic (default `zigbee2mqtt`) on a broker. A broker can be reachable while no bridge publishes on it.

**Device** — a Zigbee device the bridge reports in `bridge/devices`. Devices exist independently of dashboards.

**Dashboard** — a named, user-arranged screen of tiles belonging to one home; the primary object users work with. Rooms are not a concept: a user who wants rooms names dashboards after them. The app opens on the last-used dashboard.

**Panel** — one control or readout on a dashboard, bound to MQTT topics (code term). Users see it as a **tile**; "panel" does not appear in UI copy.

**Device tile** — one tile representing a whole device of a known class (color light, light, switch/plug, cover, climate sensor, contact, motion, leak/smoke), stored as one panel of type `device` bound to the device's IEEE address. Tap the icon for the quick action, the body for full controls, long-press to edit. Unknown classes get a generic device tile.

**Reading tile** — a tile showing one numeric value with its unit (temperature, humidity, power).

**Custom MQTT tile** — any of the raw panel types (toggle, slider, multi-state, text log…) configured by topic and payload rather than from a device. The expert path.

**Unassigned device** — a device reported by the bridge that is on no dashboard in its home. Surfaced as a prompt, never added automatically.

**Tile size** — how much of a dashboard row a tile takes: **Small** (one grid column), **Wide** (two columns) or **Full** (the whole row). Columns are 2 on phones, 3 on medium windows, 4 on tablets, so a Small tile stays small on a tablet. Code: `PanelWidth` small/wide/full from 1.12 (before that full/half/third; half and third migrate to Small).

**Section** — a titled group of tiles inside a dashboard (e.g. Lights, Sensors). Generated dashboards are sectioned by device type. Tiles with no section render first, without a header; dashboards from before 1.12 start that way.

**Device link** — the IEEE address a tile carries (`panels.deviceIeee`): always on device and reading tiles, optional on custom MQTT tiles. It decides whether a device is on a dashboard.

**Not responding** — a device tile's state when the device ignored its state request (`/get`) for 15 seconds after connecting. Zigbee2MQTT availability is off by default, so this is often the only sign a device has dropped off the Zigbee network. The tile still sends commands.

**Device page** — the page for one device, reached from the Devices tab, a device tile's sheet or Edit mode: full controls, readings, health, and the dashboards it is on. Routed by IEEE address, so it follows renames. From 1.13.

**Needs attention** — a device whose battery is low, which availability reports offline (only when the bridge has availability turned on), which is not responding, or whose interview failed or is unsupported. Weak link quality is shown but does not count.

**Last heard** — when the app last received a state message from a device, taken from the last-known store. Used instead of Zigbee2MQTT's `last_seen`, which is off by default.

**Edit mode** — the one mode in which a dashboard is rearranged: tiles show a grip and an edit badge, controls are inert, and changes save as they happen.

**Generated dashboard** — a dashboard created from discovered devices during setup, then editable like any other.

**First run** — from install until the user has a home or has chosen the demo. During first run the app shows only setup (and its manual entry and help). It ends when setup, manual entry or the connection form saves a real home, or when the user tries the demo. Code: `needsOnboarding` / `FirstRun`.

**Demo mode** — a sample connection and dashboard with no real broker, marked as demo on screen and removed when real setup completes.

**Last-known value** — a tile's most recent received value, kept on the phone across restarts, shown when the value is not fresh (broker unreachable, or not yet reported since connecting) and marked stale with its age. Never leaves the device, not even in Android backups.

**Successful session** — a calendar day on which the user sent a command and received a confirming state update. Counted locally for the rating prompt; nothing leaves the device.
