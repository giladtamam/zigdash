import '../../core/analytics/analytics_events.dart';
import '../../l10n/app_localizations.dart';
import '../onboarding/setup/setup_error_guidance.dart';
import 'support_details.dart';

typedef HelpTip = ({String title, String body});

/// The tips Get help shows first, for the place it was opened from
/// (docs/design/support.md §3). A setup error gets its own tips; errors
/// without any fall back to the "No connection found" ones.
List<HelpTip> tipsFor(AppLocalizations l, HelpFrom from, SetupErrorKind? error) {
  HelpTip t(String title, String body) => (title: title, body: body);
  final noConnection = [
    t(l.tipSameWifiTitle, l.tipSameWifiBody),
    t(l.tipBrokerRunningTitle, l.tipBrokerRunningBody),
    t(l.tipBrokerAcceptsTitle, l.tipBrokerAcceptsBody),
    t(l.tipMeshTitle, l.tipMeshBody),
    t(l.tipByAddressTitle, l.tipByAddressBody),
  ];
  return switch (from) {
    HelpFrom.noConnection => noConnection,
    HelpFrom.setupError => switch (error) {
        SetupErrorKind.hostUnreachable => [
            t(l.tipSameNetworkTitle, l.tipSameNetworkBody),
            t(l.tipAddressChangedTitle, l.tipAddressChangedBody),
          ],
        SetupErrorKind.portClosed => [
            t(l.tipRightPortTitle, l.tipRightPortBody),
            t(l.tipStartBrokerTitle, l.tipStartBrokerBody),
            t(l.tipMosquitto2Title, l.tipMosquitto2Body),
          ],
        SetupErrorKind.authRequired || SetupErrorKind.authRejected => [
            t(l.tipMqttLoginTitle, l.tipMqttLoginBody),
            t(l.tipSpacesTitle, l.tipSpacesBody),
          ],
        SetupErrorKind.notZigbee2Mqtt => [
            t(l.tipZ2mBrokerTitle, l.tipZ2mBrokerBody),
            t(l.tipBaseTopicTitle, l.tipBaseTopicBody),
          ],
        SetupErrorKind.noDevices => [
            t(l.tipPairFirstTitle, l.tipPairFirstBody),
            t(l.tipRestartZ2mTitle, l.tipRestartZ2mBody),
          ],
        _ => noConnection,
      },
    HelpFrom.manualConnect => [
        t(l.tipNumberAddressTitle, l.tipNumberAddressBody),
        t(l.tipPortProtocolTitle, l.tipPortProtocolBody),
        t(l.tipManualLoginTitle, l.tipManualLoginBody),
      ],
    HelpFrom.homeUnreachable => [
        t(l.tipHubOnTitle, l.tipHubOnBody),
        t(l.tipAwayTitle, l.tipAwayBody),
        t(l.tipHomeAddressChangedTitle, l.tipHomeAddressChangedBody),
      ],
    HelpFrom.deviceListMissing => [
        t(l.tipRestartZ2mButtonTitle, l.tipRestartZ2mButtonBody),
        t(l.tipZ2mRunningTitle, l.tipZ2mRunningBody),
      ],
    HelpFrom.settings => [
        t(l.tipCantConnectTitle, l.tipCantConnectBody),
        t(l.tipDeviceWrongTitle, l.tipDeviceWrongBody),
        t(l.tipHowDoITitle, l.tipHowDoIBody),
      ],
    HelpFrom.demo => [
        t(l.tipWhatYouNeedTitle, l.tipWhatYouNeedBody),
        t(l.tipSetupAtHomeTitle, l.tipSetupAtHomeBody),
        t(l.tipFindSetupTitle, l.tipFindSetupBody),
      ],
  };
}

/// Where Get help was opened from, in English for Support details.
String openedFromLabel(HelpFrom from, SetupErrorKind? error) => switch (from) {
      HelpFrom.noConnection => 'Setup › No connection found',
      HelpFrom.setupError => 'Setup › ${error == null ? 'error' : failureKindLabel(failureKindFromSetup(error))}',
      HelpFrom.manualConnect => 'Manual connect › check failed',
      HelpFrom.homeUnreachable => "Dashboard › home can't be reached",
      HelpFrom.deviceListMissing => 'Devices › device list missing',
      HelpFrom.settings => 'Settings',
      HelpFrom.demo => 'Demo',
    };
