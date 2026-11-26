import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/engine/engine_providers.dart';
import 'package:zigdash/features/devices/devices_providers.dart' show homeBaseTopicProvider;
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

// 3.8.8: the Engine's view says whether the Home's broker is connected
// (engine-check-timeout.md).

class _Repo implements ConnectionRepo {
  @override
  Future<Connection?> getById(String id) async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A manager whose connection the test turns on and off; nothing is heard.
class _Manager extends MqttManager {
  _Manager(this._now)
      : super(
          config: const BrokerConfig(id: 'c1', host: 'localhost', port: 1883, protocol: MqttProtocol.tcp),
          password: '',
        );
  MqttStatus _now;
  final _status = StreamController<MqttStatus>.broadcast();

  void set(MqttStatus s) {
    _now = s;
    _status.add(s);
  }

  @override
  MqttStatus get status => _now;
  @override
  Stream<MqttStatus> get status$ => _status.stream;
  @override
  Stream<MqttRxMessage> subscribe(String pattern) => const Stream.empty();
  @override
  void unsubscribe(String pattern) {}
}

void main() {
  late SharedPreferences prefs;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<(ProviderContainer, List<EngineView>)> watch(_Manager mgr) async {
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      connectionRepoProvider.overrideWithValue(_Repo()),
      homeBaseTopicProvider.overrideWith((ref, _) => 'zigbee2mqtt'),
      mqttManagerProvider.overrideWith((ref, _) async => mgr),
    ]);
    addTearDown(container.dispose);
    final views = <EngineView>[];
    container.listen<AsyncValue<EngineView>>(engineViewProvider('c1'), (_, next) {
      final v = next.valueOrNull;
      if (v != null && !next.isLoading) views.add(v);
    }, fireImmediately: true);
    await pumpEventQueue();
    return (container, views);
  }

  test('connected follows the broker, and only a flip emits', () async {
    final mgr = _Manager(MqttStatus.connecting);
    final (_, views) = await watch(mgr);
    expect(views.map((v) => v.connected), [false]);
    mgr.set(MqttStatus.reconnecting);
    await pumpEventQueue();
    expect(views, hasLength(1), reason: 'still not connected: nothing new');
    mgr.set(MqttStatus.connected);
    await pumpEventQueue();
    expect(views.map((v) => v.connected), [false, true]);
    mgr.set(MqttStatus.disconnected);
    await pumpEventQueue();
    expect(views.map((v) => v.connected), [false, true, false]);
  });

  test('a broker already connected starts connected', () async {
    final (_, views) = await watch(_Manager(MqttStatus.connected));
    expect(views.map((v) => v.connected), [true]);
  });
}
