#!/usr/bin/env bash
# baseline-jev-raw.jsonl から Markdown 表を生成する。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RAW="$ROOT/docs/baseline-jev-raw.jsonl"
OUT="$ROOT/docs/baseline-jev.md"
THRESH="${JEV_THRESHOLD:-0.75}"

fmt_cell() {
  local axis="$1" noul="$2"
  local pct
  pct=$(awk -v n="$noul" 'BEGIN { printf "%.2f", n }')
  if awk -v n="$noul" -v t="$THRESH" 'BEGIN { exit !(n >= t) }'; then
    echo "**yes ($pct)**"
  else
    echo "no ($pct)"
  fi
}

row() {
  local file="$1" tags="${2:-}"
  local line ctx err conc sec
  ctx=$(jq -r --arg f "$file" 'select(.file==$f) | .answers.ctx.noul' "$RAW")
  err=$(jq -r --arg f "$file" 'select(.file==$f) | .answers.err.noul' "$RAW")
  conc=$(jq -r --arg f "$file" 'select(.file==$f) | .answers.conc.noul' "$RAW")
  sec=$(jq -r --arg f "$file" 'select(.file==$f) | .answers.sec.noul' "$RAW")
  if [[ -n "$tags" ]]; then
    printf '| `%s` | %s | %s | %s | %s | %s |\n' "$(basename "$file")" \
      "$(fmt_cell ctx "$ctx")" "$(fmt_cell err "$err")" "$(fmt_cell conc "$conc")" "$(fmt_cell sec "$sec")" "$tags"
  else
    printf '| `%s` | %s | %s | %s | %s |\n' "$(basename "$file")" \
      "$(fmt_cell ctx "$ctx")" "$(fmt_cell err "$err")" "$(fmt_cell conc "$conc")" "$(fmt_cell sec "$sec")"
  fi
}

usage=$(cat "$ROOT/docs/baseline-jev-usage.json")
model=$(echo "$usage" | jq -r '.model')
files=$(echo "$usage" | jq -r '.files')
tin=$(echo "$usage" | jq -r '.total_input_tokens')
tout=$(echo "$usage" | jq -r '.total_output_tokens')

{
  cat <<HDR
# JEV ベースライン（4 軸 Noul）

- **判定軸:** ctx / err / conc / sec（Claude ベースラインと同一 instructions）
- **記法:** \`yes|no (noul)\` — \`noul\` は問題あり確率 0.00〜1.00
- **検出閾値（表の太字）:** \`noul ≥ $THRESH\`
- **モデル:** \`$model\`（${files} ファイル）
- **usage 合計:** input ${tin} / output ${tout} tokens
- **生データ:** [baseline-jev-raw.jsonl](./baseline-jev-raw.jsonl)

---

## bad（10）

| ファイル | ctx | err | conc | sec | 注釈の主タグ |
|----------|-----|-----|------|-----|--------------|
HDR
  for f in testdata/bad/b*.go; do
    case $(basename "$f") in
      b01_no_context_param.go) row "$f" "ctx, api" ;;
      b02_swallow_error.go) row "$f" "err" ;;
      b03_leaky_goroutine.go) row "$f" "conc, ctx" ;;
      b04_sql_concat.go) row "$f" "sec" ;;
      b05_defer_in_loop.go) row "$f" "resource ※" ;;
      b06_log_secret.go) row "$f" "sec" ;;
      b07_mutex_unlock_missing.go) row "$f" "conc, err" ;;
      b08_panic_in_lib.go) row "$f" "api, err" ;;
      b09_race_on_map.go) row "$f" "conc" ;;
      b10_ignore_close_error.go) row "$f" "err, resource" ;;
    esac
  done
  cat <<MID

※ \`b05\` の主題（ループ内 defer）は 4 軸に無い。

---

## good（10）

| ファイル | ctx | err | conc | sec |
|----------|-----|-----|------|-----|
MID
  for f in testdata/good/g*.go; do row "$f"; done
  cat <<MID2

---

## gray（10）

| ファイル | ctx | err | conc | sec | 注釈の主タグ |
|----------|-----|-----|------|-----|--------------|
MID2
  for f in testdata/gray/y*.go; do
    case $(basename "$f") in
      y01_context_todo.go) row "$f" "ctx" ;;
      y02_log_only_error.go) row "$f" "err, api" ;;
      y03_goroutine_wg_no_ctx.go) row "$f" "conc, ctx" ;;
      y04_unexported_no_ctx.go) row "$f" "ctx, api" ;;
      y05_optional_err_ignore.go) row "$f" "err, resource" ;;
      y06_rwlock_always_write.go) row "$f" "conc" ;;
      y07_global_background_ctx.go) row "$f" "ctx, conc" ;;
      y08_naked_return.go) row "$f" "api" ;;
      y09_unbuffered_signal_chan.go) row "$f" "conc" ;;
      y10_json_marshal_best_effort.go) row "$f" "err" ;;
    esac
  done
  echo ""
  echo "---"
  echo ""
  echo "## 生 JSON（1 行 / ファイル）"
  echo ""
  while IFS= read -r line; do
    f=$(echo "$line" | jq -r '.file')
    compact=$(echo "$line" | jq -c '{ctx:.answers.ctx,err:.answers.err,conc:.answers.conc,sec:.answers.sec}')
    echo "\`$f\`"
    echo "\`\`\`"
    echo "$compact"
    echo "\`\`\`"
    echo ""
  done <"$RAW"
} >"$OUT"

echo "wrote $OUT"
