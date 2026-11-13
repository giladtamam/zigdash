# The Home Assistant route: connecting when the phone can't reach the broker

Design, 2026-10-20. Status: route A built on `feat/ha-route` (2.10):
`lib/mqtt/ha_mqtt_client.dart`, `ha_token.dart`, `ha_address.dart`, the
`transport` column, `lib/features/onboarding/setup/ha_connect*.dart`, and
`bin/e2e_real_broker.dart --transport ha`. The direct web-interface client
(route C) stays a spike on `spike/z2m-frontend-ws`.

## The problem, from the data

Usage data, 2026-09-01 to 10-20, robots and the developer's own phone removed:

| Home Assistant users who tried setup | 24 |
|---|---|
| Connected | 1 (4%) |
| Scan found nothing | 22 |
| …of which the scan saw **no Home Assistant at all** on the network | 21 |
| …of which other machines did answer (so the phone was on a home network) | 18 |

Since 2.9.6, every Home Assistant user (4 of 4) took the same path: tapped
"I use Home Assistant" → `homeassistant.local` could not be looked up → gave
up ("no hub yet" or "other network"), although the screen says to type the
IP address from Settings › System › Network.

The scan probes port 8123 over both HTTP and HTTPS and widens to the
surrounding network, so this is not a detection gap: Home Assistant is on a
network the phone is not on (another subnet or VLAN, a different router, or
used only remotely). Any fix must start from the Home Assistant address the
user already knows, and must work from anywhere, since "at home on the same
Wi-Fi" is exactly what these users don't have.

Looking for ZHA users (Home Assistant without Zigbee2MQTT) finds about 6 of
92 setup users; the Home Assistant problem is not mainly a ZHA problem.

## What a Home Assistant sign-in gives us

The app already signs in to Home Assistant for the 2.8 import
(`ha_auth.dart`: Home Assistant's own login page with PKCE, client id
`https://giladtamam.github.io/zigdash/ha/`, fallback: paste a long-lived
token) and talks to its WebSocket API (`ha_client.dart`). Two routes to
Zigbee2MQTT exist behind that sign-in. Both verified in Home Assistant's
source (core `dev`, Supervisor `main`, 2026-10-20); route A also on a live
install.

### Route A: Home Assistant's own MQTT

Home Assistant's MQTT integration (which every Zigbee2MQTT + Home Assistant
user has: it is what shows Zigbee2MQTT's devices in Home Assistant) is
reachable over the WebSocket API:

- `mqtt/subscribe {topic, qos}`: events `{topic, payload, qos, retain}`. Home
  Assistant re-sends SUBSCRIBE to its broker on every new subscription "to
  ensure retained messages are replayed" (`mqtt/client.py`), so
  `bridge/devices` and the other retained bridge topics arrive as over MQTT.
  Wildcards (`#`, `+`) are allowed.
- `call_service mqtt.publish {topic, payload: string, qos, retain}`: any
  topic, retain allowed, so the Node-RED automation configs and every other
  non-Zigbee2MQTT topic keep working.
- Both are **admin-only** (`if not connection.user.is_admin: raise
  Unauthorized`; `async_register_admin_service`). The household owner is an
  admin; a family member's account may not be.

Works on every Home Assistant install, including Docker without the add-on
system, and remotely (Nabu Casa, own domain) because it is all one
WebSocket to Home Assistant.

**Verified 2026-10-20** on the Pi (Home Assistant 2026.1.1 in Docker, MQTT
integration on its Mosquitto) with the app's real `MqttManager` and
`HaMqttClient` injected through `clientFactory`: sign-in, admin check,
`bridge/state`, `bridge/devices` and `bridge/info` byte-identical to the MQTT
copies, `bridge/request/health_check` → `bridge/response/health_check`.

### Route B: ingress to the Zigbee2MQTT add-on's web interface

For Home Assistant OS and Supervised with the official add-on
(`45df7312_zigbee2mqtt`, also `_edge` and `_proxy`; the `45df7312` prefix is
the repository hash as commonly reported, not read from a source here:
confirm on a Home Assistant OS install before the probe keys off it). The
add-on forces the frontend to port 8099 behind ingress and does not open it
on the network.

1. `supervisor/api GET /addons/45df7312_zigbee2mqtt/info` → `ingress_entry`
   (`/api/hassio_ingress/<token>`), add-on state and version.
