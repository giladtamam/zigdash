"""Writes the zigdash.app subpages (setup, home-assistant, help, 404) into landing/.

Run from the repo root: python3 tool/build_site.py. The home page, landing/index.html, is edited by hand."""
import pathlib

PLAY = "https://play.google.com/store/apps/details?id=com.giladtamam.zigdash"
APP_STORE = "https://apps.apple.com/app/zigdash-for-zigbee2mqtt/id6829857829"
# GoatCounter: page views and referrers, no cookies. Dashboard at zigdash.goatcounter.com.
GOATCOUNTER = '<script data-goatcounter="https://zigdash.goatcounter.com/count" async src="https://gc.zgo.at/count.js"></script>'


def page(slug, title, desc, body):
    nav = [("setup", "Setup"), ("hubs", "Hubs"), ("home-assistant", "Home Assistant"), ("help", "Help")]
    links = "\n".join(
        f'    <a href="../{s}/"{" aria-current=\"page\"" if s == slug else ""}>{n}</a>'
        for s, n in nav
    )
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title} · ZigDash</title>
<meta name="description" content="{desc}">
<link rel="canonical" href="https://zigdash.app/{slug}/">
<link rel="icon" href="../assets/icon.png">
<meta property="og:title" content="{title} · ZigDash">
<meta property="og:description" content="{desc}">
<meta property="og:url" content="https://zigdash.app/{slug}/">
<meta property="og:image" content="https://zigdash.app/assets/01-dashboard.jpg">
<link rel="stylesheet" href="../assets/site.css">
</head>
<body>
<header>
  <a class="brand" href="../"><img src="../assets/icon.png" alt=""> ZigDash</a>
  <nav>
{links}
    <a href="https://t.me/zigdash_app">Community</a>
  </nav>
</header>
<main>
<article class="doc">
{body.strip()}
</article>
</main>
<footer>
  <p>© 2026 ZigDash · <a href="https://github.com/giladtamam/zigdash">Source code</a> · <a href="https://github.com/giladtamam/zigdash/blob/main/store/PRIVACY.md">Privacy policy</a> · <a href="mailto:support@zigdash.app">support@zigdash.app</a></p>
</footer>
{GOATCOUNTER}
</body>
</html>
"""


SETUP = f"""
<h1>Setting up ZigDash</h1>
<p class="lead">ZigDash connects to the MQTT broker that your Zigbee2MQTT already uses. Most people are done in a minute.</p>

<div class="toc"><strong>On this page</strong>
<ul>
  <li><a href="#need">What you need</a></li>
  <li><a href="#scan">Let ZigDash find it</a></li>
  <li><a href="#address">Connect by address</a></li>
  <li><a href="#login">The login</a></li>
  <li><a href="#hubs">Notes for your hub</a></li>
  <li><a href="#away">Away from home</a></li>
</ul></div>

<h2 id="need">What you need</h2>
<ul>
  <li><strong>Zigbee2MQTT</strong>, running, with at least one device paired.</li>
  <li><strong>An MQTT broker</strong> that Zigbee2MQTT uses, usually Mosquitto. It can run on Home Assistant, a Raspberry Pi, a server or an SMLIGHT hub. No hub yet? See <a href="../hubs/">the hubs we recommend</a>.</li>
  <li><strong>An Android phone or tablet, or an iPhone or iPad</strong>, on the same Wi-Fi as that hub.</li>
</ul>
<p>No Zigbee2MQTT yet? Open ZigDash and try the demo home first.</p>
<div class="buttons" style="justify-content:flex-start"><a class="btn primary" href="{PLAY}" data-goatcounter-click="play-setup">Get ZigDash on Google Play</a> <a class="btn" href="{APP_STORE}" data-goatcounter-click="appstore-setup">Download on the App Store</a></div>

<figure class="video">
  <video controls preload="none" poster="../assets/setup-video.jpg" width="1920" height="1080">
    <source src="../assets/setup-video.mp4" type="video/mp4">
  </video>
  <figcaption>The whole setup in 52 seconds · <a href="https://youtu.be/1wI13XWMCCA">also on YouTube</a></figcaption>
</figure>

