# JEV ベースライン（4 軸 Noul）

- **判定軸:** ctx / err / conc / sec（Claude ベースラインと同一 instructions）
- **記法:** `yes|no (noul)` — `noul` は問題あり確率 0.00〜1.00
- **検出閾値（表の太字）:** `noul ≥ 0.75`
- **モデル:** `jev-1.13.0`（30 ファイル）
- **usage 合計:** input 15866 / output 2040 tokens
- **生データ:** [baseline-jev-raw.jsonl](./baseline-jev-raw.jsonl)

---

## bad（10）

| ファイル | ctx | err | conc | sec | 注釈の主タグ |
|----------|-----|-----|------|-----|--------------|
| `b01_no_context_param.go` | **yes (0.91)** | no (0.20) | no (0.11) | no (0.12) | ctx, api |
| `b02_swallow_error.go` | **yes (0.90)** | **yes (0.98)** | no (0.06) | no (0.19) | err |
| `b03_leaky_goroutine.go` | **yes (0.96)** | **yes (0.98)** | **yes (0.90)** | no (0.12) | conc, ctx |
| `b04_sql_concat.go` | **yes (0.93)** | no (0.26) | no (0.08) | **yes (0.87)** | sec |
| `b05_defer_in_loop.go` | **yes (0.94)** | no (0.10) | no (0.05) | no (0.12) | resource ※ |
| `b06_log_secret.go` | no (0.69) | no (0.67) | no (0.05) | **yes (0.91)** | sec |
| `b07_mutex_unlock_missing.go` | no (0.45) | no (0.29) | no (0.34) | no (0.14) | conc, err |
| `b08_panic_in_lib.go` | no (0.17) | no (0.45) | no (0.05) | no (0.14) | api, err |
| `b09_race_on_map.go` | no (0.22) | no (0.26) | no (0.64) | no (0.14) | conc |
| `b10_ignore_close_error.go` | no (0.09) | no (0.58) | no (0.11) | no (0.12) | err, resource |

※ `b05` の主題（ループ内 defer）は 4 軸に無い。

---

## good（10）

| ファイル | ctx | err | conc | sec |
|----------|-----|-----|------|-----|
| `g01_context_first.go` | no (0.05) | no (0.08) | no (0.07) | no (0.18) |
| `g02_error_wrap.go` | no (0.23) | no (0.09) | no (0.05) | no (0.20) |
| `g03_goroutine_ctx.go` | no (0.07) | no (0.28) | no (0.14) | no (0.12) |
| `g04_defer_close.go` | no (0.08) | no (0.09) | no (0.07) | no (0.17) |
| `g05_timeout_query.go` | no (0.07) | no (0.11) | no (0.10) | no (0.24) |
| `g06_mutex_guard.go` | no (0.38) | no (0.11) | no (0.10) | no (0.12) |
| `g07_structured_log.go` | no (0.10) | no (0.16) | no (0.06) | no (0.14) |
| `g08_parallel_fetch.go` | no (0.11) | no (0.16) | no (0.55) | no (0.17) |
| `g09_table_driven_helper.go` | no (0.24) | no (0.18) | no (0.03) | no (0.17) |
| `g10_cancel_propagation.go` | no (0.10) | no (0.12) | no (0.09) | no (0.17) |

---

## gray（10）

| ファイル | ctx | err | conc | sec | 注釈の主タグ |
|----------|-----|-----|------|-----|--------------|
| `y01_context_todo.go` | no (0.20) | no (0.14) | no (0.07) | no (0.09) | ctx |
| `y02_log_only_error.go` | no (0.10) | no (0.56) | no (0.09) | no (0.19) | err, api |
| `y03_goroutine_wg_no_ctx.go` | **yes (0.92)** | no (0.67) | no (0.21) | no (0.19) | conc, ctx |
| `y04_unexported_no_ctx.go` | no (0.26) | no (0.07) | no (0.04) | no (0.13) | ctx, api |
| `y05_optional_err_ignore.go` | no (0.06) | no (0.72) | no (0.08) | no (0.16) | err, resource |
| `y06_rwlock_always_write.go` | no (0.61) | no (0.20) | no (0.39) | no (0.23) | conc |
| `y07_global_background_ctx.go` | no (0.73) | no (0.52) | no (0.54) | no (0.13) | ctx, conc |
| `y08_naked_return.go` | no (0.28) | no (0.13) | no (0.05) | no (0.16) | api |
| `y09_unbuffered_signal_chan.go` | **yes (0.89)** | no (0.35) | no (0.17) | no (0.18) | conc |
| `y10_json_marshal_best_effort.go` | no (0.22) | **yes (0.95)** | no (0.06) | no (0.22) | err |

