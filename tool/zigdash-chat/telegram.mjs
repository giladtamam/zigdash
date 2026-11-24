// Telegram adapter: the Bot API client, and long polling (getUpdates) for the
// dev bot. The live bot uses the webhook in http.mjs instead; both hand every
// update to the same router (bot.mjs). Nothing here logs a token, a chat id,
// a name or a message.

const MAX_REPLY = 4000;

/** Never let the token reach a log: errors are reduced to a short code. */
export const errorCode = (e) => String((e && (e.code || e.name)) || 'error').replace(/[^A-Za-z0-9_]/g, '').slice(0, 30);

export function makeBot({ token, fetchImpl = fetch, signal }) {
  const api = async (method, body, { timeoutMs } = {}) => {
    const res = await fetchImpl(`https://api.telegram.org/bot${token}/${method}`, {
      method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(body),
      signal: timeoutMs ? AbortSignal.any([AbortSignal.timeout(timeoutMs), ...(signal ? [signal] : [])]) : signal,
    });
    const data = await res.json();
    if (!data.ok) { const e = new Error('telegram'); e.code = `tg_${data.error_code || res.status}`; throw e; }
    return data.result;
  };
  return {
    api,
    /** Sends [text] (split under Telegram's limit); [markup] goes with the last part. */
    async say(chatId, text, markup) {
      for (let i = 0; i < text.length; i += MAX_REPLY) {
        const last = i + MAX_REPLY >= text.length;
        await api('sendMessage', { chat_id: chatId, text: text.slice(i, i + MAX_REPLY), disable_web_page_preview: true, ...(last && markup ? { reply_markup: markup } : {}) });
      }
    },
    typing: (chatId) => api('sendChatAction', { chat_id: chatId, action: 'typing' }).catch(() => {}),
    answerCallback: (id) => api('answerCallbackQuery', { callback_query_id: id }).catch(() => {}),
    /** Takes the buttons off a message once they were answered. */
    clearButtons: (chatId, messageId) => api('editMessageReplyMarkup', { chat_id: chatId, message_id: messageId, reply_markup: { inline_keyboard: [] } }).catch(() => {}),
  };
}

/**
 * Long polling, so a slow tool loop can never make Telegram resend an update
 * and no public address is needed. [onUpdate] is awaited for each update.
 */
export function startPolling({ token, onUpdate, metrics, fetchImpl = fetch, pollSeconds = 30, retryMs = 5000 }) {
  const abort = new AbortController();
  const bot = makeBot({ token, fetchImpl, signal: abort.signal });
  const done = (async () => {
    try {
      await bot.api('getMe', {});
      metrics.count('telegram_ready');
    } catch (e) {
      if (abort.signal.aborted) return;
      metrics.count('telegram_error', { start: 1 });
      console.error(`telegram: getMe failed (${errorCode(e)})`);
    }
    let offset = 0;
    while (!abort.signal.aborted) {
      try {
        const updates = await bot.api('getUpdates', { offset, timeout: pollSeconds, allowed_updates: ['message', 'callback_query'] });
        for (const u of updates) {
          offset = u.update_id + 1;
          try { await onUpdate(u); } catch (e) { if (!abort.signal.aborted) console.error(`telegram: update failed (${errorCode(e)})`); }
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