<h2 id="scan">1. Let ZigDash find it</h2>
<ol>
  <li>Connect your phone to your home Wi-Fi. Not a guest network, and turn mobile data off while you set up.</li>
  <li>Open ZigDash and tap <strong>Find my setup</strong>. While it looks, tell it where Zigbee2MQTT runs: Home Assistant, an SMLIGHT hub, a Raspberry Pi or Docker, or not sure.</li>
  <li>ZigDash looks for an MQTT broker on your network, then checks that Zigbee2MQTT is on it.</li>
  <li>Pick the devices you want and you have a dashboard.</li>
</ol>
<div class="tip">If your phone isn't on Wi-Fi, ZigDash says so and gives you a button for the Wi-Fi settings. Once you join, it scans again by itself.</div>

<h2 id="address">2. Nothing found? Connect by address</h2>
<p>The scan can miss a hub behind a second router, on a mesh network, or one that answers slowly. Type its address instead:</p>
<ol>
  <li>Find the hub's address: in your router's app, or the address you open Home Assistant or the hub's web page with. It looks like <code>192.168.1.20</code>.</li>
  <li>Type it in ZigDash and tap <strong>Check this address</strong>. You can paste the link from your browser too.</li>
</ol>
<div class="tip">Use the number, not a name. Names ending in <code>.local</code> don't work on every Android phone. Use the address that works at home, not a remote link such as Nabu Casa or DuckDNS.</div>
<p>In manual setup the usual settings are <strong>TCP, port 1883</strong>. Use 8883 only if your broker is set up for TLS. Port 8080 or 80 is the hub's web page, not MQTT.</p>

<h2 id="login">3. The login</h2>
<p>If the broker asks for a login, it wants the <strong>MQTT login</strong>, not the password of your hub's web page.</p>
<ul>
  <li><strong>Home Assistant:</strong> a Home Assistant user. See the <a href="../home-assistant/">Home Assistant guide</a>.</li>
  <li><strong>Raspberry Pi or Docker:</strong> the user from Mosquitto's password file. It's the same one in Zigbee2MQTT's <code>configuration.yaml</code> under <code>mqtt</code>.</li>
  <li><strong>SMLIGHT:</strong> the login shown on the hub's web page under Settings › MQTT.</li>
</ul>
<p>Zigbee2MQTT already logs in to this broker, so its web page shows the username under Settings › MQTT. Copying a password can add a space at the end; check for one.</p>

<h2 id="hubs">Notes for your hub</h2>
<h3>Home Assistant</h3>
<p>Needs the Mosquitto broker add-on and the Zigbee2MQTT add-on, both running. The easiest way is <strong>Connect through Home Assistant</strong> (ZigDash 2.10): sign in once, no broker address or MQTT user, and it works away from home too. Full steps in the <a href="../home-assistant/">Home Assistant guide</a>.</p>
<h3>Raspberry Pi, Linux or Docker</h3>
<p>Mosquitto 2 only accepts connections from the machine it runs on until you tell it to listen on the network. Add this to <code>mosquitto.conf</code> and restart Mosquitto:</p>
<pre><code>listener 1883
password_file /etc/mosquitto/passwd
allow_anonymous false</code></pre>
<p>Create the user with <code>mosquitto_passwd -c /etc/mosquitto/passwd zigdash</code> (leave out <code>-c</code> if the file already exists).</p>
<h3>SMLIGHT (SMHUB, SLZB)</h3>
<p>Open the hub's web page, go to Settings › MQTT and turn on <strong>Allow External</strong>, so your phone can reach the broker. Check that Zigbee2MQTT shows as running.</p>

<h2 id="away">Away from home</h2>
<p>At home ZigDash talks to your hub directly. To use it away from home, install <a href="https://tailscale.com/">Tailscale</a> on the hub and the phone, then add the hub's Tailscale address (<code>100.x.y.z</code>) as the home's remote host. Nothing is opened to the internet and no port forwarding is needed.</p>

<div class="next"><a class="btn" href="../help/">Something not working?</a><a class="btn" href="https://t.me/zigdash_app">Ask the community</a></div>
"""

HA = f"""
<h1>ZigDash with Home Assistant</h1>
<p class="lead">ZigDash shows the devices that Zigbee2MQTT runs. On Home Assistant that means the Mosquitto broker add-on and the Zigbee2MQTT add-on. Your automations stay in Home Assistant and keep running.</p>

<div class="tip"><strong>New in ZigDash 2.10:</strong> sign in to Home Assistant once and ZigDash connects through it, at home or away. No broker address, no MQTT user. See <a href="#through">Connect through Home Assistant</a>.</div>

