#!/usr/bin/env bash
# JEV API で testdata 全 .go をファイル区分 choice のみで走査する。
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
  echo "run-jev-choice2.sh: JEV_API_KEY が未設定です (.env)" >&2
  exit 1
fi
if [[ -z "${JEV_API_URL:-}" ]]; then
  echo "run-jev-choice2.sh: JEV_API_URL が未設定です (.env)" >&2
  exit 1
fi

OUT="${1:-docs/jev-choice2-raw.jsonl}"
USAGE="${2:-docs/jev-choice2-usage.json}"
: >"$OUT"

read -r -d '' QUESTIONS <<'EOF' || true
{
  "ctx": { "type": "noul", "instructions": "コンテキストの伝播が欠落しており、キャンセル・タイムアウトが機能しない" },
  "err": { "type": "noul", "instructions": "エラーが握りつぶされているか、呼び出し元に適切に返却されていない" },
  "conc": { "type": "noul", "instructions": "goroutine のリーク・データレース・排他制御の欠落など並行処理の安全性問題" },
  "sec": { "type": "noul", "instructions": "SQLインジェクションや機微情報の外部露出などセキュリティリスク" },
  "resource": { "type": "noul", "instructions": "ファイルや接続などのリソースが適切に解放されない、または解放エラーが無視される" },
  "api": { "type": "noul", "instructions": "公開 API が通常の入力で panic するか、戻り値の契約が不明瞭" },
  "verdict": {
    "type": "choice",
    "instructions": "この Go コードはどの区分か",
    "criteria": {
      "bad": "コードパスによらず修正必須の明確な欠陥",
      "gray": "設計意図や実行環境によって許容か要修正かが変わる",
      "good": "言語慣習とベストプラクティスに沿っている"
    }
  }
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
    echo "run-jev-choice2.sh: API error on $gofile: $(echo "$resp" | jq -c .)" >&2
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

# 入力 100 万トークンあたり $0.042。出力は無料（https://docs.typesafe.ai/models）。
# レスポンスに usage.cost_usd があればそれを合計する。
usd=$(jq -s '
  if length > 0 and all(.[]; .usage.cost_usd != null) then
    map(.usage.cost_usd) | add
  else
    (map(.usage.input_tokens // 0) | add) * 0.042 / 1000000
  end
' "$OUT")

jq -n \
  --arg model "$model_seen" \
  --argjson total_in "$total_in" \
  --argjson total_out "$total_out" \
  --argjson count "$(grep -c '"file":' "$OUT" || true)" \
  --argjson usd "$usd" \
  '{ model: $model, files: ($count|tonumber), total_input_tokens: $total_in, total_output_tokens: $total_out, usd: $usd }' \
  >"$USAGE"

echo "wrote $OUT and $USAGE (cost \$$usd)" >&2
