#!/usr/bin/env bash
# Renders the Signal launcher icon layers (docs/design/signal-2.0.md §9)
# from tool/icons/signal/*.svg to assets/icon/*.png at 1024 px, then
# regenerates the platform icons. Needs Chrome (headless).
set -euo pipefail
cd "$(dirname "$0")/../.."
tmp=$(mktemp -d)
for name in icon foreground monochrome; do
  svg="$PWD/tool/icons/signal/$name.svg"
  printf '<html><body style="margin:0;background:transparent">%s</body></html>' "$(cat "$svg")" > "$tmp/$name.html"
  "${CHROME:-/opt/google/chrome/chrome}" --headless=new --disable-gpu --no-sandbox \
    --user-data-dir="$tmp/profile" --hide-scrollbars --default-background-color=00000000 \
    --window-size=1024,1024 --screenshot="$PWD/assets/icon/$name.png" "file://$tmp/$name.html" 2>/dev/null
done
rm -rf "$tmp"
tool/flutter pub run flutter_launcher_icons
