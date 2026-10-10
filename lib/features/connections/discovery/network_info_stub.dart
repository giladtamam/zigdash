/// Web fallback: no LAN IP introspection in the browser.
Future<String?> wifiIpv4() async => null;

Future<({String name, String ip})?> homeIpv4() async => null;
