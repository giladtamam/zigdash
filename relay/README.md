# ZigDash relay (3.1)

Remote control from away for Pro (docs/design/zigdash-3.0.md §5). Two parts:

- `verifier/` — admits a Home after a Pro purchase (Google Play, checked with
  Google's API; or the App Store, whose signed transaction is checked offline
  in `apple.mjs`; `APPLE_ENVIRONMENTS=Production,Sandbox` admits TestFlight
  purchases too) and creates its
  broker logins (one role per Home, a hub login, phone logins); paired phones
  add and remove phones. A founder's code admits a Home for a number of days
  instead of a purchase (below). Tests run against a real local Mosquitto:
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

## Founders' passes (docs/design/founders-pass.md)

Remote control and Chat for one Home, for 90 days from the day its code is
entered; then the Home is switched off (logins disabled, Chat ACLs removed),
and 90 days later deleted with its retained messages, unless upgraded to Pro.
The hourly sweep in the verifier does both.

Deploy order: the chat service first (its internal listener on 8791), then the
verifier, then the Worker.

1. The codes' key, once (mode 600, readable by the container's user, uid 1000;
   not in the database or its backups; keep a copy offline: without it no
   unused code can be entered, while Homes already admitted go on):
   `openssl rand -base64 32 | sudo install -m 600 -o 1000 -g 1000 /dev/stdin deploy/secrets/pass-secret`
2. `docker compose up -d --build` in `deploy/` (Compose sets `PASS_SECRET_FILE`,
   `CHAT_INTERNAL_URL` and `ADMIN_SOCKET`; the verifier adds its new columns
   and tables to an existing database by itself).
3. The owner's commands, from `deploy/` (codes are printed once and kept
   nowhere; dates are YYYY-MM-DD, the end of that day UTC):

   | command | what it does |
   | --- | --- |
   | `docker compose exec verifier node cli.mjs passes new --count N [--days 90] [--redeem-by D]` | N new codes (to be entered by D, default 60 days) |
   | `... passes list` | every pass by its hash prefix, with its state and Home |
   | `... passes revoke <prefix or code>` | ends the pass now; its Home is switched off at once |
   | `... passes unrevoke <prefix or code>` | its date back; the Home switched on if still in time |
   | `... passes extend <prefix or code> [--redeem-by D] [--days N]` | a later deadline, and/or N days from the day the code was entered; a Home in time again is switched on |
   | `... passes reissue <home id> [--redeem-by D]` | a new code for a lost founder's Home (same end) |
   | `... passes sweep` | the hourly sweep, now |
   | `... homes delete <home id>` | deletes any Home (a deletion request), its Chat links too |

   `--days N` counts from the day the code was entered: on a pass entered long
   ago, a small N ends it in the past, and 90 days past its end the next sweep
   deletes the Home.
