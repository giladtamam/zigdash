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

## Restoring

Zigbee2MQTT has no restore request, so restore is a one-shot extension,
`hub/zigdash-restore.js`, installed only for it:

1. Extensions allowed? If `advanced.enable_external_js` is false (fresh
   2.11+ installs, and a regenerated config), the Engine's consent step
   turns it on and restarts Zigbee2MQTT.
2. `extension/save` of `zigdash-restore.js`.
3. The zip on non-retained `zigdash/backup/restore` `{tx, zip}`. The
   extension unzips it (stored and deflated entries), writes only names
   inside the data folder (no `..`, no absolute paths, no `log/` or
   `*.log`, never itself), keeps the files it replaces in
   `zigdash-restore-previous/<stamp>/`, adds 100 000 to the coordinator
   backup's network-key frame counter (a backup is up to a day old and
   devices ignore a coordinator whose counter went backwards), answers
   `{tx, status: 'writing'}` on `zigdash/backup/restore/result`, deletes
   its own file and kills Zigbee2MQTT with SIGKILL 1.5 s later.
4. A clean stop is avoided on purpose: Zigbee2MQTT's shutdown saves
   `database.db`, `state.json` and `coordinator_backup.json` from memory and
   the adapter, over the restored files. The service manager (OpenRC's
   supervise-daemon on an SMHUB, Docker's restart policy, the add-on)
   starts it again, as it does after `bridge/request/restart`.
5. The app waits for `bridge/state` offline then online (3 minutes) and
   says so; "written but not back" asks the user to restart it.

On start, zigbee-herdsman compares the restored config with the adapter;
when they differ (the hub formed a new network meanwhile) it leaves, finds
the config matching the restored `coordinator_backup.json` (written by
Zigbee2MQTT itself, so the byte order matches) and forms the network from
the backup. Devices in the restored `database.db` are known again; devices
paired after the backup are not and must pair again (an announce from a
device missing from the database is ignored).

Tested on the owner's only hub by restoring a backup taken minutes
earlier (nothing changes if it works); the wiped-config case is not tested
on hardware.

## Pro

Free: automatic daily backups, Back up now, Save a copy. A backup protects
the network the free app already controls; holding it back would be the
"nothing free moves behind Pro" rule turned around. Pro later: a sealed
copy through the relay for remote homes, so a lost phone does not take the
only copy with it.

## Analytics

`hub_backup` with `step` only: `made` (with `auto` yes/no), `failed`,
`unsupported`, `saved_copy`. Never a size, a file name or a content.
