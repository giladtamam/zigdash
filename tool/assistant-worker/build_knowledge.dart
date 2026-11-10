// Builds the assistant Worker's knowledge text from the app's own strings,
// then stamps worker.js from worker.template.js.
//
// Run from the worktree root (see README.md):
//   ~/development/flutter-3.47.5/bin/dart tool/assistant-worker/build_knowledge.dart
//
// Inputs:  lib/l10n/app_en.arb, facts.md, system_prompt.md, worker.template.js
// Outputs: knowledge.md, worker.js   (both committed; the output is
//          deterministic, so a rebuild without changes is a no-op)
//
// Plain Dart, dart:io and dart:convert only, so it needs no pub get.

import 'dart:convert';
import 'dart:io';

final here = File(Platform.script.toFilePath()).parent;
final root = here.parent.parent;

/// Keys the generated text must not carry: button labels, progress chrome,
/// options of a question, and the Pro sale strings.
const skipKeys = {
  'guideBack', 'guideStep', 'guideNotHelped', 'guideSkipToHelp',
  'guideWhichHa', 'guideWhichZ2m', 'guideWhichSmlight', 'guideWhichNothing',
  'guidedConnect', 'guidedTesting', 'guidedBackToForm', 'guidedBaseTopicHint',
  'haConnectButton', 'haConnectChecking', 'haConnectLooking',
  'haConnectManualLink', 'haConnectWithToken',
  'setupRunningAsk', 'setupRunningYes', 'setupRunningNotYet',
  'setupRunningNotSure', 'setupRunningWhatToGet',
  'noHubRemind', 'noHubRemindSet', 'noHubHaveOne', 'noHubDemoNote',
  'noHubTitle', 'noHubHeadline', 'setupAskNothingSub', 'setupAskSmlightSub',
  'guidedConnectIntro', 'guidedConnectTitle', 'guidedBaseTopic', 'guidedSaveFailed',
  'loginGuidePick', 'loginGuidePi2', 'loginGuidePi3', 'loginGuidePi4', 'loginGuideSmlight3',
  'setupErrUnknownTitle', 'setupErrUnknownBody', 'setupErrSaveFailedTitle', 'setupErrSaveFailedBody',
  'tipFindSetupTitle', 'tipFindSetupBody',
  // Off scope for an assistant that only connects (the prompt says so).
  'tipHowDoITitle', 'tipHowDoIBody', 'tipRenameHomeTitle', 'tipRenameHomeBody',
  'tipDeviceWrongTitle', 'tipDeviceWrongBody',
};

/// ICU placeholders, replaced by something a reader understands.
const placeholders = {
  'host': 'the address',
  'count': 'N',
  'network': 'Wi-Fi',
  'ip': '192.168.1.37',
  'prefix': '192.168.1',
  'renamed': 'N',
  'dashboards': 'N',
};

class Section {
  Section(this.title, this.intro, this.keys);
  final String title;
  final String intro;
  final List<String> keys;
}

