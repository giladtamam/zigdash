import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/features/ha_import/ha_auth.dart';
import 'package:zigdash/features/ha_import/ha_client.dart';
import 'package:zigdash/features/ha_import/ha_import_apply.dart';
import 'package:zigdash/features/ha_import/ha_import_controller.dart';
import 'package:zigdash/features/ha_import/ha_registry.dart';

final _sensor = Z2mDevice(
  friendlyName: '0xa4c13836276df66f',
  type: 'EndDevice',
  ieeeAddress: '0xa4c13836276df66f',
  description: 'Motion sensor',
);

final _registry = HaRegistry.fromLists(
  devices: [
    {
      'id': 'd1',
      'identifiers': [
        ['mqtt', 'zigbee2mqtt_0xa4c13836276df66f'],
      ],
      'name_by_user': 'Living room motion',
      'area_id': 'living_room',
    },
  ],
  areas: [
    {'area_id': 'living_room', 'name': 'Living Room'},
  ],
);

void main() {
  late List<(Uri, String)> reads;
  late List<(bool, Set<String?>)> writes;

  HaImportController controller({
    HaReadResult? result,
    List<Z2mDevice>? devices = const [],
  }) {
    reads = [];
    writes = [];
    return HaImportController(
      address: '192.168.68.52',
      reader: (base, token) async {
        reads.add((base, token));
        return result ?? (registry: _registry, error: null);
      },
      devices: () async => devices == null ? null : [_sensor, ...devices],
      writer: (plan, {required makeDashboards, required skipRooms}) async {
        writes.add((makeDashboards, skipRooms));
        return const HaImportResult(renamed: 1, dashboardIds: ['b'], tiles: 1);
      },
    );
  }

  test('starts on the address, prefilled', () {
    final c = controller();
    expect((c.value as HaImportAsk).address, '192.168.68.52');
  });

  test('reads with the token, previews, applies', () async {
    final c = controller();
    await c.read(' 192.168.68.52 ', ' secret ');
    expect(reads.single.$1.toString(), 'http://192.168.68.52:8123');
    expect(reads.single.$2, 'secret');
    final preview = c.value as HaImportPreview;
    expect(preview.plan.matched, 1);
    c.toggleRoom('Living Room');
    c.setMakeDashboards(false);
    await c.apply();
    expect(writes.single.$1, isFalse);
    expect(writes.single.$2, {'Living Room'});
    expect((c.value as HaImportDone).result.renamed, 1);
  });

  test('the token is never kept in a state', () async {
    final c = controller();
    final seen = <HaImportState>[];
    c.addListener(() => seen.add(c.value));
    await c.read('192.168.68.52', 'secret-token-value');
    for (final s in seen) {
      expect(s.toString(), isNot(contains('secret-token-value')));
      if (s is HaImportAsk) expect(s.address, isNot(contains('secret')));
    }
  });

  test('a refused token goes back to the first step, saying so', () async {
    final c = controller(result: (registry: null, error: HaReadError.badToken));
    await c.read('192.168.68.52', 'wrong');
    final ask = c.value as HaImportAsk;
    expect(ask.problem, HaImportProblem.badToken);
    expect(ask.address, '192.168.68.52');
  });

  test('missing address or token, or a home not connected', () async {
    final c = controller();
    await c.read('', 'x');
    expect((c.value as HaImportAsk).problem, HaImportProblem.noAddress);
    await c.read('192.168.68.52', '  ');
    expect((c.value as HaImportAsk).problem, HaImportProblem.noToken);
    final offline = controller(devices: null);
    await offline.read('192.168.68.52', 'secret');
    expect((offline.value as HaImportAsk).problem, HaImportProblem.noDevices);
    expect(reads, isEmpty, reason: 'Home Assistant is not asked for nothing');
  });

  test('nothing to import cannot be applied', () async {
    final c = controller(
      result: (
        registry: HaRegistry.fromLists(devices: const [], areas: const []),
        error: null,
      ),
    );
    await c.read('192.168.68.52', 'secret');
    expect((c.value as HaImportPreview).empty, isTrue);
    await c.apply();
    expect(writes, isEmpty);
  });

  group('signing in at Home Assistant\'s login page', () {
    late List<HaImportEvent> events;
    late int signIns;
    HaImportController signingIn(
      HaSignInResult result,
      List<String> revoked, {
      HaImportProblem? unreached,
    }) {
      signIns = 0;
      reads = [];
      writes = [];
      events = [];
      return HaImportController(
        address: '192.168.68.52',
        onEvent: events.add,
        reader: (base, token) async {
          reads.add((base, token));
          return (registry: _registry, error: null);
        },
        devices: () async => [_sensor],
        writer: (plan, {required makeDashboards, required skipRooms}) async =>
            const HaImportResult(renamed: 0, dashboardIds: [], tiles: 0),
        signIn: (_) async {
          signIns++;
          return result;
        },
        revoke: (_, refresh) async => revoked.add(refresh),
        reach: (_) async => unreached,
      );
    }

    test('reads with the signed-in token, then signs out', () async {
      final revoked = <String>[];
      final c = signingIn((
        accessToken: 'access',
        refreshToken: 'refresh',
        error: null,
      ), revoked);
      expect(c.canSignIn, isTrue);
      await c.signInAndRead('192.168.68.52');
      expect(reads.single.$2, 'access');
      expect(c.value, isA<HaImportPreview>());
      expect(revoked, ['refresh']);
      expect(events.single.props, {
        'step': 'sign_in',
        'method': 'page',
        'outcome': 'ok',
      });
    });

    test('how the sign-in ended is counted, the token never', () async {
      for (final (error, outcome) in [
        (HaSignInError.cancelled, 'cancelled'),
        (HaSignInError.refused, 'refused'),
        (HaSignInError.failed, 'failed'),
      ]) {
        final c = signingIn((
          accessToken: null,
          refreshToken: null,
          error: error,
        ), []);
        await c.signInAndRead('192.168.68.52');
        expect(events.single.props['outcome'], outcome);
        expect(events.single.props.values.join(), isNot(contains('secret')));
      }
    });

    // 3.2.9: it went back in silence, and one user tapped Sign in six
    // times in two minutes.
    test('closing the login says the sign-in did not finish', () async {
      final c = signingIn((
        accessToken: null,
        refreshToken: null,
        error: HaSignInError.cancelled,
      ), []);
      await c.signInAndRead('192.168.68.52');
      expect(
        (c.value as HaImportAsk).problem,
        HaImportProblem.signInUnfinished,
      );
      expect(reads, isEmpty);
    });

    // 3.2.9: the address is filled in from the broker; when nothing
    // answers there, say so instead of opening an error page.
    test('nothing at the address: said before the browser opens', () async {
      for (final problem in [
        HaImportProblem.unreachable,
        HaImportProblem.certificate,
      ]) {
        final c = signingIn(
          (accessToken: 'access', refreshToken: null, error: null),
          [],
          unreached: problem,
        );
        await c.signInAndRead('192.168.68.64:8123');
        expect(signIns, 0);
        expect((c.value as HaImportAsk).problem, problem);
        expect(events, isEmpty);
      }
    });

    test('a refused sign-in points to the token', () async {
      final c = signingIn((
        accessToken: null,
        refreshToken: null,
        error: HaSignInError.refused,
      ), []);
      await c.signInAndRead('192.168.68.52');
      expect((c.value as HaImportAsk).problem, HaImportProblem.signInRefused);
    });

    test('without a sign-in, only the token way exists', () {
      expect(controller().canSignIn, isFalse);
    });
  });

  test('a pasted token is counted once Home Assistant judged it', () async {
    for (final (result, outcome) in <(HaReadResult, String?)>[
      ((registry: _registry, error: null), 'ok'),
      ((registry: null, error: HaReadError.failed), 'ok'),
      ((registry: null, error: HaReadError.badToken), 'failed'),
      ((registry: null, error: HaReadError.unreachable), null),
    ]) {
      final events = <HaImportEvent>[];
      final c = HaImportController(
        address: '192.168.68.52',
        onEvent: events.add,
        reader: (base, token) async => result,
        devices: () async => [_sensor],
        writer: (plan, {required makeDashboards, required skipRooms}) async =>
            const HaImportResult(renamed: 0, dashboardIds: [], tiles: 0),
      );
      await c.read('192.168.68.52', 'secret');
      expect(
        events.map((e) => e.props['outcome']).toList(),
        outcome == null ? isEmpty : [outcome],
      );
      for (final e in events) {
        expect(e.props['method'], 'token');
        expect(e.props.values.join(), isNot(contains('secret')));
      }
    }
  });
}
