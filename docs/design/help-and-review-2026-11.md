# Help that arrives, a review asked at the right moment (plan, 2026-11-10)

Status: plan for ZigDash 3.4.8, branch `feat/help-review` from `release/3.4.7`. Not built. Revision 3, after two independent reviews (5, then 8; see "Changed" at the end).

## Why

Thirty days to 2026-11-09, from the usage data, the Play Console, Telegram, the inbox and the code:

| What | Count |
|---|---|
| Setup starts / completions | 1,341 / 75 |
| Get help opened | 954, of which 527 from the broker form, 254 from a setup error, 6 from "no connection found" |
| "Contact support" (opens a mail app) tapped | 272 |
| Support emails that reached the inbox | 2 to 3 |
| "Copy details" tapped | 483 |
| Telegram link tapped / group members | 315 / 4 |
| Review prompt requested / Play ratings all time | 29 / 10 (4.9 stars) |
| Home Assistant sign-in ending as "no address" | 873 of 960 attempts; 136 of 151 discovery looks found nothing |

Three conclusions:

1. **Help requests are lost in transit, not unsent.** 272 contact taps became 2 or 3 emails: the hand-over to a mail app loses about 99 percent. "Copy details" is a dead end: the text sits on the clipboard with nowhere to go. A Telegram link opens a preview of a near-empty group, and people back out.
2. **Help is not where the stuck people are.** The empty scan, the most common stop, produced 6 help opens in a month. The broker form, where help is one tap away, produced 527. But most empty scans are people with no Zigbee2MQTT hub at all (the no-hub card and the Zigbee2MQTT-running question exist for them), and a message from them is one the developer cannot answer.
3. **The review prompt fires at an arbitrary instant.** It is allowed on the second day with live data, and the trigger also fires on a passive device report, so the dialog can appear the moment a sensor reports after the dashboard opens.

A fourth, separate finding: on the Home Assistant sign-in, a tap during discovery waits for the look (deliberate in 3.3.1), but most looks find nothing, so the tap is wasted and ends as "type the address".

## What changes

### 1. A kind way in, that sorts before it asks

- **Empty scan result:** a prominent filled button under the result, *"Nothing found? Don't worry, I'll help you"*. It opens Get help with `from = scan_empty`.
- **Get help opened from there starts with one question**, before any form: *"Is Zigbee2MQTT running somewhere in your home right now?"* with three answers. *Yes* → the message form below. *Not yet* → the hub guide (the existing no-hub path), with no message form, because there is nothing to fix. *Not sure* → the existing "how to tell" tips, then the form. The answer is the existing `z2m_running` event; if it was already answered in this setup, the question is skipped.
- **The no-hub card** does not get the button: it is the answer for people without a hub.
- **Tone:** first person ("I'll help you", "I usually reply within 3 days"), because one developer answers and the promise is already written that way.

### 2. Get help, reordered around sending

Top to bottom:

1. The promise line (unchanged text, moved to the top).
2. A text field, *"What were you trying to do, and what happened?"*, three lines. **Send is enabled only once there is text**, so no message arrives with details and no question.
3. An optional email field, always visible, one line: *"Your email, if you want an answer"*.
4. **Send** (filled). It sends the text, the email if given, and the Support details the screen already builds (app version, where it was opened from, the connection facts, never passwords). On success: *"Sent. I usually answer within 3 days if you left an email."*
5. **Share details** (text button) replaces *Copy details*: Android's share sheet through the existing `shareText` channel (used by "Ask your AI"), so the same text can go to WhatsApp, Telegram or any mail app. Copy is inside the share sheet.
6. *Ask in the Telegram group* (unchanged), and *Try these first* with the tips, collapsed by default, at the bottom.

**Send delivery.** `POST` to a Cloudflare Worker, JSON `{text, email?, details, app, build, locale}`, no auth. The Worker forwards each message to the developer's private Telegram chat through the existing bot (token and chat id are Worker secrets, never in the app, never on the Pi). The Pi is not involved, so a home power cut does not lose messages. Rules in the Worker:

- body over 8 KB → 413; text and details truncated to fit Telegram's 4,096-character message, with a marker, rather than split;
- rate limit by `CF-Connecting-IP`: 5 messages per hour per address, and a global cap of 200 a day; beyond either the Worker answers 503, never a silent drop. Mobile carriers share addresses, so the app's failure text says *"try again in an hour, or share"*;
- the body is never logged; the Worker keeps nothing.

Address: `support.giladha.com`, a Worker route on a domain already on Cloudflare, from day one; some carriers block `workers.dev` names. One minute in the dashboard, and the user has already agreed to hostnames on that domain for this purpose.

**When sending fails** (no network, 503, timeout after 8 seconds): the button turns into *"Couldn't send. Share instead"*, which opens the share sheet with the same text. Nothing opens by itself.

### 3. The review prompt, asked after a win

Keep the counting (days with live data, two days since the first, 90-day cooldown). Change when the request is made:

