import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the assistant answers from (assistant-in-app-2026-11.md §How it
/// works): a Cloudflare Worker the developer runs, which adds the prompt and
/// the knowledge text, calls the model and keeps nothing.
const assistantUrl = 'https://assistant.giladha.com/v1/chat';

/// The first answer may take a while on a cold cache; the tips stay visible
/// underneath meanwhile (plan revision 4: 20 s for the card, 30 s in chat).
const assistantFirstTimeout = Duration(seconds: 20);
const assistantReplyTimeout = Duration(seconds: 30);

/// What the Worker accepts: at most this many turns, each at most this long;
/// the phone trims the oldest turns before sending.
const assistantMaxTurns = 12;
const assistantMaxTurnChars = 1000;

/// One turn of the conversation, the user's or the assistant's.
class AssistantTurn {
  const AssistantTurn.user(this.text) : fromUser = true;
  const AssistantTurn.assistant(this.text) : fromUser = false;

  final String text;
  final bool fromUser;

  Map<String, String> toJson() => {
    'role': fromUser ? 'user' : 'assistant',
    'content': text.length > assistantMaxTurnChars
        ? text.substring(0, assistantMaxTurnChars)
        : text,
  };
}

/// The triage answers the card is built on, as the Worker names them.
class AssistantTriage {
  const AssistantTriage({this.running, this.platform});

  /// 'yes' or 'not_sure'; null when the question was not asked.
  final String? running;
  final String? platform;

  Map<String, String?> toJson() => {'running': running, 'platform': platform};
}

/// Everything one call needs. [turns] is empty for the first answer.
class AssistantRequest {
  const AssistantRequest({
    required this.details,
    required this.triage,
    required this.locale,
    required this.appVersion,
    required this.build,
    this.turns = const [],
  });

  final String details;
  final AssistantTriage triage;
  final String locale;
  final String appVersion;
  final String build;
  final List<AssistantTurn> turns;

  Map<String, Object?> toJson() {
    final kept = turns.length > assistantMaxTurns
        ? turns.sublist(turns.length - assistantMaxTurns)
        : turns;
    return {
      'details': details,
      'triage': triage.toJson(),
      'locale': locale,
      'app': appVersion,
      'build': build,
      'messages': [for (final t in kept) t.toJson()],
    };
  }
}

/// How a call ended. [text] is set on [AssistantOutcome.answered] only.
enum AssistantOutcome {
  answered,

  /// The Worker is over a limit or its budget (503): a person is still
  /// reachable, the assistant is not.
  resting,

  /// The model declined; the card says so and offers a person.
  refused,

  /// No network, a timeout, or the Worker failing.
  failed,
}

class AssistantReply {
  const AssistantReply(this.outcome, {this.text, this.truncated = false});
  final AssistantOutcome outcome;
  final String? text;
  final bool truncated;
}

typedef AssistantCaller =
    Future<AssistantReply> Function(AssistantRequest request, Duration timeout);

Future<AssistantReply> postAssistant(
  AssistantRequest request,
  Duration timeout,
) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final http = await client
        .postUrl(Uri.parse(assistantUrl))
        .timeout(timeout);
    http.headers.contentType = ContentType.json;
    http.write(jsonEncode(request.toJson()));
    final response = await http.close().timeout(timeout);
    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(timeout);
    if (response.statusCode == 503) {
      return const AssistantReply(AssistantOutcome.resting);
    }
    if (response.statusCode != 200) {
      return const AssistantReply(AssistantOutcome.failed);
    }
    final json = jsonDecode(body);
    if (json is! Map) return const AssistantReply(AssistantOutcome.failed);
    if (json['refused'] == true) {
      return const AssistantReply(AssistantOutcome.refused);
    }
    final text = json['text'];
    if (text is! String || text.trim().isEmpty) {
      return const AssistantReply(AssistantOutcome.failed);
    }
    return AssistantReply(
      AssistantOutcome.answered,
      text: text.trim(),
      truncated: json['truncated'] == true,
    );
  } catch (e) {
    debugPrint('assistant call failed: $e');
    return const AssistantReply(AssistantOutcome.failed);
  } finally {
    client.close(force: true);
  }
}

/// Swapped for a fake in tests.
final assistantCallerProvider = Provider<AssistantCaller>(
  (_) => postAssistant,
);
