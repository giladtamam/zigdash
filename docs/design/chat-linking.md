# ZigDash Chat, phase 3: linking from the app, for Pro owners (v1)

Part of [whatsapp-assistant.md](whatsapp-assistant.md), revision 6.1 (start now, Telegram first, Pro owners
as a free beta). Milestone 1 works end to end on the owner's home (Nov 15): the hand-installed 9.0.0-chat
Engine, `zigdash-chat` on grocery-vps through the relay, the dev bot. This plan turns it into something a
Pro owner can switch on from the app without anyone touching a server.

## What changes

### 1. The Engine: chat in every release, dormant until linked
- The chat code (hub/src/chat.js) moves into the release Engine (next version, e.g. 3.7.0). It does
  nothing until a Chat client's retained config exists: no extra subscriptions to device topics, no relay
  topics, no CPU. A test asserts the dormant Engine behaves like 3.4.5 (rules, alerts, history, relay).
- The owner's hub goes back from `9.0.0-chat` to the release numbering by installing 3.7.0 by hand; its
  client `tg1` keeps working (same config format).

### 2. The service: many homes, linking over HTTPS
- `zigdash-chat` serves `https://chat.zigdash.app` (Caddy on grocery-vps, like relay.zigdash.app):
  - `POST /v1/link` from the phone: `{home_id, client_id, token, key, scope}` with the phone's **relay
    credential** (HTTP Basic, the same login the app uses for the relay). The service checks it by calling
    the verifier's existing `GET /v1/homes/<id>/phones` with that credential (200 = a phone of a Pro home);
    no verifier change. It returns a 6-character code, kept unclaimed 10 minutes, 5 tries an hour per
    home.
  - `POST /v1/link/confirm` `{code_back}` from the same phone: finishes the claim (step 4 below).
  - `DELETE /v1/link/<client_id>` from a phone of that home: deletes the binding, token, key and
    conversation at once.
- **Keys at rest:** one encrypted record per binding (as the milestone 1 keystore, many entries); the
  service key in its separate secrets folder.
- **Relay access:** the service's relay login gets `homes/+/x/#` (send and receive) instead of one home's
  two topics: every request it sends is sealed with a per-client key, opaque topics can't be guessed, and
  it still can't read the phones' `s/` and `c/` traffic. One ACL change on the relay, documented.
- **The live bot:** @ZigDashHomeBot's webhook moves from the support Worker to `zigdash-chat`
  (`https://chat.zigdash.app/v1/tg/<secret>`, secret header checked, 200 at once, work in the background,
  repeated `update_id`s dropped). `/start early_c|early_n` is passed to the Worker's early-access logic
  over HTTPS with a server secret, so the list keeps working exactly as today; `/stop` keeps meaning "off
  the early-access list"; `/unlink` unlinks (with a confirm). Switched only after both flows pass on the
  dev bot, with a one-command rollback (set the webhook back to the Worker).

### 3. The app: Home settings › Chat (Play Pro only)
Shown on a Home when all hold: Play flavor, Pro owned (not the trial), the Engine installed, remote on.
Otherwise the row explains what is missing (remote off → "Turn on remote control first").
1. **Intro:** what Chat is, what it can and can't do (never locks, valves, sirens), that it's a free beta
   with 300 messages a month, and in plain words who reads the messages: Telegram, our server, Anthropic
   (Claude). Link to the policy section.
2. **Scope:** Read, or Read and control. Read is pre-selected.
3. **Control list** (Read and control only): every device that can be changed, with switches. Defaults:
   lights, switches, thermostats and covers on a dashboard tile on; plugs on only if on a tile; covers and
   plugs whose name or dashboard says gate, garage, door (a word list per app language: Tor, poort,
   portail, שער, …) off; locks, valves, sirens not listed (never controllable).
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
  notes. The EU representative was skipped by the owner on 2026-10-22; that stays the owner's decision.
- Analytics: `chat_link {step: intro | linked | removed | failed, why}`, counts only.

### 5. Beta size and costs
- Pro owners only (single digits today); 300 messages a Home a month, enforced by the service; a global
  monthly model budget of $20 that pauses chat (with a message) when reached.
- The founders' invite (remote in the app too, 3 months from the invite) and the card wording ("We're
  building it") ship in the same release; the founder pass gets its own small plan in this phase.

## Tests
- Engine: dormant equals 3.4.5 behaviour; a client created from the app's config format works.
- Service: link with a valid phone credential, with a wrong one (401), an expired or reused code, 5 tries,
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
About 9–12 days: Engine merge 1, service linking and webhook 3, app screen 4, policy and forms 1, tests and
lab runs 2.
