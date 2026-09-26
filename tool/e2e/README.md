# Real-broker end-to-end checks

`bin/e2e_real_broker.dart` drives ZigDash's real `MqttManager` against a live broker and checks:

1. Connecting with ZigDash's MQTT 3.1 CONNECT.
2. Zigbee2MQTT bridge state and device list.
3. Retained device state.
4. A command round trip through `<device>/set`. This is skipped with `--read-only true`.
5. Two clients for the same connection staying connected (the client-id takeover regression), plus a control that forces a shared id.
6. A broker restart: the drop is detected, the client reconnects and resubscribes. Pass `--restart-cmd`.

Against a real home, use read-only mode so no device is switched:

```bash
tool/flutter pub get
dart run bin/e2e_real_broker.dart --host 192.168.1.20 --port 1883 --read-only true
```

Without Zigbee2MQTT hardware, run `tool/e2e/z2m_sim.py` next to any broker. It needs `pip install paho-mqtt`.

```bash
python3 tool/e2e/z2m_sim.py --host localhost --port 1883 &
dart run bin/e2e_real_broker.dart --host localhost --port 1883
dart run bin/e2e_real_broker.dart --host localhost --port 9001 --protocol ws
```

Brokers verified on 2026-09-26 are Mosquitto 2.0.18 over TCP and WebSocket, and aedes. All checks pass on all three.

Connection diagnostics, as used by the setup flow:

```bash
dart run bin/smoke_diagnostics.dart --host localhost --port 1883
```
