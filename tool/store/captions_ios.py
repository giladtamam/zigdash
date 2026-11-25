#!/usr/bin/env python3
"""Composes the App Store iPhone 6.9" screenshots (1320x2868): a headline, a
sub-line and the simulator capture (store/captures-ios, from
tool/store/capture_ios.sh) in a phone frame, for all 13 store locales. Same
palette, fonts and headless-Chrome render as captions.py (Play).

    tool/store/captions_ios.py            all 13 locales
    tool/store/captions_ios.py en-US he

Output: store/appstore/<locale>/iphone/0N-*.png (24-bit, no alpha).
Captions say only what is true on iOS: no "no cloud" (Pro's relay), no
"zero setup" (Zigbee2MQTT and a broker are needed).
"""

from __future__ import annotations

import html
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CAPTURES = Path(os.environ.get('STORE_ROOT', ROOT / 'store' / 'captures-ios'))
OUT = ROOT / 'store' / 'appstore'
FONTS = ROOT / 'assets' / 'fonts'
CHROME = os.environ.get(
    'CHROME', '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
)
if not os.access(CHROME, os.X_OK):
    CHROME = '/opt/google/chrome/chrome'

W, H = 1320, 2868
RTL = {'he'}

# The five shots, in App Store order. The first three show in search results.
# (name, source capture, theme)
SHOTS = [
    ('01-dashboard', 'iphone/01-dashboard.png', 'light'),
    ('02-controls', 'iphone/02-device-controls.png', 'light'),
    ('03-home-assistant', 'iphone/03-devices.png', 'light'),
    ('04-attention', 'iphone/04-device-page.png', 'light'),
    ('05-no-account', 'iphone/05-dashboard-dark.png', 'dark'),
]

