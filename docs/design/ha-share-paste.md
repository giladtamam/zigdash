# Home Assistant's address without typing: Share and Paste (2026-11-06)

Status: built on `feat/ha-share-paste` (from `release/3.4.2`), tested, not released. The phone check below changed the plan: Share and Paste ship together. Comes **before** [ha-connect-app.md](ha-connect-app.md): it attacks the same group with no install on Home Assistant, and its numbers decide whether that plan is still needed.

## Why

Last 7 days to 2026-11-06 (from ha-connect-app.md): 106 setup sessions took the Home Assistant path, 9 connected (8%). About 41 stopped at Home Assistant's address: none typed, none found, a name that didn't resolve, an address that didn't answer, or the sign-in opened and left.

What already exists for that step: DNS-SD (3.1.8), the usual names and the `/24` sweep (3.3.1), address-shape advice (3.1.12), the "Where do you open Home Assistant?" chips (3.3.4), and from 3.4.2 port 80 beside 8123. All of them try to *find* the address or explain how to *type* it. Nothing lets the person hand over the address they are already looking at.

Two facts about that address:

- **It is on the person's screen.** In a browser it is the address bar. In the Home Assistant Companion app it is under Settings › Companion app › the server.
- **ZigDash already accepts it as it is.** `haBaseCandidates` takes `http://192.168.1.20:8123/lovelace/0` or `https://x.ui.nabu.casa/config` and keeps scheme, host and port. A long-press paste into the field works today; nobody is told, and nothing counts it.

## What the phone check found (2026-11-06, Home Assistant app 2026.10.1)

The plan first assumed the Home Assistant app could not share its address out, so Share would reach browser users only and Paste would ship alone first. On a real phone:

- **Settings › Companion app › the server has a share icon at the top** ("Share server"). It opens Android's share sheet with a link, and the sheet has **Copy link**.
- The link is `https://my.home-assistant.io/invite/#url=<the server's address>`: the app's invite flow (from 2025.7). ZigDash reads the address out of it.
- On that phone the link carried the remote address as plain `http://`, for a server behind an https tunnel. So an http link to a remote name without a port is now tried on https first.
- The app's 2026.10 notes also list a gesture for "Open page in browser", which leads to the browser's own Share.

So both halves reach people who live in the Home Assistant app, which is most of them. "Paste alone first, Share only if browser users turn out to be a real group" is withdrawn.

## What it is

Two ways to give the address without typing, on the Home Assistant sign-in screen.

### 1. Paste

- A **Paste** button beside the address field.
- The clipboard is read **only on the tap**, never when the screen opens: Android shows a "pasted from clipboard" notice on every read, and reading unasked is not ours to do.
- The text goes through the same reading as a typed address. The first `http(s)://` link in it wins; without one, a single word that reads as a host or `host:port` is taken. Anything else: "No address in what you copied."
- A pasted address fills the field; the check happens when Sign in is tapped, as for a typed one.
- Works for everyone: the Home Assistant app's Copy link, a browser's address bar, a note, a message from whoever set Home Assistant up.

### 2. Share to ZigDash

