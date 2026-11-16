# Moving from ZHA: helping ZHA homes reach Zigbee2MQTT (3.7.1–3.8)

Status: plan, 2026-11-16, draft 3, **scored 9** (independent reviewer;
five small fixes applied after). Draft 2 scored 8 (multiprotocol note,
`from_zha` definition, reads on live reconnects, English-only guide,
untested rollback, import gaps, adapter settings). Draft 1 scored 6 (rollback for the
same-adapter way could lose a network; Phase 0 assumed knowledge the code
doesn't have at those points; kill rule had gaps; scope too big for the
expected numbers). Destination of the wayfinder map "ZHA to ZigDash"
(charted 2026-10-23): records the go verdict (ticket 04) and the path
(ticket 05). Research: `research/zha-move-ways.md` (branch
research/zha-move-ways), `research/zha-ha-api.md` (branch
research/zha-ha-api).

## The verdict: go

The map's bar: at least 15% of setup users who answer "Home Assistant" are
on ZHA. Self-hosted Aptabase, 2026-11-09 to 2026-11-16 (the self-hosted
store starts Nov 9, so one week), Google's US test device excluded, last
platform answer per setup session:

| Last answer | Sessions | People | Never changed answer | Finished setup |
|---|---|---|---|---|
| Pi or Docker | 97 | 85 | 91 | 16 |
| Home Assistant (Zigbee2MQTT app) | 36 | 35 | 28 | 13 |
| **ZHA** | **29** | **25** | **20** | **0** |
| SMLIGHT | 15 | 14 | 9 | 0 |

ZHA is 25 of 60 people (42%) of the two Home Assistant answers; 20 of 48
(42%) counting only people who never changed answer. With 60 people the
uncertainty is about ±12 points, so even the low end (30%) is twice the
bar. People are counted once per session; someone with sessions under
both answers is in both rows (small effect, under 5 people).

The interim read of Oct 27 said 9% (2 of 23, 3.1.3 only, Oct 23–27). The
jump is not explained: the first screen was reworded in 3.4.0 (Nov 4) and
the sample then was tiny. A second read on Nov 23 (two weeks) confirms;
the verdict holds even if the share halves.

Other signals, read and too thin to weigh: the in-app poll has 3 non-US
voters, none chose "Work with ZHA"; the Home Assistant import saw 2
`zha_only` events. Supporting ZHA directly stays out (map decision).

**Expectation, honestly:** re-pairing a whole network to use a dashboard
is a big ask. Expect single-digit completed moves a month. The plan is
sized for that: Phase 0 and 1 are small, the bigger in-app parts wait for
proof.

## What ZHA people do today

Same 29 sessions, every event:

- 21 opened the demo home (72%).
- 12 opened the Home Assistant sign-in, 4 got to a connect try, 1 signed in
  and got "no MQTT integration", whose advice (the Mosquitto app under
  Settings › Apps) is wrong for Container installs: the case of
  2026-11-16 (see "Pilot").
- 11 also ran a network scan that found nothing.

Most never sign in, so nothing here may depend on the sign-in.

## Fixed decisions

From the map and the research; not reopened:

- ZigDash **reads** Home Assistant and never writes to it: no Supervisor
  calls, no installing apps, no disabling ZHA, no editing automations.
- ZigDash never asks for or reads the network key (`zha/network/settings`,
  backups, restore are never called).
- Way 3 (keep the network, no re-pair) is not built and not offered in the
  app; the web guide names it as advanced and unsupported, with links.
- ZigDash does not control ZHA devices.
- No Home Assistant token is kept for a user who has no home yet. Any read
  is one-shot: sign in, read, drop (as `HaImportController` does).

## The two ways (what the guide teaches)

From zha-move-ways.md. The guide presents both side by side and lets the
user choose; it does not pick for them.

