#!/bin/sh
# Points @ZigDashHomeBot's webhook at zigdash-chat (live) or back at the
# support Worker (rollback), or shows where it points (info). Secrets are read
# from files and never printed. One command either way:
#   CHAT_CONFIG_DIR=/srv/zigdash-chat/config sh webhook.sh live
#   CHAT_CONFIG_DIR=/srv/zigdash-chat/config sh webhook.sh rollback
# Files in CHAT_CONFIG_DIR: bot_token, webhook_secret (zigdash-chat's), and
# worker_webhook_secret (the Worker's ASSISTANT_WEBHOOK_SECRET, for rollback).
set -eu
dir="${CHAT_CONFIG_DIR:?the folder with bot_token and the webhook secrets}"
token="$(cat "$dir/bot_token")"
api="https://api.telegram.org/bot$token"
case "${1:-info}" in
  live)
    secret="$(cat "$dir/webhook_secret")"
    url="https://chat.zigdash.app/v1/tg/$secret" ;;
  rollback)
    secret="$(cat "$dir/worker_webhook_secret")"
    url="${WORKER_URL:-https://support.giladha.com}/v1/tg/$secret" ;;
  info)
    curl -sS "$api/getWebhookInfo" | sed -E 's#/v1/tg/[^"]+#/v1/tg/<secret>#'
    echo
    exit 0 ;;
  *) echo "usage: webhook.sh live|rollback|info" >&2; exit 2 ;;
esac
curl -sS "$api/setWebhook" \
  --data-urlencode "url=$url" \
  --data-urlencode "secret_token=$secret" \
  --data-urlencode 'allowed_updates=["message","callback_query"]' \
  --data-urlencode "drop_pending_updates=false" | sed -E 's#/v1/tg/[^"]+#/v1/tg/<secret>#'
echo
