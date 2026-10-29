// 3.2 spike: resolve a `.local` name ourselves. Android resolves mDNS names
// on some phones and not others; 65 address checks in 17 days failed on
// exactly that. One DNS query for the A record goes to 224.0.0.251:5353 from
// an ordinary port, which makes it a "legacy unicast" query (RFC 6762 §6.7):
// responders answer straight back to that port, so no multicast lock.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

/// The IPv4 address of [name] (`smhub.local`), or null within [timeout].
Future<InternetAddress?> mdnsLookup(
  String name, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final labels = name.toLowerCase().replaceAll(RegExp(r'\.$'), '').split('.');
  if (labels.length < 2 || labels.last != 'local') return null;
  RawDatagramSocket? socket;
  try {
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    final id = DateTime.now().microsecondsSinceEpoch & 0xffff;
    final query = BytesBuilder()
      ..add([id >> 8, id & 0xff, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0]);
    for (final l in labels) {
      final b = l.codeUnits;
      query
        ..addByte(b.length)
        ..add(b);
    }
    query.add([0, 0, 1, 0x80, 1]); // type A, class IN with the "unicast reply" bit
    final packet = query.toBytes();
    final done = Completer<InternetAddress?>();
    socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final d = socket!.receive();
      if (d == null || done.isCompleted) return;
      final ip = _firstA(d.data, labels);
      if (ip != null) done.complete(ip);
    });
    // Twice: a single UDP packet can be lost on busy Wi-Fi.
    socket.send(packet, InternetAddress('224.0.0.251'), 5353);
    Timer(const Duration(milliseconds: 400), () {
      if (!done.isCompleted) socket?.send(packet, InternetAddress('224.0.0.251'), 5353);
    });
    return await done.future.timeout(timeout, onTimeout: () => null);
  } catch (_) {
    return null;
  } finally {
    socket?.close();
  }
}

/// The first A record for [labels] in a DNS response, or null.
InternetAddress? _firstA(Uint8List m, List<String> labels) {
  if (m.length < 12) return null;
  final qd = (m[4] << 8) | m[5];
  // Answers, authority and additional records: some responders put the A
  // record in the additional section.
  final an = ((m[6] << 8) | m[7]) + ((m[8] << 8) | m[9]) + ((m[10] << 8) | m[11]);
  var o = 12;
  (String, int)? readName(int at) {
    final parts = <String>[];
    var p = at, end = -1, jumps = 0;
    while (p < m.length) {
      final len = m[p];
      if (len == 0) { p++; break; }
      if (len & 0xc0 == 0xc0) {
        if (p + 1 >= m.length || ++jumps > 10) return null;
        if (end < 0) end = p + 2;
        p = ((len & 0x3f) << 8) | m[p + 1];
        continue;
      }
      if (p + 1 + len > m.length) return null;
      parts.add(String.fromCharCodes(m.sublist(p + 1, p + 1 + len)).toLowerCase());
      p += 1 + len;
    }
    return (parts.join('.'), end < 0 ? p : end);
  }
  for (var i = 0; i < qd; i++) {
    final n = readName(o);
    if (n == null) return null;
    o = n.$2 + 4;
  }
  final want = labels.join('.');
  for (var i = 0; i < an && o < m.length; i++) {
    final n = readName(o);
    if (n == null || n.$2 + 10 > m.length) return null;
    o = n.$2;
    final type = (m[o] << 8) | m[o + 1];
    final rdlen = (m[o + 8] << 8) | m[o + 9];
    o += 10;
    if (type == 1 && rdlen == 4 && n.$1 == want && o + 4 <= m.length) {
      return InternetAddress.fromRawAddress(m.sublist(o, o + 4));
    }
    o += rdlen;
  }
  return null;
}