STRINGS = {
    'en-US': [
        ('Your Zigbee home, set up in minutes',
         'Needs Zigbee2MQTT and an MQTT broker. ZigDash finds them and gives every device a tile.'),
        ('Every control, one tap away',
         'Brightness, white, colour, blinds and scenes.'),
        ('Works with Home Assistant, or on its own',
         'Sign in with Home Assistant, or connect straight to your MQTT broker.'),
        ('See what needs attention',
         'Low batteries and devices that went quiet, at a glance.'),
        ('No account. No ads.',
         "Free to use, one-time Pro. Your home's data stays on your broker."),
    ],
    'de-DE': [
        ('Ihr Zigbee-Zuhause, in Minuten eingerichtet',
         'Braucht Zigbee2MQTT und einen MQTT-Broker. ZigDash findet beide und gibt jedem Gerät eine Kachel.'),
        ('Jede Steuerung, ein Tipp entfernt',
         'Helligkeit, Weißton, Farbe, Rollläden und Szenen.'),
        ('Mit Home Assistant oder ganz ohne',
         'Melden Sie sich mit Home Assistant an oder verbinden Sie sich direkt mit Ihrem MQTT-Broker.'),
        ('Sehen, was Aufmerksamkeit braucht',
         'Schwache Batterien und verstummte Geräte auf einen Blick.'),
        ('Kein Konto. Keine Werbung.',
         'Kostenlos nutzbar, Pro als Einmalkauf. Die Daten Ihres Zuhauses bleiben auf Ihrem Broker.'),
    ],
    'fr-FR': [
        ('Votre maison Zigbee, prête en quelques minutes',
         'Requiert Zigbee2MQTT et un broker MQTT. ZigDash les trouve et crée une tuile par appareil.'),
        ('Chaque réglage à portée de doigt',
         'Luminosité, blanc, couleur, volets et scènes.'),
        ('Avec Home Assistant, ou sans',
         'Connectez-vous avec Home Assistant, ou directement à votre broker MQTT.'),
        ("Voyez ce qui demande attention",
         "Piles faibles et appareils devenus muets, d'un coup d'œil."),
        ('Sans compte. Sans pub.',
         'Gratuit, Pro en achat unique. Les données de votre maison restent sur votre broker.'),
    ],
    'es-ES': [
        ('Tu casa Zigbee, lista en minutos',
         'Necesita Zigbee2MQTT y un bróker MQTT. ZigDash los encuentra y crea un mosaico para cada dispositivo.'),
        ('Todo el control a un toque',
         'Brillo, blanco, color, persianas y escenas.'),
        ('Con Home Assistant, o sin él',
         'Inicia sesión con Home Assistant o conecta directamente con tu bróker MQTT.'),
        ('Mira qué necesita atención',
         'Pilas bajas y dispositivos que dejaron de responder, de un vistazo.'),
        ('Sin cuenta. Sin anuncios.',
         'Gratis, con Pro de pago único. Los datos de tu casa se quedan en tu bróker.'),
    ],
    'it': [
        ('La tua casa Zigbee, pronta in pochi minuti',
         'Richiede Zigbee2MQTT e un broker MQTT. ZigDash li trova e crea un riquadro per ogni dispositivo.'),
        ('Ogni comando a portata di tocco',
         'Luminosità, bianco, colore, tapparelle e scene.'),
        ('Con Home Assistant, o da solo',
         'Accedi con Home Assistant o collegati direttamente al tuo broker MQTT.'),
        ('Vedi cosa richiede attenzione',
         'Batterie scariche e dispositivi silenziosi, a colpo d’occhio.'),
        ('Nessun account. Nessuna pubblicità.',
         'Gratis, Pro con acquisto unico. I dati della tua casa restano sul tuo broker.'),
    ],
    'nl-NL': [
        ('Je Zigbee-huis, in minuten klaar',
         'Vereist Zigbee2MQTT en een MQTT-broker. ZigDash vindt ze en geeft elk apparaat een tegel.'),
        ('Elke bediening, één tik verwijderd',
         'Helderheid, wit, kleur, rolluiken en scènes.'),
        ('Met Home Assistant, of zonder',
         'Log in met Home Assistant of verbind rechtstreeks met je MQTT-broker.'),
        ('Zie wat aandacht nodig heeft',
         'Bijna lege batterijen en stille apparaten in één oogopslag.'),
        ('Geen account. Geen reclame.',
         'Gratis te gebruiken, Pro als eenmalige aankoop. De gegevens van je huis blijven op je broker.'),
    ],
    'pl': [
        ('Twój dom Zigbee gotowy w kilka minut',
         'Wymaga Zigbee2MQTT i brokera MQTT. ZigDash je znajdzie i da każdemu urządzeniu kafelek.'),
        ('Każde sterowanie na jedno dotknięcie',
         'Jasność, biel, kolor, rolety i sceny.'),
        ('Z Home Assistant albo bez',
         'Zaloguj się przez Home Assistant lub połącz się bezpośrednio z brokerem MQTT.'),
        ('Zobacz, co wymaga uwagi',
         'Słabe baterie i urządzenia, które ucichły, na pierwszy rzut oka.'),
        ('Bez konta. Bez reklam.',
         'Darmowy, Pro jako jednorazowy zakup. Dane twojego domu zostają na twoim brokerze.'),
    ],
    'pt-BR': [
        ('Sua casa Zigbee pronta em minutos',
         'Requer Zigbee2MQTT e um broker MQTT. O ZigDash os encontra e cria um bloco para cada dispositivo.'),
        ('Todo controle a um toque',
         'Brilho, branco, cor, persianas e cenas.'),
        ('Com Home Assistant, ou sem',
         'Entre com o Home Assistant ou conecte direto ao seu broker MQTT.'),
        ('Veja o que precisa de atenção',
         'Baterias fracas e dispositivos que ficaram em silêncio, num relance.'),
        ('Sem conta. Sem anúncios.',
         'Grátis, Pro com compra única. Os dados da sua casa ficam no seu broker.'),
    ],
    'ru': [
        ('Ваш Zigbee-дом готов за минуты',
         'Нужен Zigbee2MQTT и MQTT-брокер. ZigDash найдёт их и создаст плитку для каждого устройства.'),
        ('Любое управление в одно касание',
         'Яркость, белый, цвет, жалюзи и сцены.'),
        ('С Home Assistant или без него',
         'Войдите через Home Assistant или подключитесь напрямую к MQTT-брокеру.'),
        ('Видно, что требует внимания',
         'Разряженные батареи и замолчавшие устройства — с первого взгляда.'),
        ('Без аккаунта. Без рекламы.',
         'Бесплатно, Pro — разовая покупка. Данные вашего дома остаются на вашем брокере.'),
    ],
    'sv': [
        ('Ditt Zigbee-hem, klart på några minuter',
         'Kräver Zigbee2MQTT och en MQTT-broker. ZigDash hittar dem och ger varje enhet en ruta.'),
        ('All styrning ett tryck bort',
         'Ljusstyrka, vitt, färg, rullgardiner och scener.'),
        ('Med Home Assistant, eller utan',
         'Logga in med Home Assistant eller anslut direkt till din MQTT-broker.'),
        ('Se vad som behöver uppmärksamhet',
         'Svaga batterier och enheter som tystnat, med en blick.'),
        ('Inget konto. Inga annonser.',
         'Gratis att använda, Pro som engångsköp. Hemmets data stannar på din broker.'),
    ],
    'no': [
        ('Zigbee-hjemmet ditt, klart på minutter',
         'Krever Zigbee2MQTT og en MQTT-broker. ZigDash finner dem og gir hver enhet en rute.'),
        ('All styring ett trykk unna',
         'Lysstyrke, hvitt, farge, persienner og scener.'),
        ('Med Home Assistant, eller uten',
         'Logg inn med Home Assistant eller koble direkte til MQTT-brokeren din.'),
        ('Se hva som trenger oppmerksomhet',
         'Svake batterier og enheter som har blitt stille, med ett blikk.'),
        ('Ingen konto. Ingen reklame.',
         'Gratis å bruke, Pro som engangskjøp. Hjemmets data blir på brokeren din.'),
    ],
    'cs': [
        ('Tvůj Zigbee domov hotový za pár minut',
         'Vyžaduje Zigbee2MQTT a MQTT broker. ZigDash je najde a každému zařízení dá dlaždici.'),
        ('Každé ovládání na jedno klepnutí',
         'Jas, bílá, barva, žaluzie a scény.'),
        ('S Home Assistantem, nebo bez něj',
         'Přihlas se přes Home Assistant, nebo se připoj přímo k MQTT brokeru.'),
        ('Uvidíš, co potřebuje pozornost',
         'Slabé baterie a zařízení, která ztichla, na první pohled.'),
        ('Bez účtu. Bez reklam.',
         'Zdarma, Pro jako jednorázový nákup. Data tvé domácnosti zůstávají na tvém brokeru.'),
    ],
    'he': [
        ('בית ה‑Zigbee שלכם, מוכן תוך דקות',
         'דורש Zigbee2MQTT ו‑broker MQTT. ‏ZigDash מוצא אותם ונותן אריח לכל מכשיר.'),
        ('כל שליטה במרחק הקשה',
         'בהירות, לבן, צבע, תריסים וסצנות.'),
        ('עם Home Assistant, או בלעדיו',
         'התחברו דרך Home Assistant, או ישירות ל‑broker ה‑MQTT שלכם.'),
        ('רואים מה דורש תשומת לב',
         'סוללות חלשות ומכשירים שהשתתקו, במבט אחד.'),
        ('בלי חשבון. בלי פרסומות.',
         'חינמי לשימוש, Pro ברכישה חד‑פעמית. נתוני הבית נשארים ב‑broker שלכם.'),
    ],
}

