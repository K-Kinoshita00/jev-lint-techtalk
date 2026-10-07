#!/usr/bin/env bash
# JEV API で testdata 全 .go を走査し JSONL に保存する。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

if [[ -z "${JEV_API_KEY:-}" ]]; then
  echo "run-jev-baseline.sh: JEV_API_KEY が未設定です (.env)" >&2
  exit 1
fi
if [[ -z "${JEV_API_URL:-}" ]]; then
  echo "run-jev-baseline.sh: JEV_API_URL が未設定です (.env)" >&2
  exit 1
fi

OUT="${1:-docs/baseline-jev-raw.jsonl}"
: >"$OUT"

read -r -d '' QUESTIONS <<'EOF' || true
{
  "ctx": { "type": "noul", "instructions": "I/O や待ちがあり得る API が context.Context を第一引数で受け取っておらず、キャンセルも考慮されていない" },
  "err": { "type": "noul", "instructions": "エラーを無視している、または呼び出し元に返すべきエラーを返していない" },
  "conc": { "type": "noul", "instructions": "キャンセル・待ち合わせのない goroutine、または共有 map 等のデータレースの疑い" },
  "sec": { "type": "noul", "instructions": "SQL 文字列連結、パスワード等の機微情報ログ" }
}
EOF

total_in=0
total_out=0
model_seen=""

while IFS= read -r gofile; do
  echo "jev: $gofile" >&2
  SRC=$(cat "$gofile")
  jq -n --arg state "$SRC" --arg model "${JEV_MODEL:-jev-latest}" --argjson questions "$QUESTIONS" \
    '{ model: $model, state: $state, questions: $questions }' >/tmp/jev-payload.json

  resp=$(curl -sS "$JEV_API_URL" \
    -H "Authorization: Bearer $JEV_API_KEY" \
    -H "Content-Type: application/json" \
    -d @/tmp/jev-payload.json)

  if echo "$resp" | jq -e '.detail.error_type' >/dev/null 2>&1; then
    echo "run-jev-baseline.sh: API error on $gofile: $(echo "$resp" | jq -c .)" >&2
    exit 1
  fi

  model_seen=$(echo "$resp" | jq -r '.model')
  in_t=$(echo "$resp" | jq -r '.usage.input_tokens // 0')
  out_t=$(echo "$resp" | jq -r '.usage.output_tokens // 0')
  total_in=$((total_in + in_t))
  total_out=$((total_out + out_t))

  jq -cn \
    --arg file "$gofile" \
    --arg model "$model_seen" \
    --argjson answers "$(echo "$resp" | jq '.answers')" \
    --argjson usage "$(echo "$resp" | jq '.usage')" \
    '{ file: $file, model: $model, answers: $answers, usage: $usage }' >>"$OUT"

  sleep "${JEV_SLEEP_SEC:-1}"
done < <(find testdata -name '*.go' | sort)

jq -n \
  --arg model "$model_seen" \
  --argjson total_in "$total_in" \
  --argjson total_out "$total_out" \
  --argjson count "$(grep -c '"file":' "$OUT" || true)" \
  '{ model: $model, files: ($count|tonumber), total_input_tokens: $total_in, total_output_tokens: $total_out }' \
  >docs/baseline-jev-usage.json

echo "wrote $OUT and docs/baseline-jev-usage.json" >&2
