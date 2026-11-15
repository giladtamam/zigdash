# ZigDash Chat, phase 3: linking from the app, for Pro owners (v2)

v2 after review (v1 scored 7/10): a verifier ticket instead of the phone's password, founders later,
stricter control-list defaults, the legal items reconciled with the main plan, the webhook details.

Part of [whatsapp-assistant.md](whatsapp-assistant.md), revision 6.1 (start now, Telegram first, Pro owners
as a free beta). Milestone 1 works end to end on the owner's home (Nov 15): the hand-installed 9.0.0-chat
Engine, `zigdash-chat` on grocery-vps through the relay, the dev bot. This plan turns it into something a
Pro owner can switch on from the app without anyone touching a server.

## What changes

### 1. The Engine: chat in every release, dormant until linked
- The chat code (hub/src/chat.js) moves into the release Engine (next version, e.g. 3.7.0). Dormant until a
  Chat client exists: it subscribes only to its config topic; no device-topic subscriptions for chat, no
  relay topics, no work. A test asserts the dormant Engine behaves like 3.4.5 (rules, alerts, history,
  relay). Because the app updates Engines silently, every user's hub gets this dormant code; PRIVACY.md
  says so in one line.
- **The sealing key is not left retained:** the app publishes the client config once; the Engine takes
  the key into its data folder (like `zigdash/remote/set`) and clears the retained copy, so broker and
  Home Assistant backups don't carry it. The CLI does the same for the owner's `tg1`.
- The owner's hub goes back from `9.0.0-chat` to the release numbering by installing 3.7.0 by hand; its
  client `tg1` keeps working (same config format).

### 2. The service: many homes, linking over HTTPS
- `zigdash-chat` serves `https://chat.zigdash.app` (Caddy on grocery-vps, like relay.zigdash.app):
  - **The phone's relay password never reaches the chat service.** A new verifier route
    `POST /v1/homes/<id>/chat-ticket` takes the phone's Basic login (as the other routes) and the Pro
    purchase token, re-checks the purchase with Play now (not only at pairing) and that its hash matches
    the Home's binding, and returns a ticket: `{home_id, client_id, request_topic, answer_topic, exp: 10
    min}` signed with HMAC under a secret shared only by the verifier and the chat service. In the same
    step the verifier (which already administers the broker's access control) adds the client's two
    opaque topics to the chat service's role, so the service can use only linked clients' topics, with no
    wildcard. Removing a link removes those two ACL entries.
  - `POST /v1/link` from the phone: `{ticket, token, key, scope}`; the service verifies the ticket's
    signature and expiry, and returns a link code (`L` + 6 characters), kept unclaimed 10 minutes, 5 tries
    an hour per home.
  - `POST /v1/link/confirm` `{code_back}` from the same phone: finishes the claim (step 4 below).
  - `DELETE /v1/link/<client_id>` from a phone of that home: deletes the binding, token, key and
    conversation at once.
- **Keys at rest:** one encrypted record per binding (as the milestone 1 keystore, many entries); the
  service key in its separate secrets folder.
- **Relay access:** per client, added and removed by the verifier at link and unlink (above); the owner's
  `tg1` entries are moved to the same mechanism.
- **The live bot:** @ZigDashHomeBot's webhook moves from the support Worker to `zigdash-chat`
  (`https://chat.zigdash.app/v1/tg/<secret>`, secret header checked, 200 at once, work in the background,
  repeated `update_id`s dropped). `/start early_c|early_n` is passed to the Worker's early-access logic
  over HTTPS with a server secret, so the list keeps working exactly as today; `/stop` keeps meaning "off
  the early-access list"; `/unlink` unlinks (with a confirm). Switched only after both flows pass on the
  dev bot, with a one-command rollback (set the webhook back to the Worker).
  - **The Worker gains one route** for the passthrough, `POST /v1/early/tg` with a server secret, carrying
    the chat id, language and payload; the rest of the early-access logic is unchanged.
  - **Rollback message:** while the webhook is back on the Worker, a message from a linked chat (not
    `/start early_*`) gets "Chat is paused for maintenance; it will be back soon", not the early-access
    reply. The Worker knows linked chat ids from a list the service publishes to its KV at each link and
    unlink.
  - **No collisions:** link codes are `L` + 6 characters from an alphabet without `_`, so `start=<code>`
    can never be `early_c` or `early_n`; a test checks both directions.

### 3. The app: Home settings › Chat (Play Pro only)
Shown on a Home when all hold: Play flavor, Pro owned (not the trial), the Engine installed, remote on.
Otherwise the row explains what is missing (remote off → "Turn on remote control first"). **The App Store
version isn't in this beta** (the ticket route checks Play purchases; iOS follows with the App Store check
the verifier already has); the policy says so.
1. **Intro:** what Chat is, what it can and can't do (never locks, valves, sirens), that it's a free beta
   with 300 messages a month, and in plain words who reads the messages: Telegram, our server, Anthropic
   (Claude). Link to the policy section.
