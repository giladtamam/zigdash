# 3.6.3: stop asking Android 17 for a permission ZigDash doesn't need (v3)

v3 after the second review (v2 scored 8/10): a bar that isn't already met, the hint detected from the network,
and a TCP check. v2 after review (v1 scored 4/10): v1 looked for the trigger only in Dart. The trigger is ZigDash's own
Android code, and Google says apps at our target SDK must not ask at all. The plan is now: remove the
request, test what happens to people who already said no, and leave the "ask with a reason" design to the
later move to target SDK 37.

## What we found

**Android 17 is now our largest group and sets up half as often** (self-hosted analytics, last 6 days,
Play robots excluded, per session): Android 17 51 setup sessions, 5 completed (**10%**), empty scan 76%;
older Android 92, 20 completed (**22%**), empty scan 68%. First opens: Android 17 86, Android 16 71.

**The prompt is ours.** `MainActivity.onCreate` (android/app/src/main/kotlin/com/giladtamam/zigdash/
MainActivity.kt:184–188) requests `android.permission.ACCESS_LOCAL_NETWORK` on every launch on SDK ≥ 37
until it is granted, and the manifest declares it (AndroidManifest.xml:10). Added in 2.3 (commit 21fe3a90,
alerts-2.3.md §3), before Android 17's rules were final. Seen on a real Galaxy Tab S12 Ultra (Android 17,
One UI 9) on Nov 15: the "find, connect to, and determine the relative position of nearby devices" prompt
over the first screen, before any tap. (ACCESS_LOCAL_NETWORK is in the NEARBY_DEVICES group, hence the
wording.)

**Google's rule** (developer.android.com/privacy-and-security/local-network-permission, "Split permission
model"): local network protection applies only to apps targeting SDK 37+. Apps targeting < 37 with INTERNET
"receive an implicit permission grant for ACCESS_LOCAL_NETWORK"; "For these lower target SDKs, don't add
ACCESS_LOCAL_NETWORK to your manifest or request it at runtime." ZigDash targets 36
(android/app/build.gradle.kts:51). So the prompt buys nothing, scares new users on the first screen, and a
"Don't allow" may switch off the access they would otherwise have had (to be tested, step 2).

## The change

1. **Remove the request and the declaration** while targetSdk is 36: delete the block in
   `MainActivity.onCreate` and the `ACCESS_LOCAL_NETWORK` line in the manifest. Comment in their place that
   the permission comes back with the target-SDK-37 work, which has its own plan.
2. **Test on a real Android 17 device** (Samsung Remote Test Lab over adb), in this order, with screenshots:
   1. fresh install of 3.6.3: no prompt at launch. **UDP:** Find my setup runs its mDNS sends without
      EPERM in logcat. **TCP:** in Check this address, type the lab device's default gateway (from
      `adb shell ip route`) on port **80** (not 53, which is exempt): a refusal or an HTTP answer means TCP
      reached the LAN; a timeout means it was blocked.
   2. install 3.6.2, tap **Don't allow**, then update to 3.6.3: run the same UDP and TCP checks. Is local
      access back, or does the denial stick?
   - If the denial sticks, add one thing, detected from the network, not the permission API (once the
     permission is no longer declared, `checkSelfPermission` reports it denied for everyone): on Android
     17, when the scan's mDNS send fails with **EPERM**, the empty-scan screen shows "Android is blocking
     ZigDash from your home network" with **Open settings** (app settings). Only then; no new sheet before
     setup. Tested on the lab device in the denied-then-updated state.
3. **Small fixes from the same device run:**
   - the Wall display sheet's last lines sit under One UI's tablet taskbar: bottom padding from the system
     insets on that sheet and the other long scrolling sheets;
   - demo home: "Wake on motion" says there are no motion or door sensors although the demo has Hallway
     motion and Front door;
   - "Nothing yet": the Home Assistant row says "add-ons"; Home Assistant calls them apps now (13 languages).
4. **PRIVACY.md:** the "Permissions" paragraph says Android 17 asks for the local network permission; it
   changes to say ZigDash doesn't ask for it (Android gives apps like ZigDash local network access with the
   internet permission). Effective 3.6.3.

**Not in 3.6.3 (own plan, before target SDK 37, which Play will require around Aug 2027):** asking with a
reason at Find my setup, the denied screen in general, the reset-counter re-ask, and the NSD picker
(`DiscoveryRequest.FLAG_SHOW_PICKER`) for the scan. Paths that need the LAN then: the scan, a typed local
address, any `.local` name, local http Home Assistant; not: https Home Assistant on a public name, the
relay, a LAN DNS server (port 53 exempt).

## Read (3 weeks after 3.6.3 is live)
Per device (an install's first setup, from `app_started homes=0` sessions), Android 17 vs older:
- **Bar: Android 17's own empty-scan share drops at least 15 points from its per-device baseline** (the
  3 weeks before 3.6.3, computed at release; per session today it is 76%, older Android 68%), or the gap to
  older Android shrinks to 3 points or less.
- Completion per device, Android 17 vs older, reported with its count (about 8 Android 17 setups a day, so
  ~150 in 3 weeks); descriptive, since a 10% vs 18% gap is at the edge of what that volume shows.
- Before/after on the same measure: Android 17 devices in the 3 weeks before 3.6.3 vs after.

## Effort
Half a day of code and copy, plus one 30-minute Remote Test Lab session (2 credits).