<div class="tip"><strong>Using ZHA?</strong> ZHA is Home Assistant's own Zigbee and doesn't use MQTT, so ZigDash can't show those devices. ZigDash is for Zigbee2MQTT.</div>

<h2>1. Check the two add-ons</h2>
<p>In Home Assistant, open Settings › Add-ons and check that both are installed and <strong>started</strong>:</p>
<ul>
  <li><strong>Mosquitto broker</strong>: the MQTT broker.</li>
  <li><strong>Zigbee2MQTT</strong>: with your devices paired. Its configuration should point at the Mosquitto broker (the default on Home Assistant).</li>
</ul>

<h2 id="through">2. Connect through Home Assistant (the easy way)</h2>
<p>Your phone talks to Home Assistant, and Home Assistant talks to the broker. That works wherever you can open Home Assistant, your home Wi-Fi or your remote link included.</p>
<ol>
  <li>In ZigDash, tap <strong>Find my setup</strong>. On the result, choose <strong>Home Assistant</strong>, then <strong>Connect through Home Assistant</strong>. (It's also under manual entry.)</li>
  <li>Type the address you open Home Assistant with: <code>192.168.1.20:8123</code>, <code>homeassistant.local:8123</code>, or your remote address like <code>https://xyz.ui.nabu.casa</code>.</li>
  <li>Tap <strong>Sign in with Home Assistant</strong>. Home Assistant's own login page opens in your browser; ZigDash never sees your password. If that page refuses (Home Assistant without internet), paste a long-lived access token instead: in Home Assistant, your profile › Security › Create token.</li>
</ol>
<p>It needs two things: your Home Assistant user must be an <strong>administrator</strong> (Home Assistant only lets administrators use its MQTT), and Home Assistant must have the <strong>MQTT integration</strong> set up (it is, when the Mosquitto add-on is installed the usual way). ZigDash tells you if either is missing.</p>
<p>ZigDash keeps the sign-in on your phone, in the same secure storage as passwords, and uses it only for MQTT. To end it, delete the home in ZigDash, or remove ZigDash under your profile › Security in Home Assistant.</p>

<h2>3. Or connect to the broker directly</h2>
<p>The way ZigDash worked before 2.10: your phone connects to the Mosquitto add-on itself. It needs your phone on the same network as Home Assistant, and an MQTT login.</p>
<h3>Make a user for ZigDash</h3>
<p>The Mosquitto add-on accepts Home Assistant users. Most people make one just for MQTT:</p>
<ol>
  <li>Settings › People › Users › <strong>Add user</strong>. (Turn on Advanced mode in your profile if you don't see Users.)</li>
  <li>Give it a name like <code>zigdash</code> and a password. It doesn't need to be an administrator.</li>
</ol>
<p>You can also use your own Home Assistant login, or a login set in the Mosquitto add-on's options.</p>

<h3>Connect</h3>
<ol>
  <li>With your phone on your home Wi-Fi, open ZigDash and tap <strong>Find my setup</strong>. When it asks where Zigbee2MQTT runs, choose <strong>Home Assistant</strong>.</li>
  <li>If it doesn't find it, type the address you open Home Assistant with, for example <code>192.168.1.20:8123</code>, and tap <strong>Check this address</strong>. ZigDash finds the broker on the same machine.</li>
  <li>When it asks for a login, enter the user you made.</li>
</ol>
<div class="tip"><code>homeassistant.local</code> doesn't work on every Android phone. Use the number address: Home Assistant shows it under Settings › System › Network. For this direct way, a remote link such as Nabu Casa or DuckDNS doesn't work; if that's all you have, connect through Home Assistant instead.</div>
<p>The Mosquitto add-on checks each login with Home Assistant, which can take a few seconds on a Raspberry Pi. If ZigDash says the broker didn't answer the login, try again.</p>

<h2>4. Optional: bring your names and rooms</h2>
<p>In ZigDash, Settings › <strong>Import from Home Assistant</strong> reads the names and rooms you gave your devices in Home Assistant, and can make a dashboard for each room. It reads them once and keeps nothing else from Home Assistant.</p>

<div class="next"><a class="btn" href="../setup/">General setup guide</a><a class="btn" href="../help/">Something not working?</a></div>
"""


def q(title, body):
    return f"<details><summary>{title}</summary>\n{body.strip()}\n</details>"


HELP = "\n".join([
    """<h1>Help</h1>
<p class="lead">The problems people hit most, and what to do. ZigDash shows the same tips in the app under Get help.</p>
<h2>Setup</h2>""",
    q("ZigDash says my phone isn't on Wi-Fi", """
<p>The scan only sees devices on the same network as your phone. Turn on Wi-Fi and join your home network; setup starts again by itself. On a VPN, or away from home? Enter the details manually.</p>"""),
    q("The scan found nothing", """
<ul>
<li>Phone and hub on the same Wi-Fi, not a guest network. Turn mobile data off.</li>
<li>The broker is running: the Mosquitto add-on on Home Assistant, Mosquitto on a Pi, Settings › MQTT on SMLIGHT.</li>
<li>The broker accepts your phone: on SMLIGHT turn on Allow External; Mosquitto 2 needs <code>listener 1883</code> (see <a href="../setup/#hubs">setup</a>).</li>
<li>Mesh Wi-Fi or two routers? Your phone may not see a hub on the second one. Connect by address.</li>
</ul>"""),
    q("Nothing answers at the address I typed", """
<p>Check the address in your router's app, and that your phone is on the same Wi-Fi. Use the number address (like <code>192.168.1.20</code>), not a <code>.local</code> name, and not a remote link such as Nabu Casa or DuckDNS.</p>"""),
    q("The login is rejected", """
<p>It needs the MQTT login, not your hub's web page password. On Home Assistant, use a Home Assistant user. Zigbee2MQTT's web page shows the username it uses under Settings › MQTT. Check for a space at the end of a pasted password.</p>"""),
    q("“No Zigbee2MQTT here”", """
<p>A broker answered, but Zigbee2MQTT isn't publishing to it. Check that Zigbee2MQTT is running and that its MQTT server is this same broker. If you changed the base topic from <code>zigbee2mqtt</code>, enter it in manual setup. On Home Assistant with ZHA instead of Zigbee2MQTT, ZigDash can't show the devices.</p>"""),
    q("“No devices received”", """
<p>Zigbee2MQTT is running but sent no devices. Pair at least one device in Zigbee2MQTT's web page, then check again. If devices are paired, restart Zigbee2MQTT so it publishes its device list.</p>"""),
    "<h2>Day to day</h2>",
    q("The device list is missing", """
<p>When the broker restarts, Zigbee2MQTT's device list is gone until Zigbee2MQTT restarts too. Use the <strong>Restart Zigbee2MQTT</strong> button on the Devices tab. If Zigbee2MQTT's own web page doesn't load, restart it on your hub.</p>"""),
    q("ZigDash can't reach my home", """
<ul>
<li>Is the hub on? After a power cut or an update, give it a minute.</li>
<li>Are you away from home? ZigDash needs a remote address, for example <a href="../setup/#away">Tailscale</a>. Use the hub's <code>100.x.y.z</code> address, not a <code>.ts.net</code> name.</li>
<li>Did the address change? After a router restart the hub may get a new one. Reserve it in your router's app, then update the home in ZigDash.</li>
</ul>"""),
    q("A device shows wrong or doesn't respond", """
<p>Check it in Zigbee2MQTT's web page first. If it works there but not in ZigDash, use Settings › Report a problem in the app.</p>"""),
    """<h2>Still stuck?</h2>
<p>Ask in the <a href="https://t.me/zigdash_app">Telegram group</a>, <a href="https://github.com/giladtamam/zigdash/issues">open an issue on GitHub</a>, or write to <a href="mailto:support@zigdash.app">support@zigdash.app</a>. Tell us what you run (Home Assistant, Raspberry Pi, SMLIGHT) and what ZigDash says.</p>""",
])

