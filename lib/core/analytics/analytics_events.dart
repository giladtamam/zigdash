/// The only usage events ZigDash can send (ADR 0006). Every property value
/// is an enum name or a bucket label, never text the user typed or a broker
/// sent. The privacy policy lists this file's contents.
sealed class AnalyticsEvent {
  const AnalyticsEvent();

  String get name;
  Map<String, String> get props;
}

enum FormFactor { phone, tablet }

enum ThemeChoice { system, light, dark }

/// Once per launch, after consent.
class AppStarted extends AnalyticsEvent {
  const AppStarted({
    required this.form,
    required this.theme,
    required this.materialYou,
    required this.homes,
    required this.tiles,
    required this.demo,
    this.daysInstalled,
  });

  final FormFactor form;
  final ThemeChoice theme;
  final bool materialYou;
  final int homes;
  final int tiles;
  final bool demo;

  /// Whole days since ZigDash was installed on this phone (2.9.7), from
  /// Android's install time; null when it couldn't be read. Only the range
  /// is sent: it shows whether people come back, which a daily-changing
  /// anonymous id can't.
  final int? daysInstalled;

  @override
  String get name => 'app_started';

  @override
  Map<String, String> get props => {
    'form': form.name,
    'theme': theme.name,
    'material_you': materialYou ? 'on' : 'off',
    'homes': bucket(homes, const [0, 1], top: '2+'),
    'tiles': bucket(
      tiles,
      const [0],
      ranges: const [(1, 10), (11, 30)],
      top: '31+',
    ),
    'demo': demo ? 'yes' : 'no',
    'installed': switch (daysInstalled) {
      null => 'unknown',
      final d => bucket(
        d,
        const [0, 1],
        ranges: const [(2, 7), (8, 30)],
        top: '31+',
      ),
    },
  };
}

enum SetupStepKind {
  started,
  scanFound,
  scanEmpty,
  needsLogin,
  loginRejected,
  failed,
  review,
  complete,
  manual,
  demo,

  /// The address check on the empty result (2.6.2), with its [SetupStep.result].
  address,

  /// Test & connect on the broker form (2.7.2), with its
  /// [SetupStep.result]: connected, or the first step that failed.
  manualTest,

  /// Zigbee2MQTT's web page asked where its broker is (2.7.2), with its
  /// [SetupStep.result]: broker, local_only, unreachable or no_answer;
  /// from 2.10.4 also name_only (a name only that machine knows) and
  /// token_required (the page is protected by a token).
  z2mAsked,

  /// One of the three choices on the empty result (2.9.6), with its
  /// [SetupStep.choice].
  emptyChoice,

  /// "Remind me tomorrow" was tapped where setup stopped (2.9.7).
  remindLater,

  /// The app was opened from that reminder (2.9.7).
  reminderOpened,

  /// "No Zigbee2MQTT yet?" on the welcome screen (2.9.7): the demo home…
  welcomeDemo,

  /// …or the page of hubs that run Zigbee2MQTT.
  welcomeHubs,

  /// A try to connect through Home Assistant (2.10), with its
  /// [SetupStep.result]: ok, or why not (`HaConnectOutcome`).
  haConnect,

  /// The Home Assistant sign-in was opened from setup (3.1.3), with
  /// [SetupStep.choice] saying from where (a [HaSignInFrom]).
  haOpened,

  /// An answer to "where does Zigbee2MQTT run?" was picked (3.1.3), with
  /// [SetupStep.platform]; counted when given, not only with later steps.
  platformChosen,

  /// "Ask your AI" on a screen where setup is stuck (3.1.5): its
  /// [SetupStep.choice] says which screen (an `AiHelpFrom`), its
  /// [SetupStep.result] what was done (opened, shared, copied). Never the
  /// write-up itself.
  aiHelp,

  /// Back on the review asked first (3.1.6): its [SetupStep.result] is the
  /// answer (a `ReviewBackAnswer`): create, start over, or stay.
  reviewBack,

  /// Looking for Home Assistant on the network (3.1.8), with its
  /// [SetupStep.result] (a `HaDiscoveryOutcome`): one, several, by_name or
  /// none when the look ends; used when a sign-in goes to a found address.
  haDiscovery,

  /// The review was left without creating a dashboard (2.10.2): back, or
  /// setup started over. Carries [SetupStep.devices] and
  /// [SetupStep.selected], the state of the list when it was left.
  reviewLeft,
}

