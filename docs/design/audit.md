# ZigDash UI audit — 1.9.2 (2026-09-26)

Input for the redesign map's first-run and information-architecture decisions. Captured from the Flutter web build (same widgets as Android) in demo mode against a local MQTT broker seeded with a simulated Zigbee2MQTT bridge of seven devices. Phone is 412×915 dp, tablet is 1280×800 dp landscape.

Heuristic findings only, no usage data. Severity is judged against the map's primary metric, **retention of a new user**: **High** blocks or confuses the first ten minutes, **Medium** degrades daily use, **Low** is polish.

## Coverage

| Screen | Phone light | Phone dark | Hebrew RTL | Tablet |
|---|---|---|---|---|
| Onboarding carousel | page 1 of 3 | | | |
| Setup welcome ("Find my setup") | yes | | | |
| Connections (Brokers tab) | yes | | | light |
| Dashboards tab | yes | | | |
| Settings | yes | | yes | |
| Dashboard | yes | yes | yes | light, dark |
| Dashboard, connection lost | yes | | | |
| Add-panel picker | yes | | | |
| Panel form (Toggle) | yes | | | |
| Devices | yes | | | |
| Scenes (empty) | yes | | | |
| Scene form | yes | | | |
| Connection form | yes | | | |
| Help | yes | | | |
| **Not captured:** guided connect, device picker ("Add from a device"), dashboard form, onboarding pages 2–3 | | | | |

11 of the 14 screen files are covered. The missing three are forms and a step of the setup flow; the first-run ticket should look at the guided connect flow on a device before deciding.

Images: [`audit/`](audit/), one folder per variant.

## Findings

### First run and navigation

1. **High — Connection-first structure with a dead-end tab.** The app opens on "Connections" with a Brokers / Dashboards / Settings bar. The Dashboards tab shows "Open a broker from the Brokers tab to see and manage its dashboards" even when exactly one broker exists ([04](audit/phone-light/04-dashboards-tab.png)). A one-broker user needs two taps and a concept ("broker") before seeing a single control. The Help guide spends a callout explaining that the dashboard title is the broker's name, not a dashboard ([14](audit/phone-light/14-help.png)): documentation compensating for the IA.
2. **High — Three-page carousel before the first action.** Welcome / Connect your broker / Build your dashboards, with Skip, Try demo and Next competing on page one ([01](audit/phone-light/01-onboarding-welcome.png)). None of the benchmarked apps does this.
3. **Medium — Two first-run doors that look alike.** The carousel's "Connect my broker" and the setup screen's "Find my setup" / "Enter details manually" ([02](audit/phone-light/02-setup-welcome.png)) are separate flows; setup also renders inside the tab shell, so the bottom bar is visible mid-onboarding.
4. **Medium — "Auto-connect on app start" defaults to off** in the connection form ([13](audit/phone-light/13-connection-form.png)). If this applies to the guided flow too, a returning user lands on a disconnected list. Verify in the first-run ticket.
5. **Medium — Tablet is a stretched phone.** Bottom navigation bar at 1280 dp, a single list row across the full width, no navigation rail or second pane ([tablet 01](audit/tablet-light/01-connections.png)).

### Dashboard

6. **High — Toolbar overload truncates the title.** Six actions (edit, reorder, add dashboard, scenes, devices, overflow) leave "Demo …" for the title on a phone ([06](audit/phone-light/06-dashboard.png)). Scenes and Devices are primary destinations hidden as unlabeled icons.
7. **Medium — A tab bar for one dashboard.** "My Home" sits in a full tab strip even when it is the only dashboard, costing ~100 dp above the fold.
8. **Medium — No shared tile grammar.** Each panel type draws its own layout: toggle with a leading icon, slider with no icon, cover as a large control block, LED as a grey dot, node status as a green cloud, button as a small outlined card. Half- and third-width tiles leave holes in the grid (Brightness and Battery each sit alone on a row).
9. **Medium — Editing hidden behind long-press.** Panel options open only on long-press (`panel_tile.dart`, `onLongPress`); there is no visible affordance, and Edit dashboard in the toolbar does not enter a panel-editing mode.
10. **Medium — FAB covers content.** "Add panel" overlaps the last tile on phone in both light and dark.
11. **Low — Dark mode surfaces barely separate.** Tiles use a surface container that is close to the background in dark ([dark 06](audit/phone-dark/06-dashboard.png)); the "online" green is hard-coded, not a theme role.

