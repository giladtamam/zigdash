/* ZigDash connect links (docs/design/ha-link.md): the same rules as the
   app's haLinkFromParams and haAddressIn (lib/mqtt/ha_address.dart), so a
   link made here reads the same there. Nothing here sends anything: the
   address stays in the page and in the part of the link after "#". */
(function (root) {
  'use strict';

  var IPV4 = /^\d{1,3}(\.\d{1,3}){3}$/;
  var HOME_SUFFIXES = ['.local', '.lan', '.home', '.internal', '.home.arpa'];
  var HOST_WORD = /^[A-Za-z0-9.-]+(:\d{1,5})?(\/\S*)?$/;
  var DOMAIN_WORD = /^(?:[a-z0-9](?:[a-z0-9-]{0,30}[a-z0-9])?\.)+[a-z]{2,24}$/;
  var LINK = /https?:\/\/[^\s<>"]+/i;

  /* Home Assistant's address in what was typed or pasted: scheme, host and
     port of a link (a login, path or query is dropped), or one word that
     reads as a host. Null otherwise. */
  function cleanAddress(text) {
    text = String(text || '').trim();
    var m = text.match(LINK);
    if (m) {
      var u;
      try { u = new URL(m[0]); } catch (e) { return null; }
      if (!u.hostname || u.hostname.toLowerCase() === 'my.home-assistant.io') return null;
      return u.protocol.toLowerCase() + '//' + u.host;
    }
    if (!text || /\s/.test(text) || text.indexOf('@') >= 0) return null;
    if (!HOST_WORD.test(text)) return null;
    var host = text.split(/[:/]/)[0];
    var lower = host.toLowerCase();
    var known = IPV4.test(host) || host === 'homeassistant' || host === 'localhost' ||
      HOME_SUFFIXES.some(function (s) { return lower.slice(-s.length) === s; }) ||
      DOMAIN_WORD.test(host);
    return known ? text : null;
  }

  /* `ha=…&src=…`, `ha` may repeat. */
  function fromParams(params) {
    var addresses = [];
    var src = 'site';
    String(params || '').split('&').forEach(function (pair) {
      var i = pair.indexOf('=');
      if (i <= 0) return;
      var value;
      try { value = decodeURIComponent(pair.slice(i + 1).replace(/\+/g, ' ')).trim(); } catch (e) { return; }
      var key = pair.slice(0, i);
      if (key === 'ha') {
        var a = cleanAddress(value);
        if (a !== null && addresses.indexOf(a) < 0) addresses.push(a);
      } else if (key === 'src' && value === 'ha_integration') {
        src = 'ha_integration';
      }
    });
    return { addresses: addresses, src: src };
  }

  function toParams(addresses, src) {
    return addresses.map(function (a) { return 'ha=' + encodeURIComponent(a); })
      .concat(['src=' + (src || 'site')]).join('&');
  }

  var api = { cleanAddress: cleanAddress, fromParams: fromParams, toParams: toParams };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.ZigDashLink = api;
})(this);
