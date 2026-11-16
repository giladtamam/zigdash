// ZigDash Chat, phase 3 (docs/design/chat-linking.md §2): linking from the
// app, and every Telegram update, whichever way it came (webhook or polling).
//
// Linking, step by step:
//   1. The phone, with a fresh ticket from the relay verifier, sends the
//      client's token, key and scope: POST /v1/link. The service checks the
//      ticket and that its two relay topics are the ones the key makes, and
//      answers a link code, L + 6 characters (no "_", so it never collides
//      with early_c / early_n), kept unclaimed 10 minutes, 5 a Home an hour.
//   2. The person opens t.me/<bot>?start=<code>; the first private chat to
//      send it claims it and gets a 4-digit back-code (5 failed claims a chat
//      an hour, then silence).
//   3. The phone sends the back-code: POST /v1/link/confirm. Three wrong
//      codes cancel the claim. Only then does the verifier add the client's
//      two topics to the service's broker role, and the binding is written.
//   A link that is never finished is forgotten when it expires; it never
//   reaches the broker or the keys file.
// Unlinking: DELETE /v1/link/<client_id> with a fresh ticket of that Home, or
// /unlink (with a confirm) from the linked chat. Both delete the binding, its
// token and key and the conversation, and remove the ACL entries.
// /stop always stays the early-access "take me off the list": it is passed to
// the support Worker, and never unlinks. So are /start early_c|early_n, the
// early-access buttons, and anything from a chat that isn't linked.
//
// Founder's passes (docs/design/founders-pass.md): before the model answers a
// linked chat, the verifier says whether its Home is still entitled (cached
// 10 minutes, a "no" 1 minute; unreachable: the last answer, else yes, since
// the broker enforces the end anyway). An ended Home's chat hears once that
// the pass ended (then at most daily) and the model is not called. The
// verifier tells the service (internal port, http.mjs) when a Home changes
// (cache and notices dropped) or is deleted (its links removed, each chat told
// once); a 410 from the status route does the same.

import crypto from 'node:crypto';
import { HomeLink } from './link.mjs';
import { chatTopics, CLIENT_ID_RE } from './wire.mjs';
import { verifyTicket } from './ticket.mjs';
import { errorCode } from './telegram.mjs';

export const CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
export const CODE_RE = /^L[A-HJ-NP-Z2-9]{6}$/;
const LINK_MS = 10 * 60000;
const LINKS_PER_HOUR = 5;
const CLAIMS_PER_HOUR = 5;
const BACK_CODE_TRIES = 3;
const UNLINK_ASK_MS = 60000;
const SEEN_UPDATES = 1000;
const ACL_RETRY_MS = 10 * 60000;
const STATUS_OK_MS = 10 * 60000;
const STATUS_ENDED_MS = 60000;
const STATUS_TIMEOUT_MS = 5000;
const ENDED_REMIND_MS = 24 * 3600000;
const HOME_ID_RE = /^[0-9a-f]{16}$/;

export const LINK_TEXT = {
  backCode: (code) => `Your ZigDash code: ${code}\n\nType it in the app to finish linking. Didn't start this in ZigDash? Ignore this message: nothing is linked without the code.`,
  badCode: "That link code isn't valid any more. Start again in ZigDash.",
  alreadyLinked: 'This Telegram account is already linked to a home. Send /unlink first to link it again.',
  linked: 'Linked! This chat now talks to your home. Ask me something like "is the front door closed?". Send /unlink to remove it.',
  cancelled: 'Linking was cancelled: the code was typed wrong 3 times. Start again in ZigDash.',
  askUnlink: 'Unlink this chat from your home? It stops answering here, and its keys and this conversation are deleted.',
  unlinked: 'Unlinked. This chat no longer reaches your home.',
  unlinkedInApp: 'This chat was unlinked from your home in ZigDash.',
  kept: 'OK, still linked.',
  unlinkExpired: 'That expired. Send /unlink again if you still want it.',
  notLinkedHere: "This chat isn't linked to a home.",
  textOnly: 'I can only read text messages.',
  cap: (cap) => `Your home has used this month's ${cap} Chat messages (free beta). Chat works again on the 1st.`,
  paused: "Chat is paused until the 1st: this month's beta budget is used up. Sorry!",
  passEnded: "This chat was unlinked: the founder's pass ended.",
  ended: (date) => `This Home's founder's pass ended${date ? ` on ${date}` : ''}. ZigDash Pro keeps Chat: open ZigDash to get it.`,
};

