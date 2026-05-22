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
#   tool/build_release.sh bundle  # -> build/app/outputs/bundle/release/app-release.aab (Play Store)
set -euo pipefail
cd "$(dirname "$0")/.."

TARGET="${1:-apk}"
case "$TARGET" in
  apk)    flutter build apk --release --no-tree-shake-icons ;;
  bundle) flutter build appbundle --release --no-tree-shake-icons ;;
  *) echo "usage: $0 [apk|bundle]"; exit 2 ;;
esac
