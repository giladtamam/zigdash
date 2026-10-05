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
  });

  final FormFactor form;
  final ThemeChoice theme;
  final bool materialYou;
  final int homes;
  final int tiles;
  final bool demo;

  @override
  String get name => 'app_started';

  @override
  Map<String, String> get props => {
        'form': form.name,
        'theme': theme.name,
        'material_you': materialYou ? 'on' : 'off',
        'homes': bucket(homes, const [0, 1], top: '2+'),
        'tiles': bucket(tiles, const [0], ranges: const [(1, 10), (11, 30)],
            top: '31+'),
        'demo': demo ? 'yes' : 'no',
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
}

/// Each step of first-run setup: where people get stuck.
class SetupStep extends AnalyticsEvent {
  const SetupStep(this.step, {this.error, this.devices});

  final SetupStepKind step;

  /// The setup error kind's name, when [step] is failed.
  final Enum? error;

  /// Devices found, at review and complete.
  final int? devices;

  @override
  String get name => 'setup_step';

  @override
  Map<String, String> get props => {
        'step': _snake(step.name),
        if (error != null) 'error': _snake(error!.name),
        if (devices != null)
          'devices': bucket(devices!, const [0],
              ranges: const [(1, 5), (6, 20)], top: '21+'),
      };
}

enum Feature {
  devicesTab,
  devicePage,
  scenes,
  editMode,
  wallDisplay,
  tileAdded,
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

/// [n] as a coarse label: an exact value from [exact], a "lo-hi" range from
/// [ranges], else [top].
String bucket(int n,
    List<int> exact, {List<(int, int)> ranges = const [], required String top}) {
  if (exact.contains(n)) return '$n';
  for (final (lo, hi) in ranges) {
    if (n >= lo && n <= hi) return '$lo-$hi';
  }
  return top;
}

String _snake(String camel) => camel.replaceAllMapped(
    RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');
