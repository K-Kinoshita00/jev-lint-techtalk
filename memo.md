1. ctx: I/O や待ちがあり得る API が context.Context を第一引数で受け取っておらず、キャンセルも考慮されていない
2. err: エラーを無視している、または呼び出し元に返すべきエラーを返していない
3. conc: キャンセル・待ち合わせのない goroutine、または共有 map 等のデータレースの疑い
4. sec: SQL 文字列連結、パスワード等の機微情報ログ
5. resource: ループ内の defer で Close が関数終了まで遅れる、または書き込み後の Close エラーを無視している
6. api: ライブラリや公開関数が通常の入力不備で panic する、または naked return で戻り値の契約が不明瞭

bad: 呼び出し方によらず明確に直すべき欠陥
gray: 文脈次第で許容にも要修正にもなる
good: 一般的な Go の慣習に沿っている

# go vet

0件ヒット

# golangci-lint run
gosec や contextcheck を足した結果ではない

3件ヒット

```bash
testdata/bad/b05_defer_in_loop.go:15:16: Error return value of `f.Close` is not checked (errcheck)
                defer f.Close()
                             ^
testdata/good/g04_defer_close.go:18:17: Error return value of `src.Close` is not checked (errcheck)
        defer src.Close()
                       ^
testdata/good/g04_defer_close.go:24:17: Error return value of `dst.Close` is not checked (errcheck)
        defer dst.Close()
                       ^
3 issues:
* errcheck: 3
```

# claude

sonnet 4.6
Total cost: $0.4939（$0.5前後）
Total duration (API): 2m 59s
Total duration (wall): 3m 37s
Total code changes: 0 lines added, 0 lines removed
Usage by model:
claude-haiku-4-5: 1.5k input, 12 output, 0 cache read, 0 cache write ($0.0016)
claude-sonnet-4-6: 7 input, 13.0k output, 221.6k cache read, 61.4k cache write ($0.4923)
Prompt cache (main): 5 requests · 78% of input tokens from cache · no misses · warm (5m TTL, last activity 2m 46s ago)

プロンプト

```
あなたは Go コードの静的レビュアです。修正コードは書かず、判定だけしてください。

以下の Go ソースについて、6 軸それぞれの「問題あり」確率と、ファイル区分の確率を出してください。
- 軸: 0.0〜1.0。1.0 に近いほど問題あり。yes/no は書かない。
- verdict: bad / gray / good の確率。合計は 1.0。
- 判定に使ってよいのはソース本文だけ。ディレクトリ名、ファイル名、package 句はラベルではないので無視する。見出しのパスはどのファイルかの識別用であり、根拠にしない。
- 出力する値は小数第2位まで。0.05 刻みに丸めない

【6軸】
1. ctx: I/O や待ちがあり得る API が context.Context を第一引数で受け取っておらず、キャンセルも考慮されていない
2. err: エラーを無視している、または呼び出し元に返すべきエラーを返していない
3. conc: キャンセル・待ち合わせのない goroutine、または共有 map 等のデータレースの疑い
4. sec: SQL 文字列連結、パスワード等の機微情報ログ
5. resource: ループ内の defer で Close が関数終了まで遅れる、または書き込み後の Close エラーを無視している
6. api: ライブラリや公開関数が通常の入力不備で panic する、または naked return で戻り値の契約が不明瞭

【3区分】
- bad: 呼び出し方によらず明確に直すべき欠陥
- gray: 文脈次第で許容にも要修正にもなる
- good: 一般的な Go の慣習に沿っている

【出力】説明不要。補足不要。次の JSON のみ。

{"ctx":0.0,"err":0.0,"conc":0.0,"sec":0.0,"resource":0.0,"api":0.0,"verdict":{"bad":0.0,"gray":0.0,"good":0.0}}

【ソース】
- ./testdata/*.go
各ファイルごとに結果を出力して
```

6軸の問題あり確率と verdict。軸の太字は ≥ 0.70。verdict の太字は最大。

## bad（10）

