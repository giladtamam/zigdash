#!/usr/bin/env bash
# Renders the 2.0 Play feature graphic (1024x500, signal-2.0.md §9, board
# H-launcher) for every store locale, with the tagline localized:
#   fastlane/metadata/android/<locale>/images/featureGraphic.png
# Needs Chrome (headless). Fonts are the app's bundled subsets.
set -euo pipefail
cd "$(dirname "$0")/../.."
root="$PWD"
chrome="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
[[ -x "$chrome" ]] || chrome=/opt/google/chrome/chrome
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

taglines=(
  "en-US|ltr|Your Zigbee home, at a glance."
  "de-DE|ltr|Dein Zigbee-Zuhause auf einen Blick."
  "fr-FR|ltr|Votre maison Zigbee, d’un coup d’œil."
  "es-ES|ltr|Tu casa Zigbee, de un vistazo."
  "nl-NL|ltr|Je Zigbee-huis in één oogopslag."
  "no-NO|ltr|Zigbee-hjemmet ditt, med ett blikk."
  "sv-SE|ltr|Ditt Zigbee-hem i en blick."
  "iw-IL|rtl|הבית החכם שלכם, במבט אחד."
  "ru-RU|ltr|Ваш дом на Zigbee — с одного взгляда."
  "pl-PL|ltr|Twój dom Zigbee w jednym spojrzeniu."
  "pt-BR|ltr|Sua casa Zigbee, num piscar de olhos."
)
icon="$(cat tool/icons/signal/icon.svg | sed 's/width="1024" height="1024"/width="84" height="84"/')"

for entry in "${taglines[@]}"; do
  IFS='|' read -r locale dir tagline <<<"$entry"
  cat > "$tmp/$locale.html" <<HTML
<!doctype html><html><head><meta charset="utf-8"><style>
@font-face{font-family:SG;src:url('file://$root/assets/fonts/SpaceGrotesk-Bold.ttf');font-weight:700}
@font-face{font-family:Plex;src:url('file://$root/assets/fonts/IBMPlexSans-Regular.ttf');font-weight:400}
@font-face{font-family:Plex;src:url('file://$root/assets/fonts/IBMPlexSans-SemiBold.ttf');font-weight:600}
@font-face{font-family:PlexHe;src:url('file://$root/assets/fonts/IBMPlexSansHebrew-Regular.ttf')}
*{box-sizing:border-box;margin:0}
body{width:1024px;height:500px;background:#F6F3EC;overflow:hidden;position:relative;font-family:Plex,PlexHe,sans-serif}
.brand{position:absolute;left:72px;top:170px}
.mark{display:flex;align-items:center;gap:18px}
.mark svg{border-radius:22px;overflow:hidden}
.word{font-family:SG;font-weight:700;font-size:66px;color:#1C1A16;letter-spacing:-1px}
.tag{margin-top:22px;font-size:30px;color:#5B5446;max-width:520px;font-family:Plex,PlexHe,sans-serif}
.phone{position:absolute;left:672px;top:84px;width:136px;height:280px;border:7px solid #1C1A16;border-radius:30px;background:#F6F3EC;padding:16px 10px}
.phone h1{font-family:Plex;font-weight:600;font-size:15px;color:#1C1A16;margin:0 2px 8px}
.grid{display:grid;grid-template-columns:1fr 1fr;gap:5px}
.t{height:44px;border-radius:12px;background:#fff;border:1px solid #E7E1D4;display:flex;align-items:center;justify-content:center;font-family:SG;font-weight:700;font-size:15px;color:#1C1A16}
.t.on{background:#F5C878;border-color:#F5C878}
.tab{position:absolute;left:818px;top:134px;width:260px;height:222px;border-radius:26px;background:#15130F;padding:14px}
.tab .grid{gap:8px}
.tab .t{height:58px;border-radius:14px;background:#211E18;border-color:#211E18;color:#EFE9DD;font-size:22px}
.tab .t.on{background:#F0A544;border-color:#F0A544}
</style></head><body>
<div class="brand"><div class="mark">$icon<span class="word">ZigDash</span></div>
<p class="tag" dir="$dir">$tagline</p></div>
<div class="phone"><h1>My Home</h1><div class="grid">
<div class="t on"></div><div class="t"></div><div class="t on"></div><div class="t"></div><div class="t">21°</div><div class="t"></div>
</div></div>
<div class="tab"><div class="grid">
<div class="t on"></div><div class="t"></div><div class="t"></div><div class="t on"></div><div class="t">21.4°</div><div class="t"></div>
</div></div>
</body></html>
HTML
  out="$root/fastlane/metadata/android/$locale/images/featureGraphic.png"
  mkdir -p "$(dirname "$out")"
  rm -f "$out"
  # Headless Chrome on macOS can hang after writing the screenshot: wait for
  # the file, then stop it.
  "$chrome" --headless=new --disable-gpu --no-sandbox --user-data-dir="$tmp/profile-$locale" \
    --hide-scrollbars --allow-file-access-from-files --window-size=1024,500 \
    --screenshot="$out" "file://$tmp/$locale.html" >/dev/null 2>&1 &
  pid=$!
  for _ in $(seq 60); do [[ -s "$out" ]] && break; sleep 0.5; done
  sleep 1; kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true
  [[ -s "$out" ]] || { echo "failed: $locale" >&2; exit 1; }
  echo "$out"
done
cp "$root/fastlane/metadata/android/en-US/images/featureGraphic.png" "$root/store/feature_graphic.png"
