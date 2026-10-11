1. ctx: コンテキストの伝播が欠落しており、キャンセル・タイムアウトが機能しない
2. err: エラーが握りつぶされているか、呼び出し元に適切に返却されていない
3. conc: goroutine のリーク・データレース・排他制御の欠落など並行処理の安全性問題
4. sec: SQLインジェクションや機微情報の外部露出などセキュリティリスク
5. resource: ファイルや接続などのリソースが適切に解放されない、または解放エラーが無視される
6. api: 公開 API が通常の入力で panic するか、戻り値の契約が不明瞭

- bad: コードパスによらず修正必須の明確な欠陥
- gray: 設計意図や実行環境によって許容か要修正かが変わる
- good: 言語慣習とベストプラクティスに沿っている

# go vet

0件ヒット

# go vet ./testdata

gosec や contextcheck を足した結果ではない

3件ヒット

```bash
testdata/defer_close.go:18:17: Error return value of `src.Close` is not checked (errcheck)
        defer src.Close()
                       ^
testdata/defer_close.go:24:17: Error return value of `dst.Close` is not checked (errcheck)
        defer dst.Close()
                       ^
testdata/defer_in_loop.go:15:16: Error return value of `f.Close` is not checked (errcheck)
                defer f.Close()
                             ^
3 issues:
* errcheck: 3
```

# claude

sonnet 4.6
Total cost: $0.51（$0.5前後）
Total duration (API): 3m 39s
Total duration (wall): 5m 32s
Total code changes: 0 lines added, 0 lines removed
Usage by model:
claude-haiku-4-5: 1.6k input, 18 output, 0 cache read, 0 cache write ($0.0017)
claude-sonnet-4-6: 4 input, 16.8k output, 104.4k cache read, 60.3k cache write ($0.51)
Prompt cache (main): 3 requests · 63% of input tokens from cache · no misses · warm (5m TTL, last activity 4m 11s ago)

プロンプト

```
あなたは Go コードの静的レビュアです。修正コードは書かず、判定だけしてください。

以下の Go ソースについて、6 軸それぞれの「問題あり」確率と、ファイル区分の確率を出してください。
- 軸: 0.0〜1.0。1.0 に近いほど問題あり。yes/no は書かない。
- verdict: bad / gray / good の確率。合計は 1.0。
- 判定に使ってよいのはソース本文だけ。ディレクトリ名、ファイル名、package 句はラベルではないので無視する。見出しのパスはどのファイルかの識別用であり、根拠にしない。
- 出力する値は小数第2位まで。0.05 刻みに丸めない

【6軸】
1. ctx: コンテキストの伝播が欠落しており、キャンセル・タイムアウトが機能しない
2. err: エラーが握りつぶされているか、呼び出し元に適切に返却されていない
3. conc: goroutine のリーク・データレース・排他制御の欠落など並行処理の安全性問題
4. sec: SQLインジェクションや機微情報の外部露出などセキュリティリスク
5. resource: ファイルや接続などのリソースが適切に解放されない、または解放エラーが無視される
6. api: 公開 API が通常の入力で panic するか、戻り値の契約が不明瞭

【3区分】
- bad: コードパスによらず修正必須の明確な欠陥
- gray: 設計意図や実行環境によって許容か要修正かが変わる
- good: 言語慣習とベストプラクティスに沿っている

【出力】説明不要。補足不要。次の JSON のみ。

{"ctx":0.0,"err":0.0,"conc":0.0,"sec":0.0,"resource":0.0,"api":0.0,"verdict":{"bad":0.0,"gray":0.0,"good":0.0}}

【ソース】
- ./testdata/*.go
各ファイルごとに結果を出力して
```

6軸の問題あり確率と verdict。軸の太字は ≥ 0.70。verdict の太字は最大。

## bad（10）