| ファイル                      | ctx            | err            | conc           | sec            | resource       | api            | verdict（bad / gray / good） | 注釈の主タグ  |
| ----------------------------- | -------------- | -------------- | -------------- | -------------- | -------------- | -------------- | ---------------------------- | ------------- |
| `b01_no_context_param.go`     | **yes (0.93)** | no (0.05)      | no (0.05)      | no (0.05)      | no (0.05)      | no (0.05)      | **0.82** / 0.14 / 0.04       | ctx, api      |
| `b02_swallow_error.go`        | no (0.05)      | **yes (0.92)** | no (0.05)      | no (0.05)      | no (0.05)      | no (0.05)      | **0.80** / 0.16 / 0.04       | err           |
| `b03_leaky_goroutine.go`      | **yes (0.92)** | no (0.20)      | **yes (0.95)** | no (0.05)      | no (0.05)      | no (0.05)      | **0.90** / 0.08 / 0.02       | conc, ctx     |
| `b04_sql_concat.go`           | **yes (0.88)** | no (0.05)      | no (0.05)      | **yes (0.97)** | no (0.05)      | no (0.05)      | **0.92** / 0.07 / 0.01       | sec           |
| `b05_defer_in_loop.go`        | no (0.55)      | no (0.05)      | no (0.05)      | no (0.05)      | **yes (0.93)** | no (0.05)      | **0.82** / 0.15 / 0.03       | resource      |
| `b06_log_secret.go`           | no (0.05)      | no (0.05)      | no (0.05)      | **yes (0.97)** | no (0.05)      | no (0.05)      | **0.93** / 0.06 / 0.01       | sec           |
| `b07_mutex_unlock_missing.go` | no (0.05)      | no (0.05)      | **yes (0.95)** | no (0.05)      | no (0.05)      | no (0.05)      | **0.90** / 0.08 / 0.02       | conc, err     |
| `b08_panic_in_lib.go`         | no (0.05)      | no (0.05)      | no (0.05)      | no (0.05)      | no (0.05)      | **yes (0.72)** | 0.22 / **0.62** / 0.16       | api, err      |
| `b09_race_on_map.go`          | no (0.05)      | no (0.05)      | no (0.68)      | no (0.05)      | no (0.05)      | no (0.05)      | 0.32 / **0.55** / 0.13       | conc          |
| `b10_ignore_close_error.go`   | no (0.05)      | no (0.05)      | no (0.05)      | no (0.05)      | **yes (0.90)** | no (0.05)      | **0.72** / 0.23 / 0.05       | err, resource |

verdict の最大は 9/10 が bad。外れたのは `b08`（gray 0.62 / bad 0.22 / good 0.16）、`b09`（gray 0.55 / bad 0.32 / good 0.13）。注釈の主タグが 0.70 未満なのは `b01` の api（0.05）、`b07` の err（0.05）、`b08` の err（0.05）、`b09` の conc（0.68）、`b10` の err（0.05）。0.70 以上で注釈にないのは `b04` の ctx（0.88）。

## good（10）

| ファイル                     | ctx       | err       | conc      | sec       | resource       | api       | verdict（bad / gray / good） |
| ---------------------------- | --------- | --------- | --------- | --------- | -------------- | --------- | ---------------------------- |
| `g01_context_first.go`       | no (0.05) | no (0.05) | no (0.05) | no (0.05) | no (0.05)      | no (0.05) | 0.03 / 0.10 / **0.87**       |
| `g02_error_wrap.go`          | no (0.58) | no (0.05) | no (0.05) | no (0.05) | no (0.05)      | no (0.05) | 0.12 / **0.70** / 0.18       |
| `g03_goroutine_ctx.go`       | no (0.05) | no (0.05) | no (0.55) | no (0.05) | no (0.05)      | no (0.05) | 0.15 / **0.65** / 0.20       |
| `g04_defer_close.go`         | no (0.05) | no (0.10) | no (0.05) | no (0.05) | **yes (0.72)** | no (0.05) | 0.25 / **0.62** / 0.13       |
| `g05_timeout_query.go`       | no (0.05) | no (0.05) | no (0.05) | no (0.05) | no (0.05)      | no (0.05) | 0.03 / 0.10 / **0.87**       |
| `g06_mutex_guard.go`         | no (0.05) | no (0.05) | no (0.05) | no (0.05) | no (0.05)      | no (0.05) | 0.03 / 0.10 / **0.87**       |
| `g07_structured_log.go`      | no (0.05) | no (0.05) | no (0.05) | no (0.05) | no (0.05)      | no (0.05) | 0.03 / 0.10 / **0.87**       |
| `g08_parallel_fetch.go`      | no (0.05) | no (0.05) | no (0.12) | no (0.05) | no (0.05)      | no (0.05) | 0.05 / 0.18 / **0.77**       |
| `g09_table_driven_helper.go` | no (0.05) | no (0.05) | no (0.05) | no (0.05) | no (0.05)      | no (0.05) | 0.03 / 0.10 / **0.87**       |
| `g10_cancel_propagation.go`  | no (0.05) | no (0.05) | no (0.05) | no (0.05) | no (0.05)      | no (0.05) | 0.03 / 0.10 / **0.87**       |

