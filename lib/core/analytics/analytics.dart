import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:aptabase_flutter/storage_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/providers/settings_controller.dart';
import '../build/store_capture.dart';
import 'analytics_events.dart';

export 'analytics_events.dart';

/// The Aptabase app key, from `--dart-define=ZIGDASH_ANALYTICS_KEY`. Builds
/// without it (F-Droid, local) contain no analytics: the SDK is never
/// started and no consent is asked (ADR 0006).
const analyticsKey = String.fromEnvironment('ZIGDASH_ANALYTICS_KEY');

/// Whether this build can send usage data at all.
final analyticsAvailableProvider =
    Provider<bool>((ref) => analyticsKey.isNotEmpty && !storeCapture);

/// The privacy policy's section listing every event (opened by "What's
/// shared").
final usageDataPolicyUrl = Uri.parse(
    'https://giladtamam.github.io/zigdash/PRIVACY#anonymous-usage-data');

enum AnalyticsConsent { unasked, granted, declined }

const _kConsent = 'analytics_consent';

/// The user's choice, stored as a bool; absent means never asked.
class AnalyticsConsentController extends Notifier<AnalyticsConsent> {
  @override
  AnalyticsConsent build() =>
      switch (ref.read(sharedPreferencesProvider).getBool(_kConsent)) {
        true => AnalyticsConsent.granted,
        false => AnalyticsConsent.declined,
        null => AnalyticsConsent.unasked,
      };

  Future<void> set(bool share) async {
    await ref.read(sharedPreferencesProvider).setBool(_kConsent, share);
    state = share ? AnalyticsConsent.granted : AnalyticsConsent.declined;
  }
}

final analyticsConsentProvider =
    NotifierProvider<AnalyticsConsentController, AnalyticsConsent>(
        AnalyticsConsentController.new);

/// Where events go. Swapped for a fake in tests.
abstract interface class AnalyticsSink {
  /// Starts sending; the first call starts the SDK.
  Future<void> start();

  /// Stops sending and deletes every unsent event.
  Future<void> stop();

  void send(String name, Map<String, String> props);
}

/// Aptabase, with a queue ZigDash owns: the SDK has no off switch once
/// started, so opting out empties the queue and refuses new events.
class AptabaseSink implements AnalyticsSink {
  AptabaseSink(this._key);

  final String _key;
  final _queue = _ConsentQueue();
  bool _initialized = false;

  @override
  Future<void> start() async {
    _queue.enabled = true;
    if (_initialized) return;
    _initialized = true;
    await Aptabase.init(_key, const InitOptions(), _queue);
  }

  @override
  Future<void> stop() async {
    _queue.enabled = false;
    await _queue.clear();
  }

  @override
  void send(String name, Map<String, String> props) {
    if (!_initialized || !_queue.enabled) return;
    Aptabase.instance.trackEvent(name, props);
  }
}

class _ConsentQueue extends StorageManager {
  static const _prefix = 'aptabase_';
  final _events = <String, String>{};
  bool enabled = false;

  @override
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where((k) => k.startsWith(_prefix))) {
      final value = prefs.get(key);
      if (value is String) _events[key] = value;
    }
  }

  @override
  Future<Iterable<MapEntry<String, String>>> getItems(int length) async =>
      enabled ? _events.entries.take(length).toList() : const [];

  @override
  Future<void> addEvent(String key, String event) async {
    if (!enabled) return;
    _events[key] = event;
    await (await SharedPreferences.getInstance()).setString(key, event);
  }

  @override
  Future<void> deleteEvents(Set<String> keys) async {
    _events.removeWhere((k, _) => keys.contains(k));
    final prefs = await SharedPreferences.getInstance();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  Future<void> clear() async {
    _events.clear();
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where((k) => k.startsWith(_prefix))) {
      await prefs.remove(key);
    }
  }
}

final analyticsSinkProvider =
    Provider<AnalyticsSink>((ref) => AptabaseSink(analyticsKey));

/// Records [AnalyticsEvent]s when the build can send and the user opted in;
/// does nothing otherwise. Feature events are sent once per session.
class Analytics {
  Analytics(this._sink, {required this.enabled});

  final AnalyticsSink _sink;
  final bool enabled;
  final _featuresSeen = <Feature>{};

  void track(AnalyticsEvent event) {
    if (!enabled) return;
    if (event is FeatureUsed &&
        event.feature != Feature.tileAdded &&
        !_featuresSeen.add(event.feature)) {
      return;
    }
    _sink.send(event.name, event.props);
  }
}

final analyticsProvider = Provider<Analytics>((ref) {
  final sink = ref.watch(analyticsSinkProvider);
  // A build without a key never touches the SDK or its queue.
  if (!ref.watch(analyticsAvailableProvider)) {
    return Analytics(sink, enabled: false);
  }
  final on = ref.watch(analyticsConsentProvider) == AnalyticsConsent.granted;
  if (on) {
    sink.start();
  } else {
    sink.stop();
  }
  return Analytics(sink, enabled: on);
});