| ファイル                  | ctx            | err            | conc           | sec            | resource       | api            | verdict（bad / gray / good） | 注釈の主タグ  |
| ------------------------- | -------------- | -------------- | -------------- | -------------- | -------------- | -------------- | ---------------------------- | ------------- |
| `no_context_param.go`     | **yes (0.72)** | no (0.00)      | no (0.00)      | no (0.00)      | no (0.00)      | no (0.00)      | 0.12 / **0.75** / 0.13       | ctx, api      |
| `swallow_error.go`        | no (0.00)      | **yes (0.82)** | no (0.00)      | no (0.12)      | no (0.00)      | no (0.00)      | **0.78** / 0.18 / 0.04       | err           |
| `leaky_goroutine.go`      | **yes (0.88)** | **yes (0.72)** | **yes (0.85)** | no (0.12)      | **yes (0.75)** | no (0.00)      | **0.85** / 0.12 / 0.03       | conc, ctx     |
| `sql_concat.go`           | no (0.48)      | no (0.05)      | no (0.00)      | **yes (0.95)** | no (0.12)      | no (0.00)      | **0.92** / 0.06 / 0.02       | sec           |
| `defer_in_loop.go`        | no (0.00)      | no (0.05)      | no (0.00)      | no (0.00)      | **yes (0.85)** | no (0.05)      | **0.78** / 0.18 / 0.04       | resource      |
| `log_secret.go`           | no (0.00)      | no (0.00)      | no (0.00)      | **yes (0.95)** | no (0.00)      | no (0.00)      | **0.92** / 0.06 / 0.02       | sec           |
| `mutex_unlock_missing.go` | no (0.00)      | no (0.00)      | **yes (0.92)** | no (0.00)      | no (0.00)      | no (0.05)      | **0.90** / 0.08 / 0.02       | conc, err     |
| `panic_in_lib.go`         | no (0.00)      | no (0.00)      | no (0.00)      | no (0.00)      | no (0.00)      | **yes (0.72)** | 0.22 / **0.68** / 0.10       | api, err      |
| `race_on_map.go`          | no (0.00)      | no (0.00)      | **yes (0.72)** | no (0.00)      | no (0.00)      | no (0.15)      | 0.38 / **0.55** / 0.07       | conc          |
| `ignore_close_error.go`   | no (0.05)      | no (0.22)      | no (0.00)      | no (0.00)      | no (0.18)      | no (0.00)      | 0.12 / **0.72** / 0.16       | err, resource |

verdict の最大は 6/10 が bad。外れたのは `no_context_param`（gray 0.75 / bad 0.12）、`panic_in_lib`（gray 0.68 / bad 0.22）、`race_on_map`（gray 0.55 / bad 0.38）、`ignore_close_error`（gray 0.72 / bad 0.12）。注釈の主タグが 0.70 未満なのは `no_context_param` の api（0.00）、`mutex_unlock_missing` の err（0.00）、`panic_in_lib` の err（0.00）、`ignore_close_error` の err（0.22）・resource（0.18）。0.70 以上で注釈にないのは `leaky_goroutine` の err（0.72）・resource（0.75）。

## good（10）

| ファイル                 | ctx       | err       | conc      | sec       | resource  | api       | verdict（bad / gray / good） |
| ------------------------ | --------- | --------- | --------- | --------- | --------- | --------- | ---------------------------- |
| `context_first.go`       | no (0.05) | no (0.05) | no (0.00) | no (0.00) | no (0.00) | no (0.05) | 0.00 / 0.05 / **0.95**       |
| `error_wrap.go`          | no (0.58) | no (0.05) | no (0.00) | no (0.00) | no (0.00) | no (0.00) | 0.08 / **0.77** / 0.15       |
| `goroutine_ctx.go`       | no (0.05) | no (0.05) | no (0.10) | no (0.00) | no (0.00) | no (0.00) | 0.00 / 0.12 / **0.88**       |
| `defer_close.go`         | no (0.12) | no (0.22) | no (0.00) | no (0.00) | no (0.22) | no (0.05) | 0.18 / **0.68** / 0.14       |
| `timeout_query.go`       | no (0.05) | no (0.05) | no (0.00) | no (0.05) | no (0.08) | no (0.00) | 0.00 / 0.10 / **0.90**       |
| `mutex_guard.go`         | no (0.00) | no (0.00) | no (0.05) | no (0.00) | no (0.00) | no (0.00) | 0.00 / 0.05 / **0.95**       |
| `structured_log.go`      | no (0.00) | no (0.00) | no (0.00) | no (0.05) | no (0.00) | no (0.00) | 0.00 / 0.05 / **0.95**       |
| `parallel_fetch.go`      | no (0.05) | no (0.12) | no (0.10) | no (0.00) | no (0.00) | no (0.00) | 0.02 / 0.20 / **0.78**       |
| `table_driven_helper.go` | no (0.00) | no (0.00) | no (0.00) | no (0.00) | no (0.00) | no (0.00) | 0.00 / 0.02 / **0.98**       |
| `cancel_propagation.go`  | no (0.05) | no (0.05) | no (0.05) | no (0.00) | no (0.05) | no (0.05) | 0.02 / 0.08 / **0.90**       |