/// What the user tapped on an empty result with no hub found (2.9.6): no
/// hub yet (opens the Hubs page), Home Assistant (checks
/// homeassistant.local), or a hub on another network (the guest-network
/// note and usual names).
enum ScanEmptyChoice { noHub, homeAssistant, otherNetwork }

/// How setup succeeded (3.1.3), on [SetupStepKind.complete]: the scan and
/// its review, Home Assistant's sign-in (which also ends in the review), or
/// the broker form, which until 3.1.3 sent no complete at all.
enum SetupVia { scan, homeAssistant, brokerForm, shared }

/// Where setup opened the Home Assistant sign-in (3.1.3): while scanning,
/// the card on an empty result, the note under "I use Home Assistant",
/// the first button when Home Assistant was found without a broker, the
/// broker's login prompt, or the link on the broker form; from 3.1.9 also
/// the no-Wi-Fi screen ([noWifi]), where a remote address is the way in.
enum HaSignInFrom {
  scanning,
  emptyCard,
  emptyChoice,
  haFound,
  login,
  manualForm,
  noWifi,
}

/// How Test & connect on the broker form ended (2.7.2): connected, or the
/// first step that failed (name lookup, TCP connection, MQTT handshake,
/// login). Never the address. 2.9.3 splits out the cases with their own
/// message: a `.local` name, Home Assistant without a broker, Home
/// Assistant refusing the login. 2.9.5 adds a refused port on an SMLIGHT
/// hub (Allow External off) and on a Zigbee2MQTT machine whose broker
/// listens only locally.
enum ManualTestResult {
  connected,
  resolve,
  tcp,
  connack,
  auth,
  localName,
  haNoBroker,
  haLogin,
  smlightClosed,
  z2mNoBroker,

  /// A Zigbee2MQTT machine whose own settings name the broker elsewhere
  /// (2.10.4): another machine, or a container on this one.
  z2mBrokerElsewhere,
}

/// The port typed on the broker form, as a class (2.10.4): the MQTT
/// ports, a web port (the Zigbee2MQTT page's, Home Assistant's), or other.
/// Never the address.
String portClassOf(int port) => switch (port) {
  1883 => '1883',
  8883 => '8883',
  80 || 443 || 8080 || 8081 || 8099 || 8123 || 8443 => 'web',
  _ => 'other',
};

/// Each step of first-run setup: where people get stuck. An empty scan
/// (2.5) also says what the scan saw: the user's platform answer, the hub
/// kind it found (or none), how many hosts it tried, whether it widened to
/// the /22, and the shape of the phone's subnet; from 2.6.2 also how many
/// hosts answered at all, whether a VPN was up and the kind of network. The
/// address check (2.6.2) reports only its outcome. Kinds and buckets only;
/// never an address.
class SetupStep extends AnalyticsEvent {
  const SetupStep(
    this.step, {
    this.error,
    this.devices,
    this.platform,
    this.hub,
    this.hostsTried,
    this.widened,
    this.subnet,
    this.aliveHosts,
    this.lateHosts,
    this.vpn,
    this.network,
    this.result,
    this.tidied,
    this.noNetwork,
    this.choice,
    this.selected,
    this.portClass,
    this.via,
    this.aiHelped,
  });

  final SetupStepKind step;

  /// Whether "Ask your AI" was shared or copied earlier in this setup, on
  /// [SetupStepKind.complete] (3.1.5).
  final bool? aiHelped;

  /// How setup succeeded, on [SetupStepKind.complete] (3.1.3).
  final SetupVia? via;

  /// The choice tapped on the empty result (a [ScanEmptyChoice]), when
  /// [step] is emptyChoice; where the sign-in was opened from (a
  /// [HaSignInFrom]), when [step] is haOpened.
  final Enum? choice;

  /// The setup error kind's name, when [step] is failed.
  final Enum? error;

  /// How many scanned hosts answered at all, on an empty scan.
  final int? aliveHosts;

  /// How many answered only to the scan's second, slower look (2.9.3), on
  /// an empty scan and on a found one.
  final int? lateHosts;

  /// Why the phone had no home address, on a scan_failed (2.9.4): mobile
  /// data, no network, or unknown. Never an address or interface name.
  final Enum? noNetwork;

  /// Whether a VPN interface was up during the scan.
  final bool? vpn;

  /// 'Wi-Fi', 'Ethernet' or 'other', as Support details names the interface.
  final String? network;

  /// The address check's outcome (an [AddressOutcome]), when [step] is
  /// address.
  final Enum? result;

