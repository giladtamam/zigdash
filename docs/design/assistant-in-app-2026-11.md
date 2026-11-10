# An assistant inside the app (plan, 2026-11-10)

Status: plan for ZigDash 3.5.0, to branch from `release/3.4.8` after that release's three-week Send read, so the two do not blur each other. Not built. Decided by the user on 2026-11-10 ("chatbot inside the app"; "any help should be inside the app"). Revision 3, after independent reviews scoring 6, 8 and finally 9 and one measurement that changes the premise; see "What the data says" and the "Changed" sections at the end.

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

## Changed in revision 3

After the third review (score 9): the lift read waits for at least 40 baseline completions or six weeks, a result within 5 completions of the bar is flat; `help_seen` set on answered, not shown; the rate's denominator stated. After the second review (score 8): cost re-estimated from 3.4.8's setup-origin opens, about 700 cards a month on a cold cache, roughly $16; the cut line is $25, not $5; the Worker enforces the $60 stop from its own token counter, the console alert is the backstop; the completion join is a `help_seen` flag on the `complete` event from a persisted timestamp on the phone, with the baseline flag shipped in a 3.4.8 point release; "Did this help? No" messages are tagged so the Send read excludes them; an 8-second timeout on the card call with the tips visible meanwhile; the details-format check described as tidiness, not defence.

## Changed in revision 2

After the review (score 6): the "Ask your AI" measurement added, which lowers the expected effect and puts the one-shot card first; the install id dropped, with IP limits and an hourly global cap instead; the opener is a template, so the model is called once per card and not on every Get help open; Haiku's missing fallback handled by model; the prompt forbids recommending disabled authentication, opened ports or configuration edits; "Did this help? No" doubles as the Play-required report path and attaches the answer; the transcript attachment is ordered so clipping never loses the details; measurement population fixed to setup-origin, triage-passed opens with a 24-hour completion window on the same install; cost rules in dollars with a spend alert; setup origins only; the branch waits for the 3.4.8 read; estimate raised to 5 plus 3 days.