軸が 0.70 以上の行なし（最高は `error_wrap` ctx 0.58）。verdict の最大は 8/10 が good。外れたのは `error_wrap`（gray 0.77 / good 0.15 / bad 0.08）、`defer_close`（gray 0.68 / bad 0.18 / good 0.14）。

## gray（10）

| ファイル                      | ctx            | err       | conc      | sec       | resource  | api       | verdict（bad / gray / good） | 注釈の主タグ  |
| ----------------------------- | -------------- | --------- | --------- | --------- | --------- | --------- | ---------------------------- | ------------- |
| `context_todo.go`             | no (0.62)      | no (0.05) | no (0.00) | no (0.00) | no (0.00) | no (0.05) | 0.08 / **0.77** / 0.15       | ctx           |
| `log_only_error.go`           | no (0.00)      | no (0.58) | no (0.00) | no (0.00) | no (0.00) | no (0.00) | 0.12 / **0.78** / 0.10       | err, api      |
| `goroutine_wg_no_ctx.go`      | no (0.42)      | no (0.00) | no (0.05) | no (0.00) | no (0.00) | no (0.00) | 0.05 / **0.72** / 0.23       | conc, ctx     |
| `unexported_no_ctx.go`        | no (0.00)      | no (0.05) | no (0.00) | no (0.00) | no (0.00) | no (0.38) | 0.07 / **0.65** / 0.28       | ctx, api      |
| `optional_err_ignore.go`      | no (0.05)      | no (0.15) | no (0.00) | no (0.00) | no (0.12) | no (0.00) | 0.05 / **0.60** / 0.35       | err, resource |
| `rwlock_always_write.go`      | no (0.00)      | no (0.00) | no (0.38) | no (0.00) | no (0.00) | no (0.05) | 0.12 / **0.75** / 0.13       | conc          |
| `global_background_ctx.go`    | **yes (0.85)** | no (0.00) | no (0.58) | no (0.00) | no (0.05) | no (0.00) | **0.58** / 0.37 / 0.05       | ctx, conc     |
| `naked_return.go`             | no (0.00)      | no (0.05) | no (0.00) | no (0.00) | no (0.00) | no (0.28) | 0.08 / **0.72** / 0.20       | api           |
| `unbuffered_signal_chan.go`   | no (0.00)      | no (0.00) | no (0.10) | no (0.00) | no (0.05) | no (0.10) | 0.00 / 0.18 / **0.82**       | conc          |
| `json_marshal_best_effort.go` | no (0.00)      | no (0.48) | no (0.00) | no (0.00) | no (0.00) | no (0.22) | 0.12 / **0.72** / 0.16       | err           |

軸が 0.70 以上なのは `global_background_ctx` ctx（0.85）のみ。verdict の最大は 8/10 が gray。外れたのは `global_background_ctx`（bad 0.58 / gray 0.37）、`unbuffered_signal_chan`（good 0.82 / gray 0.18）。

---

# JEV

- **モデル:** jev-1.13.0（リクエスト指定 `jev-latest`）
- **閾値:** noul ≥ 0.70 を検出（表の太字）
- **usage 合計:** input 21932 / output 4050 tokens（30 ファイル）/ $0.000921

再実行:

```bash
set -a && source .env && set +a
./scripts/run-jev-choice2.sh docs/jev-choice2-raw.jsonl docs/jev-choice2-usage.json
```

6軸 noul（ctx / err / conc / sec / resource / api）とファイル区分 choice（verdict）。生データは [docs/jev-choice2-raw.jsonl](docs/jev-choice2-raw.jsonl)。usage は [docs/jev-choice2-usage.json](docs/jev-choice2-usage.json)。verdict は bad / gray / good の確率。軸の太字は ≥ 0.70。verdict の太字は最大。

## bad（10）

