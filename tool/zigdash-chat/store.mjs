// What the service keeps between restarts.
//
// Bindings (one per linked chat): in the encrypted keys file (keystore.mjs),
// one entry each, keyed "<home_id>.<client_id>" (milestone 1's entries keep
// their own key, e.g. "tg1"):
//   {client_id, home_id, chat_id, telegram_name, scope, token, key,
//    request_topic, answer_topic, linked_at}
// The state file (plain JSON, mode 600, no chat ids, names or keys): this
// month's message counts per Home and the model spend, each binding's last
// use, and ACL removals still to retry.

import fs from 'node:fs';
import { readKeys, writeKeys, writePrivate } from './keystore.mjs';

const month = (now) => new Date(now).toISOString().slice(0, 7);

export function makeBindings(file, serviceKey) {
  let stamp = null;
  let cached = { clients: {} };
  const read = () => {
    let st = null;
    try { st = fs.statSync(file); } catch { /* none yet */ }
    const now = st ? `${st.mtimeMs}:${st.size}` : 'none';
    if (now !== stamp) {
      cached = st ? readKeys(file, serviceKey) : { clients: {} };
      stamp = now;
    }
    return cached;
  };
  const view = (id, e) => ({ ...e, id, client_id: e.client_id || id });
  return {
    /** Every binding, read again whenever the file changes (the CLI writes it too). */
    list: () => Object.entries(read().clients).map(([id, e]) => view(id, e)),
    byChat(chatId) { return this.list().find((b) => b.chat_id !== undefined && b.chat_id !== null && String(b.chat_id) === String(chatId)) || null; },
    byClient(homeId, clientId) { return this.list().find((b) => b.home_id === homeId && b.client_id === clientId) || null; },
    forHome(homeId) { return this.list().filter((b) => b.home_id === homeId); },
    add(entry) {
      const data = readKeys(file, serviceKey);
      const id = `${entry.home_id}.${entry.client_id}`;
      data.clients[id] = entry;
      writeKeys(file, serviceKey, data);
      stamp = null;
      return id;
    },
    remove(id) {
      const data = readKeys(file, serviceKey);
      if (!data.clients[id]) return false;
      delete data.clients[id];
      writeKeys(file, serviceKey, data);
      stamp = null;
      return true;
    },
  };
}

export function makeState(file, { now = Date.now } = {}) {
  let s = { v: 1, month: month(now()), homes: {}, cost_usd: 0, last_used: {}, acl_retry: [] };
  try {
    const saved = JSON.parse(fs.readFileSync(file, 'utf8'));
    if (saved && saved.v === 1) s = { ...s, ...saved };
  } catch { /* none yet */ }
  const save = () => writePrivate(file, `${JSON.stringify(s)}\n`);
  const roll = () => {
    const m = month(now());
    if (s.month !== m) { s.month = m; s.homes = {}; s.cost_usd = 0; }
  };
  return {
    messages(homeId) { roll(); return s.homes[homeId] || 0; },
    spent() { roll(); return s.cost_usd; },
    /** One message from a Home, and what the model cost for it. */
    note(homeId, bindingId, costUsd) {
      roll();
      s.homes[homeId] = (s.homes[homeId] || 0) + 1;
      s.cost_usd = Math.round((s.cost_usd + (costUsd || 0)) * 1e6) / 1e6;
      s.last_used[bindingId] = now();
      save();
    },
    lastUsed: (bindingId) => s.last_used[bindingId] || null,
    forget(bindingId) { delete s.last_used[bindingId]; save(); },
    retries: () => [...s.acl_retry],
    setRetries(list) { s.acl_retry = list; save(); },
  };
}
