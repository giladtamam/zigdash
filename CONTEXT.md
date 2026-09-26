# ZigDash — domain glossary

**Broker** — the user's MQTT server (e.g. Mosquitto on a Pi or SMLIGHT hub). ZigDash stores one **Connection** per broker: address, protocol, credentials. User-facing copy says "broker"; code says `Connection`.

**Zigbee2MQTT bridge** — the Zigbee2MQTT instance publishing under a base topic (default `zigbee2mqtt`) on a broker. A broker can be reachable while no bridge publishes on it.

**Device** — a Zigbee device the bridge reports in `bridge/devices`. Devices exist independently of dashboards.

**Dashboard** — a named, user-arranged screen of panels belonging to one connection. **Home** is the last-used dashboard; the app opens there.

**Panel** — one control or readout on a dashboard, bound to MQTT topics. A **tile** is a panel's visual on screen.

**Generated dashboard** — a dashboard created from discovered devices during setup, then editable like any other.

**Demo mode** — a sample connection and dashboard with no real broker, marked as demo on screen and removed when real setup completes.

**Last-known value** — a panel's most recent received value while its broker is unreachable; shown, but marked stale.

**Successful session** — a calendar day on which the user sent a command and received a confirming state update. Counted locally for the rating prompt; nothing leaves the device.