---

## 生 JSON（1 行 / ファイル）

`testdata/bad/b01_no_context_param.go`
```
{"ctx":{"type":"noul","noul":0.91},"err":{"type":"noul","noul":0.2},"conc":{"type":"noul","noul":0.11},"sec":{"type":"noul","noul":0.12}}
```

`testdata/bad/b02_swallow_error.go`
```
{"ctx":{"type":"noul","noul":0.9},"err":{"type":"noul","noul":0.98},"conc":{"type":"noul","noul":0.06},"sec":{"type":"noul","noul":0.19}}
```

`testdata/bad/b03_leaky_goroutine.go`
```
{"ctx":{"type":"noul","noul":0.96},"err":{"type":"noul","noul":0.98},"conc":{"type":"noul","noul":0.9},"sec":{"type":"noul","noul":0.12}}
```

`testdata/bad/b04_sql_concat.go`
```
{"ctx":{"type":"noul","noul":0.93},"err":{"type":"noul","noul":0.26},"conc":{"type":"noul","noul":0.08},"sec":{"type":"noul","noul":0.87}}
```

`testdata/bad/b05_defer_in_loop.go`
```
{"ctx":{"type":"noul","noul":0.94},"err":{"type":"noul","noul":0.1},"conc":{"type":"noul","noul":0.05},"sec":{"type":"noul","noul":0.12}}
```

`testdata/bad/b06_log_secret.go`
```
{"ctx":{"type":"noul","noul":0.69},"err":{"type":"noul","noul":0.67},"conc":{"type":"noul","noul":0.05},"sec":{"type":"noul","noul":0.91}}
```

`testdata/bad/b07_mutex_unlock_missing.go`
```
{"ctx":{"type":"noul","noul":0.45},"err":{"type":"noul","noul":0.29},"conc":{"type":"noul","noul":0.34},"sec":{"type":"noul","noul":0.14}}
```

`testdata/bad/b08_panic_in_lib.go`
```
{"ctx":{"type":"noul","noul":0.17},"err":{"type":"noul","noul":0.45},"conc":{"type":"noul","noul":0.05},"sec":{"type":"noul","noul":0.14}}
```

`testdata/bad/b09_race_on_map.go`
```
{"ctx":{"type":"noul","noul":0.22},"err":{"type":"noul","noul":0.26},"conc":{"type":"noul","noul":0.64},"sec":{"type":"noul","noul":0.14}}
```

`testdata/bad/b10_ignore_close_error.go`
```
{"ctx":{"type":"noul","noul":0.09},"err":{"type":"noul","noul":0.58},"conc":{"type":"noul","noul":0.11},"sec":{"type":"noul","noul":0.12}}
```

`testdata/good/g01_context_first.go`
```
{"ctx":{"type":"noul","noul":0.05},"err":{"type":"noul","noul":0.08},"conc":{"type":"noul","noul":0.07},"sec":{"type":"noul","noul":0.18}}
```

`testdata/good/g02_error_wrap.go`
```
{"ctx":{"type":"noul","noul":0.23},"err":{"type":"noul","noul":0.09},"conc":{"type":"noul","noul":0.05},"sec":{"type":"noul","noul":0.2}}
```

`testdata/good/g03_goroutine_ctx.go`
```
{"ctx":{"type":"noul","noul":0.07},"err":{"type":"noul","noul":0.28},"conc":{"type":"noul","noul":0.14},"sec":{"type":"noul","noul":0.12}}
```

`testdata/good/g04_defer_close.go`
```
{"ctx":{"type":"noul","noul":0.08},"err":{"type":"noul","noul":0.09},"conc":{"type":"noul","noul":0.07},"sec":{"type":"noul","noul":0.17}}
```

