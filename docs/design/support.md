# In-app support: build spec

This is the handoff for in-app support. The decisions were made on 2026-10-10 in the "In-app user support" map and accepted by the user. It serves users stuck in setup (who never leave First run) first. Words follow [CONTEXT.md](../../CONTEXT.md): **Get help**, **Support request**, **Support details**, **Report a problem**.

**Release:** not chosen here. It fits next to 2.1 (see the post-2.0 roadmap); the work is small (one screen, a few links, two events).

## Scope

In: the Get help screen and its tips, help links in setup, on the dashboard, on the Devices tab, in Settings and on the demo banner; Support details and how it is sent; the support promise; two opt-in analytics events; the privacy policy and README lines.

Out: live chat, WhatsApp (personal or Business), in-app call booking, and anything that sends data without the user sending it.

## 1. The support promise

- **Channel:** written, by email to a new address used only for ZigDash support. `giladtamam1@gmail.com` keeps working for the privacy policy and older app versions. GitHub stays open for those who prefer it.
- **Reply time:** "usually within 3 days". Nothing faster is promised.
- **Languages:** English and Hebrew. Users may write in any language; replies may go through a translator. Calls are English or Hebrew.
- **Calls:** never offered in the app. For setup problems only, after two email rounds haven't solved it, the developer may send a private Cal.com link: one hidden 20-minute event with Cal Video, 15-minute buffer, 24 hours' notice, at most 2 a week, availability in Israel time. Fallback: propose two or three times by email in both time zones with a Meet or Jitsi link.
- **Never asked for:** passwords (MQTT, Wi-Fi, hub) or remote access to the user's network or phone. On a call, the user shares their own screen and types any password themselves.
- **Shown:** one line on Get help, and the README's Support section. Not on the Play listing.

Get help line: *"Still stuck? I usually reply within 3 days, in English or Hebrew. I'll never ask for your passwords."*

## 2. Where help appears

Every link opens the one **Get help** screen, telling it where it came from.

| Place | Link | `from` |
|---|---|---|
| Setup: "No connection found" | "Still stuck? Get help" under the main button, below the platform tips | `no_connection` |
| Setup: each error screen (`setupErr*`) | the same link next to Try again | `setup_error` (with the error kind) |
| Manual connect: the connection check failed | the same link under the diagnostics | `manual_connect` |
| Dashboard: the home can't be reached | in the unreachable state | `home_unreachable` |
| Devices tab: device list missing | under Restart Zigbee2MQTT | `device_list_missing` |
| Settings | new **Help & support** group: Help & Guide, **Get help**, Report a problem, Request a feature | `settings` |
| Demo banner | "Need help connecting your hub? Get help" | `demo` |

Not on: scanning and "Checking the connection…" screens (nothing has failed yet), or a device page for a device that is not responding (a Zigbee problem the page already explains).

**Get help** is for "I can't get it working" (a Support request). **Report a problem** stays for bugs to fix.

## 3. The Get help screen

Layout A from the prototype (branch `prototype/get-help`, `docs/design/prototypes/get-help-prototype.html`, local only):

1. App bar "Get help".
2. **Try these first:** the tips for the place it was opened from, as a list the user can tick. Ticks are not saved.
3. The promise line (section 1).
4. **What's included**, collapsed: the Support details exactly as they will be sent.
5. **Contact support** (filled button): opens the email app with the support address, a subject, a short prompt, and Support details at the bottom.
6. **Copy details** (text button): copies Support details to the clipboard, for webmail or GitHub.

From a setup error, it opens straight to that error's tips; it doesn't ask which message the user saw.

### Tips

**No connection found**
- **Same Wi-Fi as your hub.** Your phone must be on the same network as the hub, not a guest network. Turn mobile data off while you set up.
- **The broker is running.** Home Assistant: the Mosquitto add-on is started. Raspberry Pi: Mosquitto is running. SMLIGHT: Settings › MQTT is on.
- **The broker accepts your phone.** SMLIGHT: turn on Allow External. Mosquitto 2 only accepts connections from the hub itself until it's set to listen on the network (port 1883).
- **Mesh Wi-Fi or two routers?** If the hub hangs off a second router, your phone may not see it. Plug the hub into the main router, or connect by its address.
- **Connect by address.** Find the hub's address in your router's app, then tap Enter details manually.