| | Way 1: second adapter | Way 2: same adapter |
|---|---|---|
| Cost | a new adapter (EFR32: ZBT-2, SLZB-06M/-07; ~30–60 EUR) | free |
| The house during the move | keeps working: ZHA runs on the old stick | Zigbee is down until devices are re-paired |
| Pace | room by room, over days if wanted | all at once |
| Setup | Zigbee2MQTT on the new stick, its own network, all set **before its first start** (changing the channel later can force re-pairing): leave network key and PAN ID on generate (the default) and choose a channel different from ZHA's (ZHA › Configure › Network settings shows it; HA advises 15, 20 or 25). Keep the two sticks apart on USB extension cables. | Back up ZHA right before (Download backup). Disable ZHA (Devices & services › Zigbee Home Automation › ⋮ › Disable, not Delete) and restart. Switch off mains-powered Zigbee devices at the wall or breaker (the Zigbee2MQTT FAQ: otherwise routers keep trying the old network), then re-pair one by one, switching each back on. |
| Home Assistant OS | when the new stick is plugged in, Home Assistant may offer to set it up for ZHA or Thread: ignore that offer and give the stick to Zigbee2MQTT | — |
| Order | per room: mains-powered devices (routers) first, then battery devices | same: routers first |
| To go back | unplug the new stick; ZHA never stopped. Devices already moved need pairing to ZHA again. | stop Zigbee2MQTT and enable ZHA. The stick now holds Zigbee2MQTT's network, so restore the ZHA backup from the first step (ZHA's network settings: migrate / restore a backup). Devices not yet re-paired come back; devices already re-paired need pairing to ZHA again. Until this is tested (work 1b), the guide says so and adds: "If you need a sure way back, use the second-adapter way." |

Adapter notes:

- **Multiprotocol, way 2 only, and only if it is on** (ZBT-1 or Yellow;
  check the hardware's page in Home Assistant). Zigbee2MQTT does not run on
  multiprotocol firmware. Turn it off **while still on ZHA**, with Home
  Assistant's documented procedure (ZHA moves the network onto Zigbee-only
  firmware); Thread devices that used this stick stop working until another
  Thread border router takes them. In way 1, ZHA keeps the old stick and
  nothing on it changes; the new stick is bought Zigbee-only.
- **Zigbee2MQTT settings per chip** (Zigbee2MQTT's adapter pages), in the
  guide's compose files and notes:
  - Silicon Labs (ZBT-1, ZBT-2, Yellow, Sonoff Dongle-E, SLZB-06M/-07):
    `adapter: ember` (not the deprecated `ezsp`); ZBT-2 needs
    `baudrate: 460800`; Sonoff Dongle-E needs software flow control
    (`rtscts: false`); SLZB-06M needs firmware 20240510 or later;
  - TI (Sonoff Dongle-P, SLZB-06/-06P7): `adapter: zstack`;
  - ConBee/RaspBee: `adapter: deconz`.
- **CC2531, ZiGate:** too old or unmaintained for a good Zigbee2MQTT
  network: way 1 with a new adapter.
- **Network adapters (SLZB-06/-06M/-07, MR series):** ZHA shows
  `socket://IP:6638`; Zigbee2MQTT takes `tcp://IP:6638`, and the Docker
  setup has no USB mapping.
- **Over about 60 devices:** way 3 exists (community tools, unsupported,
  can wipe the network if a value is wrong); linked, not taught.

Time: about 5 minutes a device is an **estimate with no source**
(the research found none); the pilot times it, and the guide says
evening / day / weekend only after that.

## Phase 0: say the right thing (3.7.1)

1. **Read before closing, setup's check only.** `HaMqttClient` also runs
   live homes (`client_factory_io.dart`), so the reads are opt-in: a
   `readFacts` flag set only by setup's `probeHomeAssistant` (client id
   `zd-check`). When the probe fails with `noMqtt` or `notAdmin`, two reads
   run on the open socket before it closes, with their own 3 s limit inside
   the 12 s connect budget (both need no admin): `get_config` (`components` has `hassio` →
   apps exist) and `config/device_registry/list` (count of devices with a
   `zha` identifier, excluding the Zigbee Coordinator, i.e. entries whose
   `via_device_id` is null). The failure carries
   `HaFacts {apps: bool?, zhaDevices: int?}` (null when a read timed out);
   nothing is stored. `HaMqttClient._call` already takes a full command
   map.
2. **Texts from those facts** (`haConnectNoMqtt`, and the `notAdmin` text):
   - ZHA devices found: lead with "Your Zigbee runs in ZHA, Home
     Assistant's own Zigbee (N devices). ZigDash works with Zigbee2MQTT."
     and a **Moving from ZHA** button (Phase 1; in 3.7.1 it opens the web
     guide).
   - no apps (Container/Core): "This Home Assistant has no apps (Container),
     so Mosquitto and Zigbee2MQTT run as their own containers next to it."
     plus the guide's Docker link, instead of the Settings › Apps advice.
   - apps: today's text.
   - Known gap: a ZHA user whose Home Assistant already has an MQTT
     integration passes the check and later sees the fixed
     `setupErrHaNoZ2mBody` text, which already mentions ZHA.
