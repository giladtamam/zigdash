import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:mqtt_client/mqtt_server_client.dart';

Future<void> main() async {
  final client = MqttServerClient.withPort('localhost', 'probe', 1884)
    ..logging(on: false)
    ..keepAlivePeriod = 5
    ..connectTimeoutPeriod = 5000
    ..autoReconnect = false;
  client.setProtocolV311();
  client.connectionMessage = mc.MqttConnectMessage()
      .withClientIdentifier('probe')
      .startClean()
      .withWillQos(mc.MqttQos.atLeastOnce);
  try {
    await client.connect();
    print('state=${client.connectionStatus?.state}');
  } catch (e) {
    print('threw: $e');
  }
}