**Setup errors**
- *Can't reach this address:* **Same network** (phone and hub on the same Wi-Fi, mobile data off). **The address changed** (hubs can get a new address after a restart; check it in the router's app and reserve it there).
- *Nothing answers on this port:* **The right port** (MQTT is usually 1883, 8883 with TLS; 8080 or 80 is the hub's web page). **The broker is running.** **Mosquitto 2** (the reworded tip above).
- *Login rejected / Login required:* **The MQTT login, not the web login** (Home Assistant: a Home Assistant user, or the login set in the Mosquitto add-on). **Check for spaces** (copying a password can add one at the end).
- *No Zigbee2MQTT here:* **Zigbee2MQTT uses this broker** (check its MQTT server setting). **Base topic** (if it isn't "zigbee2mqtt", enter it in manual setup).
- *No devices received:* **Pair devices first** (in Zigbee2MQTT's web page). **Restart Zigbee2MQTT** (so it publishes its device list).
- Other errors (no local network, couldn't save, unknown) show the No connection found tips.

**Manual connect failed**
- **Use the number address.** Names ending in .local don't work on every Android phone. Try the hub's number address, like 192.168.1.20.
- **Port and protocol.** TCP on 1883 is the usual. Pick TLS or WebSocket only if your broker is set up for it.
- **Login.** Leave username and password empty if your broker has none. Otherwise use the MQTT login, not the hub's web login.

**Home can't be reached**
- **Is the hub on?** A power cut or update may have restarted it. Give it a minute after it comes back.
- **Are you at home?** Away from home, the app needs a remote address (for example Tailscale). Set it in the home's connection settings.
- **Did the address change?** After a router restart the hub may get a new address. Reserve its address in your router's app, then update the home.

**Device list missing**
- **Restart Zigbee2MQTT.** If the broker restarted, Zigbee2MQTT's device list is gone until Zigbee2MQTT restarts. Use the Restart Zigbee2MQTT button on the Devices tab.
- **Is Zigbee2MQTT running?** Open its web page. If it doesn't load, restart it on your hub.

**Settings**
- **Can't connect to my hub.** Same Wi-Fi, broker running, Allow External or Mosquitto listening on the network, then connect by address.
- **A device shows wrong or doesn't respond.** Check it in Zigbee2MQTT's web page first. If it works there, use Report a problem.
- **How do I…** Scenes, Wall display, schedules and backups are in Help & Guide.

**Demo banner**
- **What you need.** An MQTT broker (Mosquitto) and Zigbee2MQTT running on a hub: Home Assistant, a Raspberry Pi, or an SMLIGHT hub.
- **On the same Wi-Fi.** Set up at home, with your phone on the same Wi-Fi as the hub.
- **Then.** Leave the demo and tap Find my setup. ZigDash looks for your hub on its own.

The screen and tips are translated into the 11 app languages like every other string. Support details is not (section 4).

## 4. Support details

Always in English, as short fixed labels. Example:

```
ZigDash 2.0.1 (31) · Android 15 · Samsung SM-S721B
Opened from: Setup › No connection found
Connection: local · TCP · port 1883 · private address in 192.168.x
Zigbee2MQTT: 2.6.1 · bridge online · 14 devices
Last error: timed out
Last scan: /24 then /22 · 1,018 hosts tried · 0 brokers · Wi-Fi
```

| Line | Source (on `main`, see `research/support-details` branch for paths) | Work |
|---|---|---|
| App version and build | `package_info_plus` | none |
| Android version, phone model | `device_info_plus`, added as a direct dependency at the version `aptabase_flutter` already pulls in (12.4.0) | small |
| Opened from | the `from` Get help was opened with | none |
| Connection | local or remote endpoint in use, protocol, port, and an **address shape** computed on the phone: "private address in 192.168.x" / "10.x" / "172.16–31.x", "public address", "host name", ".local name" | small |
| Zigbee2MQTT | `version` read by name from `bridge/info`, bridge state, device **count** | small |
| Last error | a fixed **kind** (timed out, refused, host not found, login rejected, not MQTT, no Zigbee2MQTT…), mapped the way the guided-connect diagnostics already are | small |
| Last scan | network size (/24, widened to /22), hosts tried, brokers found, interface type (Wi-Fi, Ethernet); `pickHomeIpv4` must return the interface name | small |

**Never included:** passwords, broker addresses or host names, MQTT usernames, home names (setup often names a home after its host), dashboard or device names, topics, raw error text (`MqttManager.lastError` contains the host and port), or the raw `bridge/info` payload (it carries the Zigbee2MQTT config: broker URL, username, device names).

**Kept:** the last error kind and last scan result stay on the phone until the next successful connection, then clear. Excluded from Android backups and never sent anywhere by the app, like Last-known value.

**Sent:** only by the user: in the Contact support email draft (visible and editable there) or via Copy details. No on/off switch. **Report a problem** attaches the same block to its GitHub issue or email and drops the "your device model and Zigbee2MQTT version help" prompt.

## 5. Measuring it

Two new events under [ADR 0006](../adr/0006-opt-in-anonymous-analytics.md), sent only when the user has opted in:

- `help_opened`: `from` (`no_connection`, `setup_error`, `manual_connect`, `home_unreachable`, `device_list_missing`, `settings`, `demo`).
- `support_contact`: `from`, `via` (`email`, `copy`).

No event for ticked tips. Success after the first month: support stays within 1–2 hours a week (about 5 emails or fewer), and the share of people who open Get help during setup and then complete setup (`setup_step`) is measured as a baseline to improve on. Each support email gets one Gmail label for its cause; the top labels decide which tips change.

## 6. Launch chores

- Create the dedicated support address and point the app's Contact support at it.
- Set up the Cal.com event (section 1) and make one test booking from a logged-out browser: the video link opens with no account, and the weekly cap is available on the free plan.
- Privacy policy (`store/PRIVACY.md`): the two new events, and "Support emails are used only to help you, never shared, and deleted within 6 months after the issue is closed."
- README Support section: the promise line and the support address.
- Gmail: a filter for the support address, cause labels, and a twice-yearly cleanup.

## 7. Exit checks

- Every place in section 2 opens Get help with the right `from` and tips; a setup error opens its own tips.
- Support details on a real phone, after a failed scan, matches section 4 and contains none of the never-included items (check with a broker on a host name and a home named after it).
- Contact support opens Gmail and one other email app with the address, subject and details filled in; Copy details copies the same text.
- After a successful connection, the last error and scan lines are cleared; an Android backup doesn't contain them.
- With analytics off, no event is sent; with it on, both events appear in Aptabase with only the listed values.
- All new strings exist in the 11 ARB files; Hebrew renders right to left.