HUBS = """
<h1>Hubs we recommend</h1>
<p class="lead">ZigDash needs Zigbee2MQTT running somewhere at home. If you're starting fresh, a small SMLIGHT hub is the simplest way to get there. No Home Assistant needed, and if you have it, ZigDash works with it too.</p>

<div class="tip">These are plain links to AliExpress. We don't earn anything from them, and ZigDash works with any Zigbee2MQTT setup, not only these.</div>

<h2 id="smhub-nano">SMHUB Nano: the easy start</h2>
<p><strong>For:</strong> a first Zigbee home, with no computer to look after.</p>
<p>A small box that runs Zigbee2MQTT and the Mosquitto broker on the hub itself. Plug it into your router, pair your devices on its web page, and ZigDash connects to it directly. It also comes with Node-RED for automations and WireGuard for reaching home.</p>
<ul>
  <li><strong>Good:</strong> everything in one box, stored on built-in eMMC rather than an SD card, with an external Zigbee antenna.</li>
  <li><strong>Keep in mind:</strong> SMLIGHT's hub software is still new and can feel slow in places. Connect it by Ethernet rather than Wi-Fi.</li>
  <li><strong>In ZigDash:</strong> turn on <strong>Allow External</strong> in the hub's Settings › MQTT, then tap Find my setup and choose SMLIGHT.</li>
</ul>
<p><a class="btn primary" href="https://www.aliexpress.com/item/1005011888765730.html">SMHUB Nano on AliExpress</a></p>

<h2 id="smhub">SMHUB Essentials and Premium: room to grow</h2>
<p><strong>For:</strong> bigger homes, or if you may add Z-Wave later.</p>
<p>The same idea as the Nano, with two radios instead of one and slots for add-on modules (Z-Wave, PoE, LTE). Premium has the newer, stronger radios. Zigbee2MQTT and Mosquitto run on the hub, just like the Nano.</p>
<ul>
  <li><strong>Good:</strong> a second radio for Thread, and the most room to expand.</li>
  <li><strong>Keep in mind:</strong> more than most homes need, and the add-on modules cost extra.</li>
</ul>
<p><a class="btn primary" href="https://www.aliexpress.com/item/1005011781605879.html">SMHUB on AliExpress</a></p>

<h2 id="slzb-06">SLZB-06: if you already run a Raspberry Pi or server</h2>
<p><strong>For:</strong> people who already run Zigbee2MQTT on a Pi, a server or Home Assistant, and want a better Zigbee radio.</p>
<p>A network Zigbee coordinator: it plugs into your router (with PoE, one cable does power and network) and Zigbee2MQTT connects to it over the network, so it can sit in the middle of the house instead of behind a computer. SMLIGHT recommends the TI versions (SLZB-06 and SLZB-06P7) for Zigbee2MQTT.</p>
<ul>
  <li><strong>Good:</strong> solid, widely used, and easy to place where the signal is best.</li>
  <li><strong>Keep in mind:</strong> it is only the Zigbee radio. Zigbee2MQTT and the broker still run on your own Pi or server, so on its own it is not a complete setup.</li>
</ul>
<p><a class="btn primary" href="https://www.aliexpress.com/item/1005004942648430.html">SLZB-06 on AliExpress</a></p>

<h2 id="which">Which one?</h2>
<ul>
  <li><strong>Starting from nothing:</strong> SMHUB Nano.</li>
  <li><strong>A big home, or Z-Wave plans:</strong> SMHUB Premium.</li>
  <li><strong>Already running Zigbee2MQTT on a Pi or server:</strong> SLZB-06.</li>
</ul>

<div class="next"><a class="btn" href="../setup/">Setup guide</a><a class="btn" href="https://t.me/zigdash_app">Ask the community</a></div>
"""

