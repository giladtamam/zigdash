# Home Assistant: when the look finds nothing (3.5.2)

Status: plan, 2026-11-10. Scored 7, revised with a diagnosis from full
session details and the reviewer's fixes, re-scored 9.

## The problem, measured

Setup read of 2026-11-10 (docs: memory `setup-read-2026-11-10`): of 274
setup sessions Oct 31 – Nov 8, 62 (23%) chose Home Assistant and never got
signed in, the largest group of people who do have a hub.

The state they stop at is "Connect through Home Assistant" after the look
(DNS-SD, the usual names, a /24 sweep on 8123 and 80) found nothing.
Oct 25 – Nov 8, Google's US Android 11 device excluded:

| After "found nothing" | Sessions |
|---|---|
| Saw the state (`ha_discovery` none) | 81 |
| Reached a sign-in try with an address | 11 (14%) |
| Finished setup through Home Assistant | 2 |
| Used Paste | 1 |
| Tapped a "where do you open it" chip | 12 |

What the screen shows today in that state (emulator, 2026-11-10), top to
bottom: an intro that says "Your phone can't reach the broker, but it can
reach Home Assistant" (false here: it just failed to), the empty address
field with a two-line helper, Paste, then "This phone can't see Home
Assistant on this Wi-Fi..." in the middle of the page, a four-line
"Fastest: in the Home Assistant app, open Settings › Companion app..."
instruction with no button, four "where" chips, a disabled Sign in button,
the browser-login note, the token link and the sign-in-kept note. Nine
blocks; the one thing that would unblock them (getting the address out of
Home Assistant) is a sentence in the middle.

## Diagnosis (full session details, 2026-11-10)

The reviewer's first question: are these people stuck for a reason a screen
can't fix? Full event details of all 81 sessions (cloud Aptabase,
live-session-details):

- **Never got an address: 66 of 81 (81%).** The loss is before any try.
  After the look found nothing, 30 left the app right there, 15 went back
  to scan, 10 tapped the old "Ask your AI" write-up, 8 picked another
  answer to "what runs your Zigbee", the rest went to the guide, demo or
  hub pages.
- **Tried an address: 15** (a re-count from full details; the step cache
  said 11). 2 finished, both remote names on https 443. 11 ended
  unreachable: 4 remote names (3 of them on versions before 3.3.4, which
  now tries https first), 3 `.local` names (Android often can't resolve
  them; the screen already says so), 4 other.
- **ZHA:** 12 of 81 (15%) also answered ZHA somewhere in the session; no
  screen helps them, and the plan does not count them as a target.
- **How they got here:** 65 of 81 opened the sign-in from the welcome
  screen's "Home Assistant" answer, not from a broker failure, so the
  intro's "your phone can't reach the broker" is wrong for 80% of them.
- **Versions:** only 11 of the 81 ran 3.4.3 or later (Paste, share target,
  chips all present). The baseline therefore mixes screens; see the read.

So most of the loss is "never got an address", which is what this changes.
The try-side failures are small and mostly already fixed by 3.3.4.

## What changes

Only the found-nothing state: the last look ended with nothing found and
the screen was not opened to sign in again for an existing home. The card
depends on that look result alone, never on whether the field is empty, so
nothing above the field moves while someone types or pastes. Every other
state of the screen is untouched.

1. **Intro.** One neutral line for every entry: "Sign in once with Home
   Assistant, and ZigDash talks to Zigbee2MQTT through it: at home or away,
   with no broker settings." The broker sentence goes; it is wrong for
   people who start from the welcome screen, which is most of them.

2. **A "couldn't find it" card first, under the intro.** Title: "ZigDash
   couldn't find Home Assistant from this phone". One line of why, chosen by
   what the phone knows:
   - no Wi-Fi address: "This phone isn't on Wi-Fi. Join your home Wi-Fi and
     tap Look again, or use the address you open Home Assistant with from
     outside.";
   The Wi-Fi state is checked when the look ends and again whenever the app
   comes back to the front (someone who left to join Wi-Fi returns to the
   right line).
   - otherwise: "It may be on another network, or you open it from outside
     (Nabu Casa, DuckDNS, your own domain)."

