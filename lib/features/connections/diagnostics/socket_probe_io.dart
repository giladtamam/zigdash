import 'dart:io';

Future<List<String>> hostLookup(String host) async {
  final list = await InternetAddress.lookup(host);
  return list.map((a) => a.address).toList();
}

Future<void> tcpProbe(String host, int port, Duration timeout) async {
  final sock = await Socket.connect(host, port, timeout: timeout);
  sock.destroy();
}