  /// Devices found, at review and complete.
  final int? devices;

  /// Devices ticked at review (2.10.2): the preselection when the list
  /// appears, the user's choice when the list is left. A 0 is a review
  /// whose button offered nothing.
  final int? selected;

  /// The user's answer to where Zigbee2MQTT runs, once given.
  final Enum? platform;

  /// The hub kind an empty scan found; null on an empty scan means none.
  final Enum? hub;

  /// Whether the broker form cleaned up what was typed (a pasted browser
  /// link, a web port), on [SetupStepKind.manualTest].
  final bool? tidied;

  /// The class of the port typed ([portClassOf]), on
  /// [SetupStepKind.manualTest] (2.10.4).
  final String? portClass;
  final int? hostsTried;
  final bool? widened;

  /// '192.168', '10', '172.16' or 'other'.
  final String? subnet;

  @override
  String get name => 'setup_step';

  @override
  Map<String, String> get props => {
    'step': _snake(step.name),
    if (error != null) 'error': _snake(error!.name),
    if (devices != null)
      'devices': bucket(
        devices!,
        const [0],
        ranges: const [(1, 5), (6, 20)],
        top: '21+',
      ),
    if (selected != null)
      'selected': bucket(
        selected!,
        const [0],
        ranges: const [(1, 5), (6, 20)],
        top: '21+',
      ),
    if (platform != null) 'platform': _snake(platform!.name),
    if (via != null) 'via': _snake(via!.name),
    if (aiHelped != null) 'ai': aiHelped! ? 'yes' : 'no',
    if (step == SetupStepKind.scanEmpty)
      'hub': hub == null ? 'none' : _snake(hub!.name),
    if (hostsTried != null)
      'hosts': bucket(
        hostsTried!,
        const [0],
        ranges: const [(1, 253), (254, 1020)],
        top: '1021+',
      ),
    if (widened != null) 'widened': widened! ? 'yes' : 'no',
    if (subnet != null) 'subnet': subnet!,
    if (aliveHosts != null)
      'alive': bucket(
        aliveHosts!,
        const [0],
        ranges: const [(1, 5), (6, 20)],
        top: '21+',
      ),
    if (lateHosts != null)
      'late': bucket(
        lateHosts!,
        const [0],
        ranges: const [(1, 5), (6, 20)],
        top: '21+',
      ),
    if (vpn != null) 'vpn': vpn! ? 'yes' : 'no',
    if (network != null) 'net': networkLabel(network!),
    if (result != null) 'result': _snake(result!.name),
    if (tidied != null) 'tidied': tidied! ? 'yes' : 'no',
    if (portClass != null) 'port': portClass!,
    if (noNetwork != null) 'why': _snake(noNetwork!.name),
    if (choice != null) 'choice': _snake(choice!.name),
  };

  /// The interface kind as a fixed label: wifi, ethernet or other.
  static String networkLabel(String kind) => switch (kind) {
    'Wi-Fi' => 'wifi',
    'Ethernet' => 'ethernet',
    _ => 'other',
  };
}

enum Feature {
  devicesTab,
  devicePage,
  scenes,
  editMode,
  wallDisplay,
  tileAdded,

  /// A history sheet or the device page's History card was opened (2.7).
  history,

  /// A device was controlled from the app (2.9.2), with its kind in `tile`.
  control,

  /// A new scene was saved (3.1.2). Never which scene or what it does.
  sceneCreated,

  /// A scene was run from the Scenes tab or a dashboard tile (3.1.2).
  /// Widget runs are `shortcut_used` with kind `scene_widget`.
  sceneRun,
}

/// The first use of a feature in a session.
class FeatureUsed extends AnalyticsEvent {
  const FeatureUsed(this.feature, {this.tile});

  final Feature feature;

  /// The added tile's device class or panel type, when [feature] is
  /// tileAdded.
  final Enum? tile;

  @override
  String get name => 'feature_used';

  @override
  Map<String, String> get props => {
    'feature': _snake(feature.name),
    if (tile != null) 'tile': _snake(tile!.name),
  };
}

/// Kiosk lock turned on (kiosk-2.6.md), with which options were chosen:
/// a PIN, Android screen pinning, and the dim delay as one of its fixed
/// choices. Sent as `feature_used` with feature `kiosk`.
class KioskStarted extends AnalyticsEvent {
  const KioskStarted({
    required this.pin,
    required this.osPinning,
    required this.dimMinutes,
    this.idleShow = 'dim',
    this.motion = false,
    this.night = false,
    this.alarms = false,
  });