3. **Get the address from Home Assistant, as steps with a button.**
   - When the Home Assistant app is installed (Android package
     `io.homeassistant.companion.android` or `.minimal`, checked through a
     `<queries>` entry): a filled button "Open the Home Assistant app", then
     three numbered lines: 1) Settings › Companion app; 2) tap your server,
     then Share (Copy link if ZigDash isn't in the list); 3) pick ZigDash, or
     come back and tap Paste. The button only opens the app; nothing is read
     from it.
   - Otherwise: two lines for a browser: open Home Assistant in the browser
     you use for it, then Share › ZigDash (or copy the address and tap
     Paste). The share wording follows the existing switch: only when
     ZigDash is in the share sheet (Android, before a home exists);
     otherwise copy and Paste. iOS always gets copy and Paste, and no app
     button.
   - The button opens the app by its launch intent; when that fails (the
     app disabled since the check), the browser lines show instead.
   The share sheet target and Paste already exist (3.4.3); this makes them
   the visible path instead of a sentence.

4. **Then the field**, labelled "Or type the address", with Paste next to
   it and the "where do you open it?" chips under it as today (they set the
   field's example and say where to find the address). The long helper text
   under the field goes in this state; the chips carry it.

5. **Two quiet ways on**, as text buttons under the field:
   - "Look again": runs the look once more, on Wi-Fi or not (someone who
     just joined the right Wi-Fi). The controller gets a real
     `lookAgain()`: today's `look()` runs once and returns the same future;
     the new one resets the found list and the phone's address, only from
     the ask state with the last look ended, so a sign-in waiting on a look
     is never handed a different one. It counts its own `ha_discovery`
     event like the first look. The card stays in place while it runs: its
     why line becomes "Looking for Home Assistant on this network…" and
     Look again shows a spinner; the card goes only if the new look finds
     Home Assistant.
   - "Not sure? Ask the assistant": opens Get help from a new origin
     `HelpFrom.haConnect`, platform `home_assistant`, so the 3.5.1 assistant
     answers with its setup knowledge (which covers Home Assistant addresses,
     Nabu Casa, ports 8123 and 80). Counted as a setup origin. This is the
     in-app successor of the "Ask your AI" write-up that 10 of the 81
     tapped; that card stays where it is for failed tries.

6. **Below, unchanged:** the Sign in button (enabled once there is an
   address), the browser-login note, the token link, the sign-in-kept note.

iOS: the app check and the "Open the Home Assistant app" button are
Android only for now; iOS shows the browser line in its copy-and-Paste
wording.

## What is measured

New `setup_step` step `ha_none` with:
- `choice`: `shown` (once per look that found nothing), `open_app`,
  `look_again`, `assistant`;
- `net`: `wifi` or `other`, on `shown` only.

Whether the Home Assistant app is installed is not sent (that would be
installed-apps data for Play's Data safety form); `open_app` taps say what
matters. The app check itself stays on the phone.

Paste, share, typing, chips and sign-in tries are already counted
(`ha_paste`, `ha_connect` with `path`, `ha_where`). Nothing about the
address, and nothing about the Home Assistant app. The privacy policy's
`setup_step` row gains one sentence for `ha_none`.

## The read and the kill rule

Read three weeks after 3.5.2 is live, on the self-hosted Aptabase, sessions
on 3.5.2 or later, Google's US Android 11 device excluded.

- Population: sessions with `ha_none` shown, minus sessions that also
  answered ZHA.
- Main measure: share that reach `ha_connect` with an address (any result
  but `no_address`), counted from full session details exactly as the
  baseline was (not from the step cache, which under-counts tries). ZHA
  means the session answered ZHA anywhere. Baseline from the 81 above, ZHA removed: 15 tries in
  69 sessions, 22%; on 3.4.3 or later only 11 sessions, too few to stand
  alone, so the mixed baseline is the one used. Bar: 35%.
- Guard: setups finished through Home Assistant after `ha_none` must not
  fall below the baseline rate (2 of 69, 3%).
- Second look: which of `open_app`, `assistant`, `look_again`, Paste and
  typing came before each try.
- Noise: at 60 sessions a share near 25% is about ±6 points, so nothing is
  decided below 60 sessions; at three weeks with fewer, read again at six.
- Kill: at 60 or more sessions and at or below 15%, the card goes and the
  old order returns in the next release. The November sale (to Nov 30)
  brings more installs, not different ones; noted, not corrected for.

## Work

About a day and a half (the reviewer's count of the hidden parts is right):
- Android: `<queries>` for the two Home Assistant packages; `hasApp` and
  `openApp` on the existing app channel (MainActivity).
- `ha_connect.dart`: `lookAgain()` as above.
- `ha_connect_screen.dart`: the found-nothing card, steps, order; intro
  string; Look again; Ask the assistant route; Wi-Fi re-check on resume
  (`homeIpv4`, an app lifecycle listener).
- `HelpFrom.haConnect` through `help_tips`, `openedFromLabel`,
  `setupOrigin`, analytics; `SetupStepKind.haNone` with `choice`, and on
  `shown` the network (`net`: `wifi` or `other`).
- About ten strings in 13 languages; policy sentence (no Data safety
  change: nothing new leaves the phone beyond the step and Wi-Fi yes/no);
  changelog; widget tests for the
  state (app installed / not, on Wi-Fi / not, Look again, assistant route,
  the card staying put during Look again, untouched other states); emulator screenshots with the look forced empty
  in a local build only.