- Only on the confirmation of a **command the user sent**. The passive device report still counts the day. For sensor-only homes, a passive request is allowed only when **no command has ever been confirmed on this install** (one boolean preference) and the install has 7 counted days, with the same delay and current-route rule. Accepted trade: those users are asked later than today.
- The **third** confirmed command of that session, not the first. The in-session count lives in the trigger widget and resets with it; the day-granular controller is unchanged.
- After a 1.5-second delay, so the tile's own confirmation is seen first, and only while the dashboard that triggered it is still the current route.
- Never during the first 10 minutes after setup completed, however old the install. Needs one new preference, the time setup last completed; none is stored today.

Play's in-app review rules stay as they are: no question before the card, no "Enjoying ZigDash?" gate. Play decides whether the card is shown; the app only requests.

### 4. Home Assistant sign-in during discovery

In `ha_connect_screen.dart` the Sign in button is enabled with an empty field while the look runs, and the tap then waits for the look. Since most looks find nothing, the tap is wasted. Change: with the field empty the button is disabled; while the look runs it reads *"Looking for Home Assistant…"* with a small progress indicator; when the look ends with nothing, the where-to-find-it line and the chips show. No autofocus: the keyboard would cover them. One line of logic and a label.

### Cut from this plan

- Probing an advertised `internal_url` before preferring it: two anecdotes, and it would turn a synchronous function into an async probe. Noted for later, with the existing hub prober if ever done.
- A "no sheet or dialog open" check for the review: needs a route observer; the delay plus the current-route check is enough.

## Measured

- `support_sent` with `from` and `result` in `sent`, `failed`, `shared_after_failure`. `support_contact` gains `via = share` (replaces `copy`).
- `help_opened` gains `from = scan_empty`; the triage answer is the existing `z2m_running` event with `from = help`.
- `review_prompt` gains `trigger` (`command`, `report`) and `nth` (bucketed 3, 4-9, 10+).
- Kinds only. The message text and email go to the developer and nowhere else, and are not usage data.

Read three weeks after release, except where stated:

- **Send:** messages received per week, and how many are answerable (a question from someone with a hub). Today the channel delivers under 1 a week from 272 taps a month. Fewer than 2 a week, or more than half unanswerable, means the form goes back to a link; anything above that stays. More than 30 a week means the triage is too loose, and *Not sure* also goes to the tips without a form.
- **Review:** read the request count now (it will fall, by design). Judge ratings at **8 weeks** as a ratio, so growth in installs does not pass the test by itself: Play ratings per 100 setup completions in the 8 weeks after, against the 8 weeks before. Pre-registered bar: a rise of at least 50 percent in that ratio. No revert on a shorter read. A miss where the ratio fell reverts the third-command rule; a flat ratio (within plus or minus 2 ratings of the bar) keeps it and reads another 8 weeks. The command-only rule stays either way.
- **Home Assistant:** connected sign-ins per Home Assistant screen open, before and after; `no_address` alone would fall mechanically and proves nothing.

## Privacy policy

New rows: the support message (what you type, the Support details, an email if you give one) is sent only when you tap Send, to a Cloudflare Worker the developer runs, which forwards it to the developer's Telegram account; Telegram (Telegram FZ-LLC) therefore stores it as part of that chat; the Worker keeps nothing and never logs the body; the developer deletes the message from the chat once answered. The share sheet row is the user's own action. Published with the release after the user reads it.

## Work

| Part | Size |
|---|---|
| Worker (forward, limits, truncation, secrets), deployed and tested with curl | half a day |
| Get help reordered: triage question, form, Send, Share, failure state | a day and a half |
| Warm button on the empty scan | half a day |
| Review trigger rules, in-session count, props | half a day |
| Home Assistant button state and label | a quarter day |
| Strings in 13 languages, events, policy rows, tests, emulator screenshots | a day and a half |

About 5 to 6 days. Tests: Send success, failure to the share state, email detection; the triage branches; the review controller with command vs report triggers, the nth rule, the sensor-only path, the post-setup window; the Home Assistant button states.

## Open, for the user

1. The private Telegram chat to forward to: send `/start` to the bot once so the chat id can be read.
2. Cloudflare Worker deployment: the Worker is pasted into the Cloudflare dashboard from the signed-in browser session, with the two secrets and a KV namespace set there, and the `support.giladha.com` route added. Code in `tool/support-worker/worker.js`.

## Changed

**Revision 3** (review scores 8, then 9 on this text; the final note: a miss reverts only when the ratio fell, a flat read waits another 8 weeks; the "a command was ever confirmed" preference is written by the command trigger even before the policy is eligible): ratings judged per 100 completions with a 50 percent bar, not a raw count; Send kept unless under 2 a week or mostly unanswerable; the passive review request only for installs that never confirmed a command; the setup-completed time as a new preference; no autofocus on the Home Assistant field; `support.giladha.com` route from day one; "usually" kept in the promise; carrier-shared addresses named in the 503 text.

**Revision 2** (review score 5): 
Receiver moved from the Pi to a Cloudflare Worker (no outage path, real per-client limits, 503 instead of silent drops, Telegram length handled). Warm button no longer on the no-hub card; Get help triages "is Zigbee2MQTT running?" before showing a form; Send needs text. Email field always visible. Failure shows a "Share instead" button instead of opening a sheet by itself. Sensor-only homes keep a (later) passive review request. Home Assistant measured by connected sign-ins per screen open; review judged at 8 weeks with a pre-registered bar. Stale-address probe and the dialog check cut. Estimate raised to 5 to 6 days.
