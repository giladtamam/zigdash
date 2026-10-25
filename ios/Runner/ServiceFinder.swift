import Foundation

/// Finds services on the home network by DNS-SD, like ServiceFinder.kt on
/// Android: Home Assistant announces itself as `_home-assistant._tcp`, with
/// its addresses in the TXT record, so this works where a `.local` name
/// doesn't. Each service is resolved to an IP; the type must be listed
/// under NSBonjourServices in Info.plist.
final class ServiceFinder: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
  private let browser = NetServiceBrowser()
  private var resolving: [NetService] = []
  private var found: [[String: Any]] = []
  private var done: (([[String: Any]]) -> Void)?

  /// The services of [type] found within [timeoutMs]; never fails.
  func find(type: String, timeoutMs: Int, done: @escaping ([[String: Any]]) -> Void) {
    self.done = done
    browser.delegate = self
    browser.searchForServices(ofType: type.hasSuffix(".") ? type : "\(type).", inDomain: "local.")
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(timeoutMs)) { [self] in
      finish()
    }
  }

  private func finish() {
    guard let done else { return }
    self.done = nil
    browser.stop()
    resolving.forEach { $0.stop() }
    resolving.removeAll()
    var seen = Set<String>()
    done(found.filter { seen.insert("\($0["host"] ?? ""):\($0["port"] ?? "")").inserted })
  }

  func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
    resolving.append(service)
    service.delegate = self
    service.resolve(withTimeout: 2)
  }

  func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
    finish()
  }

  func netServiceDidResolveAddress(_ sender: NetService) {
    guard done != nil, let host = ipv4(sender) ?? sender.hostName else { return }
    var txt: [String: String] = [:]
    if let data = sender.txtRecordData() {
      for (k, v) in NetService.dictionary(fromTXTRecord: data) {
        txt[k] = String(data: v, encoding: .utf8)
      }
    }
    found.append(["name": sender.name, "host": host, "port": sender.port, "txt": txt])
  }

  /// An IPv4 address when there is one: easier to type and to read.
  private func ipv4(_ service: NetService) -> String? {
    for data in service.addresses ?? [] {
      let ip: String? = data.withUnsafeBytes { raw in
        guard let sa = raw.baseAddress?.assumingMemoryBound(to: sockaddr.self),
              sa.pointee.sa_family == sa_family_t(AF_INET) else { return nil }
        var addr = raw.baseAddress!.assumingMemoryBound(to: sockaddr_in.self).pointee.sin_addr
        var buf = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
        return inet_ntop(AF_INET, &addr, &buf, socklen_t(INET_ADDRSTRLEN)).map { _ in String(cString: buf) }
      }
      if let ip { return ip }
    }
    return nil
  }
}
