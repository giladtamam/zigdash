# IzzyOnDroid submission: ZigDash

IzzyOnDroid is a FOSS Android repository, much faster to get into than F-Droid. It picks up APKs from GitHub releases.

## Before submitting (you)

1. **Push** `release/2.0-signal` to GitHub.
2. **Create the GitHub release** `v2.0.0` from that branch's head, and attach the files from `build/github-release/` (made by `tool/build_release.sh github`):
   - `zigdash-2.0.0-arm64-v8a.apk` (27 MB)
   - `zigdash-2.0.0-armeabi-v7a.apk` (25 MB)
   - `zigdash-2.0.0-x86_64.apk` (29 MB)
   - `SHA256SUMS`

   Each is under IzzyOnDroid's ~30 MB limit; a universal APK would be 74 MB.
3. **Release notes:** use `fastlane/metadata/android/en-US/changelogs/29.txt`, plus the two notes below.

## Two things to say up front

- **New signing key.** 2.0 is signed with a new upload key (SHA-256 `4D:B0:C1:3E:AE:24:32:79:07:08:76:43:01:93:2C:A9:86:ED:F0:25:2E:FE:53:BC:5E:4C:B0:6F:F3:29:23:3A`). The old key was lost on 2026-10-02. Anyone who sideloaded a v1.9.x APK from GitHub must uninstall once before installing 2.0. Play users are unaffected, because Google signs Play installs with its own key. That also means Play and GitHub/IzzyOnDroid installs were never interchangeable without reinstalling.
- **No analytics in these APKs.** The Play build has opt-in anonymous usage data through Aptabase (open source; ADR 0006). The GitHub and IzzyOnDroid APKs are built without the Aptabase key, so they cannot send anything: the SDK never starts and the consent screen never appears. The library is still in the APK, so IzzyOnDroid's scanner may list it. Point them at this note and at `lib/core/analytics/analytics.dart` (`analyticsAvailableProvider`).

## How to submit

Open a "New App Request" issue at https://codeberg.org/IzzyOnDroid/repodata/issues (a Codeberg account is needed). If the link has moved, it's listed on https://izzyondroid.org/about/.

```text
App name:          ZigDash
Application ID:    com.giladtamam.zigdash
Summary:           Dashboard that builds itself from your Zigbee2MQTT devices
License:           MIT
Source:            https://github.com/giladtamam/zigdash
Releases (APK):    https://github.com/giladtamam/zigdash/releases  (per-ABI APKs)
Changelog:         https://github.com/giladtamam/zigdash/releases/tag/v2.0.0
Issue tracker:     https://github.com/giladtamam/zigdash/issues
Signing cert:      SHA-256 4D:B0:C1:3E:AE:24:32:79:07:08:76:43:01:93:2C:A9:86:ED:F0:25:2E:FE:53:BC:5E:4C:B0:6F:F3:29:23:3A
Anti-features:     none in these APKs (analytics key absent; see note)
Languages:         en, de, fr, es, nl, sv, nb, he, ru, pl, pt
```

## Metadata (if they ask)

```yaml
Categories:
  - Connectivity
License: MIT
AuthorName: Gilad Tamam
SourceCode: https://github.com/giladtamam/zigdash
IssueTracker: https://github.com/giladtamam/zigdash/issues
AutoName: ZigDash
Summary: Dashboard that builds itself from your Zigbee2MQTT devices
RepoType: git
Repo: https://github.com/giladtamam/zigdash
```

Fastlane metadata (descriptions and screenshots in 11 languages) lives in `fastlane/metadata/android/`, which IzzyOnDroid can read directly.