void main(List<String> args) {
  final arbPath = args.isNotEmpty ? args.first : '${root.path}/lib/l10n/app_en.arb';
  final arb = (jsonDecode(File(arbPath).readAsStringSync()) as Map<String, dynamic>)
      .map((k, v) => MapEntry(k, v))
    ..removeWhere((k, _) => k.startsWith('@'));
  final strings = <String, String>{
    for (final e in arb.entries)
      if (e.value is String) e.key: e.value as String,
  };
  // The one placeholder that names a button: the "Yes, it runs" answer.
  final dyn = {...placeholders, 'button': strings['setupRunningYes'] ?? 'Yes, it runs'};

  final used = <String>{};
  List<String> claim(Iterable<String> keys) {
    final out = <String>[];
    for (final k in keys) {
      if (skipKeys.contains(k) || used.contains(k) || !strings.containsKey(k)) continue;
      used.add(k);
      out.add(k);
    }
    return out;
  }

  List<String> byPrefix(String prefix, {bool Function(String)? where}) => claim(
        strings.keys.where((k) => k.startsWith(prefix) && (where == null || where(k))),
      );

  bool smlightish(String k) => k.contains('Smlight') || k.contains('Smhub') || k.contains('Slzb');

  // Explicit lists claim first, in the order the guide shows its steps
  // (lib/features/onboarding/setup/setup_guide.dart), then prefix rules.
  final sections = <Section>[
    Section('No hub yet', 'What the "Nothing yet" screen says.', claim([
      'noHubIntro', 'noHubSmhub', 'noHubSmhubBody', 'noHubPi', 'noHubPiBody',
      'noHubHa', 'noHubHaBody', 'noHubRadio', 'setupAskNothingSub',
    ])),
    Section('SMLIGHT notes', 'SMHUB and SLZB specifics.', claim([
      'setupAskSmhubSub', 'setupAskSlzbSub',
      'setupGuideSmlight', 'setupAddressWhereSmlight', 'connHelpSmhubBody',
      'setupNoBrokerSmlightTitle', 'setupNoBrokerSmlightBody', 'setupNotFoundSmlight',
      'diagTcpSmlightClosed', 'setupAuthHintSmlight',
      'loginGuideSmlight1', 'loginGuideSmlight2', 'loginGuideSmlight3',
    ])),
    Section('Empty-scan guide', 'The steps the app walks through when a scan finds nothing, in order.', claim([
      'guideIntro',
      'guideVpnTitle', 'setupVpnHint',
      'guideIsolatedTitle', 'setupIsolatedHint',
      'guideHubTitle', 'setupNoBrokerHaTitle', 'setupNoBrokerHaBody',
      'setupNoBrokerHaDocker', 'setupNoBrokerHaZha',
      'setupNoBrokerZ2mTitle', 'setupNoBrokerZ2mBody',
      'guideWhichTitle',
      'guideHaTitle', 'guideHaBody',
      'guideZhaTitle', 'setupZhaNote',
      'guideRunningTitle', 'setupRunningYesNote', 'setupRunningNotSureNote',
      'guideNotYetTitle', 'setupRunningNotYetNote',
      'guideZ2mPageTitle', 'guideZ2mPageBody', 'setupZ2mPageEntry',
      'guideWiderTitle', 'guideWiderBody',
      'guideAddressTitle', 'setupManualEntryAdvanced',
      'guideHelpTitle', 'guideHelpBody',
      'setupNotFoundHa', 'setupNotFoundPi',
    ])),
    Section('Troubleshooting tips', 'The tips Get help shows, by situation.', byPrefix('tip')),
    Section('Setup errors', 'What each setup error means, in the app\'s words.',
        byPrefix('setupErr', where: (k) => !k.endsWith('Action'))),
    Section('Broker check results', 'What the broker form\'s step-by-step check reports.',
        byPrefix('diag', where: (k) => !smlightish(k) && k != 'diagAuthRejectedHa' && k != 'diagTcpHaNoBroker')),
    Section('Home Assistant', 'Connecting through Home Assistant, and its addresses.', [
      ...claim(['diagTcpHaNoBroker', 'diagAuthRejectedHa', 'setupGuideHa', 'setupAuthHintHa']),
      ...byPrefix('haConnect'),
      ...byPrefix('haWhere'),
      ...claim([
        'haImportAddressHelp', 'haImportUnreachable', 'haImportCertificate',
        'haImportSignInRefused', 'haImportSignInUnfinished', 'haImportZhaOnly',
      ]),
      ...byPrefix('loginGuideHa'),
      ...claim(['connHelpZhaBody']),
    ]),
    Section('Broker form checks', 'Entering broker details by hand: address, port, login.', [
      ...claim(['guidedConnectIntro', 'guidedHostYourPhone', 'guidedHostHa', 'guidedBaseTopic']),
      ...byPrefix('guidedStuck'),
      ...claim(['guidedNoZ2mBody', 'guidedSaveFailed', 'setupGuidePi', 'setupAuthHintPi']),
      ...claim(['loginGuideTitle']),
      ...byPrefix('loginGuidePi'),
      ...claim(['connHelpDockerBody', 'connHelpSameNetwork']),
    ]),
  ];

  final facts = File('${here.path}/facts.md').readAsStringSync().trim();
  final out = StringBuffer()
    ..writeln('# ZigDash knowledge')
    ..writeln()
    ..writeln('Generated by tool/assistant-worker/build_knowledge.dart from lib/l10n/app_en.arb and facts.md. Do not edit; rebuild.')
    ..writeln()
    ..writeln(facts.replaceFirst(RegExp(r'^# .*\n+'), ''))
    ..writeln();

  for (final s in sections) {
    if (s.keys.isEmpty) continue;
    out
      ..writeln('## ${s.title}')
      ..writeln()
      ..writeln(s.intro)
      ..writeln();
    final seen = <String>{};
    for (final k in s.keys) {
      final label = labelOf(k, strings);
      if (label != null && s.keys.contains(label)) continue; // rendered with its label
      final body = bodyOf(k, strings);
      if (buttons.contains(k)) {
        out.writeln('- The button **${clean(strings[k]!, dyn, punctuate: false)}**.');
      } else if (body != null) {
        used.add(body);
        out.writeln('- **${clean(strings[k]!, dyn, punctuate: false)}** — ${clean(strings[body]!, dyn)}');
      } else if (label != null) {
        out.writeln('- **${clean(strings[label]!, dyn, punctuate: false)}** — ${clean(strings[k]!, dyn)}');
      } else if (k.endsWith('Title') || k.endsWith('Ask')) {
        final t = clean(strings[k]!, dyn, punctuate: false);
        if (seen.add(t)) out.writeln('- **$t**');
      } else {
        out.writeln('- ${clean(strings[k]!, dyn)}');
      }
    }
    out.writeln();
  }

  final knowledge = out.toString().trimRight() + '\n';
  final leftover = RegExp(r'\{[^}\s]*\}').allMatches(knowledge).map((m) => m.group(0)).toSet();
  if (leftover.isNotEmpty) {
    stderr.writeln('ICU placeholders left in knowledge.md: $leftover');
    exit(1);
  }
  File('${here.path}/knowledge.md').writeAsStringSync(knowledge);

  // worker.js = template with the prompt + knowledge embedded as one literal.
  final prompt = File('${here.path}/system_prompt.md').readAsStringSync().trim();
  final systemText = '$prompt\n\n$knowledge';
  final template = File('${here.path}/worker.template.js').readAsStringSync();
  const marker = '/*@@SYSTEM_TEXT@@*/';
  if (!template.contains(marker)) {
    stderr.writeln('worker.template.js has no $marker marker');
    exit(1);
  }
  final literal = jsonEncode(systemText)
      .replaceAll(' ', r' ')
      .replaceAll(' ', r' ')
      .replaceAll('</', r'<\/');
  final worker = template
      .replaceFirst(marker, literal)
      .replaceFirst('/*@@SYSTEM_CHARS@@*/', '${systemText.length}')
      .replaceFirst(
        '// worker.template.js: edit this file, then rebuild worker.js.',
        '// GENERATED from worker.template.js by build_knowledge.dart. Do not edit; edit the template and rebuild.',
      );
  File('${here.path}/worker.js').writeAsStringSync(worker);

  final unusedInteresting = strings.keys
      .where((k) => !used.contains(k) && !skipKeys.contains(k) && !k.endsWith('Action'))
      .where((k) => RegExp(r'^(tip|guide|setupErr|setupNotFound|setupRunning|haConnect|haWhere|guidedStuck|diag|loginGuide|setupNoBroker)').hasMatch(k))
      .toList();
  stdout.writeln('knowledge.md: ${knowledge.length} chars (~${knowledge.length ~/ 4} tokens), '
      '${used.length} strings; system text ${systemText.length} chars (~${systemText.length ~/ 4} tokens); '
      'worker.js ${File('${here.path}/worker.js').lengthSync()} bytes');
  if (unusedInteresting.isNotEmpty) {
    stdout.writeln('not used (check the lists): ${unusedInteresting.join(', ')}');
  }
}

