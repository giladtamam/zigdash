#!/usr/bin/env python3
"""Minimal Zigbee2MQTT stand-in for real-broker end-to-end checks.

Publishes retained bridge/state, bridge/info and bridge/devices plus device
states, and answers `<base>/<device>/set` like Zigbee2MQTT does: merges the
payload into the device state and republishes it (retained).

    python3 tool/e2e/z2m_sim.py --host localhost --port 1883 [--base zigbee2mqtt]
"""
import argparse
import json
import signal
import sys

import paho.mqtt.client as mqtt

DEVICES = {
    "living_light": {
        "type": "Router", "model": "LED1545G12", "vendor": "IKEA",
        "exposes": [{"type": "light", "features": [
            {"type": "binary", "name": "state", "property": "state",
             "value_on": "ON", "value_off": "OFF", "access": 7},
            {"type": "numeric", "name": "brightness", "property": "brightness",
             "value_min": 0, "value_max": 254, "access": 7}]}],
        "state": {"state": "ON", "brightness": 180, "linkquality": 156},
    },
    "kitchen_plug": {
        "type": "Router", "model": "TS011F", "vendor": "Tuya",
        "exposes": [{"type": "switch", "features": [
            {"type": "binary", "name": "state", "property": "state",
             "value_on": "ON", "value_off": "OFF", "access": 7}]},
            {"type": "numeric", "name": "power", "property": "power",
             "unit": "W", "access": 1}],
        "state": {"state": "OFF", "power": 0, "linkquality": 120},
    },
    "living_climate": {
        "type": "EndDevice", "model": "WSDCGQ11LM", "vendor": "Aqara",
        "exposes": [
            {"type": "numeric", "name": "temperature", "property": "temperature",
             "unit": "°C", "access": 1},
            {"type": "numeric", "name": "humidity", "property": "humidity",
             "unit": "%", "access": 1},
            {"type": "numeric", "name": "battery", "property": "battery",
             "unit": "%", "access": 1}],
        "state": {"temperature": 21.4, "humidity": 48, "battery": 23,
                  "linkquality": 90},
    },
    "front_door": {
        "type": "EndDevice", "model": "MCCGQ11LM", "vendor": "Aqara",
        "exposes": [{"type": "binary", "name": "contact", "property": "contact",
                     "value_on": False, "value_off": True, "access": 1}],
        "state": {"contact": True, "battery": 91, "linkquality": 70},
    },
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--host", default="localhost")
    ap.add_argument("--port", type=int, default=1883)
    ap.add_argument("--base", default="zigbee2mqtt")
    a = ap.parse_args()
    base = a.base

    c = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id="z2m-sim")
    c.will_set(f"{base}/bridge/state", json.dumps({"state": "offline"}),
               retain=True)

    def pub(topic, payload):
        c.publish(topic, json.dumps(payload), qos=1, retain=True)

    def on_connect(client, userdata, flags, rc, props=None):
        pub(f"{base}/bridge/state", {"state": "online"})
        pub(f"{base}/bridge/info", {"version": "2.13.0-sim",
                                    "config": {"mqtt": {"base_topic": base}}})
        pub(f"{base}/bridge/devices", [
            {"friendly_name": "Coordinator", "type": "Coordinator",
             "ieee_address": "0x00", "supported": True}] + [
            {"friendly_name": n, "type": d["type"],
             "ieee_address": f"0x{i + 1:016x}", "supported": True,
             "definition": {"model": d["model"], "vendor": d["vendor"],
                            "exposes": d["exposes"]}}
            for i, (n, d) in enumerate(DEVICES.items())])
        for n, d in DEVICES.items():
            pub(f"{base}/{n}", d["state"])
            pub(f"{base}/{n}/availability", {"state": "online"})
        client.subscribe(f"{base}/+/set", qos=1)
        print(f"z2m-sim online on {a.host}:{a.port} base={base}", flush=True)

    def on_message(client, userdata, msg):
        name = msg.topic.split("/")[-2]
        if name not in DEVICES:
            return
        try:
            change = json.loads(msg.payload.decode())
        except ValueError:
            change = {"state": msg.payload.decode()}
        state = DEVICES[name]["state"]
        if change.get("state") == "TOGGLE":
            change["state"] = "OFF" if state.get("state") == "ON" else "ON"
        state.update(change)
        pub(f"{base}/{name}", state)
        print(f"set {name} {json.dumps(change)}", flush=True)

    c.on_connect = on_connect
    c.on_message = on_message
    c.connect(a.host, a.port, keepalive=30)
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    c.loop_forever(retry_first_connection=True)


if __name__ == "__main__":
    main()
