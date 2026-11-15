// Telegram adapter, long polling (getUpdates), so a slow tool loop can never
// make Telegram resend an update and no public address is needed. Only
// private chats whose id is on the allowlist get an answer; anyone else gets
// nothing back, and nothing of theirs (text, name, id) is logged: only the
// "ignored" counter goes up.

const MAX_REPLY = 4000;

export function startTelegram({ token, allowed, onText, metrics, fetchImpl = fetch, pollSeconds = 30, retryMs = 5000 }) {
  const abort = new AbortController();
  // Never let the token reach a log: errors are reduced to a short code.
  const errorCode = (e) => String((e && (e.code || e.name)) || 'error').replace(/[^A-Za-z0-9_]/g, '').slice(0, 30);
  const tg = async (method, body) => {
    const res = await fetchImpl(`https://api.telegram.org/bot${token}/${method}`, {
      method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(body), signal: abort.signal,
    });
    const data = await res.json();
    if (!data.ok) { const e = new Error('telegram'); e.code = `tg_${data.error_code || res.status}`; throw e; }
    return data.result;
  };
  const say = async (chatId, text) => {
    for (let i = 0; i < text.length; i += MAX_REPLY) await tg('sendMessage', { chat_id: chatId, text: text.slice(i, i + MAX_REPLY) });
  };

  async function handle(msg) {
    const chat = msg && msg.chat;
    const chatId = chat ? String(chat.id) : '';
    if (!chat || chat.type !== 'private' || !allowed().has(chatId)) {
      metrics.count('ignored');
      return;
    }
    if (typeof msg.text !== 'string' || !msg.text.trim()) {
      await say(chat.id, 'I can only read text messages.');
      return;
    }
    const typing = () => tg('sendChatAction', { chat_id: chat.id, action: 'typing' }).catch(() => {});
    typing();
    const timer = setInterval(typing, 4000);
    try {
      const reply = await onText(chatId, msg.text);
      if (reply) await say(chat.id, reply);
    } finally {
      clearInterval(timer);
    }
  }

  const done = (async () => {
    try {
      await tg('getMe', {});
      metrics.count('telegram_ready');
    } catch (e) {
      if (abort.signal.aborted) return;
      metrics.count('telegram_error', { start: 1 });
      console.error(`telegram: getMe failed (${errorCode(e)})`);
    }
    let offset = 0;
    while (!abort.signal.aborted) {
      try {
        const updates = await tg('getUpdates', { offset, timeout: pollSeconds, allowed_updates: ['message'] });
        for (const u of updates) {
          offset = u.update_id + 1;
          try { await handle(u.message); } catch (e) { if (!abort.signal.aborted) console.error(`telegram: reply failed (${errorCode(e)})`); }
        }
      } catch (e) {
        if (abort.signal.aborted) break;
        metrics.count('telegram_error');
        console.error(`telegram: polling failed (${errorCode(e)})`);
        await new Promise((r) => setTimeout(r, retryMs));
      }
    }
  })();

  return { stop: () => { abort.abort(); return done; } };
}
