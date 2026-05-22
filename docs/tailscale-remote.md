# Remote access with Tailscale

ZigDash connects to your MQTT broker over the LAN. To control your home while
away, add a **Tailscale** address as the connection's *Remote host* — ZigDash
uses the LAN address at home and falls back to the Tailscale address when away.

## 1. Install Tailscale on the broker host (SMHUB / Linux)

    curl -fsSL https://tailscale.com/install.sh | sh
    sudo tailscale up

Sign in with your account. Then note the hub's **Tailscale IP** (recommended —
it's stable and needs no DNS):

    tailscale ip -4      # e.g. 100.x.y.z

(You can also use a MagicDNS name like `smhub.tailnet-xxxx.ts.net`, but only if
you **enable MagicDNS** in the admin console DNS tab — and some phones don't
resolve MagicDNS names inside apps. The `100.x` IP avoids all of that.)

The Mosquitto broker already listens on `0.0.0.0:1883`, so no broker change is
needed — it's reachable on the Tailscale IP automatically.

## 2. Install Tailscale on the phone

Install the Tailscale app, sign into the **same** account/tailnet, and leave it
running (it sits idle until needed).

## 3. Configure ZigDash

Edit the connection → **Advanced** → **Remote host (Tailscale)** → enter the
hub's **Tailscale IP** (e.g. `100.x.y.z`). Leave Local host as your LAN address
(e.g. `192.168.7.210`). Port, protocol, and credentials are shared.

> Tip: prefer the `100.x` IP over a `.ts.net` name — it's stable and needs no
> DNS, so it works even when MagicDNS isn't resolving inside the app.

Now ZigDash tries the LAN first (instant at home) and falls back to Tailscale
when you're away. The status chip shows **Connected · Remote** when on the
fallback.

## Security note

The LAN leg is plain MQTT on your home network (unchanged). The remote leg is
encrypted end-to-end by Tailscale (WireGuard), so no broker TLS/auth change is
required.

## Optional: lock it down

Use Tailscale ACLs/tags so only your own devices can reach the broker host.
