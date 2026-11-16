// Logs are counters only (plan revision 6): an event name from a fixed list
// and numbers. Anything that isn't a finite number is dropped here, so no
// message text, name, chat id, home id or device name can reach a log line.

const EVENTS = new Set([
  'started', 'telegram_ready', 'telegram_error', 'mqtt_connected', 'mqtt_closed', 'mqtt_error',
  'ignored', 'message', 'confirm_asked', 'confirm_done', 'confirm_expired', 'not_linked', 'home_offline', 'model_error',
  // phase 3: linking, the webhook, the Worker, caps
  'http', 'link_created', 'link_claimed', 'link_claim_refused', 'link_confirmed', 'link_wrong_code', 'link_cancelled',
  'link_expired', 'unlinked', 'acl_error', 'webhook_refused', 'webhook_duplicate', 'forwarded', 'forward_error',
  'worker_sync', 'worker_sync_error', 'cap_reached', 'budget_paused',
  // founder's passes: the Home's status, the verifier's pushes
  'home_status', 'home_status_error', 'pass_ended', 'link_refused', 'home_changed', 'home_deleted', 'internal_refused', 'internal_http',
]);

export function makeMetrics(sink = (line) => console.log(line)) {
  const totals = {};
  return {
    totals,
    count(event, fields = {}) {
      if (!EVENTS.has(event)) throw new Error(`unknown metric ${event}`);
      totals[event] = (totals[event] || 0) + 1;
      const parts = [new Date().toISOString(), event];
      for (const [k, v] of Object.entries(fields)) {
        if (/^[a-z_]{1,30}$/.test(k) && typeof v === 'number' && Number.isFinite(v)) parts.push(`${k}=${Math.round(v * 1e6) / 1e6}`);
      }
      sink(parts.join(' '));
    },
  };
}
