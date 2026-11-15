# ZigDash Chat, milestone 1

The owner's Telegram chat talks to the owner's home: the dev bot, Claude Haiku, and the hand-installed `9.0.0-chat` Engine, over the home broker or the ZigDash relay. Plan: [docs/design/whatsapp-assistant.md](../../docs/design/whatsapp-assistant.md), "Revision 6". Nobody else links in this milestone.

Files: `service.mjs` (start), `agent.mjs` (Claude loop, caps, confirmations, memory), `link.mjs` + `wire.mjs` (sealed requests to the Engine), `telegram.mjs` (long polling), `keystore.mjs` (encrypted keys), `metrics.mjs` (counters-only logs), `cli.mjs` (link a Home by hand), `replay-test.mjs`. The Engine side is `hub/src/chat.js`.

What it does in code, whatever the model says: changes only devices on the client's control list, never locks, valves or sirens (the Engine checks both); asks "Reply yes within 60 seconds" before anything touching more than 5 devices, and only that chat's next "yes" runs it; stops at 6 tool calls or 20 s; answers only the chat ids in the allowlist (anyone else gets nothing and leaves only an `ignored` counter); logs counters only.

Tests (fake Telegram, fake Claude, a local mosquitto when installed, otherwise an in-process broker):

```sh
cd tool/zigdash-chat && pnpm install
env -u NODE_OPTIONS node --test test/*.test.mjs
env -u NODE_OPTIONS node --test ../../hub/test/*.test.js     # the Engine, chat build included
```

## 1. The 9.0.0-chat Engine on the owner's hub

```sh
env -u NODE_OPTIONS node hub/build.mjs --chat            # writes hub/build/zigdash-engine.js (not in git)
```

It replaces `zigdash-engine.js` itself (a second file would run two Engines and fire every automation twice). Its version is above any release, so the app's silent update leaves it alone. Install it the way the app does, from a computer at home:

```sh
jq -n --rawfile code hub/build/zigdash-engine.js '{name:"zigdash-engine.js", code:$code}' > /tmp/engine-save.json
mosquitto_pub -h 192.168.68.64 -t zigbee2mqtt/bridge/request/extension/save -f /tmp/engine-save.json
mosquitto_sub -h 192.168.68.64 -t zigdash/automations/state -C 1    # "engine":"9.0.0-chat"
```

Acceptance: after opening the app at home, the hub still reports `9.0.0-chat`. To go back, save `hub/zigdash-engine.js` (the release) the same way.

## 2. Local, against the home broker

Files under `~/.config/zigdash/` (mode 600; never printed or logged): `dev_bot_token` (the dev bot from BotFather, not @ZigDashHomeBot), `dev_allowed_chat_ids` (one chat id per line), `anthropic_key` (or `ANTHROPIC_API_KEY`). The CLI creates `chat-secrets.json` (the service key) and `chat-keys.json` (token and key per client, encrypted with it).

```sh
cd tool/zigdash-chat && pnpm install
export ZIGDASH_MQTT_URL=mqtt://192.168.68.64:1883     # plus ZIGDASH_MQTT_USER / ZIGDASH_MQTT_PASSWORD_FILE if the broker needs a login

# Link the Home: a Chat client on the Engine, control list by name or IEEE address.
env -u NODE_OPTIONS node cli.mjs create --id tg1 --name "Owner's Telegram" \
  --controls "Office shutter,Hall light,Kitchen light" --home-id <relay home id>
env -u NODE_OPTIONS node service.mjs
```

The relay home id is `homeId` in `zigdash-remote.json` in the Zigbee2MQTT data folder. Other commands:

```sh
env -u NODE_OPTIONS node cli.mjs list
env -u NODE_OPTIONS node cli.mjs set-controls tg1 "Office shutter,Desk lamp"   # the whole list; --scope read|control
env -u NODE_OPTIONS node cli.mjs audit tg1 --limit 20                         # sealed request; works over the relay too
env -u NODE_OPTIONS node cli.mjs audit --retained                             # every client, from the broker (at home)
env -u NODE_OPTIONS node cli.mjs revoke tg1 --hub-only                        # the acceptance test: Engine copy only
env -u NODE_OPTIONS node cli.mjs revoke tg1                                   # Engine copy and local keys
env -u NODE_OPTIONS node cli.mjs topics tg1                                   # the relay topics, for step 3
```

`create`, `set-controls` and `revoke` write retained config on the hub's broker, so they run at home (`ZIGDASH_TRANSPORT=broker`), never through the relay: a service that could change its own control list from away would defeat it.

## 3. On grocery-vps, through the relay

1. **A broker login for the service** that can use only this client's two opaque topics (`node cli.mjs topics tg1` prints them), on the relay host:

   ```sh
   cd relay/deploy
   ctrl() { docker compose exec mosquitto mosquitto_ctrl -u admin -P "$ADMIN_PASSWORD" dynsec "$@"; }
   ctrl createRole chat-tg1
   ctrl addRoleACL chat-tg1 publishClientSend    homes/<home>/x/<request id> allow
   ctrl addRoleACL chat-tg1 subscribeLiteral     homes/<home>/x/<answer id>  allow
   ctrl addRoleACL chat-tg1 publishClientReceive homes/<home>/x/<answer id>  allow
   ctrl createClient zigdash-chat               # asks for a password
   ctrl addClientRole zigdash-chat chat-tg1
   ```

   The hub's own login already covers `homes/<home>/#`; the relay itself doesn't change.
2. **Files**, copied from the computer that ran `create` (the keys and the service key in separate folders):

   ```sh
   ssh vps 'install -d -m 700 /srv/zigdash-chat/config /srv/zigdash-chat/secrets'
   scp ~/.config/zigdash/{dev_bot_token,dev_allowed_chat_ids,anthropic_key,chat-keys.json} vps:/srv/zigdash-chat/config/
   scp ~/.config/zigdash/chat-secrets.json vps:/srv/zigdash-chat/secrets/
   # and the relay password from step 1 into /srv/zigdash-chat/config/relay_password; then chmod 600, chown 1000:1000 all
   ```
3. **Run** (`deploy/.env`: `CHAT_CONFIG_DIR=/srv/zigdash-chat/config`, `CHAT_SECRETS_DIR=/srv/zigdash-chat/secrets`, `CHAT_RELAY_USER=zigdash-chat`):

   ```sh
   cd tool/zigdash-chat/deploy && docker compose up -d --build
   docker compose logs -f chat                  # counters only
   docker compose run --rm chat node replay-test.mjs --after 5,180
   docker compose run --rm chat node cli.mjs audit tg1
   ```

## Acceptance (plan revision 6), from Telegram on mobile data

"close the office shutter" closes it through the relay; "is the front door closed?" answers from live state; "turn off the valve" (or a lock) gets "Open ZigDash to do that"; a plug off the control list is refused; "turn off everything" asks first, touches only listed devices, and only "yes" runs it; `replay-test.mjs --after 5,180` shows both replays rejected and audited; after `cli.mjs revoke tg1 --hub-only` (at home) a message gets "not linked" and the audit says `refused: not linked`; another Telegram account gets no reply and leaves no log line; the `message` log lines give latency (median under 8 s over 20 messages) and `cost_usd` per message.
