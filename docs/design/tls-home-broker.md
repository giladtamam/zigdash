# Encrypted home brokers: trust on first use (3.8.5, v1)

Proposed 2026-11-21, on release/3.8.4 (3.8.4+126, rating timing, by another session).

## The bug

A broker on the home network that uses TLS with its own (self-signed) certificate, the usual way people
turn on encryption at home, can never be set up:

- The scan's MQTT check accepts any certificate (`broker_prober_io.dart:63`), so it finds the broker on
  8883, sees anonymous refused, and asks for the login (`SetupCandidate.fromProbe`: 8883 → `tcpSsl`).
- Every real connection (`client_factory_io.dart` `buildPlatformClient`: `secure = true`, no
  `onBadCertificate`) rejects the certificate. The TLS handshake fails before MQTT, `connectionStatus`
  stays `noneSpecified`, and `connect_diagnostics.dart:309` reports `diagLoginNoAnswer`: "The broker
  didn't answer the login in time. Home Assistant can take a few seconds to check it, so try again."
  The right password fails the same way; nothing the user can do helps.
- Reproduced 2026-11-21 on the emulator (3.8.3 debug): mosquitto with a self-signed certificate on 8883,
  correct password → that message; mosquitto's log shows the client closing during the handshake. A
  wrong password on plain 1883 is reported correctly as rejected.
- Data, last 14 days: 26 sessions reached the login after a scan; 6 ended in `login_no_answer` (5 on
  plain brokers: SK, RU, ES, IT, UA). The event has no port, so how many were 8883 is unknown; this
  release adds it.

## The fix

### 1. Trust on first use, home addresses only
- New `lib/mqtt/cert_pins.dart`: pins in SharedPreferences under `tls_pin::<host>:<port>` = SHA-256 of
  the certificate's DER (`X509Certificate.der`, `package:crypto`, already a dependency).
- `buildPlatformClient` gets an optional `CertPolicy`. For a secure TCP or WSS client whose target is a
  **home address** (private IPv4 per `isPrivateIpv4`, `*.local`, `*.lan`, `*.home.arpa`, or a bare name
  without a dot), `onBadCertificate` is set:
  - no pin for host:port → accept, and remember the fingerprint as *seen* (in memory, on the policy);
  - pin equals the fingerprint → accept;
  - pin differs → reject, and record *changed* on the policy.
- The pin is written only after the connection **succeeds** (CONNACK accepted): in setup's
  `createDashboard` and the broker form's save, and by `MqttManager` on its first successful connect of a
  connection with no pin (older saved connections). A failed or abandoned attempt pins nothing.
- Not a home address (a remote host, a domain name): unchanged, the system's normal certificate check.
  A valid certificate (a real CA) never reaches `onBadCertificate`, so nothing changes for those users.
- The scan probe stays as it is (it only looks).
- Deleting a connection deletes its pins; "Forget certificate" in the connection's edit screen when a
  changed certificate blocks it (a broker that renewed its self-signed certificate).

### 2. Say what happened
- `connect_diagnostics.dart`: a secure attempt whose handshake failed reports `diagTlsUntrusted` (the
  certificate isn't trusted: not a home address) or `diagTlsChanged` (it changed since last time),
  instead of `diagConnackFail` / `diagLoginNoAnswer`. Told apart by the policy's record, not by parsing
  error strings.
- New `SetupErrorKind.tlsUntrusted` and `tlsChanged` with their guidance; `diagLoginNoAnswer`'s text
  mentions Home Assistant only when the broker's machine is Home Assistant (as `diagAuthRejectedHa`).
- Strings in 13 languages (AI translations are fine).

### 3. Count it
- `failed` and `manual_test` events: `port` bucket (1883 / 8883 / other, as `manual_test` already has)
  and `tls: home_trusted | changed | untrusted` when relevant. `login_no_answer` gets `port` too.
- PRIVACY.md (store/PRIVACY.md): the two new values in the setup event row. Policy published on GitHub
  and GitLab before the release.

## Safety

Trusting an unknown certificate on first use means a device already on the home network at the moment of
setup could impersonate the broker; after that, a changed certificate is refused and said so. Without
this, the same user's only working option today is turning TLS off (plain 1883), which is weaker. Home
addresses only; never for remote or relay connections; the user sees "Encrypted, certificate remembered"
on the connection screen.

## Tests
- Unit: `CertPolicy` (no pin / same / changed; home vs remote host); pin written only after success;
  delete clears pins; diagnostics map a failed handshake to the two new keys.
- Emulator: local mosquitto with a self-signed certificate on 8883: wrong password → rejected, right
  password → connected and pinned; certificate replaced → "changed", Forget → works again. Plain 1883 and
  the SMHUB unchanged.
- Real phone on the home network, same broker on the Mac.

## Size
About 1.5 days: policy + factory + pin writes (0.5), diagnostics and error kinds (0.5), strings, events,
policy, tests, emulator and phone check (0.5). Release 3.8.5+127 after 3.8.4 is live (or both together if
3.8.4 is not sent yet: the owner decides).
