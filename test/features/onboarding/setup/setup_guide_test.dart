import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/analytics/analytics_events.dart';
import 'package:zigdash/features/connections/discovery/hub_probe.dart';
import 'package:zigdash/features/onboarding/setup/setup_coordinator.dart';
import 'package:zigdash/features/onboarding/setup/setup_screen.dart';

// 3.3.2: the steps of the guide on an empty result, by what the scan saw
// and what the user answered. Help is always last.
void main() {
  const ScanTried narrow = (
    hostsTried: 254,
    widened: false,
    aliveHosts: 30,
    lateHosts: 0,
  );
  const ScanTried wide = (
    hostsTried: 1018,
    widened: true,
    aliveHosts: 30,
    lateHosts: 0,
  );

  test('no answer: which first, then the whole network and the address', () {
    expect(guideRungsFor(const SetupScanEmpty(tried: narrow)), [
      GuideRung.which,
      GuideRung.wider,
      GuideRung.address,
      GuideRung.help,
    ]);
  });

  test('the network comes first: a VPN, else almost nothing seen', () {
    expect(
      guideRungsFor(
        const SetupScanEmpty(
          tried: (hostsTried: 254, widened: true, aliveHosts: 2, lateHosts: 0),
          network: (kind: 'Wi-Fi', vpn: true),
        ),
      ).first,
      GuideRung.vpn,
    );
    expect(
      guideRungsFor(
        const SetupScanEmpty(
          tried: (hostsTried: 254, widened: true, aliveHosts: 2, lateHosts: 0),
        ),
      ).first,
      GuideRung.isolated,
    );
  });

  test('by answer', () {
    expect(
      guideRungsFor(
        const SetupScanEmpty(
          platform: SetupPlatform.homeAssistant,
          tried: wide,
        ),
      ),
      [GuideRung.homeAssistant, GuideRung.address, GuideRung.help],
    );
    expect(
      guideRungsFor(
        const SetupScanEmpty(platform: SetupPlatform.piOrDocker, tried: wide),
      ),
      [GuideRung.running, GuideRung.z2mPage, GuideRung.address, GuideRung.help],
    );
    expect(
      guideRungsFor(
        const SetupScanEmpty(platform: SetupPlatform.smlight, tried: wide),
      ),
      [GuideRung.address, GuideRung.help],
    );
    expect(
      guideRungsFor(
        const SetupScanEmpty(platform: SetupPlatform.zha, tried: narrow),
      ),
      [GuideRung.zha, GuideRung.help],
    );
  });

  test('Zigbee2MQTT not set up yet: what to get, then help', () {
    expect(
      guideRungsFor(
        const SetupScanEmpty(platform: SetupPlatform.piOrDocker, tried: narrow),
        notYet: true,
      ),
      [GuideRung.notYet, GuideRung.help],
    );
  });

  test('a hub found: its step, then help', () {
    expect(
      guideRungsFor(
        const SetupScanEmpty(
          hubs: [
            HubFound(
              kind: HubKind.zigbee2mqtt,
              host: '192.168.1.30',
              port: 8080,
            ),
          ],
          tried: narrow,
        ),
      ),
      [GuideRung.hub, GuideRung.help],
    );
  });
}