/// Keys that name a button, rendered as such.
const buttons = {'setupZ2mPageEntry', 'setupManualEntryAdvanced', 'setupLookWider'};

/// Suffixes that make a key the text under a label: `noHubPi` + `noHubPiBody`,
/// `haWhereHome` + `haWhereHomeHelp`, `setupAskSmhub` + `setupAskSmhubSub`.
const bodySuffixes = ['Body', 'Intro', 'Sub', 'Help'];

/// The body key rendered together with [k], if any (`XTitle` pairs with `XBody`).
String? bodyOf(String k, Map<String, String> strings) {
  final stem = k.endsWith('Title') ? k.substring(0, k.length - 5) : k;
  for (final suffix in bodySuffixes) {
    final b = '$stem$suffix';
    if (b != k && strings.containsKey(b) && !skipKeys.contains(b)) return b;
  }
  return null;
}

/// The label key [k] is the body of, if any.
String? labelOf(String k, Map<String, String> strings) {
  for (final suffix in bodySuffixes) {
    if (!k.endsWith(suffix)) continue;
    final stem = k.substring(0, k.length - suffix.length);
    for (final label in [stem, '${stem}Title']) {
      if (strings.containsKey(label) && !skipKeys.contains(label) && bodyOf(label, strings) == k) {
        return label;
      }
    }
  }
  return null;
}

/// Replaces ICU plurals and placeholders with readable text, and tidies.
String clean(String s, Map<String, String> dyn, {bool punctuate = true}) {
  var t = s;
  // {count, plural, =1{...} other{...}} -> the "other" branch.
  t = t.replaceAllMapped(RegExp(r'\{(\w+),\s*plural,(.*)\}$', dotAll: true), (m) {
    final other = RegExp(r'other\{([^}]*(?:\{[^}]*\}[^}]*)*)\}').firstMatch(m.group(2)!);
    return other?.group(1) ?? m.group(0)!;
  });
  t = t.replaceAllMapped(RegExp(r'\{(\w+)\}'), (m) => dyn[m.group(1)] ?? 'N');
  t = t.replaceAll('…', '...').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (punctuate && t.isNotEmpty && !RegExp(r'[.!?:)"]$').hasMatch(t)) t = '$t.';
  return t;
}
