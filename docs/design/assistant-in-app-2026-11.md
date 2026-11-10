# An assistant inside the app (plan, 2026-11-10)

Status: being built on `feat/help-review` together with the 3.4.8 work, as one release, ZigDash 3.5.0+107 (the user's decision, 2026-11-10: "build the 3.5 chat bot and only then create the release"). Revision 4 notes what that changes; the rest of the text stands. Decided by the user on 2026-11-10 ("chatbot inside the app"; "any help should be inside the app"). Revision 3, after independent reviews scoring 6, 8 and finally 9 and one measurement that changes the premise; see "What the data says" and the "Changed" sections at the end.

## What the data says about the premise

The app already has the cheapest form of this idea: "Ask your AI" hands a write-up of the same facts (scan result, platform, network kind) to whatever assistant the user has, and the setup flow records whether that was used when a setup completes.

Thirty days to 2026-11-09:

| | Count |
|---|---|
| "Ask your AI" write-up opened | 201 |
| Shared or copied to an assistant | 44 |
| Setups completed in the same app run after sharing or copying it | **0** |
| Setups completed without it | 75 |

Caveat: the flag lives in memory, so a person who got advice, fixed their network and came back after restarting the app counts as "without it". The 0 is a lower bound, not the whole truth. It still says that an answer alone, however good, did not turn a stuck setup into a finished one within the session for any of 44 people. Most of them had no hub to find, or a hub their phone could not reach; advice does not move a router.

So the honest expectation for an in-app assistant is modest: it helps the people whose problem is knowable from the Support details and fixable from the phone, and it tells the rest, kindly and in their language, what they actually need. The plan is sized to that, and its first gate is cheap.

## Two ways to build it, and the recommendation

**A. One-shot diagnosis card.** On Get help, after the triage: one model call from the Support details and the triage answers, returning three ranked things to check, in the user's language, with "Did one of these work?" and Talk to a person underneath. No reply field, no conversation, no identifier. Tests the same hypothesis for about 3 days of work.

**B. The chat.** Everything in A, plus a reply field and up to 12 turns. About 7 to 9 days.

**Recommendation: A first.** If the card's read (below) shows a lift, B is a week on top of it and the prompt is already proven. If it shows none, B would not have either, and nothing was wasted. The user asked for a chat bot; this is the same bot answering first and listening second, and the second step is not cancelled, only ordered.

The rest of this plan is written for B, with A as its first release: everything marked **(B)** waits for the card's read.

## What the user sees

- **Get help from a setup origin** (the empty scan's warm button, a setup error, the broker form's stuck card), after the 3.4.8 triage: the assistant's card at the top. Its first text is a template, not a model call: *"Your scan on Wi-Fi tried 1,018 addresses and found no broker, and you said Zigbee2MQTT is running."* Under it, the model's three ranked checks, each one or two sentences, in the user's language. **(B)** then a reply field.
- One line above the card, always visible: *"This answer comes from an AI service that sees your Support details. It never needs your passwords or addresses."*, linking to the policy section.
- Under each answer: *"Did this help?"* with yes and no. **No** opens the Send form with the answer attached and *"What was wrong with it?"*, which is also the in-app way to report a bad AI answer that Play's generative-AI policy asks for. These messages carry `kind: ai_report` to the support Worker, so 3.4.8's Send read ("more than 30 a week means the triage is too loose") excludes them.
- **Talk to a person** stays under the card and opens Send with, in this order: the Support details, the user's text, then the last two assistant answers, so the clipping at 4,096 characters on the developer's side never cuts the details or the question.
- The tips and "What's included" stay below, collapsed, as in 3.4.8.
- **Settings and the demo keep the 3.4.8 layout.** Their questions ("how do I rename a home") are outside a prompt scoped to connecting Zigbee2MQTT, and would be refused.
- With no internet at all: the card says so and the tips show. Send is impossible then too, so nothing is lost against 3.4.8.

## How it works

**In the app.** The card posts the Support details, the triage answers and the locale to the assistant endpoint once, when it opens; **(B)** each reply posts the conversation too, at most the last 12 turns of at most 1,000 characters each. Nothing is saved to disk. No identifier is created or sent: the review showed a client-minted install id controls nothing (a script mints a new one per request) while costing a policy change and a Data safety answer.

**The endpoint.** A second Cloudflare Worker, `zigdash-assistant`, beside the support one, with its own secret and limits; the support Worker stays dumb and reliable. It prepends the system prompt and the knowledge text, calls the Claude API, returns the reply, stores nothing and logs no bodies.

- Model: `claude-opus-5-5`, `output_config: {effort: "low"}`, `max_tokens` 1,024, the server-side refusal fallback on (`fallbacks: "default"` with the `server-side-fallback-2026-07-01` beta header). If the model is ever switched to `claude-haiku-5-5`, the fallback parameter must go, since Haiku has none; the Worker reads the model name from a variable and sets the fallback only for Opus.
- Caching: the system prompt and knowledge text are the stable prefix with one cache breakpoint, a few thousand tokens, above the minimum cacheable size. At ten conversations a day the cache will often be cold on a first call; the cost estimate below counts that.
- Knowledge text: generated at build time from the app's own strings (`tool/support-worker/build_knowledge.dart`): the tips, the empty-scan guide steps, the setup error texts, the Home Assistant address help, the broker-form checks, the hub guides, and a short list of facts about ZigDash. One source of truth; English only; the model answers in the user's language.
- Prompt rules: stay on getting Zigbee2MQTT connected to ZigDash; one question at a time **(B)**; never ask for passwords, tokens or remote access; **never recommend turning off a broker's authentication, opening a port to the internet, or editing Zigbee2MQTT's configuration beyond what the hub guides say** (the SMHUB regenerates its configuration and breaks when edited by hand); when the knowledge text does not cover the situation, say so and point to Talk to a person; when the user says they have no hub, say so kindly and point to the hub guide; never invent ZigDash features.
- Limits: by `CF-Connecting-IP` as the support Worker already does, 10 calls an hour per address; a global cap of 100 calls an hour (not a day, so one abuser cannot lock everyone out until midnight); 8 KB body; the Support details must match the app's own format or the call is refused with 400 (a tidiness check, not a defence; the format is public in the repo). Over a limit the Worker answers 503 and the card says the assistant is resting and a person is still reachable. The card call times out after 8 seconds, like Send, with the tips visible underneath meanwhile, so a slow network never leaves Get help blank. Play Integrity on the caller is not in this release; it comes in a point release if the Worker's metrics show abuse.
- Cost: the card fires on every setup-origin Get help open that passes the triage, not when someone asks. 3.4.8's own numbers put that at about 700 a month (527 broker-form and 254 setup-error opens), nearly all on a cold cache at that rate, so a card is about 3,000 input tokens written to cache plus about 400 output tokens including the model's thinking at low effort: roughly $0.023 a card, about $16 a month on Opus; **(B)** adds $20 to $35 at 300 conversations of 8 turns. Rules in dollars: the Worker sums the `usage` tokens of every reply into a monthly KV counter and answers 503 past the token equivalent of $60, since it cannot read the Anthropic bill itself; the console's spend alert at $40 to the user's email is the backstop. The keep-or-cut line for the card alone is $25 a month.

## What is measured

One `assistant` event: `step` in `shown`, `answered`, `limited`, `failed`, `helped_yes`, `helped_no`, `escalated`; **(B)** also `asked` with the turn bucketed 1, 2-3, 4-9, 10+; plus the Get help origin. Kinds and counts only, never the text. The Worker counts calls and tokens in Cloudflare's metrics, nothing per user.

Population for every read: **setup-origin Get help opens that passed the triage** (the people the card is shown to), compared with the same population on 3.4.8, which is why 3.5.0 branches only after 3.4.8 has three weeks of data. The join the data cannot make on its own (no install id, and the analytics session rotates after an hour) is made on the phone: `setup_step complete` gains `help_seen` (Get help opened within the last 24 hours, yes or no) from a timestamp kept in the app's preferences, the persisted cousin of the in-memory `aiHelpUsed` flag, so nothing new leaves the device. The baseline is that same flag shipped in 3.4.8's next point release for the plain Get help, three weeks before 3.5.0; in 3.5.0 it means the card was shown.

Read at three weeks:

- **Does it help:** rate = completions carrying `help_seen` over `help_opened` events from setup origins that passed the triage, read the same way on both releases; in 3.5.0 the timestamp is set when the card **answered**, not when it was shown, so a timed-out or rate-limited card counts as the 3.4.8 experience. Bar: 1.5 times the baseline. Read at three weeks; if the baseline window holds fewer than 40 flagged completions, read again at six weeks before deciding, and treat a result within plus or minus 5 completions of the bar as flat, not a miss. A miss with "Did this help?" mostly yes means pleasant but not useful; then B is not built and the card stays only if it costs under $25 a month.
- **Is it a doorway:** share of card views that tap Talk to a person within the session. Over 50 percent means the card is in the way; it moves below Send.
- **(B) Do people type:** conversations with at least one reply. Under 15 a week: the reply field goes.
- **Cost:** the dollar rules above, read monthly; the card alone is cut above $25 a month.

## Privacy

New policy section next to Support messages: the assistant's answer is made from the Support details, your triage answers and the app's language (and, with the chat, what you type), sent only when you open the card or send a message, to a Cloudflare Worker the developer runs, which forwards it to Anthropic's Claude API; Anthropic keeps API inputs for up to 30 days for abuse monitoring under its own terms and does not train on them; the Worker keeps nothing; the conversation lives only in the app's memory until the screen closes. No identifier is sent, so the policy's "No device ID, advertising ID, account, or install ID is sent" stays true and the Data safety form does not change. Published with the release after the user reads it.

## Work

| Part | A | B on top |
|---|---|---|
| Knowledge builder from the app's strings, and the system prompt | a day | |
| Worker: prompt assembly, caching, limits, fallback by model, details-format check, curl tests | a day | |
| Card in Get help: template line, three checks, helped yes/no, Talk to a person with ordered attachment, offline state | a day | |
| Strings in 13 languages, events, policy, tests, emulator checks | a day | half a day |
| Hand-graded eval, 20 real situations, and prompt iteration | a day | half a day |
| Chat screen: reply field, 12-turn history, typing indicator | | two days |

A: about 5 days. B: about 3 more. The eval cases come from the last 30 days: an empty scan on a guest network, a Docker broker listening only on localhost, an SMLIGHT hub with Allow External off, Home Assistant without the MQTT integration, no hub at all, a CONNACK refusal with a web password, and so on; each with the answer a good human would give, graded by hand once and again whenever the prompt changes.

## Open, for the user

1. A first, or straight to B. The recommendation is A.
2. Model: Opus 5.5 as proposed, or Haiku 5.5 from the start to keep the bill near zero.
3. An Anthropic API key for the Worker, set as a secret in the Cloudflare dashboard by the user, as the bot token was, plus a spend alert on that key.

## Changed in revision 4

The user chose to ship A and B together with the 3.4.8 changes as 3.5.0, so there is no 3.4.8 point release and no `help_seen` baseline window. The baseline for the lift read is pre-3.5 cloud data: setup-origin `help_opened` sessions that reached `complete` in the same session (weaker than `help_seen`); `help_seen` still ships so the next read is clean. Body cap on the assistant Worker is 24 KB (12 turns of 1,000 characters plus details exceed 8 KB), oldest turns trimmed on the phone; the card call waits up to 20 seconds, not 8, with the tips visible underneath. `max_tokens` is 2,048, since thinking tokens bill as output on Opus 5.5 at low effort and a truncated answer is worse than a higher ceiling.

## Changed in revision 3

After the third review (score 9): the lift read waits for at least 40 baseline completions or six weeks, a result within 5 completions of the bar is flat; `help_seen` set on answered, not shown; the rate's denominator stated. After the second review (score 8): cost re-estimated from 3.4.8's setup-origin opens, about 700 cards a month on a cold cache, roughly $16; the cut line is $25, not $5; the Worker enforces the $60 stop from its own token counter, the console alert is the backstop; the completion join is a `help_seen` flag on the `complete` event from a persisted timestamp on the phone, with the baseline flag shipped in a 3.4.8 point release; "Did this help? No" messages are tagged so the Send read excludes them; an 8-second timeout on the card call with the tips visible meanwhile; the details-format check described as tidiness, not defence.

## Changed in revision 2

After the review (score 6): the "Ask your AI" measurement added, which lowers the expected effect and puts the one-shot card first; the install id dropped, with IP limits and an hourly global cap instead; the opener is a template, so the model is called once per card and not on every Get help open; Haiku's missing fallback handled by model; the prompt forbids recommending disabled authentication, opened ports or configuration edits; "Did this help? No" doubles as the Play-required report path and attaches the answer; the transcript attachment is ordered so clipping never loses the details; measurement population fixed to setup-origin, triage-passed opens with a 24-hour completion window on the same install; cost rules in dollars with a spend alert; setup origins only; the branch waits for the 3.4.8 read; estimate raised to 5 plus 3 days.

## Revision 5: the help bubble on the home screen (2026-11-10)

Decided with the developer on 2026-11-10: the 3.5.0 release carries the
assistant on Get help (above) and a second doorway to the same assistant on
the home screen. One element, three states, as the mock
(https://claude.ai/artifact/Et3qYHrepHx361zLQ8u6m5) shows.

### Premise
Connected users never find Get help (it sits behind Settings): 10 ratings
and 2-3 emails in a month against ~700 setup cards. A door on the screen
they use every day is the cheapest way to learn what connected people
struggle with, and the same Worker, prompt and panel answer there.

### What the user sees
- **Resting.** A pill "Need help?" with the assistant's dot, on the
  Dashboards tab, start side (bottom-left in LTR, bottom-right in Hebrew),
  above the bottom bar. The start side because the dashboard's own "Add
  tile" button owns the end side. Compact layouts only; on a rail layout the
  same control is the rail's trailing item.
- **Quiet.** After the first open, only the dot (icon-only button). A
  long-press offers Hide; hidden is remembered in SharedPreferences. Settings
  › Get help gets a switch "Help bubble on the home screen" to bring it back.
  The Get help screen is unchanged and always there.
- **Open.** A modal bottom sheet (DraggableScrollableSheet, 60% to 95%)
  with the assistant panel in home mode: title, the AI notice, an opening
  line from the home's facts ("Office is connected and 12 devices report.
  What do you need?" / "ZigDash can't reach Office right now."), four chips
  (A device stopped responding · Add a tile · Automations · Home can't be
  reached), the reply field enabled from the start, "Did this help?" under
  each answer, Talk to a person. Nothing is sent until a chip is tapped or
  a message is sent; a chip is sent as the user's first message.
- Hidden while Edit mode is on, while the wall display hides its chrome,
  in kiosk mode, and on the Devices, Scenes and Automations tabs.
- Talk to a person closes the sheet and opens Get help (from = bubble, home
  = this home) with the handoff (last two answers, or the flagged one)
  carried as a route extra, never in the URL. Get help for a connected
  home shows no assistant panel, only the form, as today.

### What is sent
The same request as Get help, plus `mode: "home"`: the Support details of
this home (app version, Android, phone model, connection kind, port and
address shape, Zigbee2MQTT version, bridge state and device count, last
error, last scan), the locale, the messages. No triage. Never device names,
dashboard names, addresses or logins (SupportDetails holds none by
construction). The home's name appears only in the opening line on the
phone; it is not sent.

### Worker
- `validate()` accepts `mode` in {setup, home}; missing = setup.
- `buildMessages()` adds a `Mode:` line to the head. In home mode with no
  messages the Worker answers 400 (the phone never does this).
- One system text, one cached block: the prompt gains a "Home mode" scope
  (using the app: tiles, dashboards, scenes, automations, alerts, history,
  Pro, remote, wall tablet, kiosk, backup, sharing; and a connected home
  that misbehaves: device not responding, home unreachable, list missing)
  and the knowledge gains sections generated from the app's own strings for
  those features. Setup-mode rules are unchanged; the 20 setup eval cases
  must still pass after the rebuild.
- Same caps (10/h per address, 100/h global, $60 stop). The prefix grows
  by about 4,000 tokens: a cold answer about $0.08, a warm one about $0.015
  on Opus 5.5.
- The bubble does not write `assistant_answered_at_ms`, so `help_seen` on
  a later setup stays a setup signal.

### Rules carried over, plus three
Never passwords, tokens, addresses; never opening ports or editing
configuration by hand; hand off to a person outside the knowledge. New: in
home mode never claim to see a device's state beyond the facts line; never
offer to change anything itself (it cannot); point to the right screen by
its name as the app shows it (Devices, Add tile, Automations, Settings ›
Alerts), and when a device does not respond, the first check is always
Zigbee2MQTT's own page and the device's link quality, then the tile's
topic.

### Measurement
- `assistant` event gains `from = bubble`, `chip` on the asked step (one
  of the four chip names, or `typed`), and a `hidden` step (long-press
  Hide). Opens = `shown` from bubble. No new identifier.
- Read at three weeks (about 2026-12-02): opens per weekly active home,
  helped-yes share, escalations. Kill rule: under 2 percent of weekly
  active homes opening it, or helped-yes under 40 percent of answered
  conversations, and the pill becomes the dot only from the first launch.
  Cost line as revision 4: $25 cut, $40 alert, $60 stop, now across both
  doors.

### Scored 6 → revised (2026-11-10)
An independent review scored the section above 6/10. What changed:
- **Two cached blocks, not one.** The Worker sends SYSTEM_TEXT (prompt +
  setup knowledge) on every call and appends HOME_TEXT (home knowledge) in
  home mode only, each with its own cache_control. A setup call's prefix is
  byte-identical to 3.5.0's plan: it never pays for home knowledge.
- **Each door has its own month.** Home mode spends against `cost:home:` with
  its own stop (HOME_STOP_USD, default $15); setup keeps `cost:` and $60.
  Idle chat in the bubble can never rest the setup card. Home conversations
  are capped at 8 turns (setup: 12). If the combined line crosses $25 in a
  month, the bubble is the door that is cut (pill → dot, HOME_STOP_USD → 5).
- **Chips send one text.** A chip shows its label in the person's language
  but sends the English wording, so the Worker, the eval and the read see
  one text in thirteen languages. Chips fit the state: a connected home gets
  "A device stopped responding", "Add a tile", "Automations"; an
  unreachable home gets only "Home can't be reached".
- **Counts in the details.** Home-mode Support details gain one line,
  "Devices needing attention: N (M not responding)", from what the Devices
  tab already computes. Counts only; never names.
- **Pill decay.** The pill never shows in the hour after setup (that screen
  has its own first steps), decays to the dot after 7 days unopened, and
  the demo home has no bubble at all. Hide is also a visible button in the
  sheet, so TalkBack users and people who never long-press can find it.
- **The read, defined.** Weekly active home = `app_started` sessions with a
  real home (the event exists). Opens = `assistant shown from=bubble`, with
  `state: pill|dot`. Helped rate = yes / (yes + no), reported only at 30 or
  more ratings, else "inconclusive". Read three weeks after the release
  goes live, not on a calendar date. Kill: under 1 percent of weekly active
  homes opening it on two consecutive reads removes the bubble and the home
  prefix in the next release; under 2 percent, or helped under 40 percent,
  makes the pill the dot from first launch.
- Not taken: turning "Add a tile" and "Automations" into in-app links. Those
  two chips are the cheapest way to learn what connected people cannot find;
  an $0.08 answer that names the screen is the point of the probe.

### Work
1. Worker: mode, prompt, knowledge sections, rebuild, deploy, 10 home eval
   cases plus the 20 setup cases.
2. App: `HelpBubble` + `showAssistantSheet`, panel home mode (no auto call,
   chips, reply enabled, no stamp), `HelpFrom.bubble` through every switch,
   route extra for the handoff, Settings switch, HomeShell placement.
3. Strings in 13 languages, policy paragraph, changelog 108, tests
   (bubble states, hide, sheet opens, chip sends, no call on open), emulator
   run with a connected home, Play build 3.5.0+108.
