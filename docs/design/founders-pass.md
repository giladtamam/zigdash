# Founders' pass: the early-access promise, kept (plan, rev 3.2, 2026-11-16; scored 9/10)

Rev 1 scored 5/10, rev 2 7/10, rev 3 8/10, rev 3.1 9/10. Rev 3.2 settles the last five minor points
(revoke keeps the pass's date, the chat service fails open on its status check, tombstone retention,
the clearing client's lifecycle, Get help needs an email). Rev 3.1: an internal listener for the chat service, replies
through Get help (the webhook keeps no free text), no lock across the push, the 402 passed through `acl()`,
and small gaps. Rev 3: deletion really deletes (retained relay topics, Chat links via a
tombstone and a push), upgrade only with consent, extend re-enables, a working reply path for the invite,
and the smaller fixes (status cache, Engine backoff, link refusal, attempt ceiling, redeem retry, sweep
races, 410 after deletion, devices without billing, invite dry run).

## Why
The "Chat with your home" early-access card and bot (3.5.4) told every joiner at position 1–20: **"one of
the first 20: you get it free for 3 months, remote access included."** Chat shipped in 3.7.0 for Pro
owners only, because linking needs a relay login that only a Pro purchase gives (chat-linking.md §5).
Three people are on the list today. This plan keeps the promise without giving away Pro.

## What a founder gets
- **Remote control and Chat for one Home, 90 days from the day the code is entered.** Not the other Pro
  features (30-day History, wall-tablet extras, more than three automations).
- After 90 days remote control and Chat stop; the app offers Pro (one-time), which brings both back with
  nothing to re-pair: same Home, phones and Chat links. Unless upgraded, the Home is deleted 90 days later.
- Requirements, stated in the invite: the Google Play app (3.7 or later), a Home connected to its MQTT
  broker (not through Home Assistant or Zigbee2MQTT's page), ZigDash Engine on the hub. Anyone who can't
  meet them by the deadline asks and the owner extends the code.
- One code, one Home. The code must be entered by `redeem_by` (default 60 days after the invite).

## Codes
- Format `ZD-XXXX-XXXX-XX`, Crockford base32 (no I, L, O, U): 50 random bits.
- Stored as `HMAC-SHA256(PASS_SECRET, normalised)`, `PASS_SECRET` from `PASS_SECRET_FILE` (mode 600, not
  in the database or its backups). Normalised: upper case; spaces and dashes removed; I,L→1, O→0. Every
  route normalises before hashing. Purchase key `founder:<hmac>`.
- **A code admits once**, with one retry window: the app sends a random `redeem_nonce`; a repeat of the same
  code with the same nonce within 15 minutes (a lost response) returns fresh hub and phone logins for the
  same Home; any other later use is refused (409 "code already used"). So a forwarded code can't reset the
  hub's login or add a phone. A founder who reinstalls recovers as anyone does (key backup, or a QR from
  another phone); `passes reissue <home>` gives a lost founder a new code bound to the same Home.
- CLI (`docker compose exec verifier node cli.mjs ...`): `passes new --count N --days 90 --redeem-by D`
  (prints codes once, never logged); `passes list`; `passes revoke <prefix>` (sets `passes.revoked_at` and
  `homes.expires_at = now` if redeemed; `passes.expires_at` stays as the record); `passes extend <prefix> [--redeem-by D] [--days N]` (if the Home was
  disabled, runs the re-enable path below); `passes sweep` (runs the sweep now); `passes unrevoke <prefix>` (clears `revoked_at`, copies
  `passes.expires_at` back to `homes.expires_at`, re-enables if still in time); `homes delete <id>` (the deletion steps below for any Home, a purchase
  Home too, used for deletion requests by email, so its Chat links go with it).
- Guessing: per-IP limit as today, keyed by /64 for IPv6, with old keys evicted; a global counter of failed
  code attempts that **only logs** above 1,000 an hour. 50 bits make guessing hopeless.

## Verifier (relay/verifier)
- **Schema.** `passes(hash pk, created, redeem_by, days, redeemed_at, redeem_nonce, expires_at,
  revoked_at, home)`; `chat_acls(home, request_topic, answer_topic, pk(home, request_topic))`;
  `tombstones(home pk, deleted_at)`. `homes` gains `kind` (null = purchase, `founder`), `expires_at`,
  `disabled_at`, via `ALTER TABLE` guarded by `pragma table_info`. The insert into `homes` names its
  columns. Test: open a database file with the old schema.
- **`entitled(home)`**: purchase Homes as today; founder Homes while `now < expires_at` and not revoked.
  Checked by `POST /v1/homes/<id>/hub`, `POST /v1/homes/<id>/phones`, `chat-ticket` (link topics) and
  internal `chat-acl add`; a refused `add` answers **402 `pass_ended`** (final, not 503).
- **Disable / re-enable** (one path each, per-Home lock, re-checking `kind`/`expires_at` before every broker
  command):
  - *disable*: dynsec `disableClient` for `hub-<id>` and each phone (the broker drops them and refuses them
    while disabled; the flag persists), `removeRoleACL` for each stored `chat_acls` row, set `disabled_at`.
  - *re-enable* (upgrade, extend, revoke undone): `enableClient` for all, `addRoleACL` for each stored row,
    clear `disabled_at`, then `POST` the chat service's internal `/v1/internal/home-changed` so it drops
    its cached status.
- **Sweep** (hourly, at start, and `passes sweep`): founder Homes past `expires_at` with no `disabled_at` →
  disable. Founder Homes 90 days past `expires_at` → **delete**:
  1. Clear the relay's retained data: create a temporary client in role `home-<id>` (its ACLs allow
     subscribe and publish on `homes/<id>/#`), subscribe at QoS 0 to `homes/<id>/#`, publish an empty
     retained message on every topic received, unsubscribe; repeat the subscribe until a round brings
     nothing (at most 20 rounds, 3 s quiet each, because the broker queues at most 200 messages), then delete
     the client. The client has a random username, password and clientId and is deleted in a `finally`
     (a crash or timeout never leaves a live login). If 20 rounds pass without a quiet one, log it, keep
     the role and the rows, and let the next sweep retry. Only after a quiet round the role. Test it against eclipse-mosquitto 2.1.2 with 500 retained topics.
  2. Delete the hub and phone clients, the role `home-<id>`, the `chat_acls` rows (removing the ACLs),
     the `homes` and `phones` rows; write `tombstones(home, now)`; `passes` keeps hash, dates, `home`.
  3. **Release the per-Home lock**, then `POST` the chat service's internal `/v1/internal/home-deleted
     {home_id}` (retried by later sweeps until it answers 200). The service answers 200 at once and removes
     the bindings afterwards; its `acl('remove')` calls don't take the lock (a missing Home is fine).
  Tombstones are deleted a year after `deleted_at`; pass rows a year after `created` (or after their
  Home's tombstone, whichever is later).
- **Upgrade** `POST /v1/homes/<id>/upgrade` (phone login; `{purchaseToken, store}`; during or after the pass,
  before deletion): purchase check as `/v1/homes`; 409 if that purchase already has a Home; set
  `token_hash`, `kind = null`, `expires_at = null`; re-enable if disabled. No re-pairing, works away.
- **Founder Chat tickets** use the phone's login only (no purchase token; the route checks the Home's
  `kind` before today's 400 "purchase_token missing"), so second phones, restores and
  family phones work. After the pass ends, tickets carry no link topics, so the chat service can only list and
  remove (it already refuses a link without topics: `ticket_without_client`). No new ticket field.
- **Status.** `GET /v1/homes/<id>` (phone login): `{kind, expires_at, ended}`. For a tombstoned Home,
  **410 `deleted`** without auth (the Home ID is not a secret worth guarding; it reveals only "deleted").
  Internal `GET /v1/internal/home/<id>` (the internal handler gains this route beside `POST
  /v1/internal/chat-acl`): `{entitled, ended_at}` or 410 from a tombstone; an unknown Home is
  404 and means **no action** (never "deleted"), so a lost or restored database can't unlink anyone.

## Chat service (tool/zigdash-chat)
- Before the model call for a bound chat, check the Home's status: entitled → go on (cached 10 minutes);
  verifier unreachable (timeout or 5xx) → the last cached status, or entitled if none (the broker still
  enforces the end: disabled clients, removed ACLs), with a counter in the logs;
  not entitled → cached **1 minute**, reply once per chat "This Home's founder's pass ended on <date>.
  ZigDash Pro keeps Chat: open ZigDash to get it." (then at most once a day), no model call.
- `/v1/internal/home-changed` drops the cache entry; `/v1/internal/home-deleted` removes every binding of
  that Home with `removeBinding(b, {reason: 'pass_ended'})`, which sends one message ("This chat was unlinked:
  the founder's pass ended.") instead of the usual one. A 410 from the status route does the same (catch-up).
- `acl()` (bot.mjs) returns the verifier's status instead of true/false; `confirmLink` treats 402
  `pass_ended` as final (link dropped, the app told `pass_ended`), other failures stay 503 `try_again`. The
  README's error table gains `pass_ended`.
- The "ended" notice per chat is recorded in `chat-state.json` (survives restarts) and cleared by
  `home-changed`.
- **A second listener `INTERNAL_PORT` (8791)** for `/v1/internal/home-changed` and `/home-deleted`, copied
  from the verifier's pattern: not published on the host, not under Caddy (Caddy proxies only 8790), refuses
  any request with `x-forwarded-for`, `forwarded` or `x-real-ip`, and requires `X-Chat-Acl-Secret` (the
  existing chat-acl secret, other direction). The verifier reaches it at `CHAT_INTERNAL_URL`
  (`http://zigdash-chat-chat-1:8791`; both containers are on the edge network). Tests: forwarding headers
  refused, no secret refused.