### Connection state

12. **High — Offline state hides the content it is meant to explain.** When the broker drops, a banner takes ~20% of the phone screen, and every tile gets a "Last known" chip that overlaps and truncates titles ("Front Doc", "Zigbee R") and covers the toggle ([11](audit/phone-light/11-connection-lost.png)). The information is right; the treatment should be a per-tile state, not an overlay.

### Adding things

13. **High — Add-panel picker speaks MQTT, not devices.** Sixteen options named by widget mechanics ("Multi-State", "Combo", "Radio") with jargon in the descriptions ("enum", "brightness:N", "Node-RED") ([07](audit/phone-light/07-add-panel-picker.png)). "Add from a device…" is first, which is right, but it reads as one option among seventeen.
14. **High — Panel form leads with raw payloads.** A new Toggle shows `{"state":"ON"}`, `{"state":"OFF"}`, JSON path and "On match" as the primary fields; the topic is under a collapsed "MQTT Settings" ([08](audit/phone-light/08-panel-form-toggle.png)). There is no device picker on the form.
15. **Medium — Devices is a health list, not a control surface.** Names with battery and link quality; no type icon, no state, no control, no "add to dashboard" ([09](audit/phone-light/09-devices.png)). Mains devices show a battery icon with a dash; 23% battery is not flagged. The base-topic field is the most prominent element. The empty state before data arrives is a bare spinner, then "No device list found".
16. **Low — Scene form cannot show what it captures.** The device checklist has no current state or type icon, so the user saves a state they cannot see ([12](audit/phone-light/12-scene-form.png)). Scenes' empty state is text only ([10](audit/phone-light/10-scenes.png)).

### Settings

17. **Low — Language list dominates Settings.** Nine inline radio buttons push About, Rate ZigDash and Help below the fold ([05](audit/phone-light/05-settings.png)). A single "Language" row opening a picker would do.

### RTL

18. **Low — RTL is mostly correct.** Layout, sliders, segmented buttons and icons mirror ([rtl 06](audit/phone-rtl/06-dashboard.png)). One bidi defect: the cover percentage renders as "% 40". User-authored panel names stay LTR, which is correct.

## Accessibility defects (fix regardless of redesign)

- Sliders expose `value 1, max 2` to TalkBack instead of the real value (brightness 180 is announced as "1").
- Several tiles (LED, node status, progress, text log) are announced only as "Panel options", with no name or state.
- The Devices refresh button has no label.

## Other defects found while auditing (not redesign work)

- **MQTT client takeover loop.** With the dashboard and Devices screen both active, the broker log showed the same client id (`zd-` plus 15 hex chars, derived from the connection id in `MqttManager._shortClientId`) connecting and being disconnected repeatedly; the dashboard fell into "Connection failed". Two clients in one app session appear to share the id. Needs a separate diagnosis; evidence was the aedes log on 2026-09-26.

## What this means for the next tickets

- **Decide the first-run journey** has three High findings to resolve: the carousel (2), the two doors (3), and the dead-end Dashboards tab (1). The auto-connect default (4) belongs there too.
- **Decide the information architecture** owns the connection-first tabs (1), toolbar overload (6), the single-dashboard tab strip (7), and tablet (5).
- **Explore three visual directions** should take the tile grammar (8), offline-as-tile-state (12) and dark surfaces (11) as the problems each concept must solve.
- The add-panel flow (13, 14) is the biggest retention issue that is not yet a ticket; see the map's fog.
