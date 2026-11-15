# Your home in a chat: a messaging assistant for ZigDash Pro (plan)

Drafted 2026-11-12, revision 4 after three independent reviews (revisions 1–4 scored 5, 7, 8 and 9 out of 10). Revision 5.1 (2026-11-15, scored 9/10) adds the Shelly AI Assistant as the first big competitor and a proposed change of shape (a small free cap in the app for everyone, the bigger cap in Plus); see [Competitor: Shelly](#competitor-shelly-ai-assistant-2026-11-15). Status: plan, not built; the early-access read ([assistant-early-access.md](assistant-early-access.md), ~Jan 13) still decides whether it is built. Working name **ZigDash Chat** ("Chat with your home" in the app).
Words follow [CONTEXT.md](../../CONTEXT.md): **Home**, **Engine**, **Automation**, **Alert**, **AI client** (from `docs/design/mcp-engine.md` on the local branch `docs/mcp-engine`).

## The idea in one paragraph

Instinct (Spear Street Technology) showed that people will text an assistant on WhatsApp instead of opening an app. ZigDash Chat does the same for one thing only: **your own Zigbee home**. You message it "is the back door closed?", "turn off everything downstairs", "how cold was the bedroom last night?", "why didn't the hall light come on?", and it answers or acts. It knows nothing else and does nothing else.

Owner decisions taken on 2026-11-12:
- **Control and answers**, not advice only.
- **For ZigDash Pro users**, linked from the app, through the existing relay and Engine.
- **WhatsApp and Telegram** on one core.

What the reviews changed, and why (the owner should read this part):
1. **Telegram goes first, WhatsApp second.** WhatsApp is not cheap for a chat. Since 2026-10-01, replies inside the 24-hour window are billed at the country's utility rate ([Wati](https://support.wati.io/en/articles/16954666-whatsapp-business-platform-api-pricing-changes-service-messages-and-click-to-message-ads), [Courier](https://www.courier.com/blog/whatsapp-pricing-changes-october-2026)). Some vendors mention 1,000 free a month per business number (shared by all users); that is unconfirmed, so this plan budgets as if it doesn't exist. Utility rates: about $0.066 a message in Germany, $0.060 in the Netherlands, $0.006 in Israel, $0.004 in the US (third-party copies of Meta's card; confirm on Meta's page). A German home sending 10 messages a day costs about $20 a month. Telegram costs nothing and needs no business verification.
2. **It starts after February**, unless the owner changes the roadmap. [roadmap-2026-11.md](roadmap-2026-11.md) §6 says no subscription in Nov–Feb, and the only recurring product to consider is the "ZigDash Remote" add-on once remote has 20 Pro Homes. The live Pro screen promises "Every Pro feature that comes later, at no extra cost", so a paid Chat add-on has to be part of that Remote decision, not a new Pro feature.
3. **No unlocking from a chat.** A "reply YES" doesn't help if someone else is holding the phone.

## Why it could work, and why it might not

For:
- No new app to open, including for family members who never installed ZigDash.
- The Engine already has what a chat needs: device state, history, Automations with their Recent runs, Alerts. The MCP spike (`spike/mcp`, 2026-10-27) proved an AI can answer and control the real SMHUB through it.
- It makes remote access visible every day (remote events: 9 in the 30 days to Nov 6).

Against:
- **The audience is tiny today.** It needs Pro, the Engine and remote. The Engine was installed by 4 of the 28 people offered it (30 days to Nov 6). Pro sales are in single digits. Setup is still the bottleneck: 14% of setups succeeded Oct 31–Nov 8.
- **The relay's privacy promise doesn't hold for Homes that opt in.** Our service, the messaging company and Anthropic all read what Chat answers.
- **Meta.** The 2026-01-15 ban is aimed at providers whose AI assistant *is* the product (ChatGPT, Perplexity). A bot that controls the customer's own devices is a business function and probably allowed, but Meta decides. Some Instinct users said WhatsApp banned their accounts ([Analytics Insight](https://www.analyticsinsight.net/news/instinct-ai-returns-to-whatsapp-after-outage-what-caused-the-disruption), one report). The practical blockers are business verification (needs a legal entity), display-name review and template approval.

## Competitor: Shelly AI Assistant (2026-11-15)

Read from Shelly's own page (shelly.com/pages/shelly-ai-assistant) and German tech press (Galaxus,
smarthomeassistent.de, ifun.de), mid-2026. No user reviews found yet. Revision 5.1 after review (rev 5
scored 7/10).

