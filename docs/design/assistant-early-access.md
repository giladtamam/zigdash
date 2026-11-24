# Chat with your home: early access (3.5.4)

Plan v3.1, 2026-11-14 (scores: v1 6/10, v2 8/10, v3 9/10; 3.1 adds the reviewer's last fixes). Part of the profit plan ([../growth/profit-plan-2026-11.md](../growth/profit-plan-2026-11.md), section 5): measure whether people want to control their home by chatting before ZigDash Plus is built. Decided with the user on 2026-11-14: an early-access list; **if it is built, the first 20 to join get it free for 3 months**, then a founding-member price.

Name: **"Chat with your home"** everywhere (strings, Settings, event), because the app already has an "assistant" (Get help, the help bubble, the `assistant` event).

## 1. Why
The earlier gate ("10 beta users from the Telegram community") cannot be met: the community has almost no members, and the user's own home tests whether it works, not whether strangers want it. A sign-up that leaves a way to reach the person is stronger evidence than a Yes tap and builds the beta list at the same time.

## 2. Who sees it, and where
- **Play build only in 3.5.4**, gated on `proFlavor == 'play'` (lib/features/pro/pro.dart; not `proSold`, which on ios/prep is also true for the App Store), with a test. Hidden on the foss builds (F-Droid, IzzyOnDroid, GitHub: a Telegram/Cloudflare sign-up is a NonFreeNet risk there, and they have no analytics to count it) and on iOS (in its first App Review; no new privacy labels mid-review). Revisit per flavor after the read.
- **Card on the dashboard** of a real, working home, in the poll card's slot (dashboards_screen.dart:301), same rules as the poll card (poll_card.dart: not the demo, from the 2nd day with a live connection, after the usage-data question, not kiosk). **The poll card is retired from the dashboard for good**; the poll stays in Settings. It drew 3 answers in 5 days, and its "AI assistant" choice means the person's own assistant (Claude, ChatGPT; app_en.arb:1196), a different product, so it is not cited as demand here.
- **Settings › Chat with your home** opens the same choices.

## 3. What the person sees
> **Chat with your home**
> Send a message like "close the office shutter" or "is the back door open?" and your home answers. We're deciding whether to build it. If we do, the first 20 to join get it free for 3 months, remote access included.
> [Join on Telegram] [Join by email] [Not for me]

- The card text never changes: "the first 20 to join get it free" stays true however many have joined, and the join reply says whether the person is in the 20. So there is no status call: the app talks to the Worker only when the person taps Join.
- **Join on Telegram** opens `https://t.me/ZigDashHomeBot?start=<payload>`, payload `early_c` (counted: analytics on, from the card), `early_n` (not counted: Settings, or analytics off). One bit, no ids.
- **Join by email**: a sheet with the email field, the line "We'll only use this to invite you to the beta and tell you its price. Privacy policy" (link), and Send. POST `{email, lang, counted}`.
- **The answer** (sheet or bot): "You're #N on the list" and either "you're in the first 20" or "the first 20 are taken; you'll hear first". Then one question: "After the free months, would €2.49 a month be OK?" Yes / Maybe / No (sheet chips → `POST /v1/early/price` with the sign-up's nonce: the app sends its own random id with the join, the Worker stores it with the entry, so a lost answer can be retried and nobody else can answer; in Telegram only the bot's buttons, through the webhook). Stored with the entry.
- **Not for me** hides the card for good.

## 4. The bot: @ZigDashHomeBot (created 2026-11-14)
A new bot, not @zigdash_bot (tool/telegram.py reads that one with getUpdates; a webhook would break it with 409). The beta runs on this bot later.
- `/start early_c|early_n`: store `early:tg:<chat id>` → `{lang, counted, at}` (or keep the existing entry and its number), reply as in §3 with the policy link.
- Plain `/start` (found by search): "This bot is ZigDash's chat with your home, not ready yet. Join the early-access list?" [Join] → stored as not counted.
- `/stop`: delete the entry, confirm.
- **English only** in the bot for this list (the app sheet is in 13 languages); the stored `lang` lets the beta answer in the person's language.
- Anything else: looks the chat up; on the list → "Not ready yet; you're #N." Not on the list → the plain /start text.
- Webhook set with `setWebhook` and a `secret_token`; the Worker checks the `X-Telegram-Bot-Api-Secret-Token` header. Done by Claude with the token in tool/.assistant_bot (git-ignored).

## 5. The Worker (tool/support-worker/worker.js, deployed as zigdash-support)
New routes; `/v1/message` unchanged and curl-tested after the deploy; the deployed source committed.
- `POST /v1/early` `{email ≤ 254 chars, shape check; lang ∈ the 13 locale codes; counted: bool}`.
- `POST /v1/early` also takes `nonce` (the phone's random id for the sign-up). A repeat of an address answers its number only to the same nonce; anyone else gets `{listed: true}`, so the list can't be probed.
- `POST /v1/early/price` `{email, token = the nonce, answer ∈ yes/maybe/no}`, so nobody else can set or change the answer. Telegram answers arrive only through the webhook.
- `POST /v1/tg/<path secret>`: the webhook; no IP limit (Telegram's servers), the header secret instead.
- **Own rate keys** `early:ip:<hash>:<hour>` (5 an hour, join and price together; mobile carriers share IPs) and `early:day:<date>` (100 a day), so sign-up spam never uses the support Send budget (RATE `ip:`/`day:` keys, PER_HOUR 5, PER_DAY_ALL 200).
- **Storage:** new KV namespace EARLY, entries with `expirationTtl` 180 days. **Who is in the 20:** the position is computed from a counter, which KV can repeat under a race; the rule is that every person *told* #N ≤ 20 is honored (the list keeps what each was told), so a race costs at most a place or two, never a broken promise.
- **Confirm before offer:** nobody is enrolled from the list alone. The beta invitation (sent by hand by the developer, by email or in the bot) asks the person to reply; only a reply starts their free months. An address typed by a stranger never receives more than that one invitation.
- **Tests never use places:** the release-day curl tests are run, then their entries are deleted and `early:count` is reset to 0 before the release is sent for review; the list is checked empty. The developer's own home and family don't join the list; they test the assistant directly.
- Each new entry pings the developer's Telegram (existing TELEGRAM_CHAT_ID): "Chat early access: #N, email/Telegram, counted/not, lang".

## 6. Measurement
Event `chat_early`: `step` = `shown` (once per install, a preference flag) / `telegram` / `email_sent` / `email_failed` / `not_for_me` / `price_yes|maybe|no`; `from` = `card`/`settings`. No email or chat id.

**Read:** counted card joins (Worker list, `counted=true`) against installs with `shown`. Resolution, stated plainly: about 100–200 `shown` in 60 days (6–14 consented returning homes a day, Nov 9–14), so a rate is ±5 points at 95%. So the read is by **count**:
- **Go** (write the Plus plan): ≥ 20 counted joins **and** ≥ 10% of installs with `shown`, and ≥ 40% of answered price questions Yes or Maybe. Early stop: the read closes the first day both hold (≥ 20 counted joins and ≥ 10% of `shown`).
- **Beta only** (the 20, re-read later): 6–19 counted joins.
- **Drop Plus** from the profit plan: < 6 counted joins in 60 days. Then the list is deleted and everyone on it gets one message saying so.
Uncounted joins (Settings, analytics off) are reported but not in the bars.

## 7. Privacy and stores
- **PRIVACY.md:** the Summary is rewritten (personal data *is* collected now, only if you join; three servers). New section "Chat with your home (early access)": what (email address, or Telegram chat id and language; the price answer), who holds it (Cloudflare, which runs the Worker; Telegram, for the bot chat), purpose ("to invite you to the beta and tell you its price"), how long (180 days, or until the invitation is answered, or on request; deleted if the feature is dropped), how to delete (/stop, or email), and the `chat_early` analytics row. Published on GitHub and GitLab main before release.
- **Play Data safety:** check whether the optional email from Get help › Send (PRIVACY.md:201) is already declared; add "Developer communications" as a purpose if so, otherwise declare Email address: collected, optional, not shared.
- **Apple:** not in 3.5.4 (hidden on iOS). When added: Email address, **Linked to you**, purpose Developer's Advertising or Marketing; not used for tracking.
- **Price answers** stay on the Worker with the entry and are declared under the email address's purposes, not as a separate Data safety type.
- **Consent:** the form and the link do not depend on analytics consent (a separate purpose with its own act; the tracker already drops events without consent, analytics_tracker.dart:14). Only the `counted` bit reflects analytics.

## 8. Build
- Base release/3.5.3; branch feat/assistant-early; worktree ~/dev/zigdash-early; 3.5.4+112.
- App: `lib/features/dashboards/widgets/chat_early_card.dart` (card, sheet, price chips, Settings entry), dashboards_screen.dart (slot), settings_screen.dart (row; poll row stays), analytics_events.dart (`ChatEarly`), `lib/features/support/early_access_client.dart` (join, price; same client style as support_sender.dart), the Play-only gate `proFlavor == 'play'`, strings in 13 languages (AI translations fine), tests: card rules (demo, sessions, consent order, kiosk, `proFlavor == 'play'` only), payload bit, client (join, token kept for the price answer).
- Worker: routes above (written and tested against a mock KV on 2026-11-14), KV EARLY, secrets ASSISTANT_BOT_TOKEN and ASSISTANT_WEBHOOK_SECRET; setWebhook; curl tests for every route including `/v1/message`; test entries deleted after. tool/.assistant_bot is git-ignored (done).
- Release notes en-US: "New: would you like to chat with your home? Join the early-access list; if we build it, the first 20 get it free for 3 months."

## 9. What the user does
1. ~~Create the bot~~ (done: @ZigDashHomeBot).
2. OK the privacy text and the Data safety change.
3. Drag the bundle.

## 10. Beta (after this release)
The first 20 who confirm get the chat on Haiku 5.5 (~$0.0003 a command, ~$0.10 a month for 10 a day), Sonnet 5.5 for harder questions, 30 messages a day per home, remote access included for the 3 months. Linking a chat to a home is its own plan.