軸が 0.70 以上なのは `g04` resource（0.72）。verdict の最大は 7/10 が good。外れたのは `g02`（gray 0.70 / good 0.18 / bad 0.12）、`g03`（gray 0.65 / good 0.20 / bad 0.15）、`g04`（gray 0.62 / bad 0.25 / good 0.13）。`g02` は ctx 0.58、`g03` は conc 0.55。

## gray（10）

| ファイル                          | ctx            | err            | conc           | sec       | resource  | api       | verdict（bad / gray / good） | 注釈の主タグ  |
| --------------------------------- | -------------- | -------------- | -------------- | --------- | --------- | --------- | ---------------------------- | ------------- |
| `y01_context_todo.go`             | **yes (0.72)** | no (0.05)      | no (0.08)      | no (0.05) | no (0.05) | no (0.05) | 0.18 / **0.67** / 0.15       | ctx           |
| `y02_log_only_error.go`           | no (0.05)      | no (0.68)      | no (0.05)      | no (0.05) | no (0.05) | no (0.05) | 0.18 / **0.68** / 0.14       | err, api      |
| `y03_goroutine_wg_no_ctx.go`      | no (0.55)      | no (0.05)      | no (0.15)      | no (0.05) | no (0.05) | no (0.05) | 0.10 / **0.68** / 0.22       | conc, ctx     |
| `y04_unexported_no_ctx.go`        | no (0.05)      | no (0.05)      | no (0.05)      | no (0.05) | no (0.05) | no (0.05) | 0.03 / 0.10 / **0.87**       | ctx, api      |
| `y05_optional_err_ignore.go`      | no (0.05)      | no (0.05)      | no (0.05)      | no (0.05) | no (0.48) | no (0.05) | 0.12 / **0.65** / 0.23       | err, resource |
| `y06_rwlock_always_write.go`      | no (0.05)      | no (0.05)      | **yes (0.75)** | no (0.05) | no (0.05) | no (0.05) | 0.20 / **0.68** / 0.12       | conc          |
| `y07_global_background_ctx.go`    | **yes (0.85)** | no (0.05)      | no (0.62)      | no (0.05) | no (0.05) | no (0.05) | **0.72** / 0.23 / 0.05       | ctx, conc     |
| `y08_naked_return.go`             | no (0.05)      | no (0.05)      | no (0.05)      | no (0.05) | no (0.05) | no (0.62) | 0.12 / **0.72** / 0.16       | api           |
| `y09_unbuffered_signal_chan.go`   | no (0.05)      | no (0.05)      | no (0.35)      | no (0.05) | no (0.05) | no (0.05) | 0.10 / **0.55** / 0.35       | conc          |
| `y10_json_marshal_best_effort.go` | no (0.05)      | **yes (0.80)** | no (0.05)      | no (0.05) | no (0.05) | no (0.10) | 0.22 / **0.62** / 0.16       | err           |

軸が 0.70 以上なのは `y01` ctx（0.72）、`y06` conc（0.75）、`y07` ctx（0.85）、`y10` err（0.80）。verdict の最大は 8/10 が gray。外れたのは `y04`（good 0.87 / gray 0.10）、`y07`（bad 0.72 / gray 0.23）。

---

# JEV

