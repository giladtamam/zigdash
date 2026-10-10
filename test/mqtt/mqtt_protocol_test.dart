import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_data.dart' as typed;
import 'package:zigdash/mqtt/mqtt_manager.dart';

/// Non-ASCII device names (Hebrew, accented, CJK) end up in Zigbee2MQTT
/// topics; mqtt_client's MQTT 3.1 rules reject them on the way out and
/// mis-measure them on the way in.
void main() {
  setUp(MqttManager.useProtocolRules);

  test('CONNECT still introduces itself as MQTT 3.1 (MQIsdp, 3)', () async {
    final client = MqttServerClient.withPort('127.0.0.1', 'zigdash-test', 1)
      ..logging(on: false)
      ..connectionMessage =
          mc.MqttConnectMessage().withClientIdentifier('zigdash-test');
    try {
      await MqttManager.connectAsV31(client, null, null);
    } catch (_) {
      // Nothing listens on port 1; only the packet matters.
    }
    final header = client.connectionMessage!.variableHeader!;
    expect(header.protocolName, 'MQIsdp');
    expect(header.protocolVersion, 3);
    // Everything else stays on 3.1.1 rules.
    expect(mc.Protocol.version, mc.MqttClientConstants.mqttV311ProtocolVersion);
  });

  test('publishing to a Hebrew topic doesn\'t throw', () {
    final msg = mc.MqttPublishMessage()
        .toTopic('zigbee2mqtt/אור חדר שרות/set')
        .withQos(mc.MqttQos.atLeastOnce)
        .publishData(typed.Uint8Buffer()..addAll('{"state":"ON"}'.codeUnits));
    final buf = mc.MqttByteBuffer(typed.Uint8Buffer());
    expect(() => msg.writeTo(buf), returnsNormally);
  });

  test('a received Hebrew-topic PUBLISH keeps its whole payload', () {
    const topic = 'zigbee2mqtt/תריס חדר שינה 1';
    const payload = '{"position":46}';
    final out = mc.MqttPublishMessage()
        .toTopic(topic)
        .withQos(mc.MqttQos.atMostOnce)
        .publishData(typed.Uint8Buffer()..addAll(payload.codeUnits));
    final buf = mc.MqttByteBuffer(typed.Uint8Buffer());
    out.writeTo(buf);
    buf.reset();
    final back = mc.MqttMessage.createFrom(buf) as mc.MqttPublishMessage;
    expect(back.variableHeader!.topicName, topic);
    expect(String.fromCharCodes(back.payload.message), payload);
  });
}
