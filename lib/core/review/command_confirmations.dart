import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../mqtt/providers/mqtt_manager_provider.dart';

/// Pairs commands the user sent with the state updates that confirm them.
///
/// A Zigbee2MQTT command to `<base>/<device>/set` (or `/set/<attribute>`)
/// is confirmed by the next update on `<base>/<device>`. Other commands are
/// not tracked: the broker echoes a publish back on its own topic, so a
/// custom topic cannot show that a device answered. Only updates within
/// [window] of the command count, and each command confirms once. Topics and
/// times stay in memory; nothing is stored or sent.
class CommandConfirmations {
  CommandConfirmations({this.window = const Duration(seconds: 10)});

  final Duration window;
  final Map<String, DateTime> _pending = {};

  void commandSent(String topic, DateTime at) {
    final state = _stateTopicFor(topic);
    if (state != null) _pending[state] = at;
  }

  /// True when [topic] confirms a pending command.
  bool messageReceived(String topic, DateTime at) {
    final sent = _pending[topic];
    if (sent == null) return false;
    _pending.remove(topic);
    return !at.isBefore(sent) && at.difference(sent) <= window;
  }

  static String? _stateTopicFor(String commandTopic) {
    if (commandTopic.endsWith('/set')) {
      return commandTopic.substring(0, commandTopic.length - 4);
    }
    final i = commandTopic.indexOf('/set/');
    return i > 0 ? commandTopic.substring(0, i) : null;
  }
}

/// Emits the time of each confirmed command on connection [id]: a command
/// the user sent, followed by the device's state update.
final commandConfirmedProvider =
    StreamProvider.autoDispose.family<DateTime, String>((ref, id) async* {
  final manager = await ref.watch(mqttManagerProvider(id).future);
  final confirmations = CommandConfirmations();
  final out = StreamController<DateTime>();
  final sent = manager.commandsSent
      .listen((topic) => confirmations.commandSent(topic, DateTime.now()));
  final received = manager.messages.listen((m) {
    if (confirmations.messageReceived(m.topic, m.receivedAt)) {
      out.add(m.receivedAt);
    }
  });
  ref.onDispose(() {
    sent.cancel();
    received.cancel();
    out.close();
  });
  yield* out.stream;
});
