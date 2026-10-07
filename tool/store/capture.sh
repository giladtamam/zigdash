#!/usr/bin/env bash
# Play Store screenshots for 2.0 (docs/design/signal-2.0.md §10) on two
# emulators: a Pixel 8 phone and a Pixel Tablet (2560x1600 at 320 dpi, the
# spec's 1280x800 dp tablet). Each locale runs on a fresh install, from the
# demo home, with the demo bar hidden (ZIGDASH_STORE_CAPTURE).
#
#   tool/store/capture.sh                 all forms, all 11 languages
#   tool/store/capture.sh phone en        one form, one locale
#   STORE_ROOT=/tmp/shots tool/store/...  write somewhere other than fastlane
#
# Output: $STORE_ROOT/<play locale>/images/{phoneScreenshots,tenInchScreenshots}
# (default STORE_ROOT is fastlane/metadata/android). Capture once, after the
# golden review: the spec changes store screenshots a single time, at 2.0.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"

sdk="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
adb="$sdk/platform-tools/adb"
emulator="$sdk/emulator/emulator"
avdmanager="$sdk/cmdline-tools/latest/bin/avdmanager"
image="system-images;android-36;google_apis;arm64-v8a"
store_root="${STORE_ROOT:-$root/fastlane/metadata/android}"
app_id="com.giladtamam.zigdash"

forms=(phone tablet)
locales=(en fr de es he ru pl pt nl sv nb)
if [[ $# -ge 1 ]]; then forms=("$1"); fi
if [[ $# -ge 2 ]]; then locales=("${@:2}"); fi

play_locale() {
  case "$1" in
    en) echo en-US ;; fr) echo fr-FR ;; de) echo de-DE ;;
    es) echo es-ES ;; he) echo iw-IL ;; ru) echo ru-RU ;;
    pl) echo pl-PL ;; pt) echo pt-BR ;; nl) echo nl-NL ;;
    sv) echo sv-SE ;; nb) echo no-NO ;; *) echo "$1" ;;
  esac
}

avd_for() { echo "zigdash_store_$1"; }
profile_for() { [[ $1 == tablet ]] && echo pixel_tablet || echo pixel_8; }
shots_dir() { [[ $1 == tablet ]] && echo tenInchScreenshots || echo phoneScreenshots; }

ensure_avd() {
  local name; name="$(avd_for "$1")"
  if ! "$emulator" -list-avds | grep -qx "$name"; then
    echo "Creating AVD $name ($(profile_for "$1"))"
    echo no | "$avdmanager" create avd -n "$name" -k "$image" \
      -d "$(profile_for "$1")" --force >/dev/null
  fi
}

emu_pid=""
serial=""
cleanup() {
  if [[ -n "$serial" ]]; then
    "$adb" -s "$serial" shell am broadcast -a com.android.systemui.demo \
      -e command exit >/dev/null 2>&1 || true
    "$adb" -s "$serial" emu kill >/dev/null 2>&1 || true
  fi
  if [[ -n "$emu_pid" ]]; then wait "$emu_pid" 2>/dev/null || true; fi
  emu_pid=""; serial=""
}
trap cleanup EXIT INT TERM

boot() {
  local port=5580
  serial="emulator-$port"
  "$emulator" -avd "$(avd_for "$1")" -port "$port" -no-window -no-audio \
    -no-boot-anim -no-snapshot -gpu swiftshader_indirect >/dev/null 2>&1 &
  emu_pid=$!
  # Give up after 5 minutes, or at once if the emulator exits (a stale
  # multiinstance.lock from a crashed run stops it from starting).
  local waited=0
  until [[ "$("$adb" -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == 1 ]]; do
    if ! kill -0 "$emu_pid" 2>/dev/null; then
      echo "emulator $(avd_for "$1") exited; remove ~/.android/avd/$(avd_for "$1").avd/*.lock and retry" >&2
      exit 1
    fi
    (( waited += 2 )); (( waited < 300 )) || { echo "emulator did not boot in 5 min" >&2; exit 1; }
    sleep 2
  done
  # A clean status bar: 10:00, full battery and signal, no notifications.
  local demo="$adb -s $serial shell am broadcast -a com.android.systemui.demo"
  "$adb" -s "$serial" shell settings put global sysui_demo_allowed 1
  $demo -e command enter >/dev/null
  $demo -e command clock -e hhmm 1000 >/dev/null
  $demo -e command battery -e level 100 -e plugged false >/dev/null
  $demo -e command network -e wifi show -e level 4 >/dev/null
  $demo -e command network -e mobile hide >/dev/null
  $demo -e command notifications -e visible false >/dev/null
}

for form in "${forms[@]}"; do
  ensure_avd "$form"
  boot "$form"
  for locale in "${locales[@]}"; do
    out="$store_root/$(play_locale "$locale")/images/$(shots_dir "$form")"
    echo "== $form $locale -> $out"
    "$adb" -s "$serial" uninstall "$app_id" >/dev/null 2>&1 || true
    STORE_OUT="$out" tool/flutter drive -d "$serial" \
      --driver=test_driver/store_screenshots.dart \
      --target=integration_test/store_screenshots_test.dart \
      --dart-define=ZIGDASH_STORE_CAPTURE=true \
      --dart-define=STORE_LOCALE="$locale" \
      --dart-define=STORE_FORM="$form"
  done
  cleanup
done
