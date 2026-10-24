#!/usr/bin/env bash
# App Store screenshots (docs/design/ios.md) on two simulators: an iPhone
# 6.9" (iPhone 18 Pro Max, 1320x2868) and an iPad 13" (iPad Pro 13-inch,
# 2064x2752), the two sizes App Store Connect requires. Same scenes as Play
# (integration_test/store_screenshots_test.dart), from the demo home.
#
#   tool/store/capture_ios.sh                 both forms, all 11 store languages
#   tool/store/capture_ios.sh phone en        one form, one locale
#
# Output: store/captures-ios/<App Store locale>/{iphone,ipad}/NN-name.png
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"
out_root="${STORE_ROOT:-$root/store/captures-ios}"

forms=(phone tablet)
locales=(en fr de es he ru pl pt nl sv nb)
if [[ $# -ge 1 ]]; then forms=("$1"); fi
if [[ $# -ge 2 ]]; then locales=("${@:2}"); fi

device_for() { [[ $1 == tablet ]] && echo "iPad Pro 13-inch (M5)" || echo "iPhone 18 Pro Max"; }
dir_for() { [[ $1 == tablet ]] && echo ipad || echo iphone; }
store_locale() {
  case "$1" in
    en) echo en-US ;; fr) echo fr-FR ;; de) echo de-DE ;; es) echo es-ES ;;
    he) echo he ;; ru) echo ru ;; pl) echo pl ;; pt) echo pt-BR ;;
    nl) echo nl-NL ;; sv) echo sv ;; nb) echo no ;; *) echo "$1" ;;
  esac
}

for form in "${forms[@]}"; do
  name="$(device_for "$form")"
  udid="$(xcrun simctl list devices available | grep -F "$name (" | head -1 | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')"
  [[ -n "$udid" ]] || { echo "no simulator named $name"; exit 1; }
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b >/dev/null
  xcrun simctl status_bar "$udid" override --time 9:41 --batteryState charged \
    --batteryLevel 100 --wifiBars 3 --cellularMode notSupported
  for loc in "${locales[@]}"; do
    out="$out_root/$(store_locale "$loc")/$(dir_for "$form")"
    rm -rf "$out"; mkdir -p "$out"
    echo "== $form $loc -> $out"
    xcrun simctl uninstall "$udid" com.giladtamam.zigdash 2>/dev/null || true
    STORE_OUT="$out" tool/flutter drive -d "$udid" \
      --driver=test_driver/store_screenshots.dart \
      --target=integration_test/store_screenshots_test.dart \
      --flavor appstore --dart-define=ZIGDASH_FLAVOR=appstore \
      --dart-define=ZIGDASH_STORE_CAPTURE=true \
      --dart-define=STORE_LOCALE="$loc" --dart-define=STORE_FORM="$form"
  done
  xcrun simctl status_bar "$udid" clear
done