2. `supervisor/api POST /ingress/session` → `session` (a 15-minute sliding
   window, extended by `POST /ingress/validate_session`; simplest is a new
   session per connection). The app sends no body: core's `supervisor/api`
   handler injects the signed-in user's id for the Supervisor.
3. WebSocket to `wss://<home-assistant>/api/hassio_ingress/<token>/api` with
   header `Cookie: ingress_session=<session>`, passed through Dart's
   `WebSocket.connect(url, headers: {...})`. Core proxies WebSocket
   upgrades to the Supervisor, which forwards to the add-on; the add-on's
   `base_url` is the default, so Zigbee2MQTT's WebSocket path resolves to
   `/api` as in the direct spike.

Allowed for **any** user: `/ingress/(session|validate_session)` and
`/addons/<slug>/info` are the only Supervisor endpoints a non-admin may
call. `GET /addons` (listing) is admin-only, hence the fixed slugs. Same
limits as the direct web-interface connection: base topic only, no
retained publishes. Not verified live (no Supervisor at hand); the chain is
read from `hassio/websocket_api.py`, `hassio/ingress.py`,
`supervisor/api/ingress.py`, `supervisor/ingress.py`,
`hassio-zigbee2mqtt/common/rootfs/docker-entrypoint.sh`.

### Route C, for comparison: direct to Zigbee2MQTT's web interface

Verified on the SMHUB and the Pi (`z2m_frontend_client.dart`): no login by
default, identical bridge topics, commands work (office shutter 77 → 72 →
77). Helps SMLIGHT "Allow External" and `listener 1883` cases, not the
Home Assistant users above: the add-on's interface is not on the network.

## Decision

Build **route A** as "Connect through Home Assistant", with route B as the
fallback when the signed-in user is not an admin and the add-on is present.
Route A covers every install type, keeps full MQTT, and is already proven;
route B is the only way for non-admin family accounts.

### Setup flow for a Home Assistant user

On the empty result's "I use Home Assistant" (and on the welcome screen's
manual entry), instead of only looking for `homeassistant.local`:

1. **Address**: "Where do you open Home Assistant?" with the address field
   prefilled from what the scan saw, else empty, accepting whatever the user
   types in their Home Assistant app: `homeassistant.local:8123`, an IP,
   `https://xxx.ui.nabu.casa`, their own domain. Check it answers as Home
   Assistant (`/api/websocket` → `auth_required`), as `ha_client.dart`
   already does.
2. **Sign in**: the existing browser sign-in; paste-a-token fallback.
3. **Choose the route**: `auth/current_user` → admin? Route A, test with
   `mqtt/subscribe zigbee2mqtt/bridge/info`. Not admin, or no MQTT
   integration → route B if `addons/45df7312_zigbee2mqtt/info` answers.
   Neither → explain: "Your Home Assistant user needs to be an
   administrator, or Zigbee2MQTT must run as the official add-on."
4. **Review and create** as today; the connection row records
   `transport: homeAssistant` and the Home Assistant base URL.

The MQTT broker never needs to be reachable from the phone, and the user
never needs the broker login.

### The credential: the real design decision

The import deliberately keeps nothing: the token passes through one read
and the refresh token is revoked (`ha_import_controller.dart`). A persistent
connection must keep a Home Assistant credential on the phone, and for
route A that credential is **admin access to the user's whole Home
Assistant**.

- Store the refresh token (or pasted long-lived token) in the same
  `FlutterSecureStorage` that holds broker passwords (`SecureStore`,
  `mqtt_pw::<connection id>`), under its own key; never in the Drift
  database, never in backups the app can't control (check Auto Backup
  excludes secure storage; `mqtt_pw::` already relies on this).
- Refresh the access token with the refresh token on each connect
  (`/auth/token`, `grant_type=refresh_token`); a refused refresh ends in the
  normal "login rejected" path with "Sign in to Home Assistant again".
- Deleting the connection revokes the token at Home Assistant
  (`HaRevoke` exists) and deletes it locally.