const hourAgo = (list, now) => list.filter((t) => now - t < 3600000);
const cleanName = (v) => String(v ?? '').replace(/[\u0000-\u001f\u007f-\u009f\u2028\u2029]/g, ' ').trim().slice(0, 40);
const sameSecret = (a, b) => {
  const x = Buffer.from(String(a || '')), y = Buffer.from(String(b || ''));
  return x.length === y.length && x.length > 0 && crypto.timingSafeEqual(x, y);
};

/** The id the support Worker keeps for a linked chat: never the chat id itself. */
export const linkedId = (secret, chatId) => crypto.createHmac('sha256', secret).update(String(chatId)).digest('hex').slice(0, 32);

/**
 * [deps]: bindings, state (store.mjs), bot (telegram.mjs makeBot), agent
 * (made with onCost from costSink), metrics, mqtt, fetchImpl, now, and config:
 * {transport, botUsername, cap, budgetUsd, ticketSecret, verifier: {url, secret}|null,
 *  worker: {url, secret}|null}.
 */
export function makeChat({ bindings, state, bot, agent, metrics, mqtt, fetchImpl = fetch, now = Date.now, config }) {
  const statuses = new Map(); // home id -> {entitled, ended_at, until}: the verifier's last answer
  const background = new Set(); // work started by the internal routes, for idle()
  const pending = new Map(); // code -> pending link (token and key in memory only)
  const linkTries = new Map(); // home id -> [times]
  const claimFails = new Map(); // chat id -> [times]
  const unlinkAsks = new Map(); // chat id -> expires
  const links = new Map(); // binding id -> { token, key, link }
  const seenUpdates = new Set();
  const seenOrder = [];
  const queues = new Map(); // chat id -> promise: one update at a time per chat
  const costs = new Map(); // chat id -> the model cost of the message being handled
  const timers = [];

  // ---------- helpers ----------

  const say = (chatId, text, markup) => bot.say(chatId, text, markup).catch((e) => console.error(`telegram: send failed (${errorCode(e)})`));

  function sweep() {
    const t = now();
    for (const [code, p] of pending) {
      if (p.expires <= t) { pending.delete(code); metrics.count('link_expired', { claimed: p.chatId ? 1 : 0 }); }
    }
    for (const [chatId, until] of unlinkAsks) if (until <= t) unlinkAsks.delete(chatId);
  }

  const pendingFor = (homeId, clientId) => [...pending.values()].find((p) => p.home_id === homeId && p.client_id === clientId) || null;

  async function post(url, headers, body) {
    const res = await fetchImpl(url, {
      method: 'POST', headers: { 'content-type': 'application/json', ...headers }, body: JSON.stringify(body), signal: AbortSignal.timeout(10000),
    });
    return res.status;
  }

  /**
   * The verifier adds or removes a client's two topics on the service's broker
   * role. Returns its HTTP status (0: unreachable); 402 on an add is final (the
   * Home's founder's pass ended).
   */
  async function acl(op, b) {
    if (!config.verifier) return 200; // at home, on the hub's own broker: nothing to open
    try {
      const status = await post(`${config.verifier.url}/v1/internal/chat-acl`, { 'X-Chat-Acl-Secret': config.verifier.secret },
        { home_id: b.home_id, request_topic: b.request_topic, answer_topic: b.answer_topic, op });
      if (status === 200) return 200;
      metrics.count('acl_error', { status });
      return status;
    } catch (e) {
      metrics.count('acl_error', { status: 0 });
      return 0;
    }
  }

  async function retryAcl() {
    const left = [];
    for (const r of state.retries()) if ((await acl(r.op, r)) !== 200) left.push(r);
    state.setRetries(left);
  }

  // ---------- the Home's status (founder's passes) ----------

  /** Runs [work] after whatever [chatId]'s queue holds, so it never interleaves with a message. */
  function enqueue(chatId, work) {
    const key = String(chatId);
    const run = (queues.get(key) || Promise.resolve())
      .then(work)
      .catch((e) => console.error(`chat: update failed (${errorCode(e)})`));
    queues.set(key, run);
    run.then(() => { if (queues.get(key) === run) queues.delete(key); });
    return run;
  }

  /** Forgets the cached status of [homeId] and the "ended" notices of its chats. */
  function homeChanged(homeId) {
    statuses.delete(homeId);
    state.clearEnded(bindings.forHome(homeId).map((b) => b.id));
    metrics.count('home_changed');
  }

  /** The Home is gone (deleted by the verifier): each of its chats is unlinked and told once. */
  async function homeDeleted(homeId) {
    homeChanged(homeId);
    const all = bindings.forHome(homeId);
    metrics.count('home_deleted', { links: all.length });
    // Each on its chat's queue, so it never interleaves with a message; gone already (an /unlink meanwhile): skipped.
    const remove = (b) => async () => { if (bindings.byClient(b.home_id, b.client_id)) await removeBinding(b, { reason: 'pass_ended' }); };
    await Promise.all(all.map((b) => (b.chat_id !== undefined && b.chat_id !== null ? enqueue(b.chat_id, remove(b)) : remove(b)())));
  }

  /** Starts [work] in the background (the internal routes answer first); idle() waits for it. */
  function later(work) {
    const run = new Promise((r) => setImmediate(r)).then(work).catch((e) => console.error(`chat: background work failed (${errorCode(e)})`));
    background.add(run);
    run.then(() => background.delete(run));
    return run;
  }

  /**
   * The verifier's word on [homeId]: {entitled, ended_at} or {deleted: true}.
   * An unknown Home (404) is no reason to act. Unreachable (timeout, 5xx or
   * anything unexpected): the last answer however old, else entitled.
   */
  async function homeStatus(homeId) {
    if (!config.verifier || !homeId || !HOME_ID_RE.test(homeId)) return { entitled: true, ended_at: null };
    const t = now();
    const have = statuses.get(homeId);
    if (have && have.until > t) return have;
    let status = 0, body = null;
    try {
      const res = await fetchImpl(`${config.verifier.url}/v1/internal/home/${homeId}`, {
        method: 'GET', headers: { 'X-Chat-Acl-Secret': config.verifier.secret }, signal: AbortSignal.timeout(STATUS_TIMEOUT_MS),
      });
      status = res.status;
      if (status === 200) body = await res.json().catch(() => null);
    } catch { status = 0; }
    if (status === 200 && body && typeof body.entitled === 'boolean') {
      const entry = { entitled: body.entitled, ended_at: Number.isFinite(body.ended_at) ? body.ended_at : null, until: t + (body.entitled ? STATUS_OK_MS : STATUS_ENDED_MS) };
      statuses.set(homeId, entry);
      return entry;
    }
    if (status === 410) { metrics.count('home_status', { status }); return { deleted: true }; }
    if (status === 404) {
      metrics.count('home_status', { status });
      const entry = { entitled: true, ended_at: null, until: t + STATUS_OK_MS };
      statuses.set(homeId, entry);
      return entry;
    }
    metrics.count('home_status_error', { status });
    return have || { entitled: true, ended_at: null };
  }

  const endedDate = (ms) => {
    if (!ms) return null;
    try {
      return new Date(ms).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric', timeZone: config.timeZone || undefined });
    } catch {
      return new Date(ms).toISOString().slice(0, 10);
    }
  };

  /**
   * True when [b]'s Home may use the model now. Otherwise it has answered the
   * chat itself: the notice (once, then at most daily), or the unlink of a
   * deleted Home.
   */
  async function mayAnswer(b) {
    const s = await homeStatus(b.home_id);
    if (s.deleted) {
      // This chat now (its queue is running), the Home's other chats on their own queues.
      await removeBinding(b, { reason: 'pass_ended' });
      later(() => homeDeleted(b.home_id));
      return false;
    }
    if (s.entitled) return true;
    metrics.count('pass_ended');
    const last = state.endedNotice(b.id);
    if (!last || now() - last >= ENDED_REMIND_MS) {
      state.noteEnded(b.id);
      await say(b.chat_id, LINK_TEXT.ended(endedDate(s.ended_at)));
    }
    return false;
  }

  /** The support Worker's list of linked chats, for its "paused for maintenance" reply after a rollback. */
  async function syncWorker() {
    if (!config.worker) return;
    const ids = bindings.list().filter((b) => b.chat_id !== undefined && b.chat_id !== null).map((b) => linkedId(config.worker.secret, b.chat_id));
    try {
      const status = await post(`${config.worker.url}/v1/early/linked`, { 'X-ZigDash-Chat-Secret': config.worker.secret }, { ids });
      metrics.count(status === 200 ? 'worker_sync' : 'worker_sync_error', { linked: ids.length, status });
    } catch {
      metrics.count('worker_sync_error', { linked: ids.length, status: 0 });
    }
  }

  /**
   * Early access stays the Worker's: the update goes there with only what its
   * logic reads (chat id and type, language, a command or nothing), never
   * names or free text.
   */
  async function forward(update) {
    if (!config.worker) { metrics.count('ignored'); return; }
    let slim = null;
    if (update.callback_query) {
      const q = update.callback_query;
      slim = { update_id: update.update_id, callback_query: { id: q.id, data: q.data, from: { language_code: q.from?.language_code }, message: { chat: { id: q.message?.chat?.id } } } };
    } else if (update.message) {
      const m = update.message;
      const text = typeof m.text === 'string' && m.text.trim().startsWith('/') ? m.text.trim().slice(0, 64) : '';
      slim = { update_id: update.update_id, message: { chat: { id: m.chat?.id, type: m.chat?.type }, from: { language_code: m.from?.language_code }, text } };
    }
    if (!slim) return;
    try {
      const status = await post(`${config.worker.url}/v1/early/tg`, { 'X-ZigDash-Chat-Secret': config.worker.secret }, slim);
      metrics.count(status === 200 ? 'forwarded' : 'forward_error', { status });
    } catch {
      metrics.count('forward_error', { status: 0 });
    }
  }

  // ---------- the Home's link for a chat ----------

  async function linkFor(chatId) {
    const b = bindings.byChat(chatId);
    if (!b) return null;
    const have = links.get(b.id);
    if (have && have.key === b.key && have.token === b.token) return have.link;
    if (have) have.link.stop();
    const link = new HomeLink({ mqtt, transport: config.transport, homeId: b.home_id, clientId: b.client_id, token: b.token, key: b.key });
    await link.start();
    links.set(b.id, { key: b.key, token: b.token, link });
    return link;
  }

  /** [reason] 'pass_ended': the Home's founder's pass ended and it was deleted; one message says so. */
  async function removeBinding(b, { fromApp = false, reason = null } = {}) {
    bindings.remove(b.id);
    state.forget(b.id);
    const have = links.get(b.id);
    if (have) { have.link.stop(); links.delete(b.id); }
    if (b.chat_id !== undefined && b.chat_id !== null) {
      agent.forget(String(b.chat_id));
      unlinkAsks.delete(String(b.chat_id));
    }
    // Milestone 1's hand-made client has no recorded topics: its role is removed by hand.
    if (b.request_topic && b.answer_topic && (await acl('remove', b)) !== 200) {
      state.setRetries([...state.retries(), { op: 'remove', home_id: b.home_id, request_topic: b.request_topic, answer_topic: b.answer_topic }]);
    }
    metrics.count('unlinked', { from_app: fromApp ? 1 : 0, pass_ended: reason === 'pass_ended' ? 1 : 0 });
    await syncWorker();
    if (b.chat_id !== undefined && b.chat_id !== null) {
      await say(b.chat_id, reason === 'pass_ended' ? LINK_TEXT.passEnded : fromApp ? LINK_TEXT.unlinkedInApp : LINK_TEXT.unlinked);
    }
  }

  // ---------- the HTTP API (http.mjs maps these to routes) ----------

  const ticketOf = (ticket) => {
    const t = verifyTicket(config.ticketSecret, ticket, now());
    return t.error ? { fail: { status: 401, body: { error: t.error } } } : { t: t.payload };
  };

  /** POST /v1/link {ticket, token, key, scope} */
  function createLink(body) {
    sweep();
    const { t, fail } = ticketOf(body && body.ticket);
    if (fail) return fail;
    if (!t.client_id || !CLIENT_ID_RE.test(t.client_id) || !t.request_topic || !t.answer_topic) return { status: 400, body: { error: 'ticket_without_client' } };
    const token = body.token, scope = body.scope;
    const key = typeof body.key === 'string' ? Buffer.from(body.key, 'base64') : Buffer.alloc(0);
    if (typeof token !== 'string' || token.length < 16 || token.length > 256 || key.length !== 32 || !['read', 'control'].includes(scope)) {
      return { status: 400, body: { error: 'bad_body' } };
    }
    const topics = chatTopics({ transport: 'relay', clientId: t.client_id, key, homeId: t.home_id });
    if (topics.req !== t.request_topic || topics.res !== t.answer_topic) return { status: 400, body: { error: 'topics_mismatch' } };
    const tries = hourAgo(linkTries.get(t.home_id) || [], now());
    if (tries.length >= LINKS_PER_HOUR) { linkTries.set(t.home_id, tries); return { status: 429, body: { error: 'too_many' } }; }
    tries.push(now());
    linkTries.set(t.home_id, tries);
    if (bindings.byClient(t.home_id, t.client_id)) return { status: 409, body: { error: 'already_linked' } };
    const old = pendingFor(t.home_id, t.client_id);
    if (old) pending.delete(old.code);
    let code;
    do { code = `L${Array.from({ length: 6 }, () => CODE_ALPHABET[crypto.randomInt(CODE_ALPHABET.length)]).join('')}`; } while (pending.has(code));
    pending.set(code, {
      code, home_id: t.home_id, client_id: t.client_id, request_topic: t.request_topic, answer_topic: t.answer_topic,
      token, key: key.toString('base64'), scope, expires: now() + LINK_MS, chatId: null, telegramName: null, backCode: null, wrong: 0,
    });
    metrics.count('link_created');
    return { status: 200, body: { code, expires_in: LINK_MS / 1000, bot: config.botUsername, url: `https://t.me/${config.botUsername}?start=${code}` } };
  }

  /** POST /v1/link/confirm {ticket, code_back} */
  async function confirmLink(body) {
    sweep();
    const { t, fail } = ticketOf(body && body.ticket);
    if (fail) return fail;
    const p = t.client_id ? pendingFor(t.home_id, t.client_id) : null;
    if (!p) return { status: 404, body: { error: 'unknown_code' } };
    if (!p.chatId) return { status: 409, body: { error: 'not_claimed' } };
    if (!sameSecret(String(body.code_back ?? '').trim(), p.backCode)) {
      p.wrong += 1;
      metrics.count('link_wrong_code', { tries: p.wrong });
      if (p.wrong >= BACK_CODE_TRIES) {
        pending.delete(p.code);
        metrics.count('link_cancelled');
        await say(p.chatId, LINK_TEXT.cancelled);
        return { status: 410, body: { error: 'cancelled' } };
      }
      return { status: 400, body: { error: 'wrong_code', tries_left: BACK_CODE_TRIES - p.wrong } };
    }
    if (bindings.byChat(p.chatId)) { pending.delete(p.code); return { status: 409, body: { error: 'already_linked' } }; }
    // The broker opens these two topics to the service only now.
    const added = await acl('add', p);
    if (added === 402) {
      // The Home's founder's pass ended: final, the link is dropped.
      pending.delete(p.code);
      metrics.count('link_refused', { pass_ended: 1 });
      return { status: 402, body: { error: 'pass_ended' } };
    }
    if (added !== 200) return { status: 503, body: { error: 'try_again' } };
    pending.delete(p.code);
    bindings.add({
      client_id: p.client_id, home_id: p.home_id, chat_id: String(p.chatId), telegram_name: p.telegramName, scope: p.scope,
      token: p.token, key: p.key, request_topic: p.request_topic, answer_topic: p.answer_topic, linked_at: now(),
    });
    metrics.count('link_confirmed', { control: p.scope === 'control' ? 1 : 0 });
    await syncWorker();
    await say(p.chatId, LINK_TEXT.linked);
    return { status: 200, body: { linked: true, client_id: p.client_id, telegram_name: p.telegramName, scope: p.scope } };
  }

  /** DELETE /v1/link/<client_id>, with a fresh ticket of the same Home. */
  async function deleteLink(clientId, ticket) {
    sweep();
    const { t, fail } = ticketOf(ticket);
    if (fail) return fail;
    if (t.client_id && t.client_id !== clientId) return { status: 403, body: { error: 'wrong_client' } };
    const b = bindings.byClient(t.home_id, clientId);
    if (b) { await removeBinding(b, { fromApp: true }); return { status: 200, body: { removed: true } }; }
    const p = pendingFor(t.home_id, clientId);
    if (p) { pending.delete(p.code); return { status: 200, body: { removed: true } }; }
    return { status: 404, body: { error: 'not_linked' } };
  }

  /** GET /v1/links, with a fresh ticket: this Home's linked chats. */
  function listLinks(ticket) {
    const { t, fail } = ticketOf(ticket);
    if (fail) return fail;
    return {
      status: 200,
      body: { links: bindings.forHome(t.home_id).map((b) => ({ client_id: b.client_id, telegram_name: b.telegram_name || '', scope: b.scope === 'control' ? 'control' : 'read', last_used: state.lastUsed(b.id), linked_at: b.linked_at || null })) },
    };
  }

  // ---------- Telegram ----------

  async function claim(chatId, from, code) {
    const t = now();
    const fails = hourAgo(claimFails.get(chatId) || [], t);
    claimFails.set(chatId, fails);
    if (fails.length >= CLAIMS_PER_HOUR) { metrics.count('link_claim_refused', { limited: 1 }); return; }
    if (bindings.byChat(chatId)) { await say(chatId, LINK_TEXT.alreadyLinked); return; }
    const p = pending.get(code);
    if (!p || p.expires <= t || (p.chatId && p.chatId !== chatId)) {
      fails.push(t);
      metrics.count('link_claim_refused', { limited: 0 });
      await say(chatId, LINK_TEXT.badCode);
      return;
    }
    if (!p.chatId) {
      p.chatId = chatId;
      p.telegramName = cleanName(from && from.first_name) || 'Telegram';
      p.backCode = String(crypto.randomInt(10000)).padStart(4, '0');
      p.expires = t + LINK_MS; // ten more minutes to type the back-code
      metrics.count('link_claimed');
    }
    await say(chatId, LINK_TEXT.backCode(p.backCode));
  }

  async function onCallback(update) {
    const q = update.callback_query;
    const chatId = q.message?.chat?.id !== undefined ? String(q.message.chat.id) : null;
    if (!chatId) return;
    if (q.data !== 'unlink:yes' && q.data !== 'unlink:no') { await forward(update); return; }
    await bot.answerCallback(q.id);
    // Unlink and Keep stay tappable otherwise, long after the answer.
    if (q.message?.message_id !== undefined) await bot.clearButtons(chatId, q.message.message_id);
    const asked = unlinkAsks.get(chatId);
    unlinkAsks.delete(chatId);
    const b = bindings.byChat(chatId);
    if (!b) { await say(chatId, LINK_TEXT.notLinkedHere); return; }
    if (q.data === 'unlink:no') { await say(chatId, LINK_TEXT.kept); return; }
    if (!asked || asked <= now()) { await say(chatId, LINK_TEXT.unlinkExpired); return; }
    await removeBinding(b, { fromApp: false });
  }

  async function onMessage(update) {
    const m = update.message;
    const chatId = String(m.chat.id);
    const text = typeof m.text === 'string' ? m.text.trim() : null;
    const start = text && /^\/start(?:@\w+)?(?:\s+(\S+))?$/.exec(text);
    const payload = start ? start[1] || '' : null;
    if (payload && CODE_RE.test(payload)) return claim(chatId, m.from, payload);
    if (payload === 'early_c' || payload === 'early_n' || /^\/stop(?:@\w+)?$/.test(text || '')) return forward(update);
    const b = bindings.byChat(chatId);
    if (!b) return forward(update);
    if (/^\/unlink(?:@\w+)?$/.test(text || '')) {
      unlinkAsks.set(chatId, now() + UNLINK_ASK_MS);
      await say(chatId, LINK_TEXT.askUnlink, { inline_keyboard: [[{ text: 'Unlink', callback_data: 'unlink:yes' }, { text: 'Keep', callback_data: 'unlink:no' }]] });
      return undefined;
    }
    if (!text) { await say(chatId, LINK_TEXT.textOnly); return undefined; }
    if (!(await mayAnswer(b))) return undefined;
    const command = text.startsWith('/');
    if (!command) {
      if (state.messages(b.home_id) >= config.cap) { metrics.count('cap_reached'); await say(chatId, LINK_TEXT.cap(config.cap)); return undefined; }
      if (state.spent() >= config.budgetUsd) { metrics.count('budget_paused'); await say(chatId, LINK_TEXT.paused); return undefined; }
    }
    bot.typing(chatId);
    const typing = setInterval(() => bot.typing(chatId), 4000);
    let reply;
    try {
      costs.delete(chatId);
      reply = await agent.handle(chatId, payload !== null ? '/start' : text);
    } finally {
      clearInterval(typing);
    }
    if (!command) state.note(b.home_id, b.id, costs.get(chatId) || 0);
    if (reply) await say(chatId, reply);
    return undefined;
  }

  /** One update from Telegram. Never throws; repeated update ids are dropped. */
  function onUpdate(update) {
    if (!update || typeof update !== 'object') return Promise.resolve();
    if (typeof update.update_id === 'number') {
      if (seenUpdates.has(update.update_id)) { metrics.count('webhook_duplicate'); return Promise.resolve(); }
      seenUpdates.add(update.update_id);
      seenOrder.push(update.update_id);
      while (seenOrder.length > SEEN_UPDATES) seenUpdates.delete(seenOrder.shift());
    }
    sweep();
    let chatId = null;
    let work = null;
    if (update.callback_query) {
      chatId = update.callback_query.message?.chat?.id;
      work = () => onCallback(update);
    } else if (update.message && update.message.chat) {
      if (update.message.chat.type !== 'private') { metrics.count('ignored'); return Promise.resolve(); }
      chatId = update.message.chat.id;
      work = () => onMessage(update);
    }
    if (!work || chatId === undefined || chatId === null) { metrics.count('ignored'); return Promise.resolve(); }
    return enqueue(chatId, work);
  }

  timers.push(setInterval(sweep, 60000));
  timers.push(setInterval(() => { retryAcl().catch(() => {}); }, ACL_RETRY_MS));
  for (const t of timers) t.unref?.();

  return {
    onUpdate, linkFor, createLink, confirmLink, deleteLink, listLinks, syncWorker, retryAcl, homeStatus,
    /** POST /v1/internal/home-changed (http.mjs, internal port). */
    homeChanged,
    /** POST /v1/internal/home-deleted: answered at once; the links go in the background. */
    homeDeleted: (homeId) => later(() => homeDeleted(homeId)),
    /** For the agent's onCost: what the current message of [chatId] cost. */
    costSink: (chatId, usd) => costs.set(String(chatId), usd),
    pendingCount: () => pending.size,
    async idle() {
      while (background.size || queues.size) await Promise.all([...background, ...queues.values()]);
    },
    stop() {
      for (const t of timers) clearInterval(t);
      for (const { link } of links.values()) link.stop();
      links.clear();
      pending.clear();
    },
  };
}