| ファイル                  | ctx            | err            | conc      | sec            | resource  | api       | verdict（bad / gray / good） | 注釈の主タグ  |
| ------------------------- | -------------- | -------------- | --------- | -------------- | --------- | --------- | ---------------------------- | ------------- |
| `no_context_param.go`     | **yes (0.88)** | no (0.08)      | no (0.12) | no (0.11)      | no (0.04) | no (0.13) | 0.23 / **0.63** / 0.14       | ctx, api      |
| `swallow_error.go`        | no (0.31)      | **yes (0.96)** | no (0.17) | no (0.40)      | no (0.15) | no (0.44) | 0.15 / **0.63** / 0.22       | err           |
| `leaky_goroutine.go`      | **yes (0.93)** | **yes (0.97)** | no (0.68) | no (0.44)      | no (0.39) | no (0.39) | 0.40 / **0.58** / 0.02       | conc, ctx     |
| `sql_concat.go`           | no (0.67)      | no (0.13)      | no (0.22) | **yes (0.97)** | no (0.43) | no (0.47) | **1.00** / 0.00 / 0.00       | sec           |
| `defer_in_loop.go`        | **yes (0.79)** | no (0.10)      | no (0.10) | no (0.19)      | no (0.42) | no (0.24) | **0.62** / 0.16 / 0.22       | resource      |
| `log_secret.go`           | no (0.66)      | no (0.39)      | no (0.07) | **yes (0.80)** | no (0.05) | no (0.15) | 0.43 / **0.46** / 0.11       | sec           |
| `mutex_unlock_missing.go` | no (0.56)      | no (0.15)      | no (0.41) | no (0.08)      | no (0.07) | no (0.35) | **0.49** / 0.35 / 0.16       | conc, err     |
| `panic_in_lib.go`         | no (0.20)      | no (0.17)      | no (0.07) | no (0.08)      | no (0.04) | no (0.41) | 0.17 / **0.58** / 0.25       | api, err      |
| `race_on_map.go`          | no (0.17)      | no (0.09)      | no (0.59) | no (0.05)      | no (0.03) | no (0.30) | 0.10 / 0.21 / **0.69**       | conc          |
| `ignore_close_error.go`   | no (0.61)      | no (0.31)      | no (0.32) | no (0.15)      | no (0.56) | no (0.18) | 0.30 / 0.31 / **0.39**       | err, resource |

verdict の最大は 3/10 が bad（`sql_concat` `defer_in_loop` `mutex_unlock_missing`）。外れたのは `no_context_param`（gray 0.63 / bad 0.23）、`swallow_error`（gray 0.63）、`leaky_goroutine`（gray 0.58 / bad 0.40）、`log_secret`（gray 0.46 / bad 0.43）、`panic_in_lib`（gray 0.58）、`race_on_map`（good 0.69）、`ignore_close_error`（good 0.39）。注釈の主タグが 0.70 未満なのは `no_context_param` の api（0.13）、`leaky_goroutine` の conc（0.68）、`defer_in_loop` の resource（0.42）、`mutex_unlock_missing`（conc 0.41 / err 0.15）、`panic_in_lib`（api 0.41 / err 0.17）、`race_on_map` の conc（0.59）、`ignore_close_error`（err 0.31 / resource 0.56）。0.70 以上で注釈にないのは `leaky_goroutine` の err（0.97）、`defer_in_loop` の ctx（0.79）。

## good（10）