- **モデル:** jev-1.13.0（リクエスト指定 `jev-latest`）
- **閾値:** noul ≥ 0.70 を検出（表の太字）
- **usage 合計:** input 22292 / output 4050 tokens（30 ファイル）/ $0.0009

再実行:

```bash
set -a && source .env && set +a
./scripts/run-jev-baseline.sh
./scripts/render-jev-baseline-md.sh
```

6軸 noul（ctx / err / conc / sec / resource / api）とファイル区分 choice（verdict）。生データは [docs/jev-choice2-raw.jsonl](docs/jev-choice2-raw.jsonl)。verdict は bad / gray / good の確率。太字は最大。

## bad（10）

| ファイル                      | ctx            | err            | conc           | sec            | resource       | api            | verdict（bad / gray / good） | 注釈の主タグ  |
| ----------------------------- | -------------- | -------------- | -------------- | -------------- | -------------- | -------------- | ---------------------------- | ------------- |
| `b01_no_context_param.go`     | **yes (0.93)** | no (0.19)      | no (0.11)      | no (0.12)      | no (0.06)      | no (0.09)      | **0.85** / 0.11 / 0.04       | ctx, api      |
| `b02_swallow_error.go`        | **yes (0.91)** | **yes (0.98)** | no (0.07)      | no (0.19)      | no (0.17)      | no (0.42)      | **0.65** / 0.28 / 0.07       | err           |
| `b03_leaky_goroutine.go`      | **yes (0.96)** | **yes (0.97)** | **yes (0.91)** | no (0.13)      | no (0.13)      | no (0.35)      | **0.84** / 0.15 / 0.01       | conc, ctx     |
| `b04_sql_concat.go`           | **yes (0.94)** | no (0.30)      | no (0.07)      | **yes (0.89)** | no (0.12)      | no (0.25)      | **1.00** / 0.00 / 0.00       | sec           |
| `b05_defer_in_loop.go`        | **yes (0.94)** | no (0.09)      | no (0.05)      | no (0.11)      | **yes (0.88)** | no (0.13)      | **0.84** / 0.09 / 0.07       | resource      |
| `b06_log_secret.go`           | no (0.68)      | no (0.63)      | no (0.05)      | **yes (0.90)** | no (0.06)      | no (0.12)      | **0.95** / 0.04 / 0.01       | sec           |
| `b07_mutex_unlock_missing.go` | no (0.42)      | no (0.27)      | no (0.28)      | no (0.17)      | no (0.07)      | no (0.22)      | **0.84** / 0.12 / 0.04       | conc, err     |
| `b08_panic_in_lib.go`         | no (0.16)      | no (0.47)      | no (0.05)      | no (0.14)      | no (0.05)      | **yes (0.88)** | **0.75** / 0.15 / 0.10       | api, err      |
| `b09_race_on_map.go`          | no (0.23)      | no (0.28)      | no (0.62)      | no (0.14)      | no (0.07)      | no (0.35)      | **0.39** / 0.33 / 0.28       | conc          |
| `b10_ignore_close_error.go`   | no (0.07)      | no (0.63)      | no (0.09)      | no (0.14)      | no (0.65)      | no (0.22)      | **0.79** / 0.09 / 0.12       | err, resource |

verdict は 10/10 が bad。noul で 0.70 未満のままなのは `b07` / `b09` / `b10`。`b09` は bad 0.39 / gray 0.33 / good 0.28（confidence 0.09）。

## good（10）