NOTFOUND = """
<h1>Page not found</h1>
<p class="lead">That page doesn't exist. Try the <a href="/">home page</a>, the <a href="/setup/">setup guide</a> or <a href="/help/">help</a>.</p>
"""

root = pathlib.Path("landing")
for slug, title, desc, body in [
    ("setup", "Setting up", "How to connect ZigDash to Zigbee2MQTT and your MQTT broker: scan, connect by address, the login, and notes for Home Assistant, Raspberry Pi and SMLIGHT.", SETUP),
    ("hubs", "Hubs we recommend", "SMLIGHT hubs that run Zigbee2MQTT, with an honest note on each: SMHUB Nano, SMHUB Essentials and Premium, and the SLZB-06 coordinator.", HUBS),
    ("home-assistant", "With Home Assistant", "Use ZigDash with Home Assistant's Mosquitto and Zigbee2MQTT add-ons: make a user, connect, and import your names and rooms.", HA),
    ("help", "Help", "Fixes for the most common ZigDash problems: nothing found, login rejected, no Zigbee2MQTT, missing devices, and reaching home.", HELP),
]:
    (root / slug).mkdir(exist_ok=True)
    (root / slug / "index.html").write_text(page(slug, title, desc, body))

nf = page("", "Page not found", "Page not found.", NOTFOUND).replace('href="../', 'href="/').replace('src="../', 'src="/')
nf = nf.replace('<link rel="canonical" href="https://zigdash.app//">\n', "")
(root / "404.html").write_text(nf)