- Say it in `store/PRIVACY.md` ("ZigDash keeps a login to your Home
  Assistant on this phone, in the Android keystore, until you delete the
  home") and in the sign-in screen: "ZigDash will act as you in Home
  Assistant. You can end this any time under Profile › Security."
- Shortcuts, widgets and the kiosk read the password through
  `createSecureStore()` without Riverpod; the token must be reachable the
  same way.

### Inside the app

`MqttManager` stays the single connection layer. A new `ConnectionTransport`
(`mqtt`, `zigbee2mqttFrontend`, `homeAssistant`) on the connection row
selects the client the factory builds: the existing `MqttServerClient`,
`Z2mFrontendClient`, or `HaMqttClient`. Screens, alerts, history and
shortcuts do not change. Known gaps to close for release:

- Home Assistant closes a WebSocket whose client stops reading (pending
  message cap). Subscriptions die with the socket; `MqttManager` already
  re-subscribes every pattern on reconnect, which covers it.
- `endpointCandidates` assumes host + port + protocol; the Home Assistant
  base URL (scheme, host, port, maybe a path) needs its own candidate kind,
  with the remote URL as the only candidate when the user gave one.
- Setup's "needs login" and diagnostics (`connect_diagnostics.dart`) are
  MQTT-shaped; the Home Assistant transport needs its own short ladder:
  address answers / is Home Assistant / token accepted / is admin or add-on
  found / bridge/info arrived.
- The event names: `setup_step` gains `ha_address` (outcome), `ha_signin`
  (page or token; ok, cancelled, refused, failed), `ha_route` (mqtt, ingress,
  none), so the funnel is visible from the first release.

### Follow-ups after the first release

- **Sign in again** for an existing Home Assistant home (done in 2.10.1):
  a new phone (secure storage is not backed up), a revoked token or a
  changed admin end in "login rejected"; the home's form has "Sign in
  again", which reuses the connect screen (`?again=<id>`), replaces the
  stored sign-in (`ConnectionRepo.setHomeAssistantSignIn`), ends the old
  refresh token at Home Assistant and rebuilds the live connection.

### Still to verify before release

- Route B end to end (needs Home Assistant OS: a VM on the Mac).
- Route A from outside the home network through Nabu Casa or a domain
  (expected to work: one WSS to Home Assistant).
- A non-admin user on route A gets a clean `unauthorized`, not a hang. The
  spike client reports "connected" after sign-in, before any subscribe; the
  release client must treat a refused first `mqtt/subscribe` as login
  rejected, never as connected-and-silent.
- Battery: one extra WebSocket to Home Assistant instead of MQTT; Home
  Assistant's own app keeps one open too.

### Not doing

- A Home Assistant add-on of our own, or a migration tool for ZHA users:
  few users, high risk, and against Home Assistant's own direction
  (docs/design notes, 2026-10-20).
- Controlling devices through Home Assistant entities (would include ZHA
  users): a different product; revisit only if ZHA users become a large
  share.

## Release plan

1. 2.9.7 (now): count the sign-in outcome of the import (`ha_signin`), so
   the one dependency every route shares is measured before building on it.
2. Next feature release: route A behind "Connect through Home Assistant",
   with the credential handling above and its privacy text.
3. After: route B for non-admin users, once verified on Home Assistant OS.

## Port 80 (2026-11-06)

Home Assistant OS installed since 2026.8 serves on port 80; Home Assistant Container and every older install keep 8123 ([http integration](https://www.home-assistant.io/integrations/http/)). ZigDash assumed 8123 wherever no port was given, so a new Home Assistant OS could only be reached through DNS-SD, which carries the port.

- **A typed home address without a port** (`192.168.1.20`, `homeassistant.local`) is tried on 8123 and on port 80 at once; 8123 wins when both answer. Port 80 that nobody typed counts only when the page there is Home Assistant's (the hub probe's look): a router, a printer or an SMHUB answers on port 80 too, and the browser must not open on their error page. The address that worked goes into the field and onto the home, as for remote names since 3.3.4.
- **A typed port is the only one tried**, including `:80`: Dart's `Uri` forgets a scheme's default port, and `192.168.1.20:80` used to go to 8123.
- **Looking for Home Assistant** (the usual names and the sweep of the phone's `/24`) asks both ports of each address at once and says which answered. Measured on the home network: the `/24` on both ports in about 3 seconds.
- **The setup scan's hub look** tries Home Assistant on 8123 and 80. An SMLIGHT page seen on port 80 is still reported only when SMLIGHT was asked for, and with the SMLIGHT pass on, port 80 is asked once per host.
- **Not changed:** Import from Home Assistant still fills in `:8123` from the broker's address and tries only what is in the field; a home on port 80 needs the port taken out there.