`testdata/good/g05_timeout_query.go`
```
{"ctx":{"type":"noul","noul":0.07},"err":{"type":"noul","noul":0.11},"conc":{"type":"noul","noul":0.1},"sec":{"type":"noul","noul":0.24}}
```

`testdata/good/g06_mutex_guard.go`
```
{"ctx":{"type":"noul","noul":0.38},"err":{"type":"noul","noul":0.11},"conc":{"type":"noul","noul":0.1},"sec":{"type":"noul","noul":0.12}}
```

`testdata/good/g07_structured_log.go`
```
{"ctx":{"type":"noul","noul":0.1},"err":{"type":"noul","noul":0.16},"conc":{"type":"noul","noul":0.06},"sec":{"type":"noul","noul":0.14}}
```

`testdata/good/g08_parallel_fetch.go`
```
{"ctx":{"type":"noul","noul":0.11},"err":{"type":"noul","noul":0.16},"conc":{"type":"noul","noul":0.55},"sec":{"type":"noul","noul":0.17}}
```

`testdata/good/g09_table_driven_helper.go`
```
{"ctx":{"type":"noul","noul":0.24},"err":{"type":"noul","noul":0.18},"conc":{"type":"noul","noul":0.03},"sec":{"type":"noul","noul":0.17}}
```

`testdata/good/g10_cancel_propagation.go`
```
{"ctx":{"type":"noul","noul":0.1},"err":{"type":"noul","noul":0.12},"conc":{"type":"noul","noul":0.09},"sec":{"type":"noul","noul":0.17}}
```

`testdata/gray/y01_context_todo.go`
```
{"ctx":{"type":"noul","noul":0.2},"err":{"type":"noul","noul":0.14},"conc":{"type":"noul","noul":0.07},"sec":{"type":"noul","noul":0.09}}
```

`testdata/gray/y02_log_only_error.go`
```
{"ctx":{"type":"noul","noul":0.1},"err":{"type":"noul","noul":0.56},"conc":{"type":"noul","noul":0.09},"sec":{"type":"noul","noul":0.19}}
```

`testdata/gray/y03_goroutine_wg_no_ctx.go`
```
{"ctx":{"type":"noul","noul":0.92},"err":{"type":"noul","noul":0.67},"conc":{"type":"noul","noul":0.21},"sec":{"type":"noul","noul":0.19}}
```

`testdata/gray/y04_unexported_no_ctx.go`
```
{"ctx":{"type":"noul","noul":0.26},"err":{"type":"noul","noul":0.07},"conc":{"type":"noul","noul":0.04},"sec":{"type":"noul","noul":0.13}}
```

`testdata/gray/y05_optional_err_ignore.go`
```
{"ctx":{"type":"noul","noul":0.06},"err":{"type":"noul","noul":0.72},"conc":{"type":"noul","noul":0.08},"sec":{"type":"noul","noul":0.16}}
```

`testdata/gray/y06_rwlock_always_write.go`
```
{"ctx":{"type":"noul","noul":0.61},"err":{"type":"noul","noul":0.2},"conc":{"type":"noul","noul":0.39},"sec":{"type":"noul","noul":0.23}}
```

`testdata/gray/y07_global_background_ctx.go`
```
{"ctx":{"type":"noul","noul":0.73},"err":{"type":"noul","noul":0.52},"conc":{"type":"noul","noul":0.54},"sec":{"type":"noul","noul":0.13}}
```

`testdata/gray/y08_naked_return.go`
```
{"ctx":{"type":"noul","noul":0.28},"err":{"type":"noul","noul":0.13},"conc":{"type":"noul","noul":0.05},"sec":{"type":"noul","noul":0.16}}
```

`testdata/gray/y09_unbuffered_signal_chan.go`
```
{"ctx":{"type":"noul","noul":0.89},"err":{"type":"noul","noul":0.35},"conc":{"type":"noul","noul":0.17},"sec":{"type":"noul","noul":0.18}}
```

`testdata/gray/y10_json_marshal_best_effort.go`
```
{"ctx":{"type":"noul","noul":0.22},"err":{"type":"noul","noul":0.95},"conc":{"type":"noul","noul":0.06},"sec":{"type":"noul","noul":0.22}}
```

