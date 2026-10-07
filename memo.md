# go vet

0件ヒット

# golangci-lint run

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
プロンプト

```
あなたは Go コードの静的レビュアです。修正コードは書かず、判定だけしてください。

以下の Go ソースについて、4 条件それぞれを評価してください。
- answer: "yes" = 問題あり / "no" = 問題なし
- confidence: 0.0〜1.0（確信度）

【条件】
1. ctx: I/O や待ちがあり得る API が context.Context を第一引数で受け取っておらず、キャンセルも考慮されていない
2. err: エラーを無視している、または呼び出し元に返すべきエラーを返していない
3. conc: キャンセル・待ち合わせのない goroutine、または共有 map 等のデータレースの疑い
4. sec: SQL 文字列連結、パスワード等の機微情報ログ

【出力】説明不要。次の JSON のみ。

{"ctx":{"answer":"yes|no","confidence":0.0},"err":{"answer":"yes|no","confidence":0.0},"conc":{"answer":"yes|no","confidence":0.0},"sec":{"answer":"yes|no","confidence":0.0}}

【ソース】
- ./testdata/*/*.go
各ファイルごとに結果を出力して
```
## bad（10）

| ファイル                      | ctx            | err            | conc           | sec            | 注釈の主タグ  |
| ----------------------------- | -------------- | -------------- | -------------- | -------------- | ------------- |
| `b01_no_context_param.go`     | **yes (0.97)** | no (0.95)      | no (0.95)      | no (0.97)      | ctx, api      |
| `b02_swallow_error.go`        | no (0.90)      | **yes (0.98)** | no (0.97)      | no (0.95)      | err           |
| `b03_leaky_goroutine.go`      | **yes (0.93)** | no (0.85)      | **yes (0.95)** | no (0.97)      | conc, ctx     |
| `b04_sql_concat.go`           | yes (0.85)     | no (0.90)      | no (0.97)      | **yes (0.99)** | sec           |
| `b05_defer_in_loop.go`        | yes (0.80)     | no (0.90)      | no (0.95)      | no (0.97)      | resource ※    |
| `b06_log_secret.go`           | no (0.90)      | no (0.95)      | no (0.97)      | **yes (0.99)** | sec           |
| `b07_mutex_unlock_missing.go` | no (0.90)      | no (0.90)      | **yes (0.95)** | no (0.97)      | conc, err     |
| `b08_panic_in_lib.go`         | no (0.95)      | no (0.90)      | no (0.97)      | no (0.97)      | api, err      |
| `b09_race_on_map.go`          | no (0.90)      | no (0.95)      | **yes (0.97)** | no (0.97)      | conc          |
| `b10_ignore_close_error.go`   | no (0.97)      | **yes (0.80)** | no (0.97)      | no (0.97)      | err, resource |

※ `b05` の主題（ループ内 defer）は 4 軸に無く、ctx のみ ≥0.70 で検出。

### bad サマリ（confidence ≥ 0.70）

| 観点                            | 件数                   |
| ------------------------------- | ---------------------- |
| 注釈タグのいずれかが 4 軸で検出 | 9/10                   |
| 検出弱 / 未検出                 | `b08`（4 軸すべて no） |
| 4 軸外の主題                    | `b05`（resource）      |

---

## good（10）

| ファイル                     | ctx       | err       | conc      | sec       |
| ---------------------------- | --------- | --------- | --------- | --------- |
| `g01_context_first.go`       | no (0.97) | no (0.97) | no (0.97) | no (0.97) |
| `g02_error_wrap.go`          | no (0.95) | no (0.97) | no (0.97) | no (0.97) |
| `g03_goroutine_ctx.go`       | no (0.97) | no (0.95) | no (0.95) | no (0.97) |
| `g04_defer_close.go`         | no (0.97) | no (0.90) | no (0.97) | no (0.97) |
| `g05_timeout_query.go`       | no (0.97) | no (0.97) | no (0.97) | no (0.97) |
| `g06_mutex_guard.go`         | no (0.97) | no (0.97) | no (0.97) | no (0.97) |
| `g07_structured_log.go`      | no (0.97) | no (0.97) | no (0.97) | no (0.97) |
| `g08_parallel_fetch.go`      | no (0.97) | no (0.95) | no (0.95) | no (0.97) |
| `g09_table_driven_helper.go` | no (0.97) | no (0.97) | no (0.97) | no (0.97) |
| `g10_cancel_propagation.go`  | no (0.97) | no (0.97) | no (0.97) | no (0.97) |

