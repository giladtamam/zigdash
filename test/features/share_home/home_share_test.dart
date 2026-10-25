import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/share_home/home_share.dart';
import 'package:zigdash/features/share_home/join_home_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';

void main() {
  const invite = HomeInvite(
    name: 'בית',
    host: '192.168.68.64',
    port: 1883,
    protocol: MqttProtocol.tcp,
    username: 'mqtt',
    password: 'p@ss w{value}rd',
    code: 'abcdefghjk234567',
  );

  test('a link carries the home and its login, and reads back', () {
    final link = invite.link();
    expect(link, startsWith('zigdash://home/join?c='));
    final back = HomeInvite.fromCode(Uri.parse(link).queryParameters['c'])!;
    expect(back.name, 'בית');
    expect(back.host, '192.168.68.64');
    expect(back.port, 1883);
    expect(back.protocol, MqttProtocol.tcp);
    expect(back.username, 'mqtt');
    expect(back.password, 'p@ss w{value}rd');
    expect(back.code, 'abcdefghjk234567');
    expect(back.dashboardsTopic, 'zigdash/share/abcdefghjk234567');
  });

  test('a broken or foreign code is refused', () {
    expect(HomeInvite.fromCode(null), isNull);
    expect(HomeInvite.fromCode('not-base64!'), isNull);
    expect(HomeInvite.fromCode('eyJ2IjoyfQ'), isNull, reason: 'another version');
  });

  test('codes are fresh and unguessable in length', () {
    final a = newShareCode(), b = newShareCode();
    expect(a, hasLength(16));
    expect(a, isNot(b));
  });

  testWidgets('a damaged code says so, and nothing is added', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [connectionsStreamProvider.overrideWith((ref) => Stream.value(const []))],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: JoinHomeScreen(code: 'broken'),
        ),
      ),
    );
    await tester.pump();
    expect(find.textContaining("isn't a ZigDash home invitation"), findsOneWidget);
    expect(find.byKey(const Key('join-home-add')), findsNothing);
  });

  testWidgets('a valid code asks before adding', (tester) async {
    final c = Uri.parse(invite.link()).queryParameters['c'];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [connectionsStreamProvider.overrideWith((ref) => Stream.value(const []))],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: JoinHomeScreen(code: c),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Add בית to this phone?'), findsOneWidget);
    expect(find.byKey(const Key('join-home-add')), findsOneWidget);
  });
}
