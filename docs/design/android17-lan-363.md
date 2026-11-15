# 3.6.3: Android 17's local-network question, at the right moment (v1)

## What the data and a real device say

**Android 17 is now our largest group and sets up half as often** (self-hosted analytics, last 6 days,
Play robots excluded, per session):

| | Setup started | Completed | Rate | Empty scan |
|---|---|---|---|---|
| Android 17 | 51 | 5 | **10%** | 39 (76%) |
| Older | 92 | 20 | **22%** | 63 (68%) |

First opens: Android 17 86, Android 16 71, 13–15 81. Small numbers, but the gap is large and the group is
growing (new Samsungs and Pixels ship with 17).

**On a real Galaxy Tab S12 Ultra (Android 17, One UI 9, Samsung Remote Test Lab, Nov 15):** at the very
first launch, before any tap, Android shows "Allow ZigDash to **find, connect to, and determine the
relative position of nearby devices**?". That is the new `ACCESS_LOCAL_NETWORK` permission (declared in
android/app/src/main/AndroidManifest.xml:10; targetSdk 36). Without it the setup scan, the broker test and
any local address fail. A new user who taps "Don't allow" on an unexplained, location-sounding prompt
can't set up, and today nothing tells them why: the scan just finds nothing, and `scan_failed` maps to
`noLocalNetwork` (lib/features/support/support_details.dart:53) only in support details.

What we don't know yet: what triggers the prompt at launch (no code requests it; nothing on the welcome
screen opens a socket in setup_screen.dart initState), and how many people deny it (not logged).

## The change

1. **Find the trigger** on an Android 17 device (Remote Test Lab over adb, `logcat` for the permission
   request and its caller at first launch). Then remove that early local-network access, so the first
   prompt can only come from the steps below. If Android itself prompts at launch for any app that
   declares the permission, record that, and the explanation in step 2 still applies.
2. **Ask with a reason, when the person asks for setup.** On Android 17+, the first time setup needs the
   home network (Find my setup, Zigbee2MQTT / SMLIGHT / Home Assistant local paths, a typed local address,
   Check this address), a short ZigDash sheet comes first: "To find your hub, ZigDash looks on your home
   Wi-Fi. Android will ask to let ZigDash find devices nearby: tap Allow. ZigDash only talks to your hub and
   your Home Assistant; it doesn't use your location." [Continue] then the system prompt (requested
   explicitly). Not on remote-only paths (a Nabu Casa / https Home Assistant address, the Zigbee2MQTT page
   over https), which don't need it.
3. **Denied: say so, and how to fix it.** If the permission is denied, the scan / test shows "ZigDash
   can't look on your home network" with **Open settings** (the app's settings page) and **Try again**,
   instead of an empty scan. Permanently denied ("don't ask again"): Open settings only.
4. **Measure:** event `local_network {result: granted | denied | denied_forever | already, at: scan |
   manual | ha | address}` once per request, and `scan_empty` gains `lan: granted | denied` on Android 17+.
   PRIVACY.md row added (no new data: the answer and the step).
5. **Small fixes from the same device run:**
   - the Wall display sheet's last lines sit under One UI's tablet taskbar: bottom padding from the
     system insets (view padding / safe area) on that sheet and the other long sheets that scroll;
   - demo home: "Wake on motion" says there are no motion or door sensors although the demo has Hallway
     motion and Front door (the sensor check doesn't see demo devices);
   - "Nothing yet": the Home Assistant row says "add-ons"; Home Assistant calls them apps now (13 languages).
6. **Before release:** run first launch, the sheet, Allow, Don't allow and Open settings on an Android 17
   Samsung in Remote Test Lab, with screenshots; plus the emulator for older Android (no sheet).

## Read (3 weeks after 3.6.3 is live)
- Android 17 setup completion against older versions. Bar: the Android 17 rate reaches at least 80% of
  the older rate (today 45%), on at least 100 Android 17 setup sessions.
- `local_network` denied share; if it stays above 20% after the explanation, the wording is the next work.
- `scan_empty` on Android 17 with `lan: granted` vs older: if still higher, the gap is not the permission.

## Effort
About a day plus a 30-minute Remote Test Lab session.