### good サマリ

- **4 軸すべて no（≥0.70 でも yes なし）:** 10/10
- **補足:** `g04` は golangci-lint errcheck 対象だが、Claude は err=no (0.90)

---

## gray（10）

| ファイル                          | ctx            | err            | conc           | sec       | 注釈の主タグ  |
| --------------------------------- | -------------- | -------------- | -------------- | --------- | ------------- |
| `y01_context_todo.go`             | **yes (0.75)** | no (0.95)      | no (0.95)      | no (0.97) | ctx           |
| `y02_log_only_error.go`           | no (0.90)      | **yes (0.70)** | no (0.97)      | no (0.97) | err, api      |
| `y03_goroutine_wg_no_ctx.go`      | no (0.65)      | no (0.90)      | no (0.85)      | no (0.97) | conc, ctx     |
| `y04_unexported_no_ctx.go`        | no (0.80)      | no (0.95)      | no (0.97)      | no (0.97) | ctx, api      |
| `y05_optional_err_ignore.go`      | no (0.90)      | **yes (0.70)** | no (0.97)      | no (0.97) | err, resource |
| `y06_rwlock_always_write.go`      | no (0.95)      | no (0.97)      | no (0.90)      | no (0.97) | conc          |
| `y07_global_background_ctx.go`    | **yes (0.80)** | no (0.95)      | **yes (0.85)** | no (0.97) | ctx, conc     |
| `y08_naked_return.go`             | no (0.95)      | no (0.95)      | no (0.97)      | no (0.97) | api           |
| `y09_unbuffered_signal_chan.go`   | no (0.90)      | no (0.95)      | no (0.90)      | no (0.97) | conc          |
| `y10_json_marshal_best_effort.go` | no (0.95)      | no (0.65)      | no (0.97)      | no (0.97) | err           |

### gray サマリ（confidence ≥ 0.70 の yes）

| ファイル | 検出軸    |
| -------- | --------- |
| `y01`    | ctx       |
| `y02`    | err       |
| `y05`    | err       |
| `y07`    | ctx, conc |

---

# JEV

- **モデル:** jev-1.13.0（リクエスト指定 `jev-latest`）
- **閾値:** noul ≥ 0.75 を検出（表の太字）
- **usage 合計:** input 15866 / output 2040 tokens（30 ファイル）
- **詳細:** [docs/baseline-jev.md](docs/baseline-jev.md)

再実行:

```bash
set -a && source .env && set +a
./scripts/run-jev-baseline.sh
./scripts/render-jev-baseline-md.sh
```

## bad（10）