- ZigDash becomes a share target for text. In the Home Assistant app: Settings › Companion app › the server › the share icon › **ZigDash**. In a browser: Share › **ZigDash**. ZigDash opens on the Home Assistant sign-in with the address filled in and a line saying it is the address that was shared.
- Android side: a small activity of its own, `ShareHaAddressActivity` (`ACTION_SEND`, `text/plain`, label "Connect Home Assistant" under ZigDash's name), like the NFC tag's: a share starts its target inside the sharing app's task, so it only passes the text on and closes. `MainActivity` gets it the way it gets a shortcut's request (`takeAction` on start and `onNewIntent`, the `action` channel), which covers a cold start and a running app with one instance.
- The address is read by `haAddressIn`: the address inside an invite link first, else the first `http(s)://` link in the text (some browsers send "title, link"), else one word that reads as a host. A copied token or password is not an address.
- Shared text with no address still opens the sign-in, which says so and how to share one.
- **Only until a home exists.** The share target is switched off once a real home is set up (`setShareTarget`, from `haShareTargetProvider`) and on again when none is left. A second home is added with Paste. That also means a share never arrives for a home ZigDash already has.

### The words on the screen

Above "Where do you open Home Assistant?", one line, by whether ZigDash is in the share sheet now:

- Share target on: "Fastest: in the Home Assistant app, open Settings › Companion app, tap your server, then the share icon at the top, and pick ZigDash. From a browser, share the page to ZigDash."
- Share target off (a home exists, or not Android): the same up to the share icon, then "Copy link. Come back and tap Paste."

It says "the share icon", not "Share server": on the phone it is an icon, and its label is translated in ways ZigDash cannot know. The older "Not sure what it is?" line now shows only after a chip is picked, as that kind's help.

## Not a secret, and nothing new leaves the phone

The address is used exactly as a typed one: kept on the phone with the home. No new permission, no Data safety change. The clipboard is read once, on the tap, and only its address part is kept.

## Measured

- `ha_connect` gains `from`: how the address in the field got there (`typed`, `found`, `pasted`, `shared`), and `path` = `from/result` (`shared/ok`, `pasted/unreachable`), since the analytics service cannot cross two properties. One list then answers "does an address that was handed over connect more often than a typed one?" An address edited by hand after it was filled counts as typed.
- `setup_step` `ha_share`: a share arrived, with `result` `address` or `no_address`. `ha_paste` the same for the button.
- Kinds only (ADR 0006): never the address or the text. The sentence is in `store/PRIVACY.md` on the branch; publishing it comes with the release.

## Expected effect, and when to stop

Honest size: of ~41 address-stuck sessions a week, perhaps a third take Share or Paste now that both work from inside the Home Assistant app, and an address that was handed over should connect far more often than the 8% of the whole path. That is **4 to 9 more Home Assistant connections a week**, up from the first estimate of 2 to 6, for a few days of work and no second product. Still a guess until `path` is read.

Rules, read three weeks after release:

- **Share target:** fewer than 10 shares in three weeks → remove it. It costs every user a row in their share sheet for any text they share, and has to earn that.
- **Paste:** stays either way (it is a button on one screen). If `pasted/ok` is no better than `typed/ok`, the problem is not typing, and the next step is the sign-in itself, not the address.
- **ha-connect-app.md:** only if `pasted` and `shared` together are used but the path still fails at the address for Home Assistant OS users.

## Work

| Part | Size |
|---|---|
| Paste button, clipboard reading, the address check on paste | half a day |
| Share target: manifest alias, `MainActivity`, Dart side, landing rules | a day and a half |
| Help texts, 13 languages | half a day |
| Events, policy row, tests, emulator checks | a day |

Tests: link extraction from the shapes browsers send (link only, title + link, link with a path, no link, two links); the Paste button with a link, a bare host, and nothing usable; a share arriving on first run, with a home, and for a home that exists. On the emulator, cold, running, and from another screen:

```
adb shell am start -a android.intent.action.SEND -t text/plain \
  --es android.intent.extra.TEXT "http://10.0.2.2:8123/lovelace/0" \
  -n com.giladtamam.zigdash/.MainActivity
```

Branch from `release/3.4.2`. Ships as 3.4.3 on its own, or in 3.5.0 with the hub guide, whose Home Assistant guide ends on this same sign-in screen.

## Choices taken, and one left

1. **Share target only until a home exists** (built so; the recommended default).
2. **The share sheet label:** "Connect Home Assistant", shown under ZigDash's name; translated in the ten languages the Android side has.
3. **Left to the user: release.** 3.4.3 alone, or with the hub guide in 3.5.0.

## Verified, and not yet

- Unit and widget tests: the address in every shape seen (invite link, encoded or not, with other parts; a browser's link with a path or after a title; a bare host; nothing usable; a token), Paste, a share on arrival, the share-target switch.
- Emulator: a share on a cold start and into the running app (one instance, one task), a browser-style "title, link", and text with no address.
- Phone: the Home Assistant app's share sheet and link shape were read on a real phone. **Not yet done there:** the last step, picking ZigDash in that sheet and landing on the sign-in. The test build is installed for it.

## Out of scope

- iOS: a share target there is a separate extension target on `ios/prep`. The Paste button works on iOS as it is.
- Import from Home Assistant still fills in `:8123` and tries only what is in its field (noted in ha-route.md).
- Reading the Companion app's server address directly: Android does not allow it.
