# Answer support from Telegram (support-reply)

Rev 3.1, 2026-11-16. Independent review: rev 1 6/10, rev 2 8/10, rev 3
9/10 "ready to build"; 3.1 folds in its last notes. Status: plan.

## Why, and why now

Support messages from the app arrive in the owner's Telegram (Worker
`zigdash-support`, `/v1/message`). The address in each message is tappable,
so answering today means leaving Telegram, opening Gmail, and keeping no
link between the two. In the first real case (Nov 2026) the owner replied
in the bot chat, where nothing goes back to the user. Support volume is low
(a few a week), so the time saved is small; the reasons to do it now are
that a missed answer costs a user who already likes the app, that "Send"
from the device where support is read gets answers sent the same day, and
that the parts are cheap (free sender, an additive DNS change, one Worker
route).

Stage 0, shipped with this plan in any case: the forwarded message gets a
last line "Reply to this message to answer by email." (before the bot
exists, and on the old bot's fallback: "Tap the address to answer by
email."). The body is clipped first and the line appended after, so it is
never cut off.

## What exists

- `tool/support-worker/worker.js`: `/v1/message` posts to the owner's chat
  via `TELEGRAM_BOT_TOKEN` (@zigdash_bot); `notifyDeveloper` (early-access
  notices) uses the same token. It stores nothing; the text is
  line 0 `ZigDash support|AI report, <ver>, <locale>`,
  line 1 `From: <email>` or `From: (no email)`, a blank line, the message,
  then `— Support details —`.
- @zigdash_bot is also the community group bot, read by `tool/telegram.py`
  with getUpdates; a webhook on it breaks that reader (409, seen
  2026-10-13). @ZigDashHomeBot's webhook belongs to the chat service. So
  replies need a new bot (confirmed: getUpdates and a webhook can't coexist
  on one bot).
- The app (no change needed) says "Your email, if you want an answer" and
  "I usually answer within 3 days if you left an email"; it promises nothing
  about the channel.

## Design

1. **New support bot** (e.g. @zigdash_support_bot): the owner creates it in
   BotFather, sets "allow groups" off and a description "Not monitored:
   write from the ZigDash app (Settings › Get help)", and sends it /start.
   Secret `SUPPORT_BOT_TOKEN`. `/v1/message` and `notifyDeveloper` both move
   to it in one deploy. `TELEGRAM_BOT_TOKEN` is a fallback used only on a
   definite HTTP error from the support bot, not on a timeout (a slow
   success must not be posted twice; the trade-off: a timeout that really
   failed is a lost message and the app offers Share, as today). Each
   fallback bumps KV `fallback:<yyyy-mm>`; the old token is removed once
   that counter stayed at 0 for a week. Messages forwarded before the
   switch, or through the fallback, are answered by hand.
2. **Every header field checked at intake**, so line 1 can only ever hold
   one plain address:
   - `email`: `validEmail()` plus no whitespace, comma, `;`, `<` or `>`.
     Invalid → line 1 is `From: (invalid address)`, and the typed value
     (newlines removed, cut to 100 chars) goes on a `Typed: …` line after
     the message, so the owner can still answer a typo by hand. The parser
     never reads that line.
   - `app`, `build`: only `[0-9A-Za-z._+-]`, at most 20 chars; `locale`:
     `^[a-z]{2,3}([_-][A-Za-z]{2,4})?$`. Anything else becomes `?`. So no
     field can add a line before line 1.
3. **Webhook** `POST /v1/support-tg/<SUPPORT_WEBHOOK_SECRET>` (secret of
   `[A-Za-z0-9_-]`, also sent as `X-Telegram-Bot-Api-Secret-Token`, wrong →
   401). `setWebhook` with `allowed_updates: ["message","callback_query"]`.
   Always answers 200 once the header is right, so Telegram doesn't retry.
   Messages: acted on only when `message.chat.id` and `message.from.id` are
   the owner. Callbacks: only when both `callback_query.from.id` and
   `callback_query.message.chat.id` are the owner; `answerCallbackQuery` is
   always called.
4. **Owner's message → what happens.**
   - A Reply to a forwarded support message: accepted only if
     `reply_to_message.from.id` is the support bot's own id (the number
     before the colon in its token), line 0 matches
     `^ZigDash (support|AI report), `, and line 1 is `From: <address>` that
     passes the same check as intake. Only line 1 is read, so a "From:" in
     the user's own text can't redirect the answer.
   - The same with `(no email)` or `(invalid address)`: "This message has no
     email address, so it can't be answered."
   - Plain text that isn't a Reply: "Use Reply on the support message you
     want to answer." (the exact mistake that started this).
   - A Reply to anything else: the same hint. A Reply without text (a
     photo, a sticker): "Text only".
   - The owner edits a reply that has a waiting draft (`edited_message`
     is in `allowed_updates`; KV `replyof:<replyId>` → draft id, 1 h): the
     draft is deleted and the preview edited to "Your reply changed: reply
     again to send". So what is sent is always what the screen shows.