- **Deploy order:** chat service before the verifier.

## Engine (hub/src/engine.js)
- On a refused relay login (CONNACK 134/135, or 4/5 for MQTT 3.1.1; checked against a disabled client on
  eclipse-mosquitto 2.1.2 in a test), back off by setting `client.options.reconnectPeriod`: 15 s doubling to
  **5 minutes**, reset on success. Status keeps `remote.connected` and adds `remote.error: "refused"`; the app's EngineStatus parses
  it so the Remote screen can say "The relay refused this hub's login" (passEnded itself comes from the
  relay's 402/410).
- The hub keeps its stored relay login and key until remote control is turned off; the policy says so.

## Invites (support Worker, based on feat/support-reply)
- Worker changes go on top of `feat/support-reply` (the live Worker, with Resend), merged into the founders
  branch.
- `POST /v1/early/invite`, header `X-ZigDash-Admin` compared with `sameSecret` against `EARLY_ADMIN_SECRET`;
  body `{codes: [..], redeem_by, dry_run?}`. Lists `early:email:*` and `early:tg:*` only, takes entries with
  **`position <= 20` whatever `counted` says** (it is only the analytics flag), duplicated positions
  included, not yet invited, by position. `dry_run: true` answers `{eligible: n}` only, so the owner makes
  exactly that many codes. Otherwise pairs each with the next code and sends:
  - Telegram: through @ZigDashHomeBot (the Worker's bot token);
  - email: Resend, new `inviteEmail()`: from `Gilad from ZigDash <support@zigdash.app>`, `reply_to` the
    support inbox (as `answerEmail`), no BCC, subject "Your ZigDash founder's code", idempotency key
    `invite-<position>-<first 12 hex of the code's HMAC>`.
  Writes `invited: <date>` with the entry's **remaining** TTL; never stores the code. Answers
  `{sent, failed: [{position, why}]}` (no codes, no addresses).
- **Replies.** The webhook (zigdash-chat) forwards no free text to the Worker, on purpose, and stays so.
  Questions go through Get help in the app (which reaches the owner and is answerable by email), or by
  replying to the invite email (its `reply_to` is the support inbox). The bot's answer to a listed entry
  ("isn't ready yet") becomes: invited → "Your founder's code was sent on <date>. Questions or need more
  time? Write from Get help in the ZigDash app (Settings › Get help) and add your email so I can answer."; not invited → the place line plus
  "Chat is out for Pro owners; you'll get your founder's code soon."
- Message, in the entry's language (the app's 13, else English): "You're one of the first 20 on the ZigDash
  Chat list, so here is your founder's code: ZD-XXXX-XXXX-XX. It gives one Home remote control and Chat for
  3 months, free, from the day you enter it. You need ZigDash 3.7 or later from Google Play, a Home
  connected to its MQTT broker, and ZigDash Engine on your hub. Open Settings › Home › Remote control, tap
  "Have a founder's code?" and enter it by <redeem_by>. Questions or need more time? Write from Get help in
  the app and add your email so I can answer" (email adds "or reply to this email").
- Owner script (Mac): dry run → count; the owner makes that many codes; script sends from a file, admin secret
  from `~/.config/zigdash` (never printed), prints counts.

## App
- **Status from the relay, per connection:** `founderStatusProvider(connectionId)`, cached with the remote
  login (keyed by connectionId like `RemoteHomeStore`): `{kind, expires_at}` from `GET /v1/homes/<id>`,
  refreshed on the Remote and Chat screens and at most daily; 410 → `deleted`. The code isn't kept.
- **Not gated on billing:** on the Play flavour the code field and a founder's Chat row show even when Play
  billing is unavailable (`remoteSoldProvider` and `chatRowStateOf` accept an active founder status instead
  of Pro; a founder Home doesn't need billing).
- **Redeem:** Remote control screen without Pro: "Have a founder's code?" opens a field (case, spaces, dashes
  ignored). Setup as today with `store: "founder"` and a `redeem_nonce` kept until success (a retry after a
  lost response reuses it). Errors: wrong code, already used, deadline passed, revoked, network.
- **Gating:** Remote screen and `chatRowStateOf` treat an active founder status like Pro; nothing else.
- **Remote state `passEnded`** (cached status, or 402/410 from the verifier): hides Reconnect hub and Phones;
  "Your founder's pass ended on 14 Feb. ZigDash Pro brings remote control and Chat back, with nothing to set
  up again." + Get Pro; after deletion: "This Home's founder's pass ended and its remote control was removed."
  + Set up with Pro. 7 days before the end both screens show the date and Get Pro.
- **Chat screen after the end:** lists and removes links; Link replaced by the Pro line; `ChatFail.purchase`
  says "the founder's pass ended" for a founder Home; `pass_ended` from confirm shows the same.
- **Upgrade only with consent.** Get Pro from a founder line remembers "for this Home"; when that purchase
  succeeds the app calls `/upgrade` (retried on network errors only; stops on 409, 401, 404, 410). If Pro is
  bought elsewhere while a founder Home exists, the Remote screen offers "Use your Pro purchase for this
  Home?" with a confirm; nothing happens without it. 409 → "That purchase already belongs to another Home."
- Strings in 13 languages. Analytics: none new.

## Policy, store, legal
- **Remote control:** "part of ZigDash Pro or a founder's pass"; for a pass the relay keeps the code's keyed
  hash, the dates and the Home, and for Chat the topics it granted; at the end a founder Home is switched off,
  and unless upgraded it is deleted 90 days later with its relay data (retained messages, logins, Chat
  access), leaving only a note that it existed and was deleted for a year; the hub keeps its relay login and
  key until remote control is turned off on it.
- **Chat:** "owners of ZigDash Pro or a founder's pass"; "asks Google Play" → "checks the purchase or the
  pass"; after a pass ends links can be listed and removed, and are deleted when the Home is.
- **Data stored on your device:** the founder status cached with the remote login (no code).
- **Early access:** the invite sends the code once by Telegram or by email through Resend (which keeps a
  copy of sent emails under its terms); questions go through Get help or a reply to the email, like support
  messages; the entry records
  the invite date and is deleted under the existing rule.
- Art. 30: relay entry gains the pass, `chat_acls` and tombstones. Data Safety: no new type.

## Tests
- Verifier: redeem; nonce retry within 15 min; other second use refused; deadline; revoked; reissue; after
  expiry `/hub`, `POST /phones`, re-pair and chat-acl `add` (402) refused, list/remove tickets allowed;
  sweep disables once (`disabled_at`), removes ACLs; upgrade/extend re-enable and re-add ACLs and notify the
  service; race (upgrade during sweep); deletion clears retained topics (broker test), deletes clients, role,
  rows, writes a tombstone and notifies; 410 after deletion; unknown Home → 404 not deleted; old-schema
  database; normalisation; /64 limiting; log-only ceiling; no lock held across the push; `homes delete` on a
  purchase Home writes a tombstone and pushes; unrevoke re-enables; founder ticket without purchase_token.
- Chat service: ended → one notice (persisted), no model call, 1-minute cache; home-changed drops cache and
  the notice; home-deleted answers 200 first, then removes bindings with one message; 410 the same; 402 on
  confirm is final; unknown Home → nothing; internal listener refuses forwarding headers and a missing secret; verifier down → last cached status,
  else entitled.
- Engine: refused login backoff to 5 minutes, reset on success.
- Worker: dry run count; picks by position ≤ 20 incl. uncounted and duplicated; skips invited and other keys;
  remaining TTL; Telegram and email paths (reply_to, no BCC, idempotency key); no code stored; languages;
  new bot replies (Get help pointer).
- App: redeem incl. nonce retry; gating without billing; passEnded and deleted states; manage-only Chat;
  upgrade only with consent, stop codes.

## Rollout
1. `feat/founders` from `feat/chat-3.7` with `feat/support-reply` merged; all tests green.
2. Owner deploys: chat service (script), then verifier (script; creates `PASS_SECRET_FILE`), then Worker
   (paste) with `EARLY_ADMIN_SECRET`.
3. App 3.7.0+119 to internal testing; owner test on the emulator Home: code → remote → Chat link →
   `passes extend --days 0` + `passes sweep` → passEnded, Chat notice → licence-test purchase from the
   founder line → upgrade → remote and Chat back.
4. With 3.7.0 on production: invite dry run, `passes new --count <eligible>`, run the invite.
