# Dashboards stay the primary object; no rooms

Every reference smart-home app (Home Assistant, Google Home, Apple Home, Homey) opens on rooms. ZigDash's 2.0 redesign deliberately does not. Dashboards stay the primary object, and generated dashboards are split into sections by device type. Existing users have built dashboards, and the product is organized around them. Zigbee2MQTT has no area data, so rooms would add a data model plus a manual assignment chore the app cannot pre-fill. Sections give most of the "status by category" benefit the benchmark points to. A user who wants rooms names dashboards after them.

## Considered options

- **Rooms as a first-class object:** each device assigned to a room, dashboards optional. Rejected for the assignment chore and the migration of existing dashboards.
- **Hybrid:** an automatic all-devices view grouped by type, with user dashboards beside it. Rejected because the Devices tab already covers "everything, by type" without a second home screen.

Rooms may come later as a feature, outside the redesign. Decided 2026-09-26. See `docs/design/ia.md`.