| ファイル                 | ctx            | err       | conc      | sec       | resource  | api       | verdict（bad / gray / good） |
| ------------------------ | -------------- | --------- | --------- | --------- | --------- | --------- | ---------------------------- |
| `context_first.go`       | no (0.08)      | no (0.09) | no (0.13) | no (0.10) | no (0.05) | no (0.10) | 0.03 / 0.20 / **0.77**       |
| `error_wrap.go`          | **yes (0.89)** | no (0.08) | no (0.09) | no (0.22) | no (0.08) | no (0.10) | 0.05 / 0.22 / **0.73**       |
| `goroutine_ctx.go`       | no (0.16)      | no (0.24) | no (0.21) | no (0.05) | no (0.16) | no (0.32) | 0.21 / 0.23 / **0.56**       |
| `defer_close.go`         | **yes (0.81)** | no (0.11) | no (0.25) | no (0.21) | no (0.33) | no (0.18) | 0.08 / **0.46** / 0.46       |
| `timeout_query.go`       | no (0.12)      | no (0.11) | no (0.21) | no (0.41) | no (0.37) | no (0.31) | 0.13 / 0.32 / **0.55**       |
| `mutex_guard.go`         | no (0.32)      | no (0.08) | no (0.14) | no (0.06) | no (0.05) | no (0.11) | 0.02 / 0.04 / **0.94**       |
| `structured_log.go`      | no (0.18)      | no (0.12) | no (0.11) | no (0.23) | no (0.05) | no (0.11) | 0.02 / 0.15 / **0.83**       |
| `parallel_fetch.go`      | no (0.17)      | no (0.25) | no (0.48) | no (0.13) | no (0.12) | no (0.28) | 0.34 / **0.47** / 0.19       |
| `table_driven_helper.go` | no (0.21)      | no (0.09) | no (0.05) | no (0.11) | no (0.03) | no (0.10) | 0.03 / 0.19 / **0.78**       |
| `cancel_propagation.go`  | no (0.05)      | no (0.11) | no (0.21) | no (0.06) | no (0.18) | no (0.32) | 0.07 / 0.19 / **0.74**       |

軸が 0.70 以上なのは `error_wrap` ctx（0.89）、`defer_close` ctx（0.81）。verdict の最大は 8/10 が good。外れたのは `defer_close`（gray 0.46 / good 0.46）、`parallel_fetch`（gray 0.47 / bad 0.34 / good 0.19）。

## gray（10）

| ファイル                      | ctx            | err            | conc      | sec       | resource  | api       | verdict（bad / gray / good） | 注釈の主タグ  |
| ----------------------------- | -------------- | -------------- | --------- | --------- | --------- | --------- | ---------------------------- | ------------- |
| `context_todo.go`             | no (0.10)      | no (0.13)      | no (0.22) | no (0.05) | no (0.12) | no (0.19) | 0.10 / 0.34 / **0.56**       | ctx           |
| `log_only_error.go`           | no (0.37)      | **yes (0.72)** | no (0.13) | no (0.31) | no (0.10) | no (0.31) | 0.26 / **0.54** / 0.20       | err, api      |
| `goroutine_wg_no_ctx.go`      | **yes (0.91)** | no (0.61)      | no (0.28) | no (0.08) | no (0.15) | no (0.49) | 0.07 / 0.17 / **0.76**       | conc, ctx     |
| `unexported_no_ctx.go`        | no (0.19)      | no (0.07)      | no (0.06) | no (0.10) | no (0.04) | no (0.11) | 0.27 / **0.50** / 0.23       | ctx, api      |
| `optional_err_ignore.go`      | no (0.55)      | no (0.51)      | no (0.17) | no (0.15) | no (0.62) | no (0.28) | 0.30 / **0.48** / 0.22       | err, resource |
| `rwlock_always_write.go`      | no (0.64)      | no (0.16)      | no (0.56) | no (0.11) | no (0.06) | no (0.18) | **0.52** / 0.32 / 0.16       | conc          |
| `global_background_ctx.go`    | **yes (0.79)** | no (0.37)      | no (0.57) | no (0.06) | no (0.25) | no (0.27) | 0.23 / **0.55** / 0.22       | ctx, conc     |
| `naked_return.go`             | no (0.25)      | no (0.10)      | no (0.06) | no (0.10) | no (0.04) | no (0.14) | 0.33 / **0.46** / 0.21       | api           |
| `unbuffered_signal_chan.go`   | no (0.51)      | no (0.23)      | no (0.28) | no (0.04) | no (0.15) | no (0.31) | 0.05 / 0.10 / **0.85**       | conc          |
| `json_marshal_best_effort.go` | no (0.20)      | **yes (0.96)** | no (0.07) | no (0.26) | no (0.06) | no (0.31) | 0.34 / **0.61** / 0.05       | err           |

軸が 0.70 以上なのは `log_only_error` err（0.72）、`goroutine_wg_no_ctx` ctx（0.91）、`global_background_ctx` ctx（0.79）、`json_marshal_best_effort` err（0.96）。`unbuffered_signal_chan` の主タグは conc（0.28）。verdict の最大は 6/10 が gray。外れたのは `context_todo`（good 0.56）、`goroutine_wg_no_ctx`（good 0.76）、`rwlock_always_write`（bad 0.52）、`unbuffered_signal_chan`（good 0.85）。