| ファイル                     | ctx       | err       | conc      | sec       | resource  | api       | verdict（bad / gray / good） |
| ---------------------------- | --------- | --------- | --------- | --------- | --------- | --------- | ---------------------------- |
| `g01_context_first.go`       | no (0.05) | no (0.08) | no (0.08) | no (0.16) | no (0.03) | no (0.05) | 0.03 / 0.08 / **0.89**       |
| `g02_error_wrap.go`          | no (0.19) | no (0.09) | no (0.05) | no (0.18) | no (0.03) | no (0.06) | 0.04 / 0.08 / **0.88**       |
| `g03_goroutine_ctx.go`       | no (0.07) | no (0.29) | no (0.13) | no (0.10) | no (0.09) | no (0.25) | 0.25 / 0.18 / **0.57**       |
| `g04_defer_close.go`         | no (0.09) | no (0.10) | no (0.09) | no (0.15) | no (0.32) | no (0.09) | 0.10 / 0.24 / **0.66**       |
| `g05_timeout_query.go`       | no (0.07) | no (0.11) | no (0.09) | no (0.27) | no (0.13) | no (0.16) | 0.14 / 0.17 / **0.69**       |
| `g06_mutex_guard.go`         | no (0.38) | no (0.10) | no (0.11) | no (0.13) | no (0.04) | no (0.08) | 0.02 / 0.03 / **0.95**       |
| `g07_structured_log.go`      | no (0.08) | no (0.18) | no (0.07) | no (0.14) | no (0.05) | no (0.07) | 0.01 / 0.03 / **0.96**       |
| `g08_parallel_fetch.go`      | no (0.12) | no (0.16) | no (0.53) | no (0.17) | no (0.06) | no (0.18) | 0.24 / 0.28 / **0.48**       |
| `g09_table_driven_helper.go` | no (0.22) | no (0.19) | no (0.03) | no (0.18) | no (0.04) | no (0.05) | 0.05 / 0.13 / **0.82**       |
| `g10_cancel_propagation.go`  | no (0.11) | no (0.13) | no (0.10) | no (0.17) | no (0.07) | no (0.19) | 0.07 / 0.11 / **0.82**       |

noul は 0.70 以上の軸なし（**g08 conc 0.53**）。verdict は 10/10 が good。`g08` は good 0.48 / gray 0.28 / bad 0.24（confidence 0.22）。

## gray（10）

| ファイル                          | ctx            | err            | conc      | sec       | resource  | api       | verdict（bad / gray / good） | 注釈の主タグ  |
| --------------------------------- | -------------- | -------------- | --------- | --------- | --------- | --------- | ---------------------------- | ------------- |
| `y01_context_todo.go`             | no (0.18)      | no (0.13)      | no (0.07) | no (0.09) | no (0.04) | no (0.11) | 0.17 / **0.64** / 0.19       | ctx           |
| `y02_log_only_error.go`           | no (0.10)      | no (0.67)      | no (0.09) | no (0.20) | no (0.04) | no (0.15) | 0.42 / **0.54** / 0.04       | err, api      |
| `y03_goroutine_wg_no_ctx.go`      | **yes (0.90)** | no (0.56)      | no (0.19) | no (0.19) | no (0.12) | no (0.20) | 0.08 / **0.50** / 0.42       | conc, ctx     |
| `y04_unexported_no_ctx.go`        | no (0.28)      | no (0.07)      | no (0.04) | no (0.14) | no (0.06) | no (0.06) | 0.12 / **0.74** / 0.14       | ctx, api      |
| `y05_optional_err_ignore.go`      | no (0.06)      | **yes (0.71)** | no (0.07) | no (0.15) | no (0.18) | no (0.10) | 0.28 / **0.61** / 0.11       | err, resource |
| `y06_rwlock_always_write.go`      | no (0.63)      | no (0.20)      | no (0.31) | no (0.22) | no (0.05) | no (0.13) | 0.24 / **0.50** / 0.26       | conc          |
| `y07_global_background_ctx.go`    | **yes (0.72)** | no (0.55)      | no (0.52) | no (0.13) | no (0.09) | no (0.24) | 0.27 / **0.60** / 0.13       | ctx, conc     |
| `y08_naked_return.go`             | no (0.29)      | no (0.13)      | no (0.05) | no (0.15) | no (0.03) | no (0.13) | 0.29 / **0.53** / 0.18       | api           |
| `y09_unbuffered_signal_chan.go`   | **yes (0.90)** | no (0.36)      | no (0.17) | no (0.15) | no (0.11) | no (0.23) | 0.06 / 0.32 / **0.62**       | conc          |
| `y10_json_marshal_best_effort.go` | no (0.23)      | **yes (0.96)** | no (0.06) | no (0.24) | no (0.08) | no (0.17) | 0.27 / **0.70** / 0.03       | err           |

verdict は 9/10 が gray。外れたのは `y09`（good 0.62 / gray 0.32 / bad 0.06）。