  final bool pin;
  final bool osPinning;

  /// 0 for off, else one of the fixed choices (1, 5, 15).
  final int dimMinutes;

  /// From 2.9 (wall-tablet-2.9.md §11): what the idle screen shows (dim,
  /// clock, readings, black), and whether wake on motion, the night
  /// schedule and alarm takeover are on.
  final String idleShow;
  final bool motion;
  final bool night;
  final bool alarms;

  @override
  String get name => 'feature_used';

  @override
  Map<String, String> get props => {
    'feature': 'kiosk',
    'lock': pin ? 'pin' : 'none',
    'os_pin': osPinning ? 'yes' : 'no',
    'dim': dimMinutes == 0 ? 'off' : '${dimMinutes}m',
    'idle_show': idleShow,
    'motion': motion ? 'yes' : 'no',
    'night': night ? 'yes' : 'no',
    'alarms': alarms ? 'yes' : 'no',
  };
}

/// Alarm takeover showed on a wall display (2.9): only the kind of alarm,
/// never the device.
class AlarmShown extends AnalyticsEvent {
  const AlarmShown(this.kind);

  /// leak, smoke, gas or co.
  final String kind;

  @override
  String get name => 'alarm_shown';

  @override
  Map<String, String> get props => {'kind': kind};
}

/// Where Get help was opened from (docs/design/support.md §2).
enum HelpFrom {
  noConnection,
  setupError,
  manualConnect,

  /// The manual entry form itself, before any check ran (2.5).
  manualForm,
  homeUnreachable,
  deviceListMissing,
  settings,
  demo,

  /// The one-time community card on a dashboard (community_opened only).
  card,
}

enum ContactVia { email, copy }

/// Get help was opened.
class HelpOpened extends AnalyticsEvent {
  const HelpOpened(this.from);

  final HelpFrom from;

  @override
  String get name => 'help_opened';

  @override
  Map<String, String> get props => {'from': _snake(from.name)};
}

/// The "talk to a person" card was shown (2.9.2): after two failed checks
/// on the broker form. Only where from.
class HelpOffered extends AnalyticsEvent {
  const HelpOffered(this.from);

  final HelpFrom from;

  @override
  String get name => 'help_offered';

  @override
  Map<String, String> get props => {'from': _snake(from.name)};
}

/// The user sent or copied a support request from Get help.
class SupportContact extends AnalyticsEvent {
  const SupportContact(this.from, this.via);

  final HelpFrom from;
  final ContactVia via;

  @override
  String get name => 'support_contact';

  @override
  Map<String, String> get props => {'from': _snake(from.name), 'via': via.name};
}

/// The Telegram community link was opened, from Settings or Get help.
class CommunityOpened extends AnalyticsEvent {
  const CommunityOpened(this.from);

  final HelpFrom from;

  @override
  String get name => 'community_opened';

  @override
  Map<String, String> get props => {'from': _snake(from.name)};
}

/// Where a shortcut lives (docs/design/roadmap-post-2.0.md, 2.1 §7).
enum ShortcutEventKind {
  tile('tile'),
  control('control'),
  widget('widget'),
  sceneWidget('scene_widget'),
  groupWidget('group_widget');

  const ShortcutEventKind(this.wire);

  /// The value sent, and the native side's note key (`shortcut.used.<wire>`).
  final String wire;
}

/// A Quick Settings tile or a home-screen widget was given a device, or
/// Device Controls were first set up.
class ShortcutAdded extends AnalyticsEvent {
  const ShortcutAdded(this.kind);

  final ShortcutEventKind kind;

  @override
  String get name => 'shortcut_added';

  @override
  Map<String, String> get props => {'kind': kind.wire};
}

/// A shortcut was used, sent at most once per app session for each kind.
class ShortcutUsed extends AnalyticsEvent {
  const ShortcutUsed(this.kind);

  final ShortcutEventKind kind;

  @override
  String get name => 'shortcut_used';

  @override
  Map<String, String> get props => {'kind': kind.wire};
}

/// A step of setting alerts up (docs/design/alerts-2.3.md §4).
enum AlertsSetupStep {
  flowInstalled('flow_installed'),
  flowManual('flow_manual'),
  noNodeRed('no_node_red'),
  phoneRegistered('phone_registered'),
  noGoogleServices('no_google_services'),
  testSent('test_sent'),
  testFailed('test_failed');