3. **Fix a false sentence:** `connHelpZhaBody` says Zigbee2MQTT "provides
   an MQTT broker"; it doesn't (Mosquitto does). New text: "...switch to
   Zigbee2MQTT, which runs with an MQTT broker such as Mosquitto."
4. **Static ZHA texts stay as they are** (`setupZhaNote`,
   `setupNoBrokerHaZha`, `setupErrHaNoZ2mBody`, `guidedNoZ2mBody`,
   `guideZhaTitle`, `haImportZhaOnly`); in Phase 1 the first three and the
   guide's ZHA section gain the Moving from ZHA button.
5. **Measured:** `setup_step` step `ha_connect` with `result: no_mqtt` or
   `not_admin` gains `install: apps|no_apps` and
   `zha: 0|1-10|11-30|31-60|60+`. The Moving from ZHA button in 3.7.1
   (which opens the web guide) sends `setup_step` step `zha_move`, so
   Phase 0 has its own count before `zha_move` arrives in 3.8.0.
6. **Local:** ZHA devices found by the check store `zha_found_at` on the
   phone, for `from_zha` (below). A tap on the ZHA chip does not: people
   change answers (5 of 25 ZHA people did, Nov 9–16).

## Phase 1: Moving from ZHA (3.8.0)

1. **zigdash.app/zha**, the guide, in the app's 13 languages (AI
   translations, as for the listing) so the read measures the idea, not
   the language: the two ways table,
   adapter notes, the steps per install (Home Assistant OS apps; Docker
   with a USB adapter; Docker with a network adapter, each with its
   compose file and Mosquitto config), how to find the install type (does
   Settings show **Apps**?) and the adapter (the "Zigbee Coordinator"
   device in Settings › Devices & services › Devices: its model), what
   changes in Home Assistant (automations using these devices must be
   pointed at the new ones, entity IDs change, history starts again), and
   the way 3 links.
2. **In-app "Moving from ZHA" sheet**, short (about 8 strings):
   - "ZigDash works with Zigbee2MQTT. Moving means pairing your devices
     again. Home Assistant can keep using them once you add its MQTT
     integration."
   - two lines: "Second adapter: room by room, ZHA keeps running" /
     "Same adapter: free, all at once";
   - **Read the steps** (opens the guide), **I'm moving**, **Not now**.
3. **Entry points:** under the ZHA setup answer (`setupZhaNote`, next to
   Try demo), the demo home's banner when the last setup answer was ZHA,
   the Phase 0 messages, and Settings › Help.
4. **"I'm moving":** stores `zha_moving_at`. Setup's first screen then
   leads with "Connect to your new Zigbee2MQTT" and the scan. The flag
   ends when setup completes or after 60 days (way 1 can mean ordering an
   adapter).
5. **`from_zha`** on `setup_step complete`: `moving` when `zha_moving_at`
   is set, else `devices` when `zha_found_at` is within 60 days. A ZHA chip
   tap alone never sets it. Uninstalling loses both; accepted and noted in
   the read.
6. **Names and rooms after the move.** The Home Assistant import is offered
   today only for a home that setup found next to Home Assistant
   (`ha_import_offer.dart`); it is also offered when `zha_moving_at` is set,
   so a Container user who connected straight to the broker sees it. Today it matches only Zigbee2MQTT entries
   (`z2mIeee`). It gains a fallback: for a Zigbee2MQTT device with no Home
   Assistant entry, or one with no name or area, a ZHA entry with the same
   IEEE (`zha` identifier `aa:bb:…` normalised to `0xaabb…`) gives the name
   (`name_by_user` only: ZHA's `name` is the model string, worse than
   ZigDash's, as `HaDevice.userName` already reasons) and the area. Disabling ZHA disables its
   devices (`disabled_by` set) but keeps them in the registry list;
   verified in the pilot before building.
7. **iOS:** the same Flutter code; it reaches iOS with the next iOS build.
   The guide serves both.

## Phase 2 (gated): the in-app plan

Only if the read says go: three questions (install, adapter, device count)
and a "Your move" page in the app with the steps inline; "Check my Home
Assistant" as a one-shot read (`get_config`, registry, `search/related`
for the `zha` integration, automation names from
`config/entity_registry/list`); full translations of the guide.

