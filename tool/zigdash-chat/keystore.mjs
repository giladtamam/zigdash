// Keys at rest (plan revision 6, "Keys from day one"). Each Chat client's
// token and sealing key live in a keys file encrypted (AES-256-GCM) with a
// service key, which is kept in a separate secrets file. Both files are mode
// 600, outside the container image, and their paths come from the
// environment. Nothing here ever prints a token or a key.

import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const AAD = Buffer.from('zigdash-chat-keys-v1');

export const expandHome = (p) => (p && p.startsWith('~/') ? path.join(os.homedir(), p.slice(2)) : p);

// JSON.parse errors quote the text they failed on: never let a secret reach a message.
function parseJson(file) {
  try { return JSON.parse(fs.readFileSync(file, 'utf8')); } catch { throw new Error(`${file} is not valid JSON`); }
}

function assertPrivate(file) {
  const mode = fs.statSync(file).mode & 0o777;
  if (mode & 0o077) throw new Error(`${file} is readable by others (mode ${mode.toString(8)}): chmod 600 it`);
}

/** Writes [text] to [file] mode 600, atomically (temporary file, then rename). */
export function writePrivate(file, text) {
  fs.mkdirSync(path.dirname(file), { recursive: true, mode: 0o700 });
  const tmp = `${file}.${process.pid}.${crypto.randomBytes(4).toString('hex')}.tmp`;
  fs.writeFileSync(tmp, text, { mode: 0o600 });
  fs.chmodSync(tmp, 0o600);
  fs.renameSync(tmp, file);
  fs.chmodSync(file, 0o600);
}

/** The service key from the secrets file; with [create], makes one when the file is missing. */
export function loadServiceKey(file, { create = false } = {}) {
  if (!fs.existsSync(file)) {
    if (!create) throw new Error(`no secrets file at ${file} (the CLI creates it)`);
    writePrivate(file, `${JSON.stringify({ v: 1, service_key: crypto.randomBytes(32).toString('base64') })}\n`);
  }
  assertPrivate(file);
  const s = parseJson(file);
  const key = Buffer.from(String(s.service_key || ''), 'base64');
  if (s.v !== 1 || key.length !== 32) throw new Error(`${file} has no usable service key`);
  return key;
}

/** {clients: {<id>: {token, key, name, scope, controls, home_id, created_at}}} from the keys file. */
export function readKeys(file, serviceKey) {
  if (!fs.existsSync(file)) return { clients: {} };
  assertPrivate(file);
  const box = parseJson(file);
  if (box.v !== 1) throw new Error(`${file}: unknown format`);
  try {
    const d = crypto.createDecipheriv('aes-256-gcm', serviceKey, Buffer.from(box.iv, 'base64'));
    d.setAAD(AAD);
    d.setAuthTag(Buffer.from(box.tag, 'base64'));
    const plain = Buffer.concat([d.update(Buffer.from(box.data, 'base64')), d.final()]);
    const data = JSON.parse(plain.toString('utf8'));
    return { clients: data.clients || {} };
  } catch {
    throw new Error(`${file} does not open with this service key`);
  }
}

export function writeKeys(file, serviceKey, data) {
  const iv = crypto.randomBytes(12);
  const c = crypto.createCipheriv('aes-256-gcm', serviceKey, iv);
  c.setAAD(AAD);
  const body = Buffer.concat([c.update(Buffer.from(JSON.stringify({ clients: data.clients || {} }))), c.final()]);
  writePrivate(file, `${JSON.stringify({ v: 1, alg: 'aes-256-gcm', iv: iv.toString('base64'), tag: c.getAuthTag().toString('base64'), data: body.toString('base64') })}\n`);
}

/**
 * The keys as the running service sees them: read again whenever the file
 * changes, so a client removed with the CLI stops working without a restart.
 */
export function keyring(file, serviceKey) {
  let stamp = null;
  let cached = { clients: {} };
  return {
    current() {
      let st = null;
      try { st = fs.statSync(file); } catch { /* missing: no clients */ }
      const now = st ? `${st.mtimeMs}:${st.size}` : 'none';
      if (now !== stamp) {
        cached = st ? readKeys(file, serviceKey) : { clients: {} };
        stamp = now;
      }
      return cached;
    },
  };
}

/** A file holding one secret (a bot token, an API key, a password), trimmed. Never logged. */
export function readSecretFile(file) {
  const text = fs.readFileSync(expandHome(file), 'utf8').trim();
  if (!text) throw new Error(`${file} is empty`);
  return text;
}