| ファイル                      | ctx            | err            | conc           | sec            | 注釈の主タグ  |
| ----------------------------- | -------------- | -------------- | -------------- | -------------- | ------------- |
| `b01_no_context_param.go`     | **yes (0.91)** | no (0.20)      | no (0.11)      | no (0.12)      | ctx, api      |
| `b02_swallow_error.go`        | **yes (0.90)** | **yes (0.98)** | no (0.06)      | no (0.19)      | err           |
| `b03_leaky_goroutine.go`      | **yes (0.96)** | **yes (0.98)** | **yes (0.90)** | no (0.12)      | conc, ctx     |
| `b04_sql_concat.go`           | **yes (0.93)** | no (0.26)      | no (0.08)      | **yes (0.87)** | sec           |
| `b05_defer_in_loop.go`        | **yes (0.94)** | no (0.10)      | no (0.05)      | no (0.12)      | resource ※    |
| `b06_log_secret.go`           | no (0.69)      | no (0.67)      | no (0.05)      | **yes (0.91)** | sec           |
| `b07_mutex_unlock_missing.go` | no (0.45)      | no (0.29)      | no (0.34)      | no (0.14)      | conc, err     |
| `b08_panic_in_lib.go`         | no (0.17)      | no (0.45)      | no (0.05)      | no (0.14)      | api, err      |
| `b09_race_on_map.go`          | no (0.22)      | no (0.26)      | no (0.64)      | no (0.14)      | conc          |
| `b10_ignore_close_error.go`   | no (0.09)      | no (0.58)      | no (0.11)      | no (0.12)      | err, resource |

※ `b05` 主題はループ内 defer（4 軸外）。**b07/b08/b09/b10** は Claude より検出弱い。

## good（10）

| ファイル                     | ctx      | err      | conc     | sec      |
| ---------------------------- | -------- | -------- | -------- | -------- |
| `g01_context_first.go`       | no (0.05) | no (0.08) | no (0.07) | no (0.18) |
| `g02_error_wrap.go`          | no (0.23) | no (0.09) | no (0.05) | no (0.20) |
| `g03_goroutine_ctx.go`       | no (0.07) | no (0.28) | no (0.14) | no (0.12) |
| `g04_defer_close.go`         | no (0.08) | no (0.09) | no (0.07) | no (0.17) |
| `g05_timeout_query.go`       | no (0.07) | no (0.11) | no (0.10) | no (0.24) |
| `g06_mutex_guard.go`         | no (0.38) | no (0.11) | no (0.10) | no (0.12) |
| `g07_structured_log.go`      | no (0.10) | no (0.16) | no (0.06) | no (0.14) |
| `g08_parallel_fetch.go`      | no (0.11) | no (0.16) | no (0.55) | no (0.17) |
| `g09_table_driven_helper.go` | no (0.24) | no (0.18) | no (0.03) | no (0.17) |
| `g10_cancel_propagation.go`  | no (0.10) | no (0.12) | no (0.09) | no (0.17) |

good は閾値 0.75 以上の軸なし（**g08 conc 0.55** は gray 寄りだが no 扱い）。

## gray（10）

| ファイル                          | ctx            | err            | conc      | sec           | 注釈の主タグ  |
| --------------------------------- | -------------- | -------------- | --------- | ------------- | ------------- |
| `y01_context_todo.go`             | no (0.20)      | no (0.14)      | no (0.07) | no (0.09)     | ctx           |
| `y02_log_only_error.go`           | no (0.10)      | no (0.56)      | no (0.09) | no (0.19)     | err, api      |
| `y03_goroutine_wg_no_ctx.go`      | **yes (0.92)** | no (0.67)      | no (0.21) | no (0.19)     | conc, ctx     |
| `y04_unexported_no_ctx.go`        | no (0.26)      | no (0.07)      | no (0.04) | no (0.13)     | ctx, api      |
| `y05_optional_err_ignore.go`      | no (0.06)      | no (0.72)      | no (0.08) | no (0.16)     | err, resource |
| `y06_rwlock_always_write.go`      | no (0.61)      | no (0.20)      | no (0.39) | no (0.23)     | conc          |
| `y07_global_background_ctx.go`    | no (0.73)      | no (0.52)      | no (0.54) | no (0.13)     | ctx, conc     |
| `y08_naked_return.go`             | no (0.28)      | no (0.13)      | no (0.05) | no (0.16)     | api           |
| `y09_unbuffered_signal_chan.go`   | **yes (0.89)** | no (0.35)      | no (0.17) | no (0.18)     | conc          |
| `y10_json_marshal_best_effort.go` | no (0.22)      | **yes (0.95)** | no (0.06) | no (0.22)     | err           |
