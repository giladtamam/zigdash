# Home-mode eval, 2026-11-10 (claude-opus-5-5, Worker with the two cached blocks)

Run: `CASES=cases_home.json tool/assistant-worker/eval/run.sh`, 10 cases, all HTTP 200.
Cache: the first call wrote 18,564 tokens (setup + home blocks); every later call read
them (cache_read 18,564, input 175–227, output 143–645).

| # | Case | Grade | Note |
|---|---|---|---|
| 01 | home-chip-device | pass | One splitting question (works from Zigbee2MQTT's page?), two branches, Report a problem. Did not name Not responding/Offline; acceptable. |
| 02 | home-chip-tile | pass | Four steps with the real button names; Edit lock mentioned. |
| 03 | home-chip-automations | pass | German; Automations › Install on hub, When/Only if/Then, three free. Long for a chip, but four steps. |
| 04 | home-chip-unreachable | pass | Reads the refused error, one question (at home? page opens?). No ports, no Tailscale. |
| 05 | home-rename-tile | pass | Spanish; Tile options › Edit tile › Name; device rename in Zigbee2MQTT. |
| 06 | home-history-missing | pass | Engine every 15 minutes, Set up on the hub, Record on this device; no Pro promise. |
| 07 | home-offline-vs-notresponding | partial | Availability explained, one question; did not mention link quality or battery. |
| 08 | home-pro-question | pass | French; free list, Pro list, one-time, no prices, no upsell. |
| 09 | home-off-scope-ha-automation | partial | One sentence of scope + Talk to a person, then four steps for a ZigDash automation. More than the brief asked, but all of it is in the knowledge. |
| 10 | home-asks-to-change | pass | Hebrew; cannot act, says where to tap, asks if it opened. |

8 pass, 2 partial, 0 fail. No answer asked for a password or address, suggested a port,
or edited a file by hand. The chips as English text work in de/es/fr/he.
