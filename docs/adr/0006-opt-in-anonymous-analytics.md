# Anonymous usage data, only with consent

Until 2.0, ZigDash collected nothing ("no telemetry"). From 2.0 it can send a short list of anonymous usage events, only after the user opts in. The default is off. A build without an analytics key, such as an F-Droid build, contains no analytics at all.

Play Console shows how many people install and keep ZigDash, but not where first-run setup fails or which features get used. Those are the questions that decide what to build next, and the user base is too small to answer them by asking in forums.

## The rules

- **Off until the user says yes.** A checkbox on the first setup screen, unticked. Upgraders see one card on their dashboard. A switch in Settings works any time. Nothing is sent, queued or started before consent.
- **A fixed list of events.** Event names and property values come from enums in code, never from user input. No broker hosts, ports, topics, device names, IEEE addresses, home or dashboard names, MQTT payloads or error messages.
- **No identifiers.** Aptabase receives no device ID, advertising ID or install ID. Its server derives a visitor from IP, user agent and a salt that rotates daily, and does not store the IP.
- **Turning it off is immediate.** Unsent events are deleted and nothing more is sent.
- **The rules are public.** The privacy policy lists every event and property.

ADR 0004 still holds: last-known values never leave the phone.

## Considered options

- **Stay without analytics.** Rejected because setup failures are invisible: people who fail setup leave without telling anyone.
- **On by default, with an opt-out.** Rejected. It breaks the promise for everyone who doesn't look, needs EU consent handling, and this audience reads privacy policies.
- **Firebase or Google Analytics.** Rejected. It's a proprietary Google SDK that F-Droid will not build, and the data goes to Google.
- **Self-hosted PostHog.** Rejected for now: a server to run for about 100 users. Aptabase can also be self-hosted later through the same SDK.
- **Ask after the first dashboard works.** Rejected as the only prompt, because people whose setup fails never get there, and they are the first question.

Decided 2026-10-05. See `docs/superpowers/specs/2026-10-05-opt-in-analytics-design.md`.
