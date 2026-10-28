#!/usr/bin/env bash
# Build a signed release artifact for ZigDash.
#
# Requires android/key.properties + android/zigdash-release.jks (both gitignored;
# see android/app/build.gradle.kts for how they're consumed). If key.properties
# is absent the build falls back to debug signing.
#
# --no-tree-shake-icons is REQUIRED: the app builds IconData from runtime values
# (user-selectable dashboard/panel icons), which release icon tree-shaking rejects.
#
# Usage:
#   tool/build_release.sh apk     # -> build/app/outputs/flutter-apk/app-release.apk
#   tool/build_release.sh bundle  # -> build/app/outputs/bundle/playRelease/app-play-release.aab (Play Store)
#   tool/build_release.sh github  # -> build/github-release/zigdash-<version>-<abi>.apk
#                                 #    per-ABI APKs for GitHub releases and IzzyOnDroid;
#                                 #    always WITHOUT the analytics key (ADR 0006)
#
# Opt-in analytics (ADR 0006) need the Aptabase app key: $ZIGDASH_ANALYTICS_KEY,
# else the gitignored tool/.analytics_key. Without one the build has no
# analytics at all, which is what F-Droid builds get.
set -euo pipefail
cd "$(dirname "$0")/.."

KEY="${ZIGDASH_ANALYTICS_KEY:-}"
if [[ -z "$KEY" && -f tool/.analytics_key ]]; then KEY="$(tr -d '[:space:]' < tool/.analytics_key)"; fi
DEFINES=()
if [[ -n "$KEY" ]]; then DEFINES+=(--dart-define=ZIGDASH_ANALYTICS_KEY="$KEY"); else echo "note: no analytics key, building without analytics"; fi

# The Play build carries billing for ZigDash Pro (history-2.7.md). Pro has
# been on sale since 2.9: a Play build without ZIGDASH_PRO_LIVE hides Pro from
# the people who bought it (3.1.12 to 3.2.1 shipped so). On by default;
# ZIGDASH_PRO_LIVE=0 builds without it, for tests only.
PLAY=(--dart-define=ZIGDASH_FLAVOR=play)
if [[ "${ZIGDASH_PRO_LIVE:-1}" == 1 ]]; then PLAY+=(--dart-define=ZIGDASH_PRO_LIVE=true); fi

TARGET="${1:-apk}"

# A Play bundle must have what users of the last one had: the upload key (a
# worktree without key.properties signs with the debug key, which Play
# refuses), the analytics key (3.2.1 shipped without it and went silent) and
# Pro.
if [[ "$TARGET" == bundle ]]; then
  missing=()
  [[ -f android/key.properties ]] || missing+=("android/key.properties (copy it from the main checkout)")
  [[ -n "$KEY" ]] || missing+=("the analytics key (tool/.analytics_key, copy it from the main checkout)")
  [[ "${ZIGDASH_PRO_LIVE:-1}" == 1 ]] || missing+=("Pro (ZIGDASH_PRO_LIVE is not 1)")
  if (( ${#missing[@]} )); then
    printf 'refusing to build a Play bundle without:\n' >&2
    printf '  - %s\n' "${missing[@]}" >&2
    exit 1
  fi
fi
if [[ "$TARGET" == github ]]; then
  # Builds outside Play never contain the analytics key, so they can't send data.
  tool/flutter build apk --release --split-per-abi --no-tree-shake-icons \
    --flavor foss --dart-define=ZIGDASH_FLAVOR=foss
  VERSION="$(sed -n 's/^version: \([^+]*\).*/\1/p' pubspec.yaml)"
  OUT=build/github-release; rm -rf "$OUT"; mkdir -p "$OUT"
  for abi in arm64-v8a armeabi-v7a x86_64; do
    cp "build/app/outputs/flutter-apk/app-$abi-foss-release.apk" "$OUT/zigdash-$VERSION-$abi.apk"
  done
  (cd "$OUT" && shasum -a 256 *.apk > SHA256SUMS)
  ls -la "$OUT"; exit 0
fi
case "$TARGET" in
  apk)    tool/flutter build apk --release --no-tree-shake-icons --flavor play "${PLAY[@]}" "${DEFINES[@]}" ;;
  bundle) tool/flutter build appbundle --release --no-tree-shake-icons --flavor play "${PLAY[@]}" "${DEFINES[@]}" ;;
  *) echo "usage: $0 [apk|bundle|github]"; exit 2 ;;
esac
