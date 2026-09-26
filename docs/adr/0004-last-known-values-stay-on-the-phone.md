# Last-known values live in their own file and never leave the phone

From 1.12 the last payload of every subscribed topic is kept across restarts, so a dashboard is never empty when the broker is unreachable. These values are stored in a separate SQLite file, not in the main database and not in SharedPreferences. The file is excluded from Android Auto Backup and device-to-device transfer, and it is not part of ZigDash backups. A new phone refills it on its first connect.

The values describe what happens in the user's home: when doors open, when motion is seen, and when power is drawn. ZigDash's no-telemetry rule covers them, and cloud backup would carry them off the device. A separate file also keeps high-frequency writes (batched, at most once per topic every 5 s) away from the main database and its migrations, and lets retention (a 30-day prune and a 2,000-topic cap per home) run without touching user data.

## Considered options

- **A column or table in the main database.** Rejected because Auto Backup would include it unless the whole database were excluded, and that would also drop the user's dashboards from the backup.
- **SharedPreferences.** Rejected because it is unsuited to thousands of keys with timestamps and pruning.
- **Memory only, as in 1.11.** Rejected because it leaves every tile empty when the broker is unreachable at launch, the case the redesign's "show the last known value" principle is about.

Decided 2026-09-26. See `docs/design/dashboard-1.12.md`.