  const AlertsSetupStep(this.wire);
  final String wire;
}

/// How a Home's alerts reach a phone.
enum AlertsChannel { push, ntfy, pushover }

class AlertsSetup extends AnalyticsEvent {
  const AlertsSetup(this.step, {this.channel = AlertsChannel.push});

  final AlertsSetupStep step;
  final AlertsChannel channel;

  @override
  String get name => 'alerts_setup';

  @override
  Map<String, String> get props => {'step': step.wire, 'channel': channel.name};
}

/// An alert was added: its kind (leak, smoke, opened, battery).
class AlertAdded extends AnalyticsEvent {
  const AlertAdded(this.kind);

  final String kind;

  @override
  String get name => 'alert_added';

  @override
  Map<String, String> get props => {'kind': kind};
}

/// The "What should ZigDash do next?" poll's choices
/// (docs/design/roadmap-post-2.0.md, 2.2 §6).
enum PollChoice {
  notifications('notifications'),
  history('history'),
  kiosk('kiosk'),
  groups('zigbee_groups');

  const PollChoice(this.wire);
  final String wire;
}

/// The one-time poll was answered.
class PollAnswer extends AnalyticsEvent {
  const PollAnswer(this.choice);

  final PollChoice choice;

  @override
  String get name => 'poll_answer';

  @override
  Map<String, String> get props => {'choice': choice.wire};
}

/// What made someone try ZigDash (3.1.10), from the one-time card after
/// setup.
enum WhyChoice {
  faster('faster'),
  family('family'),
  wallTablet('wall_tablet'),
  withoutHa('without_ha'),
  other('other');

  const WhyChoice(this.wire);
  final String wire;
}

/// The one-time "What made you try ZigDash?" card was answered.
class WhyAnswer extends AnalyticsEvent {
  const WhyAnswer(this.choice);

  final WhyChoice choice;

  @override
  String get name => 'why_zigdash';

  @override
  Map<String, String> get props => {'choice': choice.wire};
}

/// What happened when the review prompt policy allowed a request:
/// Play's in-app review dialog was requested, or the review flow was not
/// available on the device (not installed from Play, no Play Services).
enum ReviewPromptResult { requested, unavailable }

/// The local review prompt policy was satisfied (review_prompt_policy.dart).
/// Google gives no signal whether the dialog was then shown or answered, so
/// this is the only way to know the prompt fires at all.
class ReviewPrompted extends AnalyticsEvent {
  const ReviewPrompted(this.result);

  final ReviewPromptResult result;

  @override
  String get name => 'review_prompt';

  @override
  Map<String, String> get props => {'result': result.name};
}

/// What setting up the history recorder ended in (2.7).
enum HistorySetupResult {
  installed,
  updated,
  manual,
  noNodeRed,
  failed,

  /// 2.9.1: no Node-RED, so this device records while ZigDash is open.
  thisDevice,
}

/// The history recorder was set up from a history sheet.
class HistorySetup extends AnalyticsEvent {
  const HistorySetup(this.result);

  final HistorySetupResult result;

  @override
  String get name => 'history_setup';

  @override
  Map<String, String> get props => {'result': _snake(result.name)};
}

/// A step of the import from Home Assistant (2.8): the offer after setup
/// answered, a read that failed (with why), the preview, or the import
/// done. Counts only, in buckets; never an address, a name or the token.
enum HaImportStep {
  offerAccepted,
  offerDeclined,
  failed,
  preview,
  imported,

  /// The sign-in at Home Assistant (2.9.7), with [HaImportEvent.method]
  /// and [HaImportEvent.outcome]: every Home Assistant route depends on it.
  signIn,
}

/// How the user signed in: Home Assistant's login page, or a pasted token.
enum HaSignInMethod { page, token }

/// How the sign-in ended.
enum HaSignInOutcome { ok, cancelled, refused, failed }

class HaImportEvent extends AnalyticsEvent {
  const HaImportEvent(
    this.step, {
    this.error,
    this.devices,
    this.rooms,
    this.renamed,
    this.dashboards,
    this.zhaOnly,
    this.method,
    this.outcome,
  });

  final HaImportStep step;
  final HaSignInMethod? method;
  final HaSignInOutcome? outcome;

  /// Why the read failed (an `HaImportProblem`), on [HaImportStep.failed].
  final Enum? error;
  final int? devices;
  final int? rooms;
  final int? renamed;
  final int? dashboards;
  final bool? zhaOnly;

  @override
  String get name => 'ha_import';

