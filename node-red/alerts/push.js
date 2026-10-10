// Function node "send". In: one alert event (msg.payload). Out: one HTTP
// request per phone (Web Push, RFC 8291 aes128gcm + VAPID ES256, built-in
// crypto only), plus ntfy and Pushover when set. msg.onlyPhone limits a
// test to one phone.
const cfg = flow.get('cfg');
if (!cfg) return null;
const ev = msg.payload;
const dead = flow.get('dead') || {};
const b64 = s => Buffer.from(s, 'base64url');
const out = [];

const text = () => {
    const key = ev.kind === 'test' ? 'test' : ev.cleared ? ev.kind + 'Cleared' : ev.kind;
    const t = (cfg.text || {})[key] || key;
    return t.replace('{name}', cfg.hideNames ? '' : (ev.name || '')).replace('{home}', ev.home || '')
            .replace('{value}', ev.value === null || ev.value === undefined ? '' : String(ev.value))
            .replace(/\s+/g, ' ').replace(/\(\s*\)/, '').trim();
};

// Web Push to each phone.
if (cfg.vapid && cfg.vapid.privateJwk) {
    const key = crypto.createPrivateKey({ key: cfg.vapid.privateJwk, format: 'jwk' });
    const enc = o => Buffer.from(JSON.stringify(o)).toString('base64url');
    // Signed tokens are kept for a while, per push server and per key: a
    // token signed with an old key pair would be refused ("invalid JWT").
    const jwts = flow.get('jwts') || {};
    const nowS = Math.floor(Date.now() / 1000);
    const jwtFor = origin => {
        const c = jwts[origin + '|' + cfg.vapid.publicKey];
        if (c && c.exp - nowS > 3600) return c.jwt;
        const exp = nowS + 12 * 3600;
        const unsigned = enc({ typ: 'JWT', alg: 'ES256' }) + '.' +
            enc({ aud: origin, exp, sub: 'mailto:alerts@zigdash.app' });
        const sig = crypto.sign('sha256', Buffer.from(unsigned), { key, dsaEncoding: 'ieee-p1363' }).toString('base64url');
        jwts[origin + '|' + cfg.vapid.publicKey] = { jwt: unsigned + '.' + sig, exp };
        return jwts[origin + '|' + cfg.vapid.publicKey].jwt;
    };
    const plain = Buffer.from(JSON.stringify(ev));
    for (const p of cfg.phones || []) {
        if (dead[p.id] || !p.endpoint || !p.p256dh || !p.auth) continue;
        if (msg.onlyPhone && p.id !== msg.onlyPhone) continue;
        const uaPub = b64(p.p256dh), auth = b64(p.auth);
        const ecdh = crypto.createECDH('prime256v1'); ecdh.generateKeys();
        const asPub = ecdh.getPublicKey();
        const secret = ecdh.computeSecret(uaPub);
        const salt = crypto.randomBytes(16);
        const ikm = Buffer.from(crypto.hkdfSync('sha256', secret, auth, Buffer.concat([Buffer.from('WebPush: info\0'), uaPub, asPub]), 32));
        const cek = Buffer.from(crypto.hkdfSync('sha256', ikm, salt, Buffer.from('Content-Encoding: aes128gcm\0'), 16));
        const nonce = Buffer.from(crypto.hkdfSync('sha256', ikm, salt, Buffer.from('Content-Encoding: nonce\0'), 12));
        const c = crypto.createCipheriv('aes-128-gcm', cek, nonce);
        const body = Buffer.concat([c.update(Buffer.concat([plain, Buffer.from([2])])), c.final(), c.getAuthTag()]);
        const rs = Buffer.alloc(4); rs.writeUInt32BE(4096);
        const origin = new URL(p.endpoint).origin;
        out.push({
            url: p.endpoint, method: 'POST', phone: p.id, isTest: ev.kind === 'test',
            headers: { 'Content-Encoding': 'aes128gcm', 'TTL': '86400', 'Urgency': 'high',
                       'Authorization': 'vapid t=' + jwtFor(origin) + ',k=' + cfg.vapid.publicKey },
            payload: Buffer.concat([salt, rs, Buffer.from([65]), asPub, body]),
        });
    }
    flow.set('jwts', jwts);
}

const urgent = ev.kind === 'leak' || ev.kind === 'smoke';
if (cfg.ntfy && cfg.ntfy.topic && !msg.onlyPhone) {
    out.push({
        url: (cfg.ntfy.server || 'https://ntfy.sh').replace(/\/$/, '') + '/' + cfg.ntfy.topic,
        method: 'POST', channel: 'ntfy', isTest: ev.kind === 'test',
        headers: { 'Title': ev.home || 'ZigDash', 'Priority': urgent && !ev.cleared ? '5' : '4', 'Tags': 'zigdash' },
        payload: text(),
    });
}
if (cfg.pushover && cfg.pushover.user && cfg.pushover.token && !msg.onlyPhone) {
    const m = { token: cfg.pushover.token, user: cfg.pushover.user, title: ev.home || 'ZigDash', message: text(),
                priority: urgent && !ev.cleared ? 2 : 1 };
    if (m.priority === 2) { m.retry = 60; m.expire = 3600; }
    out.push({ url: 'https://api.pushover.net/1/messages.json', method: 'POST', channel: 'pushover',
               isTest: ev.kind === 'test', headers: { 'Content-Type': 'application/json' }, payload: m });
}
return [out];
