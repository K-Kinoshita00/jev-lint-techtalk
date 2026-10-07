# Claude ベースライン（4 軸判定）

- **判定軸:** ctx / err / conc / sec（`docs/prompts/claude-baseline.md` と同一）
- **記法:** `yes|no (confidence)` — confidence は 0.00〜1.00
- **検出閾値（参考）:** `answer=yes` かつ `confidence ≥ 0.70` を検出とみなす

---

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

## 生 JSON（1 行 / ファイル）

### bad

```
bad/b01_no_context_param.go
{"ctx":{"answer":"yes","confidence":0.97},"err":{"answer":"no","confidence":0.95},"conc":{"answer":"no","confidence":0.95},"sec":{"answer":"no","confidence":0.97}}

bad/b02_swallow_error.go
{"ctx":{"answer":"no","confidence":0.90},"err":{"answer":"yes","confidence":0.98},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.95}}

bad/b03_leaky_goroutine.go
{"ctx":{"answer":"yes","confidence":0.93},"err":{"answer":"no","confidence":0.85},"conc":{"answer":"yes","confidence":0.95},"sec":{"answer":"no","confidence":0.97}}

bad/b04_sql_concat.go
{"ctx":{"answer":"yes","confidence":0.85},"err":{"answer":"no","confidence":0.90},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"yes","confidence":0.99}}

bad/b05_defer_in_loop.go
{"ctx":{"answer":"yes","confidence":0.80},"err":{"answer":"no","confidence":0.90},"conc":{"answer":"no","confidence":0.95},"sec":{"answer":"no","confidence":0.97}}

bad/b06_log_secret.go
{"ctx":{"answer":"no","confidence":0.90},"err":{"answer":"no","confidence":0.95},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"yes","confidence":0.99}}

bad/b07_mutex_unlock_missing.go
{"ctx":{"answer":"no","confidence":0.90},"err":{"answer":"no","confidence":0.90},"conc":{"answer":"yes","confidence":0.95},"sec":{"answer":"no","confidence":0.97}}

bad/b08_panic_in_lib.go
{"ctx":{"answer":"no","confidence":0.95},"err":{"answer":"no","confidence":0.90},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}

bad/b09_race_on_map.go
{"ctx":{"answer":"no","confidence":0.90},"err":{"answer":"no","confidence":0.95},"conc":{"answer":"yes","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}

bad/b10_ignore_close_error.go
{"ctx":{"answer":"no","confidence":0.97},"err":{"answer":"yes","confidence":0.80},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}
```

### good

```
good/g01_context_first.go
{"ctx":{"answer":"no","confidence":0.97},"err":{"answer":"no","confidence":0.97},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}

good/g02_error_wrap.go
{"ctx":{"answer":"no","confidence":0.95},"err":{"answer":"no","confidence":0.97},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}

good/g03_goroutine_ctx.go
{"ctx":{"answer":"no","confidence":0.97},"err":{"answer":"no","confidence":0.95},"conc":{"answer":"no","confidence":0.95},"sec":{"answer":"no","confidence":0.97}}

good/g04_defer_close.go
{"ctx":{"answer":"no","confidence":0.97},"err":{"answer":"no","confidence":0.90},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}

good/g05_timeout_query.go
{"ctx":{"answer":"no","confidence":0.97},"err":{"answer":"no","confidence":0.97},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}

good/g06_mutex_guard.go
{"ctx":{"answer":"no","confidence":0.97},"err":{"answer":"no","confidence":0.97},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}

good/g07_structured_log.go
{"ctx":{"answer":"no","confidence":0.97},"err":{"answer":"no","confidence":0.97},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}

good/g08_parallel_fetch.go
{"ctx":{"answer":"no","confidence":0.97},"err":{"answer":"no","confidence":0.95},"conc":{"answer":"no","confidence":0.95},"sec":{"answer":"no","confidence":0.97}}

good/g09_table_driven_helper.go
{"ctx":{"answer":"no","confidence":0.97},"err":{"answer":"no","confidence":0.97},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}

good/g10_cancel_propagation.go
{"ctx":{"answer":"no","confidence":0.97},"err":{"answer":"no","confidence":0.97},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}
```

### gray

```
gray/y01_context_todo.go
{"ctx":{"answer":"yes","confidence":0.75},"err":{"answer":"no","confidence":0.95},"conc":{"answer":"no","confidence":0.95},"sec":{"answer":"no","confidence":0.97}}

gray/y02_log_only_error.go
{"ctx":{"answer":"no","confidence":0.90},"err":{"answer":"yes","confidence":0.70},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}

gray/y03_goroutine_wg_no_ctx.go
{"ctx":{"answer":"yes","confidence":0.65},"err":{"answer":"no","confidence":0.90},"conc":{"answer":"no","confidence":0.85},"sec":{"answer":"no","confidence":0.97}}

gray/y04_unexported_no_ctx.go
{"ctx":{"answer":"no","confidence":0.80},"err":{"answer":"no","confidence":0.95},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}

gray/y05_optional_err_ignore.go
{"ctx":{"answer":"no","confidence":0.90},"err":{"answer":"yes","confidence":0.70},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}

gray/y06_rwlock_always_write.go
{"ctx":{"answer":"no","confidence":0.95},"err":{"answer":"no","confidence":0.97},"conc":{"answer":"no","confidence":0.90},"sec":{"answer":"no","confidence":0.97}}

gray/y07_global_background_ctx.go
{"ctx":{"answer":"yes","confidence":0.80},"err":{"answer":"no","confidence":0.95},"conc":{"answer":"yes","confidence":0.85},"sec":{"answer":"no","confidence":0.97}}

gray/y08_naked_return.go
{"ctx":{"answer":"no","confidence":0.95},"err":{"answer":"no","confidence":0.95},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}

gray/y09_unbuffered_signal_chan.go
{"ctx":{"answer":"no","confidence":0.90},"err":{"answer":"no","confidence":0.95},"conc":{"answer":"no","confidence":0.90},"sec":{"answer":"no","confidence":0.97}}

gray/y10_json_marshal_best_effort.go
{"ctx":{"answer":"no","confidence":0.95},"err":{"answer":"yes","confidence":0.65},"conc":{"answer":"no","confidence":0.97},"sec":{"answer":"no","confidence":0.97}}
```