  @override
  Map<String, String> get props {
    String count(int n) =>
        bucket(n, const [0], ranges: const [(1, 5), (6, 20)], top: '21+');
    return {
      'step': _snake(step.name),
      if (error != null) 'error': _snake(error!.name),
      if (devices != null) 'devices': count(devices!),
      if (rooms != null) 'rooms': count(rooms!),
      if (renamed != null) 'renamed': count(renamed!),
      if (dashboards != null) 'dashboards': count(dashboards!),
      if (zhaOnly != null) 'zha_only': zhaOnly! ? 'yes' : 'no',
      if (method != null) 'method': method!.name,
      if (outcome != null) 'outcome': outcome!.name,
    };
  }
}

/// A step of ZigDash Pro in the Play build (2.7): a locked view was shown,
/// the Pro screen opened (2.9.6), Unlock was tapped, or Play reported Pro
/// unlocked afterwards. Nothing about the payment.
enum ProStep { lockedShown, screenShown, unlockTapped, unlocked }

class ProEvent extends AnalyticsEvent {
  const ProEvent(this.step);

  final ProStep step;

  @override
  String get name => 'pro';

  @override
  Map<String, String> get props => {'step': _snake(step.name)};
}

/// [n] as a coarse label: an exact value from [exact], a "lo-hi" range from
/// [ranges], else [top].
String bucket(
  int n,
  List<int> exact, {
  List<(int, int)> ranges = const [],
  required String top,
}) {
  if (exact.contains(n)) return '$n';
  for (final (lo, hi) in ranges) {
    if (n >= lo && n <= hi) return '$lo-$hi';
  }
  return top;
}

String _snake(String camel) =>
    camel.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

/// The ZigDash Engine on the hub (3.0, zigdash-3.0.md §2): a step of
/// putting it there or of its health as the app saw it. Never an address;
/// Zigbee2MQTT's version as major.minor only.
enum EngineStep {
  offered,
  installed,
  consentShown,
  consented,
  declined,
  tooOld,
  failed,
  removed,
  startedAgain,
  seenPaused,
  seenStopped,
}

/// Which screen led to the Engine: Automations, Alerts or History.
enum EngineFrom { automations, alerts, history }

class EngineEvent extends AnalyticsEvent {
  const EngineEvent(this.step, {this.z2m, this.from = EngineFrom.automations});

  final EngineStep step;

  /// Zigbee2MQTT's version string; reported as "major.minor".
  final String? z2m;
  final EngineFrom from;

  @override
  String get name => 'engine_setup';

  @override
  Map<String, String> get props => {
        'step': _snake(step.name),
        'from': from.name,
        if (z2mMinor(z2m) != null) 'z2m': z2mMinor(z2m)!,
      };
}

/// "2.14.1" → "2.14"; null when unreadable.
String? z2mMinor(String? version) {
  final m = RegExp(r'^(\d+)\.(\d+)').firstMatch(version ?? '');
  return m == null ? null : '${m[1]}.${m[2]}';
}

/// An Automation was saved (3.0): its shape, never a device, a name or a
/// time.
class AutomationSaved extends AnalyticsEvent {
  const AutomationSaved({
    required this.trigger,
    required this.conditions,
    required this.action,
    required this.offAfter,
    required this.isNew,
    required this.homeCount,
  });

  /// device_state, device_action, device_reading, clock or sun.
  final String trigger;
  final int conditions;

  /// device or scene.
  final String action;
  final bool offAfter;
  final bool isNew;

  /// How many Automations the Home has after saving.
  final int homeCount;

  @override
  String get name => 'automation_saved';

  @override
  Map<String, String> get props => {
        'trigger': trigger,
        'conditions': bucket(conditions, const [0, 1], top: '2+'),
        'action': action,
        'off_after': offAfter ? 'yes' : 'no',
        'new': isNew ? 'yes' : 'no',
        'count': bucket(homeCount, const [1, 2, 3], ranges: const [(4, 10)], top: '11+'),
      };
}

/// "Share this home" (3.1.7): a phone showed its code, another joined, and
/// whether the dashboards arrived. Never the home, the address or a login.
enum HomeShareStep { codeShown, joined, dashboardsImported, dashboardsMissing }

class HomeShareEvent extends AnalyticsEvent {
  const HomeShareEvent(this.step);

  final HomeShareStep step;

  @override
  String get name => 'home_share';

  @override
  Map<String, String> get props => {'step': _snake(step.name)};
}

