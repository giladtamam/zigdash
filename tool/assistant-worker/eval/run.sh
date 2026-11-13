#!/usr/bin/env bash
# Posts every case in cases.json to the assistant Worker and writes one
# Markdown file per case to eval/out/ for hand grading.
#
# Usage:
#   tool/assistant-worker/eval/run.sh [URL] [FROM]
#     URL   defaults to https://assistant.giladha.com/v1/chat
#     FROM  1-based case number to start from (to resume after a 503)
#   DRY=1 tool/assistant-worker/eval/run.sh   writes the request bodies only, no network
#   CASES=cases_home.json tool/assistant-worker/eval/run.sh   the home-mode cases (3.5.0)
#
# The Worker allows 10 calls an hour per address: set the Worker var
# PER_HOUR_IP to 100 for the run and remove it afterwards (README.md).
set -euo pipefail

url="${1:-https://assistant.giladha.com/v1/chat}"
from="${2:-1}"
here="$(cd "$(dirname "$0")" && pwd)"
out="$here/out"
mkdir -p "$out"
command -v jq >/dev/null || { echo "jq is needed (brew install jq)" >&2; exit 1; }

cases="$here/${CASES:-cases.json}"
count=$(jq length "$cases")
for ((i = from - 1; i < count; i++)); do
  case=$(jq -c ".[$i]" "$cases")
  id=$(jq -r .id <<<"$case")
  num=$(printf '%02d' $((i + 1)))
  body=$(jq -c '{mode: (.mode // "setup"), details, triage, locale, app: "3.5.0", build: "108", messages: (.messages // [])}' <<<"$case")

  if [[ "${DRY:-}" == 1 ]]; then
    printf '%s\n' "$body" > "$out/$num-$id.request.json"
    echo "$num $id (dry: request written)"
    continue
  fi

  resp=$(mktemp)
  status=$(curl -sS -m 60 -o "$resp" -w '%{http_code}' \
    -H 'content-type: application/json' --data-binary "$body" "$url" || echo 000)

  {
    echo "# Case $num: $id"
    echo
    echo "Locale: $(jq -r .locale <<<"$case") · Triage: $(jq -c .triage <<<"$case")"
    echo
    echo '```'
    jq -r .details <<<"$case"
    echo '```'
    if [[ "$(jq '.messages | length' <<<"$case")" != 0 ]]; then
      echo
      echo "## Conversation"
      echo
      jq -r '.messages[] | "**\(.role):** \(.content)\n"' <<<"$case"
    fi
    echo
    echo "## Answer (HTTP $status)"
    echo
    if [[ "$status" == 200 ]]; then
      jq -r '.text // "(refused)"' "$resp"
      echo
      echo "_model $(jq -r .model "$resp") · usage $(jq -c .usage "$resp")$(jq -r 'if .truncated then " · truncated" else "" end' "$resp")_"
    else
      cat "$resp"
      echo
    fi
    echo
    echo "## Expected"
    echo
    jq -r '.expected[] | "- \(.)"' <<<"$case"
    echo
    echo "## Grade"
    echo
    echo "- [ ] pass   - [ ] partial   - [ ] fail"
    echo
    echo "Notes:"
  } > "$out/$num-$id.md"
  rm -f "$resp"
  echo "$num $id HTTP $status"
done
