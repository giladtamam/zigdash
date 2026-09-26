# ZigDash — domain glossary

**Broker** — the user's MQTT server (e.g. Mosquitto on a Pi or SMLIGHT hub). ZigDash stores one **Connection** per broker: address, protocol, credentials.

**Home** — what users call a connection in everyday UI. The app shows one home at a time and switches between homes in the header. The word "broker" appears only in setup and connection settings; code says `Connection`.

**Zigbee2MQTT bridge** — the Zigbee2MQTT instance publishing under a base topic (default `zigbee2mqtt`) on a broker. A broker can be reachable while no bridge publishes on it.

**Device** — a Zigbee device the bridge reports in `bridge/devices`. Devices exist independently of dashboards.

**Dashboard** — a named, user-arranged screen of tiles belonging to one home; the primary object users work with. Rooms are not a concept: a user who wants rooms names dashboards after them. The app opens on the last-used dashboard.

**Panel** — one control or readout on a dashboard, bound to MQTT topics (code term). Users see it as a **tile**; "panel" does not appear in UI copy.

**Device tile** — one tile representing a whole device of a known class (light, switch/plug, cover, climate sensor, contact, motion, leak/smoke), composed from panel behaviors. Tap the icon for the quick action, the body for full controls, long-press to edit. Unknown classes get a generic device tile.

**Reading tile** — a tile showing one numeric value with its unit (temperature, humidity, power).

**Custom MQTT tile** — any of the raw panel types (toggle, slider, multi-state, text log…) configured by topic and payload rather than from a device. The expert path.

**Unassigned device** — a device reported by the bridge that is on no dashboard in its home. Surfaced as a prompt, never added automatically.

**Section** — a titled group of tiles inside a dashboard (e.g. Lights, Covers). Generated dashboards are sectioned by device type.

**Generated dashboard** — a dashboard created from discovered devices during setup, then editable like any other.

**Demo mode** — a sample connection and dashboard with no real broker, marked as demo on screen and removed when real setup completes.

**Last-known value** — a panel's most recent received value while its broker is unreachable; shown, but marked stale.

**Successful session** — a calendar day on which the user sent a command and received a confirming state update. Counted locally for the rating prompt; nothing leaves the device.