5. **Preview.** The bot answers as a Telegram reply to the owner's message
   (whose text is right above it): "Send this answer (<length> chars,
   starts \"<first 60 chars>…\") to <full address>?" with buttons **Send** / **Cancel**. The reply text isn't repeated, so the
   preview never nears 4,096 chars; a reply over 3,800 chars is refused
   ("too long, shorten it") to leave room in the email. The draft
   `{to, reply, original, date, forwardedId, replyId}` (`date` = the
   forwarded message's date) is put in KV `RATE` under `reply:<id>`, id = 12
   random base64url chars, TTL 1 hour. Callback data `s:<id>` / `c:<id>`
   (under Telegram's 64-byte limit). The header comment of worker.js says
   that `RATE` now also holds these short-lived drafts (personal data).
6. **Send**, safe against double taps and retries:
   - Resend is called with `Idempotency-Key: reply-<id>` (Resend keeps it
     24 h), so two taps or a Telegram retry can't send twice, whatever KV
     shows. The email is built only from the stored draft (no clock, no
     random), so a retry sends the identical payload.
   - **Only success and Cancel edit the preview.** Everything else is a
     notice on the button tap (`answerCallbackQuery` with `show_alert`), so
     a late or losing callback can never overwrite "Accepted". Telegram's
     "message is not modified" and "message to delete not found" errors
     are swallowed.
   - Draft missing: `sent:<id>` → notice "Already sent"; otherwise
     "Not ready yet, tap Send again" if under 1 hour
     since the preview (KV can lag between locations), "Expired: reply
     again" after.
   - 2xx: the preview is edited to "Accepted by Resend" (no address: the
     preview stays in the chat; not "delivered": bounces show only in
     Resend's dashboard) and gets a **Done** button. Before the draft is
     deleted, KV `sent:<id>` (1 h) is written, so a tap after a failed
     preview edit says "Already sent", never "expired" (which would invite
     a second email). KV `replies:<yyyy-mm>` goes up.
   - 409 `concurrent_idempotent_requests` (the other tap is still sending),
     429, 5xx: notice "Still sending or busy, tap Send again"; draft kept.
   - 409 `invalid_idempotent_request` (payload changed: a bug, since the
     body is deterministic): notice with the error; draft kept; counted in
     KV `bug:<yyyy-mm>`.
   - Other 4xx (e.g. 422): notice with the error text; draft deleted.
   - **Cancel**: draft deleted, preview edited to "Cancelled".
   - **Done** (callback `d:<forwardedId>:<replyId>`, ids only, under 64
     bytes), tapped when the conversation is over (the user may write back
     to Gmail, and the forwarded message holds the device details): deletes
     each of the forwarded message, the owner's reply and the preview that
     is under 48 hours old (Telegram's limit), one by one, then a notice
     naming the ones left to delete by hand (usually the forwarded message:
     Done is mostly tapped later). Nothing is deleted on Send. A Cancel and
     a Send within a second may still send (KV lag): accepted.
7. **The email** (plain text, Resend open/click tracking off):
   - From `Gilad from ZigDash <support@zigdash.app>`; Reply-To and BCC the
     owner's support inbox (open question 1), so the owner has a copy and
     answers land there.
   - Subject `Your ZigDash support message`.
   - Body: "You wrote to ZigDash support from the app on <date of the
     forwarded message, day only, no time>." then the reply text, then "Reply to this email to
     answer." then `Your message:` and the user's original text, cut to
     1,500 characters on a code-point boundary, then links replaced by
     `[link removed]`: `https?://\S+`, `www\.\S+`, bare
     `domain.tld/path` and bare `domain.tld` for common TLDs (so the sender can't be used to mail someone a
     link). The device details are never sent back.
8. **Sending service: Resend, free plan** (100/day, 3,000/month, up to 3
   domains, 30-day logs). Domain `zigdash.app` added in region
   **eu-west-1 (Ireland)** (the region can't be changed later without
   re-adding the domain). API key with **sending access for zigdash.app
   only**, stored only as Worker secret `RESEND_API_KEY`.
   DNS at GoDaddy, **additive only** (the GitHub Pages records and the HA
   client_id site are untouched; the record list is screenshotted before and
   after): DKIM TXT `resend._domainkey`; MX and SPF TXT on the `send`
   subdomain. **DMARC: a record already exists**
   (`v=DMARC1; p=quarantine; adkim=r; aspf=r; …`); it is kept as is, not
   duplicated. Resend's DKIM and the `send.` return path align under relaxed
   mode, so mail passes. Mail to `support@zigdash.app` itself bounces (no
   root MX); the body says to reply, which goes to Reply-To. A forwarding MX
   is a later, separate change.
   Rejected: Cloudflare Email Sending (beta, needs Workers Paid and the
   domain on Cloudflare DNS); Gmail API from the Worker (a long-lived token
   to the owner's mailbox is too much power).

## Privacy

The support section of `store/PRIVACY.md` is rewritten (not one line
added), because two current sentences become untrue ("keeps nothing; it
does not log the message" and "deleted from the chat once answered").
New wording, approved by the owner before deploy, says:
- the Worker stores nothing about a message, except, when the owner answers,
  a draft of the answer (the address, the answer and the person's message)
  for at most one hour, and a monthly count of answers;
- answers are emailed through Resend (Plus Five Five, Inc., USA; sent from
  the EU; EU-US Data Privacy Framework and standard contractual clauses),
  which keeps sending logs for 30 days; a copy goes to the developer's
  support inbox and is deleted within 6 months, like other support email;
- the Telegram copy (the message, the answer and a note that it was
  sent, without the address) is deleted when the conversation is over, by
  the bot when under 48 hours old, otherwise by hand, and in any case
  within 6 months.
Published on GitHub + GitLab; no app release needed.

The public repo gets no real user data: examples use `user@example.com`.

## Tests

`tool/support-worker/worker.test.mjs` (node:test; fetch, KV and clock
mocked):
- Intake: valid address kept; `a@b.c\nFrom: x@y.z`, `a@b.c, x@y.z`,
  `a@b.c x`, `<a@b.c>` → `From: (invalid address)` plus a `Typed:` line;
  a newline or `From:` in app, build or locale doesn't change line 1;
  the stage-0 line survives a message clipped at 4,096.
- Reply parsing: only line 1 counts (a `From:` or `Typed:` in the body is
  ignored); from another bot id / wrong line 0 → hint; reply over 3,800
  chars → refused; `(no email)` and
  `(invalid address)` → "can't be answered"; clipped `… (cut)` original;
  AI report kind.
- Webhook guards: wrong header → 401; another chat → ignored; callback from
  another user in the owner's chat → ignored, still answered; plain non-reply
  text → hint.
- Send: one Resend call with the right to / reply_to / bcc / subject /
  idempotency key, body without support details, http, www and bare-domain
  links replaced, original cut at 1,500 on a code-point boundary; the same
  draft gives a byte-identical body twice. Two concurrent Sends with a mock
  that answers the second with 409 `concurrent_idempotent_requests` → one
  email, the preview ends as "Accepted", the loser only gets a notice.
  Draft missing under an hour → "tap again", after → "expired"; 429/5xx →
  draft kept; 422 → notice, draft deleted; the "Accepted" preview has no
  address; Cancel → no call; Done → deletes only the messages under 48 h
  and names the rest; preview edit fails after 2xx → the next tap says
  "Already sent"; an edited reply deletes its draft; a photo reply →
  "Text only".
- `/v1/message` and `notifyDeveloper` use the support bot; the old token
  only on an HTTP error (not a timeout), with the "Tap the address" line
  and the fallback counter.

## Rollout

1. Stage 0 line in the forwarded message (deploy with the current bot).
2. Owner: BotFather bot as in Design 1; paste its token as
   `SUPPORT_BOT_TOKEN` (Claude never types tokens).
3. Owner: Resend account (EU region) and a sending-only key, pasted as
   `RESEND_API_KEY`; Claude adds the DNS records at GoDaddy in Chrome with
   the owner signed in, screenshots before and after, owner clicks Save.
4. Policy wording approved and published.
5. Deploy; `setWebhook`; test from the emulator with the owner's own
   address: Reply, Send, double-tap Send, Cancel, Done. Check the mail lands in
   the inbox (not spam) with DKIM and DMARC pass in "Show original".

## Measure

KV counter `replies:<yyyy-mm>`. Read 2026-12-15: answers sent vs support
messages received, and whether any landed in spam (ask in the next
replies). No kill rule; remove only if Resend's free plan changes.

## Open questions for the owner

1. Support inbox for Reply-To and BCC: giladtamam1@gmail.com (already
   public as the support address; recommended) or tamamg@gmail.com
   (Claude can read it with the Gmail connector)?
2. Sender name "Gilad from ZigDash"?
