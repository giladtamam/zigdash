import '../../mqtt/connection_failure.dart';
import '../connections/diagnostics/connect_diagnostics.dart';
import '../onboarding/setup/setup_error_guidance.dart';

export '../../mqtt/connection_failure.dart';

/// The shape of a broker address, so a support request shows what kind of
/// address was used without showing the address (docs/design/support.md §4).
enum AddressShape {
  private192,
  private10,
  private172,
  publicAddress,
  hostName,
  dotLocal,
}

AddressShape addressShape(String host) {
  final h = host.trim().toLowerCase();
  final parts = h.split('.');
  final isIpv4 =
      parts.length == 4 && parts.every((p) => int.tryParse(p) != null);
  if (!isIpv4) {
    return h.endsWith('.local') ? AddressShape.dotLocal : AddressShape.hostName;
  }
  final a = int.parse(parts[0]), b = int.parse(parts[1]);
  if (a == 192 && b == 168) return AddressShape.private192;
  if (a == 10) return AddressShape.private10;
  if (a == 172 && b >= 16 && b <= 31) return AddressShape.private172;
  return AddressShape.publicAddress;
}

String addressShapeLabel(AddressShape shape) => switch (shape) {
      AddressShape.private192 => 'private address in 192.168.x',
      AddressShape.private10 => 'private address in 10.x',
      AddressShape.private172 => 'private address in 172.16–31.x',
      AddressShape.publicAddress => 'public address',
      AddressShape.hostName => 'host name',
      AddressShape.dotLocal => '.local name',
    };

FailureKind failureKindFromSetup(SetupErrorKind kind) => switch (kind) {
      SetupErrorKind.hostUnreachable => FailureKind.unreachable,
      SetupErrorKind.portClosed => FailureKind.refused,
      SetupErrorKind.authRequired => FailureKind.loginRequired,
      SetupErrorKind.authRejected => FailureKind.loginRejected,
      SetupErrorKind.notZigbee2Mqtt => FailureKind.noZigbee2mqtt,
      SetupErrorKind.noDevices => FailureKind.noDevices,
      SetupErrorKind.scanFailed => FailureKind.noLocalNetwork,
      SetupErrorKind.saveFailed => FailureKind.saveFailed,
      SetupErrorKind.unknown => FailureKind.unknown,
    };

/// The kind of a failed guided-connect check, from its first failed step.
FailureKind failureKindFromLadder(DiagnosticsReport report) {
  for (final s in report.steps) {
    if (s.status != StepStatus.fail) continue;
    return switch (s.detailKey) {
      'diagResolveFail' || 'diagResolveTimeout' => FailureKind.hostNotFound,
      'diagTcpTimeout' => FailureKind.timedOut,
      'diagTcpFail' => FailureKind.refused,
      'diagConnackFail' => FailureKind.notMqtt,
      'diagAuthRejected' || 'diagAuthRefused' => FailureKind.loginRejected,
      _ => FailureKind.unknown,
    };
  }
  return FailureKind.unknown;
}

/// The kind of network an interface is on; never its name.
String? networkOfInterface(String? name) {
  if (name == null) return null;
  if (name.startsWith('wlan')) return 'Wi-Fi';
  if (name.startsWith('eth') || name.startsWith('en')) return 'Ethernet';
  return 'other';
}

/// What the last broker scan tried.
class ScanSummary {
  const ScanSummary({
    required this.widened,
    required this.hostsTried,
    required this.brokersFound,
    this.network,
  });

  /// True when the scan went on from the /24 to the surrounding /22.
  final bool widened;
  final int hostsTried;
  final int brokersFound;

  /// "Wi-Fi", "Ethernet" or "other".
  final String? network;

  Map<String, Object?> toJson() => {
        'widened': widened,
        'hostsTried': hostsTried,
        'brokersFound': brokersFound,
        'network': network,
      };

  factory ScanSummary.fromJson(Map<String, Object?> j) => ScanSummary(
        widened: j['widened'] == true,
        hostsTried: (j['hostsTried'] as num?)?.toInt() ?? 0,
        brokersFound: (j['brokersFound'] as num?)?.toInt() ?? 0,
        network: j['network'] as String?,
      );

  String get label => [
        widened ? '/24 then /22' : '/24',
        '${_thousands(hostsTried)} hosts tried',
        '$brokersFound ${brokersFound == 1 ? 'broker' : 'brokers'}',
        if (network != null) network!,
      ].join(' · ');

  @override
  bool operator ==(Object other) =>
      other is ScanSummary &&
      other.widened == widened &&
      other.hostsTried == hostsTried &&
      other.brokersFound == brokersFound &&
      other.network == network;

  @override
  int get hashCode => Object.hash(widened, hostsTried, brokersFound, network);
}

class ConnectionFacts {
  const ConnectionFacts({
    required this.remote,
    required this.protocol,
    required this.port,
    required this.shape,
  });

  final bool remote;
  final String protocol;
  final int port;
  final AddressShape shape;
}

class Z2mFacts {
  const Z2mFacts({this.version, this.online, this.devices});

  final String? version;
  final bool? online;
  final int? devices;
}

/// The snapshot added to a support request (CONTEXT.md: Support details).
/// Always English; holds no addresses, usernames or names by construction.
class SupportDetails {
  const SupportDetails({
    required this.appVersion,
    required this.build,
    required this.openedFrom,
    this.android,
    this.phone,
    this.connection,
    this.z2m,
    this.lastFailure,
    this.lastScan,
  });

  final String appVersion;
  final String build;
  final String openedFrom;
  final String? android;
  final String? phone;
  final ConnectionFacts? connection;
  final Z2mFacts? z2m;
  final FailureKind? lastFailure;
  final ScanSummary? lastScan;

  String format() {
    final c = connection;
    final z = z2m;
    return [
      [
        'ZigDash $appVersion ($build)',
        if (android != null) 'Android $android',
        if (phone != null) phone!,
      ].join(' · '),
      'Opened from: $openedFrom',
      'Connection: ${c == null ? 'none' : [
          c.remote ? 'remote' : 'local',
          c.protocol,
          'port ${c.port}',
          addressShapeLabel(c.shape),
        ].join(' · ')}',
      'Zigbee2MQTT: ${z == null || (z.version == null && z.online == null && z.devices == null) ? 'not found' : [
          if (z.version != null) z.version!,
          if (z.online != null) z.online! ? 'bridge online' : 'bridge offline',
          if (z.devices != null) '${z.devices} devices',
        ].join(' · ')}',
      'Last error: ${lastFailure == null ? 'none' : failureKindLabel(lastFailure!)}',
      'Last scan: ${lastScan?.label ?? 'none'}',
    ].join('\n');
  }
}

String _thousands(int n) => n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