# Signal palette (docs/design/signal-2.0.md): ivory, ink, amber.
THEME = {
    'light': dict(bg='#F6F3EC', fg='#1C1A16', sub='#5B5446', frame='#1C1A16', accent='#F0A544'),
    'dark': dict(bg='#15130F', fg='#EFE9DD', sub='#B8B0A2', frame='#2E2A24', accent='#F0A544'),
}

CSS = """
@font-face{font-family:SG;src:url('file://%(fonts)s/SpaceGrotesk-Bold.ttf');font-weight:700}
@font-face{font-family:Plex;src:url('file://%(fonts)s/IBMPlexSans-Regular.ttf');font-weight:400}
@font-face{font-family:Plex;src:url('file://%(fonts)s/IBMPlexSans-SemiBold.ttf');font-weight:600}
@font-face{font-family:PlexHe;src:url('file://%(fonts)s/IBMPlexSansHebrew-Regular.ttf');font-weight:400}
@font-face{font-family:PlexHe;src:url('file://%(fonts)s/IBMPlexSansHebrew-SemiBold.ttf');font-weight:600}
*{box-sizing:border-box;margin:0;padding:0}
html,body{width:%(w)dpx;height:%(h)dpx;overflow:hidden}
body{background:%(bg)s;color:%(fg)s;position:relative;
  font-family:Plex,PlexHe,sans-serif;-webkit-font-smoothing:antialiased}
.text{position:absolute;left:96px;right:96px;top:170px}
h1{font-family:SG,PlexHe,sans-serif;font-weight:700;font-size:100px;line-height:1.06;
  letter-spacing:-2px;color:%(fg)s}
[dir=rtl] h1{font-family:PlexHe,SG,sans-serif;font-weight:600;letter-spacing:0}
p{margin-top:30px;font-size:48px;line-height:1.3;color:%(sub)s;max-width:1128px}
.bar{position:absolute;left:96px;top:96px;width:150px;height:14px;border-radius:7px;background:%(accent)s}
[dir=rtl] .bar{left:auto;right:96px}
.phone{position:absolute;left:%(px)dpx;top:%(py)dpx;width:%(pw)dpx;height:%(ph)dpx;
  border:18px solid %(frame)s;border-radius:96px;overflow:hidden;background:%(frame)s}
.phone img{display:block;width:100%%;height:100%%;border-radius:78px}
"""

