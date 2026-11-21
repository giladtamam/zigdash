# Encrypted brokers: say what's wrong, fix WSS, count it (3.8.5, v2)

v2 after review (v1, trust on first use, scored 5/10). The owner chose two steps: **this release** tells
the user the truth about an untrusted certificate, fixes direct WSS, and counts both; **trust on first
use** (v1's idea, ~3 days done right: one policy through the client factory seam, pins committed on an
accepted CONNACK, shortcut engine read-only, ConnectionRepo deletes, host edits) is built only if the
data says so (section 5). Based on release/3.8.4 (3.8.4+126, another session's rating timing).

## 1. What is wrong today (checked against the code)

- **Untrusted certificate reads as "no answer".** Every real client (`client_factory_io.dart`
  `buildPlatformClient`) uses the system's trust check. A broker with a self-signed, expired or
  wrong-name certificate fails the TLS handshake; `mqtt_client` rethrows the `HandshakeException`
  unwrapped; `connect_diagnostics.dart:290` catches it, the status is still `noneSpecified`, and 309-313
  report `diagLoginNoAnswer` ("…Home Assistant can take a few seconds to check it, so try again") when a
  login was given, `diagConnackFail` otherwise. `MqttManager._failureOf` gives `FailureKind.unknown`.
  Retrying can never help. Reproduced 2026-11-21 on the emulator (3.8.3 debug, mosquitto with a
  self-signed certificate on 8883, correct password).
- **The scan asks for a password that can't work:** `broker_prober_io.dart:63` accepts any certificate,
  finds the 8883 broker, sees anonymous refused, and setup asks for the login.
- **Direct WSS never connects:** `client_factory_io.dart:58-62` sets `secure = true` for `wss` and
  `useWebSocket = true`; `MqttServerClient.connect` (mqtt_server_client.dart:125-130) runs its `secure`
  block after the WebSocket one and sets `useWebSocket = false`, so it opens a raw `SecureSocket` to
  "wss://host". The package says not to set `secure` for wss; `relay_mqtt_client.dart:37` does it right.
- **Reach, honestly:** 14 days, 26 sessions reached the login after a scan, 6 ended in `login_no_answer`.
  The events carry no port, and `hub: none` means "machine unknown", not "plain broker", so how many of
  the 6 were TLS is unknown: possibly 1. WSS use is unknown too. This release is mostly about not lying,
  and about measuring.

## 2. The changes

### 2a. Tell a certificate failure apart (no change to what is trusted)
- `ConnectDiagnostics` and `MqttManager`, right after the factory returns a client: if it is a
  `MqttServerClient` and the connection is TLS (`tcpSsl` or `wss`), set `client.onBadCertificate =
  (Object? _) { sawBadCert = true; return false; }`. Typed `(Object?)` because `mqtt_server_client.dart:131`
  casts it to `bool Function(Object)?`; a `(X509Certificate)` closure would throw on every secure
  connect. It always returns **false**: nothing new is trusted. The scan's own prober is unchanged.
- Classification after a failed connect, in both places:
  - `sawBadCert` → **certificate not trusted** (`diagTlsUntrusted`, `FailureKind.tlsUntrusted`,
    `SetupErrorKind.tlsUntrusted`);
  - `HandshakeException`/`TlsException` without `sawBadCert` → **TLS failed for another reason** (for
    example a broker that wants a client certificate, or a TLS version mismatch): `diagTlsFailed`,
    `FailureKind.tlsFailed`, `SetupErrorKind.tlsFailed`;
  - otherwise as today.
  In diagnostics the exception is caught at :290 (kept as `e`); `_failureOf` gets the same test.
- New strings (13 languages, AI translations fine):
  - untrusted: "This broker's encryption certificate isn't trusted by your phone: it is self-signed,
    expired, or made for another name. ZigDash can't use it yet. On your home network, use the broker's
    unencrypted port 1883 instead, or give the broker a certificate from a public authority." Action:
    "Edit settings".
  - failed: "The encrypted connection didn't start. The broker may want a client certificate, which
    ZigDash doesn't support. Try its unencrypted port 1883 on your home network." Action: "Edit settings".
- Every switch over the two enums handles the new kinds: `support_details.dart` (42, 73),
  `help_tips.dart` (40), `ai_help.dart` (179; the assistant's facts get the true cause),
  `setup_error_guidance.dart` (95 and `guidanceFor`), `diagnostics_ladder_view.dart` (46), and the
  dashboard's connection-problem text for a saved connection (`FailureKind` → message).
- `diagLoginNoAnswer`'s Home Assistant sentence stays (it is right for real slow logins); a TLS failure
  no longer reaches it.

### 2b. Setup: don't ask for a password that can't work
- `SocketMqttProber._confirmMqtt` records whether its accept-all callback was called; `ProbeResult` and
  `SetupCandidate` get `untrustedCert` (bool). In the coordinator, a candidate with `needsAuth &&
  untrustedCert` goes straight to `SetupFailed(tlsUntrusted)` instead of `SetupNeedsAuth`, unless the
  same host also answered on 1883, which the scan then offers as usual (identity merge keeps both).
  The failed screen's "Edit settings" opens the broker form with host and port 1883 prefilled.

### 2c. Direct WSS
- `buildPlatformClient`: `secure` only for `tcpSsl`; `wss` stays WebSocket with the `wss://` URL
  (`webSocketServer`), which brings TLS itself. With 2a's callback set, mqtt_client builds an
  `HttpClient` whose `badCertificateCallback` calls it (ws_connection:69-73), so WSS gets the same
  classification.

### 2d. Count it
- `SetupStep` `failed` events: `port` (`portClassOf`) for `login_no_answer`, `tls_untrusted`,
  `tls_failed`, `port_closed`; new `error` values `tls_untrusted`, `tls_failed`. `scan_found` and
  `needs_login`: `tls: yes` when the candidate is 8883 (no address).
- `ManualTestResult` gains `tlsUntrusted`, `tlsFailed` (`manual_test` already has `port`).
- `store/PRIVACY.md`: the new values in the setup event row; policy published to GitHub and GitLab before
  the build goes to Play (as every release that changes it).

## 3. Not in this release
- Trusting a self-signed certificate (v1). The shortcut engine and widgets only get the new failure
  kinds through `MqttManager`; nothing about trust changes anywhere, so the relay, Home Assistant and
  Zigbee2MQTT-page clients (which return before the TCP branch) are untouched.
- IPv6 and Tailscale addresses: no change in this release.

## 4. Tests
- Unit: factory (`wss` → not `secure`, `useWebSocket`, `wss://` URL; `tcpSsl` → `secure`); diagnostics
  with a fake client that calls the callback and throws `HandshakeException` → `diagTlsUntrusted`, one
  that throws without the callback → `diagTlsFailed`, a login timeout without TLS → `diagLoginNoAnswer`
  still; `_failureOf` the same three; prober `untrustedCert`; coordinator: 8883 `needsAuth+untrustedCert`
  → `tlsUntrusted`, with 1883 also found → offers 1883; analytics fields; every switch covered (the
  analyzer's exhaustiveness does most of it).
- **Real TLS round trip, offline:** a `SecureServerSocket` and `HttpServer.bindSecure` on localhost with a
  fixture certificate (test-only key, under test/fixtures/tls, labelled so): an `MqttServerClient` from
  the factory with the callback gets `sawBadCert == true` on TCP and on WSS and does not connect, and the
  `(Object?)` cast doesn't throw.
- Emulator (3.8.5 debug): mosquitto with a self-signed certificate on 8883 (also mosquitto's CA plus
  server-certificate setup, connected by IP): broker form with TLS → the new message, not "no answer";
  same broker with 1883 plain also open → the scan offers it; WSS on 9001 with TLS → the new message
  (before: a raw socket error); plain 1883 SMHUB unchanged. Then on the owner's phone against the Mac's
  test broker.
- Goldens: re-rendered on Linux if a screen changes (CI recipe in memory).

## 5. Gate for trust on first use
Three weeks after 3.8.5 is live: `failed` with `error=tls_untrusted` plus `manual_test=tls_untrusted`.
**3 or more distinct sessions** → write v3 (trust on first use with the review's nine fixes) and score it;
fewer → stop.

## 6. Size
About 1.5 days: 2a 0.5, 2b 0.25, 2c 0.1, 2d 0.15, strings 0.1, tests incl. the TLS round trip 0.3,
emulator and phone 0.2. Release 3.8.5+127 (after 3.8.4, or together if 3.8.4 isn't sent: the owner
decides). Built code gets its own independent score before release.
