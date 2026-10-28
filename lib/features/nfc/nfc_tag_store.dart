import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'nfc_tags.dart';

/// The tags this phone wrote, newest first (3.3). NfcTagActivity reads
/// [nfcTagsKey] to skip a tag that is off, and writes `nfc.tap.<serial>`.
const nfcTagsKey = 'nfc.tags';
String nfcTapKey(String serial) => 'nfc.tap.$serial';

class NfcTagRecord {
  const NfcTagRecord({
    required this.serial,
    required this.connectionId,
    required this.action,
    required this.target,
    required this.label,
    required this.writtenAt,
    this.off = false,
  });

  /// The tag's own serial number (hex), read when it was written.
  final String serial;
  final String connectionId;
  final NfcTagAction action;
  final String target;
  final String label;
  final DateTime writtenAt;
  final bool off;

  NfcTagRecord copyWith({bool? off}) => NfcTagRecord(
    serial: serial,
    connectionId: connectionId,
    action: action,
    target: target,
    label: label,
    writtenAt: writtenAt,
    off: off ?? this.off,
  );

  Map<String, Object?> toJson() => {
    'serial': serial,
    'home': connectionId,
    'action': action.name,
    'target': target,
    'label': label,
    'writtenAt': writtenAt.millisecondsSinceEpoch,
    'off': off,
  };

  static NfcTagRecord? fromJson(Object? j) {
    if (j is! Map) return null;
    final action = NfcTagAction.values
        .where((a) => a.name == j['action'])
        .firstOrNull;
    if (j['serial'] is! String ||
        j['home'] is! String ||
        j['target'] is! String ||
        action == null) {
      return null;
    }
    return NfcTagRecord(
      serial: j['serial'] as String,
      connectionId: j['home'] as String,
      action: action,
      target: j['target'] as String,
      label: (j['label'] as String?) ?? '',
      writtenAt: DateTime.fromMillisecondsSinceEpoch(
        (j['writtenAt'] as int?) ?? 0,
      ),
      off: j['off'] == true,
    );
  }
}

class NfcTagStore {
  NfcTagStore(this._prefs);

  final SharedPreferences _prefs;

  List<NfcTagRecord> all() {
    final raw = _prefs.getString(nfcTagsKey);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      return [for (final j in list) ?NfcTagRecord.fromJson(j)];
    } on FormatException {
      return const [];
    }
  }

  List<NfcTagRecord> ofHome(String connectionId) => [
    for (final t in all())
      if (t.connectionId == connectionId) t,
  ];

  Future<void> _save(List<NfcTagRecord> tags) => _prefs.setString(
    nfcTagsKey,
    jsonEncode([for (final t in tags) t.toJson()]),
  );

  /// A tag written now; a tag written again keeps one entry, the new one.
  Future<void> written(NfcTagRecord tag) => _save([
    tag,
    for (final t in all())
      if (t.serial != tag.serial) t,
  ]);

  Future<void> setOff(String serial, bool off) => _save([
    for (final t in all()) t.serial == serial ? t.copyWith(off: off) : t,
  ]);

  Future<void> forget(String serial) async {
    await _save([
      for (final t in all())
        if (t.serial != serial) t,
    ]);
    await _prefs.remove(nfcTapKey(serial));
  }

  /// When the tag was last tapped; the tap is written by Android outside
  /// the app, so read after [SharedPreferences.reload].
  DateTime? lastTap(String serial) {
    final ms = int.tryParse(_prefs.getString(nfcTapKey(serial)) ?? '');
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }
}

final nfcTagStoreProvider = Provider<NfcTagStore>(
  (ref) => NfcTagStore(ref.watch(sharedPreferencesProvider)),
);