# Phone: 900 wide including the frame, the 1320x2868 capture inside,
# bottom-anchored so the headline keeps the top ~40%.
PW = 900
PH = round((PW - 36) * 2868 / 1320) + 36
PX, PY = (W - PW) // 2, H - PH - 60


def page(locale: str, headline: str, sub: str, src: Path, theme: str) -> str:
    t = THEME[theme]
    css = CSS % dict(fonts=FONTS, w=W, h=H, px=PX, py=PY, pw=PW, ph=PH, **t)
    d = 'rtl' if locale in RTL else 'ltr'
    lang = locale.split('-')[0]
    return (
        f'<!doctype html><html lang="{lang}" dir="{d}"><head><meta charset="utf-8">'
        f'<style>{css}</style></head><body dir="{d}">'
        f'<div class="bar"></div>'
        f'<div class="text"><h1>{html.escape(headline)}</h1><p>{html.escape(sub)}</p></div>'
        f'<div class="phone"><img src="file://{src}"></div></body></html>'
    )


def render(html_path: Path, out: Path, profile: Path) -> None:
    out.unlink(missing_ok=True)
    proc = subprocess.Popen(
        [
            CHROME, '--headless=new', '--disable-gpu', '--no-sandbox',
            f'--user-data-dir={profile}', '--hide-scrollbars',
            '--allow-file-access-from-files', '--force-device-scale-factor=1',
            f'--window-size={W},{H}', f'--screenshot={out}', f'file://{html_path}',
        ],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    # Headless Chrome on macOS can hang after writing the file: wait for it,
    # then stop the process (feature_graphic.sh does the same).
    for _ in range(120):
        if out.exists() and out.stat().st_size > 0:
            break
        time.sleep(0.5)
    time.sleep(0.5)
    proc.kill()
    proc.wait()
    if not (out.exists() and out.stat().st_size > 0):
        sys.exit(f'render failed: {out}')


def flatten(out: Path) -> bool:
    """Drop the alpha channel (the stores want 24-bit PNG). True when done."""
    try:
        from PIL import Image  # type: ignore
    except ImportError:
        return False
    with Image.open(out) as im:
        if im.mode == 'RGB':
            return True
        rgb = Image.new('RGB', im.size)
        rgb.paste(im.convert('RGBA'), mask=None)
        rgb.save(out, optimize=True)
    return True


def main(argv: list[str]) -> None:
    locales = argv or sorted(STRINGS)
    for loc in locales:
        if loc not in STRINGS:
            sys.exit(f'no strings for {loc}')
        if not (CAPTURES / loc / 'iphone').is_dir():
            sys.exit(f'no captures for {loc} (run tool/store/capture_ios.sh phone)')
    flattened = True
    with tempfile.TemporaryDirectory() as tmp:
        tmpdir = Path(tmp)
        for loc in locales:
            out_dir = OUT / loc / 'iphone'
            if out_dir.exists():
                shutil.rmtree(out_dir)
            out_dir.mkdir(parents=True)
            for (name, src, theme), (headline, sub) in zip(SHOTS, STRINGS[loc], strict=True):
                src_path = CAPTURES / loc / src
                if not src_path.exists():
                    sys.exit(f'missing capture {src_path}')
                html_path = tmpdir / f'{loc}-{name}.html'
                html_path.write_text(page(loc, headline, sub, src_path, theme), 'utf-8')
                out = out_dir / f'{name}.png'
                render(html_path, out, tmpdir / f'profile-{loc}')
                flattened = flatten(out) and flattened
                print(out.relative_to(ROOT))
    if not flattened:
        print('note: Pillow not installed, PNGs keep the alpha channel '
              '(pip install pillow, then rerun)', file=sys.stderr)


if __name__ == '__main__':
    main(sys.argv[1:])