## Phase 3 (gated by Phase 2): progress

"12 of 34 moved" (ZHA IEEEs vs Zigbee2MQTT `bridge/devices`, one-shot read
each time it opens), names applied with the user's OK through
`bridge/request/device/rename`.

## What is measured

New event `zha_move` (no names, addresses or IDs): `opened {from: answer,
demo, no_mqtt, not_admin, help}`, `guide`, `moving`, `not_now`. Plus the
Phase 0 props on `ha_connect` (`no_mqtt`/`not_admin`) and `from_zha: moving|devices` on
`setup_step complete`.

## The read and the kill rule

Read 4 weeks after 3.8.0 is live. Counted: people (not sessions) on 3.8.0
or later, Google's US Android 11 test device excluded. If fewer than 40
people gave a ZHA answer on 3.8.0+, wait 2 more weeks and read then.

- **Phase 2 goes ahead** if at least 15 people tapped "I'm moving" **and**
  at least 3 setups completed with `from_zha` (`moving` or `devices`).
- **Otherwise Phase 0 and 1 stay as they are** (small, and correct
  advice); no Phase 2.
- **Separately**, if fewer than 10% of ZHA answerers open the sheet, the
  entry points are reworded once and read again after 2 weeks.

Baseline: 0 completed setups among people whose last answer was ZHA,
Nov 9–16 (neither flag exists yet, so `from_zha` starts at 0 by
definition; the comparison is with that last-answer count). Every outcome
lands in exactly one of the first two rules.

## Privacy

Policy wording (for the owner's OK, before 3.7.1):

> **Home Assistant without Zigbee2MQTT.** When signing in to Home Assistant
> finds no MQTT integration, or no admin rights, ZigDash reads whether your
> installation has apps and how many devices use ZHA, Home Assistant's own
> Zigbee, to show the right advice. This stays on your phone. Usage data
> records only "apps or not" and the device count in broad groups.

Phase 1 adds nothing that leaves the phone beyond the `zha_move` steps and
`from_zha` (app interactions, already declared on Play). The import
fallback reads the same registry the import already reads. Phase 2 would
need its own wording.

## Pilot: the owner's friend (2026-11-16)

ZHA, Home Assistant Container, adapter unknown. With their OK, before
building Phase 1 (Phase 0 doesn't wait):

1. A read-only check of their install from a scratch script with a token
   they create (and delete after): `get_config` (expect no `hassio`), the
   device registry (ZHA identifiers, the coordinator's `model`,
   `via_device_id`), `search/related` for `zha`.
2. Their move, with the draft guide (Container route; their way). Time it;
   note every wrong or missing step, including the way 2 rollback wording
   if they use way 2.
3. After the move: the disabled ZHA devices are still in the registry list
   with names and areas; whether rooms set only on entities survive
   (disabled entities may be left out of the entity list); and one device
   matches end to end (`aa:bb:…` → `0x…`).

They can't verify the Home Assistant OS route; there the user installs apps
by hand from the guide, so no API needs checking.

## Work

| # | What | Size |
|---|---|---|
| 0a | `readFacts` opt-in, `HaFacts` reads in the probe before close (3 s), tests | M |
| 0b | Texts from facts (13 languages), `connHelpZhaBody` fix | S |
| 0c | Props, `zha_found_at`, policy text | S |
| 1a | Pilot (check + move) | S (owner's friend's time) |
| 1b | Way 2 rollback test: a spare stick and a throwaway Home Assistant container; ZHA forms a network, backup, Zigbee2MQTT forms its own, re-enable ZHA, restore; record Home Assistant's exact wording. Docker Desktop on macOS can't pass a USB stick to a container, so the throwaway Home Assistant runs on the Pi in its own container (not the live one), or the test uses a network adapter (`socket://`) from the Mac. Needs a spare stick from the owner; until done, the guide carries the "not tested" line | S |
| 1c | zigdash.app/zha guide, 13 languages | M |
| 1d | Sheet, entry points, `zha_moving_at`, setup lead, `from_zha` (13 languages, about 8 strings) | M |
| 1e | Import offer when moving, fallback to ZHA entries, tests | S |
| 1f | Emulator screenshots, release | S |
| 2, 3 | Only after the read | L |

## Wayfinder

Ticket 04: go ("The verdict"; second read Nov 23). Ticket 05: this doc. The
map's destination is reached when the owner approves this plan.
