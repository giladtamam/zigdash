# ZigDash Chat

A linked Telegram chat talks to its own Home: @ZigDashHomeBot, Claude Haiku, and the ZigDash Engine (3.7.0 and later carry Chat, dormant until a client is linked), through the ZigDash relay. Pro owners link from the app (Home settings › Chat). Plans: [docs/design/chat-linking.md](../../docs/design/chat-linking.md) (phase 3) and [docs/design/whatsapp-assistant.md](../../docs/design/whatsapp-assistant.md) (revision 6).

Files: `service.mjs` (start, configuration), `bot.mjs` (linking, unlinking, every Telegram update, caps, the Worker passthrough), `http.mjs` (the app's API and the webhook), `agent.mjs` (Claude loop, confirmations, memory), `link.mjs` + `wire.mjs` (sealed requests to the Engine), `telegram.mjs` (Bot API, long polling), `store.mjs` (bindings in the encrypted keys file, the state file), `keystore.mjs`, `ticket.mjs`, `metrics.mjs` (counters-only logs), `cli.mjs`, `replay-test.mjs`, `deploy/` (Compose, `webhook.sh`). The Engine side is `hub/src/chat.js`; tickets and ACL entries come from `relay/verifier`; early access stays in `tool/support-worker/worker.js`.

What it does in code, whatever the model says: changes only devices on the client's control list, never locks, valves or sirens (the Engine checks both); asks "Reply yes within 60 seconds" before anything touching more than 5 devices; stops at 6 tool calls or 20 s; answers only chats a finished link names; 300 messages a Home a month and a $20 monthly model budget, each with a friendly line; logs counters only (no text, names, chat ids, home ids or codes).

Tests (fake Telegram, Claude, verifier and Worker; a local mosquitto when installed, otherwise an in-process broker):

```sh
cd tool/zigdash-chat && pnpm install
env -u NODE_OPTIONS node --test test/*.test.mjs
env -u NODE_OPTIONS node --test ../../hub/test/*.test.js
(cd ../../relay/verifier && pnpm install && env -u NODE_OPTIONS node --test test/*.test.mjs)
env -u NODE_OPTIONS node --test ../support-worker/test/*.test.mjs
```

## The contract with the app

All JSON; failures are `{error}`. A ticket comes from the relay verifier and is good for 10 minutes.

**Hub** (home broker, at home): `zigdash/chat/clients/<client_id>`, retained, `{v:1, name, hash: sha256(token), key: base64(32 bytes), scope: "read"|"control", controls: [ieee]}`. The Engine takes it into `zigdash-chat.json` (mode 600) and clears the retained copy. An empty retained payload, or `{"v":1,"delete":true}`, deletes the client (the second also reaches an Engine that is off at the time). Relay topics: `homes/<home>/x/<hex24(HMAC-SHA256(key, "zigdash/chat/req/<client_id>"))>` (requests) and the same with `res` (answers).

**Verifier** `POST https://relay.zigdash.app/v1/homes/<home>/chat-ticket`, phone Basic login, body `{purchase_token, client_id?, request_topic?, answer_topic?}` (topics only together with `client_id`; a removal ticket names only the client; a listing ticket nothing) → `200 {ticket, home_id, client_id, request_topic, answer_topic, exp}` (`exp` in seconds). `401` wrong login, `402` purchase not valid now or not this Home's (App Store Homes are not in this beta), `400` bad body, `429` over 20 tickets a Home an hour, `503` Chat off or Play down.

**Service** at `https://chat.zigdash.app`; the ticket goes in the `X-Chat-Ticket` header (or the body's `ticket`):

| Call | Body | 200 | Errors |
|---|---|---|---|
| `POST /v1/link` | `{ticket, token, key, scope}` | `{code, expires_in: 600, bot, url}` | 401 `bad_ticket` / `ticket_expired`; 400 `ticket_without_client`, `bad_body`, `topics_mismatch` (the ticket's topics aren't the ones this key makes); 409 `already_linked`; 429 `too_many` (5 a Home an hour) |
| `POST /v1/link/confirm` | `{ticket, code_back}` | `{linked: true, client_id, telegram_name, scope}` | 401 ticket; 404 `unknown_code` (no link waiting: never made, expired, cancelled or done); 409 `not_claimed` (nobody sent the code to the bot yet), `already_linked`; 400 `wrong_code` with `tries_left`; 410 `cancelled` (third wrong code); 503 `try_again` (the verifier didn't add the ACL entries; the same code works again) |
| `GET /v1/links` | – | `{links: [{client_id, telegram_name, scope, last_used (epoch ms or null), linked_at (epoch ms)}]}` | 401 |
| `DELETE /v1/link/<client_id>` | – | `{removed: true}` (a link still waiting is cancelled too) | 401; 403 `wrong_client` (a ticket for another client); 404 `not_linked` (gone already) |
| `GET /v1/health` | – | `{ok: true}` | |

Link codes are `L` + 6 characters from `ABCDEFGHJKLMNPQRSTUVWXYZ23456789`, kept 10 minutes unclaimed and 10 more after the claim; the bot answers `/start <code>` in a private chat with a 4-digit back-code. Nothing reaches the broker's ACL or the keys file before the back-code is confirmed; a link never finished is forgotten when it expires. `/unlink` in the linked chat asks first (Unlink / Keep, 60 s) and does what DELETE does; the hub's client config stays until the app deletes it at home. `/stop` stays the early-access "take me off the list" and never unlinks.

## 1. The Engine

Chat is in the release Engine since 3.7.0 (`hub/zigdash-engine.js`), which the app installs and updates silently; dormant Engines subscribe only to `zigdash/chat/clients/+`. The milestone 1 build (`node hub/build.mjs --chat`, version `9.0.0-chat`) still builds but is not needed any more. To put the owner's hub back on the release numbering, install the release build by hand from a computer at home:

```sh
jq -n --rawfile code hub/zigdash-engine.js '{name:"zigdash-engine.js", code:$code}' > /tmp/engine-save.json
mosquitto_pub -h 192.168.68.64 -t zigbee2mqtt/bridge/request/extension/save -f /tmp/engine-save.json
mosquitto_sub -h 192.168.68.64 -t zigdash/automations/state -C 1    # "engine":"3.7.0"
```

## 2. Development: the dev bot, at home

Long polling (`TELEGRAM_MODE=polling`, the default) on the dev bot, over the hub's own broker. Files under `~/.config/zigdash/` (mode 600; never printed or logged): `dev_bot_token`, `anthropic_key` (or `ANTHROPIC_API_KEY`). The CLI creates `chat-secrets.json` (the service key) and `chat-keys.json` (the bindings, encrypted with it).

```sh
cd tool/zigdash-chat && pnpm install
export ZIGDASH_MQTT_URL=mqtt://192.168.68.64:1883
env -u NODE_OPTIONS node cli.mjs create --id tg1 --name "Owner's Telegram" \
  --controls "Office shutter,Hall light" --home-id <relay home id> --chat <your Telegram chat id>
env -u NODE_OPTIONS node service.mjs
```

Other commands: `cli.mjs list`, `set-controls <id> "<names>"`, `audit <id>`, `audit --retained`, `revoke <id> [--hub-only]`, `topics <id>`, `adopt <id> --chat <chat id>` (section 5). Without `CHAT_TICKET_SECRET_FILE` the HTTP API stays off; without `WORKER_URL` messages from unlinked chats get nothing (milestone 1's behaviour).

To try the app's link flow against a local service: run with `CHAT_TICKET_SECRET_FILE`, `HTTP_PORT=8790` and a test relay, and build the app with `--dart-define=ZIGDASH_CHAT_API=http://<host>:8790 --dart-define=ZIGDASH_CHAT_BOT=<dev bot>`.

## 3. Deploy on grocery-vps

### Secrets (new)

Make each with `openssl rand -base64 32 | tr '+/' '-_' | tr -d '='` (letters, digits, `-` and `_`: Telegram accepts these as a webhook secret). Mode 600, owned by the container user (`CHAT_UID`, 1000):

| Secret | zigdash-chat (`/srv/zigdash-chat/config/`) | elsewhere |
|---|---|---|
| ticket key | `chat_ticket_secret` | `relay/deploy/secrets/chat-ticket-secret` (verifier) |
| ACL route key | `chat_acl_secret` | `relay/deploy/secrets/chat-acl-secret` (verifier) |
| Worker key | `worker_secret` | Worker secret `CHAT_SERVICE_SECRET` (`wrangler secret put CHAT_SERVICE_SECRET`) |
| webhook secret | `webhook_secret` | given to Telegram by `webhook.sh live` |
| Worker's webhook secret | `worker_webhook_secret` (for `webhook.sh rollback` only) | the Worker's `ASSISTANT_WEBHOOK_SECRET` (same value) |

Also in `config/`: `bot_token` (@ZigDashHomeBot's token; the dev bot's while testing), `anthropic_key`, `relay_password` (the service's broker login). In `/srv/zigdash-chat/secrets/`: `chat-secrets.json`. In `/srv/zigdash-chat/data/` (writable): `chat-keys.json` (move it there from `config/`) and `chat-state.json` (created).

### The verifier

Env (`relay/deploy/docker-compose.yml`, already set): `CHAT_TICKET_SECRET_FILE=/secrets/chat-ticket-secret`, `CHAT_ACL_SECRET_FILE=/secrets/chat-acl-secret`, `CHAT_ROLE=zigdash-chat` (the service's dynamic-security role), `INTERNAL_PORT=8788` (the internal ACL route; not published, not proxied), optional `TICKETS_PER_HOUR` (20). Chat stays off while the secret files are missing.

```sh
cd relay/deploy
install -m 600 /path/to/chat-ticket-secret secrets/chat-ticket-secret
install -m 600 /path/to/chat-acl-secret    secrets/chat-acl-secret
docker compose up -d --build verifier
docker compose logs verifier | tail -1        # "... internal :8788, ... chat=on"
```

Update the host Caddyfile from `relay/deploy/Caddyfile.snippet` (the new `handle /v1/internal/* { respond 404 }` before `/v1/*`) and reload Caddy.

### The broker role

The verifier creates the role `zigdash-chat` on the first link; the service's login needs it:

```sh
ctrl() { docker compose exec mosquitto mosquitto_ctrl -u admin -P "$ADMIN_PASSWORD" dynsec "$@"; }
ctrl createRole zigdash-chat            # "already exists" is fine
ctrl addClientRole zigdash-chat zigdash-chat
```

### Caddy and DNS for chat.zigdash.app

DNS: an A record `chat.zigdash.app` to grocery-vps (like `relay.zigdash.app`). Add to the host Caddyfile (Caddy is on the edge network) and reload:

```
chat.zigdash.app {
	handle /v1/* {
		reverse_proxy zigdash-chat-chat-1:8790
	}
	respond 404
}
```

### The service

`tool/zigdash-chat/deploy/.env`: `CHAT_CONFIG_DIR=/srv/zigdash-chat/config`, `CHAT_SECRETS_DIR=/srv/zigdash-chat/secrets`, `CHAT_DATA_DIR=/srv/zigdash-chat/data`, `CHAT_RELAY_USER=zigdash-chat`, `EDGE_NETWORK=<Caddy's network>`, and while testing `BOT_USERNAME=<dev bot>`.

```sh
cd tool/zigdash-chat/deploy && docker compose up -d --build
curl -s https://chat.zigdash.app/v1/health          # {"ok":true}
docker compose logs -f chat                         # counters only
```

### The Worker

Deploy `tool/support-worker/worker.js` (main's copy plus the Chat routes) and set `CHAT_SERVICE_SECRET`. Nothing else changes there; until the webhook moves, it keeps answering the bot itself.

### The webhook switch

First on the dev bot (`bot_token` = the dev bot's, `BOT_USERNAME` = its name): `sh webhook.sh live` with its token, then check both flows: a link from a debug app build, and `/start early_c` (the Worker's list answers). Then put @ZigDashHomeBot's token in `config/bot_token`, `BOT_USERNAME=ZigDashHomeBot`, `docker compose up -d`, and:

```sh
CHAT_CONFIG_DIR=/srv/zigdash-chat/config sh deploy/webhook.sh live       # Telegram -> chat.zigdash.app
CHAT_CONFIG_DIR=/srv/zigdash-chat/config sh deploy/webhook.sh info
```

**Rollback, one command:** `CHAT_CONFIG_DIR=/srv/zigdash-chat/config sh deploy/webhook.sh rollback` points the webhook back at the Worker; linked chats then hear "Chat is paused for maintenance; it will be back soon." and early access works as before.

## 4. Moving the owner's tg1 onto the per-client ACL mechanism

Home `f3a2993b55c4ed99`, client `tg1`, made by hand in milestone 1 with its own role `chat-tg1`.

1. **Engine:** install the 3.7.0 release build (section 1). It takes tg1's still-retained config into `zigdash-chat.json` and clears it on the broker; check `mosquitto_sub -h 192.168.68.64 -t zigdash/chat/clients/tg1 -C 1 -W 3` prints nothing and a message still works over the dev setup.
2. **Keys:** move `chat-keys.json` from `/srv/zigdash-chat/config/` to `/srv/zigdash-chat/data/` (same file; mode 600, owner 1000).
3. **Adopt:** record the chat and the topics, and add the ACL entries through the verifier (the CLI uses the service's environment and network):

   ```sh
   cd tool/zigdash-chat/deploy
   docker compose run --rm chat node cli.mjs adopt tg1 --chat <owner's chat id> --home-id f3a2993b55c4ed99
   # "tg1: linked to its chat, topics recorded, ACL entries added on the chat role"
   ```

4. **Roles:** the login now uses the shared role; the hand-made one goes:

   ```sh
   ctrl addClientRole zigdash-chat zigdash-chat      # if not done above
   ctrl removeClientRole zigdash-chat chat-tg1
   ctrl deleteRole chat-tg1
   ```

5. `docker compose restart chat`; a message from the owner's chat answers, and the app's Chat screen lists tg1. Removing it from the app (or `/unlink`) now works like any other link.

## Acceptance (plan revision 6 and chat-linking.md), from Telegram on mobile data

"close the office shutter" closes it through the relay; "is the front door closed?" answers from live state; a valve or lock gets "Open ZigDash to do that"; a plug off the control list is refused; "turn off everything" asks first and only "yes" runs it; `replay-test.mjs --after 5,180` shows both replays rejected and audited; another Telegram account reaches only the early-access reply; a link from the app finishes with the back-code, and removing it (app or `/unlink`) ends access at once; the `message` log lines give latency and `cost_usd`.
