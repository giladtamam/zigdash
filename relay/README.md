# ZigDash relay (3.1)

Remote control from away for Pro (docs/design/zigdash-3.0.md §5). Two parts:

- `verifier/` — admits a Home after a Pro purchase (Google Play, checked with
  Google's API; or the App Store, whose signed transaction is checked offline
  in `apple.mjs`; `APPLE_ENVIRONMENTS=Production,Sandbox` admits TestFlight
  purchases too) and creates its
  broker logins (one role per Home, a hub login, phone logins); paired phones
  add and remove phones. Tests run against a real local Mosquitto:
  `cd relay/verifier && pnpm install && pnpm test`.
- `deploy/` — Docker Compose for one host: Mosquitto 2.1.2 with dynamic
  security (8883 for hubs, WebSocket behind Caddy for phones) and the verifier.

The relay never reads device data: hubs and phones seal it with the Home's key
(hub/src/engine.js). Topic names on the relay are opaque.

## Deploying (each step needs the owner's OK; nothing here has been run)

1. DNS: `relay.zigdash.app` A record to the host (GoDaddy, owner).
2. Caddy: add `deploy/Caddyfile.snippet`, put Caddy on a shared network named in
   `EDGE_NETWORK`; Caddy obtains the certificate.
3. Firewall: open 8883/tcp (ufw).
4. Broker admin: `mosquitto_ctrl dynsec init deploy/data/dynsec.json admin <pw>`.
5. Play: a service account with "View financial data" on the Play Console app,
   its JSON key in `deploy/secrets/play-service-account.json` (owner).
6. `deploy/.env`: `ADMIN_PASSWORD`, `EDGE_NETWORK`, `CADDY_CERT_DIR` (Caddy's
   `.../certificates/acme-v02.api.letsencrypt.org-directory/relay.zigdash.app`).
   Run `deploy/sync-certs.sh` once Caddy has the certificate, then
   `docker compose up -d --build` in `deploy/`.
7. Certificate renewals: `zigdash-relay-certs.timer` runs `sync-certs.sh` daily;
   it copies a renewed certificate and sends Mosquitto SIGHUP.
8. Before go-live: the legal groundwork (wayfinder ticket 11).
