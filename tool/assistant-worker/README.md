# ZigDash assistant Worker

The server half of the in-app troubleshooting assistant
(docs/design/assistant-in-app-2026-11.md). A Cloudflare Worker that takes the
app's Support details, triage answers, locale and conversation, prepends the
system prompt and the knowledge text, calls the Claude API once and returns
the answer. It stores nothing and logs no bodies.

## Files

| File | What |
|---|---|
| `system_prompt.md` | The operator prompt (hand-written, under 80 lines) |
| `facts.md` | Facts about ZigDash the app's strings do not state (hand-written) |
| `build_knowledge.dart` | Reads `lib/l10n/app_en.arb` + `facts.md`, writes `knowledge.md`, then stamps `worker.js` from `worker.template.js` |
| `knowledge.md` | Generated; the tips, guide steps, error texts, Home Assistant help, broker-form checks, SMLIGHT notes |
| `worker.template.js` | The Worker source to edit |
| `worker.js` | Generated: the template with prompt + knowledge embedded as one string constant. This is what gets deployed |
| `eval/cases.json`, `eval/run.sh` | 20 situations for hand grading |

## Regenerate

From the worktree root, with the Flutter SDK pinned in `.fvmrc` (3.47.5):

```sh
env -u NODE_OPTIONS ~/development/flutter-3.47.5/bin/dart tool/assistant-worker/build_knowledge.dart
env -u NODE_OPTIONS node --check tool/assistant-worker/worker.js
```

The output is deterministic (no timestamps): running it twice changes
nothing. Rebuild whenever `app_en.arb`, `facts.md`, `system_prompt.md` or
`worker.template.js` change, and commit `knowledge.md` and `worker.js` with
them. The script prints the sizes (chars / 4 is the token estimate) and any
string keys the lists did not pick up.

## Deploy

1. Cloudflare dashboard → Workers & Pages → create Worker `zigdash-assistant`
   (or open it) → Edit code → replace everything with `worker.js` → Deploy.
2. Settings → Variables and Secrets:
   - `ANTHROPIC_API_KEY` (secret): a key from a dedicated Anthropic workspace,
     with a spend alert set in the console (the $40 backstop in the plan).
   - `MODEL` (text, optional): `claude-opus-5-5` (default) or `claude-haiku-5-5`.
     The refusal fallback is sent only for `claude-opus*`; Haiku has none.
   - `COST_STOP_USD` (text, optional): monthly stop, default `60`.
   - `PER_HOUR_IP`, `PER_HOUR_ALL` (text, optional): defaults 10 and 100.
     Set `PER_HOUR_IP=100` only while running the eval, then remove it.
3. Settings → Bindings → KV namespace: create `zigdash-assistant-rate`, bind it
   as `RATE`. It holds hourly counters (`ip:<hash>:<hour>`, `all:<hour>`) and
   the month's spend (`cost:YYYY-MM`), all expiring on their own.
4. Settings → Domains & Routes → add custom domain `assistant.giladha.com`.
5. Check with curl (expect 400 `details required` without a body that starts
   with "ZigDash x.y.z (n)", 405 for GET):

```sh
curl -s -X POST https://assistant.giladha.com/v1/chat -H 'content-type: application/json' \
  -d '{"details":"ZigDash 3.5.0 (107) · Android 14 · Pixel 7\nOpened from: Setup › No connection found\nConnection: none\nZigbee2MQTT: not found\nLast error: none\nLast scan: /24 · 254 hosts tried · 0 brokers · Wi-Fi","triage":{"running":"yes","platform":"smhub"},"locale":"en","app":"3.5.0","build":"107","messages":[]}'
```

## The endpoint

`POST /v1/chat`, JSON, no CORS (the app is the only caller).

Request:

```json
{
  "details": "ZigDash 3.5.0 (107) · Android 14 · Pixel 7\nOpened from: …\nConnection: …\nZigbee2MQTT: …\nLast error: …\nLast scan: …",
  "triage": {"running": "yes" | "not_sure" | null, "platform": "smhub" | "home_assistant" | "pi" | … | null},
  "locale": "de",
  "app": "3.5.0",
  "build": "107",
  "messages": [{"role": "assistant", "content": "…"}, {"role": "user", "content": "…"}]
}
```

- Body at most 24 KB (413 over). At most 12 messages of at most 1,000
  characters each, roles `user`/`assistant` only, last one `user` (400 otherwise).
- `details` must start with `ZigDash <version> (<build>)` (400 otherwise).
- `messages` empty = the card's first answer (three ranked checks). A leading
  `user` message is folded into the details turn, so the app may send either
  `[user]` or `[assistant, user, …]`.

Response 200:

```json
{"text": "1. …", "usage": {"input": 120, "cache_read": 7400, "cache_write": 0, "output": 310}, "model": "claude-opus-5-5"}
```

plus `"refused": true` with `"text": null` when the model declined, and
`"truncated": true` when the answer hit `max_tokens`.

Other answers: 400 bad body, 404, 405, 502 the API failed (no details),
503 `resting` (over 10/hour per address or 100/hour overall) or `budget`
(the month's summed cost reached `COST_STOP_USD`). Counters and cost are
added only after a successful model reply, as the support Worker does.

Model call: `max_tokens` 2048, `output_config.effort` low, no `thinking`
field, `system` as one text block with `cache_control: ephemeral` (the same
bytes on every call, so the ~7.5K-token prefix caches; everything per request
is in the user turn), `fallbacks: "default"` with the
`server-side-fallback-2026-07-01` beta header for Opus only, 25 s timeout.

## Eval

```sh
# once: in the Worker's vars set PER_HOUR_IP=100
tool/assistant-worker/eval/run.sh                       # default URL
tool/assistant-worker/eval/run.sh https://…/v1/chat 11  # resume from case 11
DRY=1 tool/assistant-worker/eval/run.sh                 # request bodies only, no network
```

Writes `eval/out/<nn>-<id>.md` with the case, the answer, the expected
points and a grade line. Grade by hand; re-run whenever `system_prompt.md`
or `facts.md` change. `eval/out/` is ignored by git. Twenty Opus calls on a
cold cache cost about $0.50.