2. **Scope:** Read, or Read and control. Read is pre-selected.
3. **Control list** (Read and control only): every device that can be changed, with switches. Defaults:
   **on** only for lights and covers that have a dashboard tile; **off** for switches (in-wall relays can
   run a boiler or a pump), plugs and thermostats until the person turns them on; covers whose name or
   dashboard says gate, garage, door (a word list per app language: Tor, poort, portail, שער, …) off;
   locks, valves, sirens not listed (never controllable).
4. **Link:** the phone creates the client on the hub (at home, over the LAN: it publishes retained config,
   like the CLI), calls `/v1/link`, then opens `t.me/ZigDashHomeBot?start=<code>`. The bot claims it and
   sends that chat a 4-digit code; the app asks for it; `/v1/link/confirm` activates. Away from home: the
   link button says "Link at home: ZigDash sets this up on your hub over your home network."
5. **After linking:** a list of linked Telegram accounts (name from Telegram, scope, last used), **What
   Chat did** (the Engine's audit log over the relay or LAN), **Remove** for each (service first, then the
   hub; if the hub is unreachable the service side alone already ends access).
6. **Family members:** each person links their own account the same way, as a separate client, with its
   own scope and list. The screen says linked people must be 16 or older and that anyone using that
   Telegram account can do what the scope allows; even Read shows whether anyone is home.

### 4. Policy, store forms and the record (before the release)
- PRIVACY.md: a "ZigDash Chat (beta)" section with every item in the main plan's "Privacy and legal"
  list (what the service reads, Telegram and Anthropic as processors, the US transfer and Anthropic's API
  retention as in force on the day, where the service runs: netcup, Vienna, already under the netcup DPA
  that covers all contracts, 24-hour conversation memory, counters-only logs, unlink and deletion, age 16).
- Play Data Safety: messages, user IDs (Telegram id) and device data, collected for linked Homes.
- The Art. 30 record gets a Chat entry; a short DPIA (home presence data) written and kept with the legal
  notes.
- **Relay ticket 11, reconciled with the main plan (a release blocker until both hold):**
  - **Hoster DPA:** recorded on 2026-10-22 as concluded in netcup's customer panel (Master Data › Order
    processing, created 2026-09-19, covering all contracts). Before release the owner re-confirms it is
    still listed there.
  - **EU representative:** the owner decided on 2026-10-22 to skip it. For Chat, a written Art. 27(2)
    note (occasional processing, scale, risk) goes into the legal notes before release; if the DPIA
    concludes the presence data makes Chat high-risk, the exemption doesn't hold and the representative
    (or not opening the beta to EU users) is the owner's decision then.
- Analytics: `chat_link {step: intro | linked | removed | failed, why}`, counts only.

### 5. Beta size and costs
- Pro owners only (single digits today); 300 messages a Home a month, enforced by the service; a global
  monthly model budget of $20 that pauses chat (with a message) when reached.
- **Founders are not in this release.** Linking needs a relay login that only a Pro purchase gives today, so
  their pass needs its own verifier change; it gets its own plan, and founders are invited when it ships,
  their 3 months starting then. The card wording ("We're building it") does ship in this release.

## Tests
- Engine: dormant equals 3.4.5 behaviour; a client created from the app's config format works.
- Verifier: the ticket route with a valid phone and purchase, a wrong login (401), a refunded or other
  purchase (402), the ACL entries added and removed.
- Service: link with a valid ticket, a forged or expired one, an expired or reused code, 5 tries,
  the back-code (3 wrong cancel), remove, many homes isolated from each other, the webhook passthrough for
  early access, `/stop` never unlinks, update_id dedupe, the monthly cap and the budget pause.
- App: the row's conditions; scope; the control-list defaults (plugs, gate words in 13 languages, locks
  never listed); link at home, refused away; back-code; remove; family list; emulator screenshots, and a
  Samsung lab run.

## Release and read
- One app release (3.7.0) with the dormant Engine, the Chat screen hidden behind Pro, the founders' part,
  the card wording, the policy. Live bot switch after the release is live.
- Read at 8 weeks after the beta opens: the main plan's success bar (linked ≥ max(2, 30% of eligible
  Homes), still messaging in week 4 ≥ half of them), cost per active Home, and refusals.

## Effort
About 12–15 days: Engine merge and key handling 1.5, verifier ticket and ACL 1.5, service linking and
webhook with the Worker route 3, app screen 4, policy, forms and the Art. 27(2) note 1.5, tests and lab
runs 2. The founder pass is separate.