**What it is** (Shelly's page unless marked). Two "AI agents" inside the **Shelly Smart Control** app;
Shelly reports 12,017,247 cloud-connected devices. **SoFi**: text commands, live status, scene building
("Set the house for sleep": lights off, blind down, heating 19 °C). **MitRa**: vague requests ("make the
living room cosy"), whole-home state including power, 20+ languages; voice per one press report. Also:
automation and energy-saving suggestions, troubleshooting help, device recommendations (which sell Shelly
hardware). Shelly's page says users "must always verify critical recommendations"; the press reports that
suggestions are confirmed before they apply and that data is anonymised (Shelly's page says only "GDPR
approved app"). A third agent is announced. Launched as testing: "a work in progress… possible to make
mistakes". Press noted Shelly has not said which model it uses or where data is processed.

**How it is sold.** Every user can use it, with a daily cap (one Shelly page mentions 50 prompts a day; which
tier is unclear). **Premium (€3.99 a month or €35.99 a year, 3 months free)** gives "up to 5× more daily AI
interactions", bundled with a longer event log, failure detection, statistics, monthly energy reports and the
"forgotten lights" reminder. The AI is one item in a general subscription, not a separate product.

**What it changes for this plan.**
1. **Demand is validated by a large brand**, and "chat with your home" stops being novel; within a year people
   will compare against Shelly's. Being second is fine for a niche; being late is not.
2. **Proposed shape (owner decides after the early-access read): a small free cap in the app for everyone,
   the bigger cap only in Plus.** Not in one-time Pro: Plus exists because a one-time payment cannot carry a
   per-message cost (profit plan §5), and the Pro screen's "every Pro feature that comes later, at no extra
   cost" (app_en.arb:1454) would lock chat into Pro for good. So the profit plan's Pro-screen rewording ships
   first, as §5 already requires, and earlier Pro buyers get Plus free within the same fair-use cap, as §5
   promises.
3. **How it would run.**
   - **On the phone, not the Engine.** The model returns the intended action; the app carries it out over
     the MQTT connection it already has. That reaches every working home, not only the few with the Engine
     (installed by 4 of the 28 offered it in the 30 days to Nov 6; see "Against"). Only history and automation questions need the Engine; without it the answer
     says so.
   - **Its own Worker and budget**, not the Get help Worker (which defaults to Opus 5.5 and shares a 100-an-hour
     cap with support). Chat uses **Haiku**: $0.002–0.005 a message with a full tool loop (Cost section).
   - **Free cap: 3 messages a day per install.** Plus: 300 a month (the beta cap below).
   - **Cost at today's volume** (~400 monthly active devices, Console, Nov 13): if 10% use it at 2 a day,
     ~2,400 messages, **about $5–12 a month**; if every active device used the whole free cap, 36,000
     messages, $70–180. A **global monthly budget of $30** for the free tier in the Worker stops the free
     cap until the next month when reached (Plus keeps working). No accounts, so a reinstall gets a fresh
     cap; the global budget bounds that, plus the per-IP rate limit the support Worker already uses.
4. **Privacy.** In the app, device names and states go to our Worker (Cloudflare) and Anthropic from every
   home that uses it, not only Telegram users. Before it ships: a separate opt-in (not the usage-data
   switch), the PRIVACY Summary rewritten, Play Data Safety and Apple labels updated, and **hidden on the
   foss builds** (F-Droid, IzzyOnDroid, GitHub) as the early-access card is, so no NonFreeNet label.
   Said plainly in the app: which model (Anthropic Claude Haiku) and where (Cloudflare, Anthropic, US).
5. **Early access stays honest.** The first 20 keep what they were promised: free for 3 months, remote
   included, on Telegram, with the **Plus cap** (not the free one), then the founding-member price. The
   €2.49 question tested Plus, so the Go bar's price condition (≥ 40% Yes/Maybe) still reads as Plus; the
   free in-app cap needs no price answer.
6. **Where ZigDash differs**, the honest pitch: Shelly's assistant knows Shelly devices; ZigDash's knows
   **any Zigbee2MQTT device**, with no manufacturer cloud between the user and the home, and says which
   model it uses.
7. **Ideas worth taking without AI:** a "forgotten lights" Alert (Premium at Shelly; free here, run by the
   Engine or the phone) and a one-command "good night" scene suggestion.

**Before an in-app build, if the owner picks it** (open question 0):
- **An install id.** The Worker counts "3 a day per install", so the app sends a random id made for chat
  alone (not the analytics session, not the early-access nonce), kept by the Worker for 2 days for the
  count. A new data type ("Device or other IDs") for Data Safety and the privacy text.
- **Safety rules move to the phone.** No locks, valves or sirens, the per-device control list and the
  confirmations were written for the chat service and the Engine; in this shape the app enforces them on
  whatever action the model returns, and refuses anything else.
- **Its own phases, effort and success bar**, written and scored before work starts; the phases, effort and
  kill rule below describe the Telegram shape.
- **One cost figure everywhere:** $0.002–0.005 a message is a full tool loop on Haiku; the ~$0.0003 in
  assistant-early-access.md §10 is a single short command. Budgets use the larger figure.

**What does not change:** no build before the early-access read (≥ 20 counted joins, ≥ 10% of shown, ≥ 40%
price Yes/Maybe, ~Jan 13), and no unlocking from a chat.

## Step 0: demand test (in a regular release, ~1 day, can run now)

- A card on the Devices tab and a row in Settings: "Talk to your home from Telegram or WhatsApp. Coming soon. [I'd use this]". A small sheet asks which: Telegram / WhatsApp / either.
- It records `chat_interest {channel, pro, engine, remote}` **once per install** (a flag on the phone stops repeats; Aptabase has no Home id, so per-install is the unit). **No contact details are collected.** When Chat ships, the same card turns into "It's here" on the phones that tapped it (a flag stored on the phone). Nothing personal to store, delete or declare.
- **Eligible today:** Homes with Pro, the Engine and remote on. Before the card ships, count them from the relay verifier's bound Homes and write the number here (`N = ?`). The Engine had 4 installs and remote 9 events in the 30 days to Nov 6, so N is likely under 10.
- **Gate (both must hold within 4 weeks):**
  - eligible installs tapping: at least **min(3, ⌈N/2⌉)** (rounded up);
  - and at least **15 taps from free installs with a working Home**. This is the main signal while N is tiny: it says whether Chat would sell Pro, which is the only way the eligible group grows.
- If N stays under 10 at the gate, the build starts only with the owner's explicit OK, as a bet on Pro conversion, not on measured use.
- Also read: Telegram vs WhatsApp split. If most choose WhatsApp, and they come from countries where it's expensive, the price section must be rerun before building.
- Exclude the Play pre-launch robot sessions (US, Android 11, identical paths; see the Nov 10 setup read).

## How it works

```
Telegram / WhatsApp ──▶ zigdash-chat (own container, grocery-vps)
                          │  Claude with tools, one conversation per linked chat
                          ▼
                    relay.zigdash.app (MQTT, Chat topics only) ──▶ Engine on the hub ──▶ Zigbee2MQTT
```

### 1. The Engine and relay side

- The MCP handler from the MCP v1 design, built for real (today it is a spike): `home_summary`, `list_devices`, `get_device`, `list_groups`, `get_history`, `list_automations`, `list_alerts`, `set_device`, `set_group`. Drafts are not in Chat v1.
- Chat is one more **AI client** in the Engine's client list. It has its own token (the Engine stores only its sha256, as in the spike), a scope (Read, or Read and control), the audit list ("What your AI did") and rate limits.
- **What Chat can control:** lights, plugs, switches, covers, thermostats. **Locks, valves and sirens are read-only from Chat**, whatever the scope. "Turn off the valve" gets "Open ZigDash to do that" and a link that opens the app.
- **Sealing, both ways:** the relay keeps seeing ciphertext. Chat gets its **own key**, not the home key. Requests from the service are sealed (AES-GCM, so authenticated) with it, and the Engine drops any request that doesn't open. Inside the sealed data each request carries a random id and a timestamp; the Engine drops requests outside ±120 s of its clock and ids it has seen (the last 1,000, kept in memory; after an Engine restart the time window alone covers replays), so a recorded request can't be replayed. Each sealed response carries the Engine's own time, so the service corrects for a drifting hub clock, and a rejected request is written to the audit list as "rejected: stale". Responses are sealed the same way. Honest limit: the relay and the chat service are run by the same person on the same host, so the separation is between containers and credentials, not between parties.
- **Per-device control list:** the Chat screen lists the devices Chat may control. Lights, switches, thermostats and covers on a dashboard tile are on by default. **Plugs start on only if they are on a dashboard tile**, since a plug can power a heater or an iron. Covers and plugs whose name or dashboard says gate, garage, door, Tor, poort, portail, שער (a word list per supported language) always start off. Linking ends on this list, so the user reviews it once.
- **Relay forwarding:** the Engine's relay forwarding today carries only the device topics the app needs, under opaque topic ids. It gains the Chat clients' request, response and Alert topics, also under opaque ids. The relay itself doesn't change. The chat service's dynsec role allows only those opaque topics for linked Homes, nothing else.
- **Rooms:** "downstairs" must mean something. The phone publishes a small index to the hub: dashboard names and the devices on each (MCP open question 3, answered yes for Chat). It is retained in plain text on the home broker, like Automations, and sealed on the relay.
- **Alerts (phase 4):** Chat becomes an extra Alert channel. **It is added on top of push or ntfy and never replaces them.** The app doesn't let Chat be a Home's only channel for leak and smoke Alerts.

### 2. The chat service (`zigdash-chat`)

- Node, in its own container and Compose project on grocery-vps, separate from the relay's verifier and dynsec admin. It keeps one MQTT connection with its own limited credential.
- A Cloudflare Worker is the wrong shape for it: Alerts need a long-lived subscriber.
- **Keys at rest:** each Home's Chat token and key are encrypted with a service key held in a separate secrets file, never in the database dump. Breach impact if the service host is compromised: every linked Home's Chat scope (read, plus lights, plugs, covers and thermostats where granted). Never locks, valves, sirens or Engine changes. The link screen states this.
- One core, two adapters: **Telegram Bot API** (a new bot, not the community `@zigdash_bot`) and **WhatsApp Cloud API**.
- It answers only private chats from linked accounts. Groups, channels and unknown senders get one fixed line, or nothing after the first.
- Model: Claude Haiku with prompt caching. A system block plus a per-Home block (device and room index, cached up to 1 hour, kept in memory only, never written to disk). The tool loop is capped at 6 calls and 20 s per message.
- Confirmations live in code, not in the model. Actions that touch more than 5 devices ("turn off everything") create a pending action id with a 60 s expiry. Only that chat's next "yes" executes it. The model can propose but can't confirm.
- Untrusted text: device names, group names, dashboard names and Alert text are passed as capped, stripped data fields. The system prompt says they are data, not instructions.
- **Scope in prompt and code:** only the linked Home and ZigDash. Everything else gets one fixed line ("I can only help with your home").
- Memory: the last 10 turns per chat, kept 24 hours. Logs hold counters only: no message text, no names.

### 3. Linking (in the app)

1. A Pro Home with the Engine and remote on: Home settings › **Chat** › Telegram or WhatsApp. Pick a scope; Read is pre-selected.
2. The phone creates the Chat client on the hub (over the LAN or the relay). It then calls the chat service over HTTPS, **authenticated with the Home's relay credential**. The service checks it against the verifier's Home binding, so only a paid, bound Home can link. The call carries `{client id, token, key, 6-character code}`; the service keeps it unclaimed for 10 minutes.
3. The app opens `t.me/<bot>?start=K7Q2F9` or `wa.me/<number>?text=link%20K7Q2F9`. The first private message carrying the code claims it; the code is single-use, and each sender gets 5 code tries an hour.
4. **The claim is inactive until a second code goes the other way.** After the claim, the bot sends that chat a 4-digit code; the user types it into the app (which sends it to the service with the relay credential). Only someone holding both the app and that chat can finish linking, so a look-alike Telegram name or an intercepted first code gets nothing. Three wrong codes cancel the claim.
5. Each family member links their own account as a separate client, with its own scope, listed in the app with last use. Remove one at any time, from anywhere.
6. The link screen says plainly: anyone using this Telegram or WhatsApp account can do what the scope allows. That includes WhatsApp Web or Desktop signed in on a shared computer. **Even Read shows whether anyone is home** and which doors and windows are open.
7. **Removing** one (from the app, at home or away) does two things: it calls the service with the relay credential, which deletes the binding, the stored token and key, and the conversation at once; and it deletes the client on the hub. If the hub is offline, the service side alone already stops all access (the service no longer has the key); the hub client is deleted when the hub is next reached. The bot also accepts "unlink" from the linked chat itself.
8. Linked family members must be 16 or older (stated on the link screen and in the policy).

### 4. Docs this changes

- `zigdash-3.0.md` §5 says the relay has "two modes only". Chat adds a third, per client: sealed on the relay, plaintext to the chat service, the messaging company and Anthropic. Amend §5 when phase 1 starts.
- `mcp-engine.md` lists a plaintext cloud client as deferred Transport 3, breaking its constraint 4. Amend it: Chat is that transport, opt-in per family member, with the per-client key.

## Cost and price

- **Model:** with the prices in `tool/assistant-worker/worker.js` (Haiku: $0.10/M input, $0.01/M cache read, $0.50/M output), a message with a full 6-call loop and large tool results (`list_devices`, `get_history`) costs about **$0.002–0.005**. Worst case at the 300-message cap: **$1.50 per Home per month**; typical (2–3 calls) about a third of that. Opus is much more than its 40× price ratio suggests, because Opus 5.5 can't turn thinking off. The eval compares Haiku with a larger model on the same 40 phrasings before the default is fixed.
- **Telegram:** free.
- **WhatsApp:** every reply is billed at the country's utility rate (budgeting as if no free allowance exists). So are Alerts outside the window. Before phase 5, take Meta's official rate card for the top 5 install countries and set caps per country so no Home costs more than its share of the price.
  - Example cap at a $1.00/month budget per Home: Germany about 15 messages, Israel about 160, US about 250.
  - In expensive countries WhatsApp may only make sense for Alerts, with chatting done on Telegram.
- **Price:** decided together with the "ZigDash Remote" add-on (roadmap §6), when remote has 20 Pro Homes. Grandfathering existing Pro buyers covers **Telegram only**. WhatsApp's per-country caps apply to everyone, because its cost has no ceiling otherwise. Until then the Telegram beta is labelled **"free during the beta"** in the app, capped at 300 messages a Home a month.

## Privacy and legal (before the first real Home links)

- **Privacy policy:** a ZigDash Chat section covering:
  - what the service reads: only what the tools return for the linked Home;
  - who else processes it: Telegram or Meta, which keep message text under their own policies whatever we delete, and Anthropic (US; state the transfer basis, SCCs, and the API's retention terms);
  - where the service runs (grocery-vps; state its country);
  - Telegram bot chats are not end-to-end encrypted (Telegram's servers read them); WhatsApp Business messages are readable by Meta's Cloud API;
  - Anthropic API retention (state the period in force on the day the policy is written, from Anthropic's commercial terms);
  - 24-hour conversation retention, the in-memory index, counters-only logs;
  - how to unlink, and how to ask for a copy or deletion of what the service holds (email in the policy; the service can export a binding's data by chat id);
  - minimum age 16 for linked members.
  - Pushed to GitHub and GitLab, as with every policy change.
- **Family members** who link are data subjects who bought nothing. The link message and the bot's first reply point them to the policy. Unlinking deletes their binding and conversation at once.
- **Play Data Safety:** for linked Homes, declare messages, user IDs (Telegram id / phone number) and device data, processed by the developer. The end-to-end exemption doesn't cover them.
- **GDPR:** controller processing of plaintext home data. An Art. 30 record entry. A DPIA screening, because the data shows when people are at home (likely conclusion: a short DPIA is needed; write it in phase 3). **Relay ticket 11 is still open** (hoster DPA, EU representative), so it blocks Chat as it blocks the relay.
- **WhatsApp only:** Meta business verification (legal entity, zigdash.app, display name), plus approval of the Alert templates.

## Phases and effort

| Phase | What | Days |
|---|---|---|
| 0 | Demand card + `chat_interest` in a regular release; 4-week read | 1 |
| 1 | Engine: MCP v1 read + safe-control tools from the spike, token hashes, client list, audit, per-client sealing key (both ways), per-device control list, rooms index; relay forwarding and the limited dynsec role. **Shared with MCP v1**: if MCP v1 ships first, this drops to about 6 days | 13 |
| 2 | `zigdash-chat` core + Telegram adapter: Claude tool loop, confirmations in code, caps, encrypted keys, own container; tested on the SMHUB | 6 |
| 3 | App: Chat screen (link, confirm the claim, scope, control list, family list, remove, audit). Eval set: 40 real phrasings in 4 languages, graded by hand like the assistant eval. Policy, Data Safety, DPIA, data export path, emulator screenshots. **Telegram beta release** | 9 |
| 4 | Chat Alerts on top of push/ntfy | 3 |
| 5 | WhatsApp adapter, per-country caps, templates, business verification (Meta's wait not counted) | 5 |
| 6 | Paid tier, with the Remote add-on decision: Play subscription + server-side verification | 5 |

| — | Relay ticket 11 (hoster DPA, EU representative): owner's work with lead time and a yearly cost; must be done before phase 3 ships | owner |

**Telegram beta (phases 1–3): about 28 days. Everything: about 42 days.** Phases 4–6 each start only after the previous read.

## Measurement and kill rule

- Events, counts only (policy and usage-data wording need the owner's OK, including the new `chat_tapped` property on the Pro purchase event): `chat_linked {channel, scope}`, `chat_unlinked`; and from the service, per Home per week: messages split into read / control / refused, Alerts sent, cost (model + Meta, joined per Home from the service's own counts × the country rate, since Meta's billing export isn't per Home).
- **Success at 8 weeks after the Telegram beta** (E = Homes eligible on that day):
  - linked: at least **max(2, ⌈0.3 × E⌉)** Homes;
  - still messaging in week 4: at least **max(2, ⌈0.5 × linked⌉)**;
  - Pro purchases from Chat interest: at least 2. Measured with a `chat_tapped` flag (stored on the phone when the card is tapped) added to the existing Pro purchase event, so a later purchase on the same install counts.
- **Kill rule at 8 weeks:** the linked and still-messaging bars decide. Missing the Pro-purchase bar does not kill the beta; it only blocks phase 6 (the paid tier). Then stop at phase 3. Keep the Engine's MCP v1 work (it serves "your own AI on your computer"), unlink everyone with a week's notice, and don't start WhatsApp.
- **WhatsApp go/no-go (before phase 5):** the Telegram success bar is met, and at least 40% of `chat_interest` picked WhatsApp, and business verification is possible.

## Open questions for the owner

0. (Rev 5.1) After the early-access read: a small free cap in the app for everyone with the bigger cap in Plus (Shelly's shape), or Telegram-first for Pro as in revisions 1–4?

1. Timing: start after February as the roadmap says, or change roadmap §6 now?
2. OK to put the demand card in the next release?
3. Is there a registered business for Meta's verification? (Needed only for phase 5.)
4. OK that locks, valves and sirens are never controlled from a chat in v1, and gates/garage doors start off?
