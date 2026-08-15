# IzzyOnDroid submission — ZigDash

IzzyOnDroid indexes FOSS Android apps and mirrors them from GitHub releases.
We now publish a signed release APK on every GitHub release (v1.9.1 is live),
which satisfies their core requirement.

## How to submit

1. Open a "New App Request" issue at the IzzyOnDroid issue tracker:
   https://codeberg.org/IzzyOnDroid/repodata/issues
   (The `repo` repo is the data/scripts; issues live in `repodata`.
   If it moves again, find the link from https://izzyondroid.org/about/.)

2. Fill the template with the data below. Their bot checks the GitHub release
   APK and the app's FOSS credentials.

3. Size limit: ~30 MB per app (rule of thumb). Our universal APK is 31.6 MB,
   so point them at the per-ABI split APKs (arm64 / armeabi-v7a / x86_64,
   ~12 MB each) already attached to the v1.9.1 release.

## Request data

```text
App name:          ZigDash
Application ID:    com.giladtamam.zigdash
Summary:           MQTT dashboard that auto-discovers Zigbee2MQTT devices
License:           MIT
Source:            https://github.com/giladtamam/zigdash
Releases (APK):    https://github.com/giladtamam/zigdash/releases
Changelog:         https://github.com/giladtamam/zigdash/releases/tag/v1.9.1
Issue tracker:     https://github.com/giladtamam/zigdash/issues
```

## Metadata (if they request a `metadata/` file)

```yaml
Categories:
  - Connectivity
License: MIT
AuthorName: Gilad Tamam
SourceCode: https://github.com/giladtamam/zigdash
IssueTracker: https://github.com/giladtamam/zigdash/issues
AutoName: ZigDash
Summary: MQTT dashboard that auto-discovers Zigbee2MQTT devices
RepoType: git
Repo: https://github.com/giladtamam/zigdash
```

## Notes

- The release APK is signed with the same key as the Play Store upload, so
  users can move between Play, IzzyOnDroid, and F-Droid without uninstalling.
- `tool/build_release.sh apk` is the reproducible build; `--no-tree-shake-icons`
  is required.
