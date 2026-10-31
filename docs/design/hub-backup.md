# Hub backup (3.3)

## Why

On 2026-10-29 the owner's SMHUB regenerated Zigbee2MQTT's data folder twice
(starting Zigbee2MQTT from the hub's Apps page rewrites it): a fresh
`configuration.yaml` with `pan_id: GENERATE`, and `database.db` gone. Only a
lucky libicu failure stopped Zigbee2MQTT from forming a new network; the
devices still had to re-announce one by one, and the names were typed again.
Nobody keeps a copy of that folder. ZigDash is connected to the hub every day
and can.

## What a backup is

Zigbee2MQTT's own `bridge/request/backup` (any version ZigDash supports)
answers on `bridge/response/backup` with `{"status":"ok","data":{"zip":
"<base64>"}}`: a zip of the data folder. On the SMHUB it was 13 KB with
`configuration.yaml` (network key, pan id, devices' friendly names),
`coordinator_backup.json`, `database.db` and `state.json`. No extension, no
Engine, no consent: every user with a broker can have it.

Adapters that cannot back up answer `status: error`; Zigbee2MQTT behind its
web page only (3.2 `z2mPage` homes) has no broker: both read as
"not supported here", never as a failure to retry forever.

## On the phone

- Kept in the app's own files, `hub-backups/<home id>/<UTC stamp>.zdbk`,
  sealed with AES-256-GCM (iv | ciphertext | tag, as `RemoteSeal`) under one
  key per install in secure storage. The zip holds the network key and can
  hold the broker password: it is never logged, never in analytics, never
  shown.
- The newest 7 are kept.
- Automatic: when a home connects on the LAN (not through the relay, which
  never carries bridge topics) and its newest backup is more than 24 hours
  old, ZigDash takes one quietly. Daily users get daily backups; no
  background job.
- Back up now, and Save a copy (the plain zip through Android's file picker,
  the same way as the JSON backup) on the Hub backup screen, Settings ›
  Home.

## Restoring (second step, not in the first build)

Zigbee2MQTT has no restore request. A one-shot extension does it: the
consent step (`enable_external_js` + restart, as for the Engine: a
regenerated config has reset it), `extension/save` of a small restore
script, the zip on a non-retained `zigdash/backup/restore`, the script
writes the files and restarts Zigbee2MQTT, the app removes the script.
To verify on the spare SMHUB before it ships: whether a graceful restart
rewrites `database.db` over the restored one (if so, write and exit hard),
and both cases: radio intact ("Adapter network matches config") and radio
reset (restored from `coordinator_backup.json`).

## Pro

Free: automatic daily backups, Back up now, Save a copy. A backup protects
the network the free app already controls; holding it back would be the
"nothing free moves behind Pro" rule turned around. Pro later: a sealed
copy through the relay for remote homes, so a lost phone does not take the
only copy with it.

## Analytics

`hub_backup` with `step` only: `made` (with `auto` yes/no), `failed`,
`unsupported`, `saved_copy`. Never a size, a file name or a content.
