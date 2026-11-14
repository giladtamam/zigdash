import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Chat with your home" early access (docs/design/assistant-early-access.md):
/// the list lives on the support Worker (tool/support-worker/worker.js), and
/// the app talks to it only when the person taps Join.
const earlyAccessUrl = 'https://support.giladha.com/v1/early';
const earlyPriceUrl = 'https://support.giladha.com/v1/early/price';

/// The chat-with-your-home bot; the beta runs on it later.
const earlyBotUrl = 'https://t.me/ZigDashHomeBot';

/// How many on the list get it free for 3 months, if it is built.
const earlyFreePlaces = 20;

const _timeout = Duration(seconds: 8);

/// The Telegram link: one bit says whether this join is counted in the
/// read (the card, with usage data on). No ids.
Uri earlyTelegramLink({required bool counted}) =>
    Uri.parse('$earlyBotUrl?start=${counted ? 'early_c' : 'early_n'}');

/// The Worker's answer to a sign-up: the place on the list, or only
/// [listed] when the address was already there from another phone (the
/// Worker never tells anyone else an address's number).
class EarlyJoin {
  const EarlyJoin({this.position, this.free = false});

  final int? position;
  final bool free;

  bool get listed => position == null;
}

/// Signs [email] up with [nonce], the phone's own random id for this
/// sign-up (also the key for the price answer); null on any failure.
typedef EarlyJoiner =
    Future<EarlyJoin?> Function({
      required String email,
      required String lang,
      required bool counted,
      required String nonce,
    });

/// Sends the price answer ('yes', 'maybe' or 'no'); false on any failure.
typedef EarlyPricer =
    Future<bool> Function({
      required String email,
      required String token,
      required String answer,
    });

Future<(int, String)> _post(String url, Map<String, Object?> body) async {
  final client = HttpClient()..connectionTimeout = _timeout;
  try {
    final request = await client.postUrl(Uri.parse(url)).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close().timeout(_timeout);
    final text = await response
        .transform(utf8.decoder)
        .join()
        .timeout(_timeout);
    return (response.statusCode, text);
  } finally {
    client.close(force: true);
  }
}

/// A fresh random id for one sign-up.
String earlyNonce() {
  final r = Random.secure();
  return List.generate(24, (_) => r.nextInt(16).toRadixString(16)).join();
}

Future<EarlyJoin?> postEarlyJoin({
  required String email,
  required String lang,
  required bool counted,
  required String nonce,
}) async {
  try {
    final (status, text) = await _post(earlyAccessUrl, {
      'email': email,
      'lang': lang,
      'counted': counted,
      'nonce': nonce,
    });
    if (status != 200) return null;
    final j = jsonDecode(text) as Map<String, Object?>;
    final position = j['position'];
    return EarlyJoin(
      position: position is num ? position.toInt() : null,
      free: j['free'] == true,
    );
  } catch (e) {
    debugPrint('early access join failed: $e');
    return null;
  }
}

Future<bool> postEarlyPrice({
  required String email,
  required String token,
  required String answer,
}) async {
  try {
    final (status, _) = await _post(earlyPriceUrl, {
      'email': email,
      'token': token,
      'answer': answer,
    });
    return status == 200;
  } catch (e) {
    debugPrint('early access price failed: $e');
    return false;
  }
}

/// Swapped for fakes in tests.
final earlyJoinerProvider = Provider<EarlyJoiner>((_) => postEarlyJoin);
final earlyPricerProvider = Provider<EarlyPricer>((_) => postEarlyPrice);
