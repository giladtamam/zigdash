# IzzyOnDroid submission — ZigDash

IzzyOnDroid indexes FOSS Android apps and mirrors them from GitHub releases.
We now publish a signed release APK on every GitHub release (v1.9.1 is live),
which satisfies their core requirement.

## How to submit

1. Open a "New App Request" issue at the IzzyOnDroid repo:
   https://codeberg.org/izzyondroid/repo/issues
   (If the repo has moved again, find it from https://android.izzysoft.de —
   follow the current "Request an app" template.)

2. Fill the template with the data below. Their bot checks the GitHub release
   APK and the app's FOSS credentials.

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
