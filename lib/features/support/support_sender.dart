import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where an in-app support message goes (help-and-review-2026-11.md §2): a
/// Cloudflare Worker the developer runs (tool/support-worker/worker.js),
/// which forwards it to the developer's Telegram and keeps nothing.
const supportReceiverUrl = 'https://support.giladha.com/v1/message';

/// How long Send waits before giving up and offering Share.
const supportSendTimeout = Duration(seconds: 8);

/// A message the user typed on Get help, with the Support details the
/// screen built. The email is optional and only ever typed by the user.
class SupportMessage {
  const SupportMessage({
    required this.text,
    required this.details,
    required this.appVersion,
    required this.build,
    required this.locale,
    this.email,
  });

  final String text;
  final String details;
  final String appVersion;
  final String build;
  final String locale;
  final String? email;

  Map<String, Object?> toJson() => {
    'text': text,
    if (email != null && email!.isNotEmpty) 'email': email,
    'details': details,
    'app': appVersion,
    'build': build,
    'locale': locale,
  };

  /// The same message as one text, for the share sheet when Send fails.
  String asText() => [
    text,
    if (email != null && email!.isNotEmpty) 'Reply to: $email',
    '',
    '— Support details —',
    details,
  ].join('\n');
}

/// Posts a [SupportMessage]; true when the receiver accepted it. Any
/// failure, including the receiver's own limits (503), is false: the screen
/// then offers Share, and nothing is retried on its own.
typedef SupportSender = Future<bool> Function(SupportMessage message);

Future<bool> postSupportMessage(SupportMessage message) async {
  final client = HttpClient()..connectionTimeout = supportSendTimeout;
  try {
    final request = await client
        .postUrl(Uri.parse(supportReceiverUrl))
        .timeout(supportSendTimeout);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(message.toJson()));
    final response = await request.close().timeout(supportSendTimeout);
    // Drain so the connection can close cleanly; the body says nothing new.
    await response.drain<void>().timeout(supportSendTimeout);
    return response.statusCode == 200;
  } catch (e) {
    debugPrint('support send failed: $e');
    return false;
  } finally {
    client.close(force: true);
  }
}

/// Swapped for a fake in tests.
final supportSenderProvider = Provider<SupportSender>(
  (_) => postSupportMessage,
);
