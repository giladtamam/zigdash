#!/usr/bin/env python3
"""Checks the App Store text limits for every locale in fastlane/metadata/ios:
subtitle <= 30 characters, keywords <= 100 bytes, no spaces after commas, no
repeated keyword, no keyword that repeats a subtitle word (zigbee excepted:
the name indexes "Zigbee2MQTT" as one token), promotional text <= 170."""
import re, sys
from pathlib import Path
M = Path(__file__).resolve().parents[2] / 'fastlane' / 'metadata' / 'ios'
bad = 0
for d in sorted(p for p in M.iterdir() if (p / 'keywords.txt').exists()):
    sub = (d / 'subtitle.txt').read_text().strip()
    kw = (d / 'keywords.txt').read_text().strip()
    promo = (d / 'promotional_text.txt').read_text().strip()
    ws = kw.split(',')
    sw = {w.lower() for w in re.findall(r'\w+', sub)}
    dup = sorted({w for w in ws if ws.count(w) > 1})
    overlap = [w for w in ws if w in sw and w != 'zigbee']
    ok = len(sub) <= 30 and len(kw.encode()) <= 100 and ' ' not in kw and not dup and not overlap and len(promo) <= 170
    bad += not ok
    print(f"{d.name:6} subtitle {len(sub):2}/30  keywords {len(kw.encode()):3}/100  promo {len(promo):3}/170  {'OK' if ok else 'FAIL'} {dup or ''}{overlap or ''}")
sys.exit(1 if bad else 0)
