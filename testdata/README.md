# testdata

30 ファイルはすべて `package testdata`。区分はディレクトリ名、package 名、ファイル名の接頭辞には出さない。

軸は ctx / err / conc / sec / resource / api。good はどの軸も検出されないことが期待。gray は主題の軸が文脈次第であり、区分は gray。

## bad

呼び出し方によらず直すべき欠陥。

| ファイル | 検出されるべき軸 | 内容 |
| --- | --- | --- |
| `no_context_param.go` | ctx, api | 待ちのある API が context を受け取らない |
| `swallow_error.go` | err | 書き込みエラーを捨てている |
| `leaky_goroutine.go` | conc, ctx | キャンセルも待ち合わせもない goroutine |
| `sql_concat.go` | sec | SQL を文字列連結している |
| `defer_in_loop.go` | resource | ループ内の defer で Close が関数終了まで遅れる |
| `log_secret.go` | sec | パスワードをログに出している |
| `mutex_unlock_missing.go` | conc, err | Lock したまま return し、エラーも Unlock 前に返している |
| `panic_in_lib.go` | api, err | 通常の入力不備で panic する |
| `race_on_map.go` | conc | 共有 map をロックなしで更新する |
| `ignore_close_error.go` | err, resource | 書き込み後の Close エラーを無視している |

## gray

文脈次第で許容にも要修正にもなる。

| ファイル | 主題の軸 | 内容 |
| --- | --- | --- |
| `context_todo.go` | ctx | `context.TODO` に deadline だけ付け、親キャンセルがない |
| `log_only_error.go` | err, api | エラーをログするだけで呼び出し元に返さない |
| `goroutine_wg_no_ctx.go` | conc, ctx | WaitGroup で待つが context で止めない |
| `unexported_no_ctx.go` | ctx, api | 非公開の処理が context を取らない |
| `optional_err_ignore.go` | err, resource | 失敗してもよい Close のエラーを捨てている |
| `rwlock_always_write.go` | conc | 読み取りでも常に書き込みロックを取る |
| `global_background_ctx.go` | ctx, conc | プロセス寿命の background context で goroutine を起動する |
| `naked_return.go` | api | naked return で戻り値の対応が読み取りにくい |
| `unbuffered_signal_chan.go` | conc | バッファなしの通知チャネルで送り手がブロックしうる |
| `json_marshal_best_effort.go` | err | JSON 化の失敗を空バイトにして続ける |

## good

一般的な Go の慣習に沿った例。検出されるべき軸はない。

| ファイル | 対になる例 |
| --- | --- |
| `context_first.go` | context を第一引数で受け、キャンセルを見る |
| `error_wrap.go` | エラーを wrap して返す |
| `goroutine_ctx.go` | context のキャンセルで goroutine を止めて待つ |
| `defer_close.go` | Close を defer し、コピー元のエラーも見る |
| `timeout_query.go` | context の期限でクエリを止める |
| `mutex_guard.go` | Lock と Unlock を対にする |
| `structured_log.go` | 機微情報を出さない構造化ログ |
| `parallel_fetch.go` | context と mutex 付きで並列に取得する |
| `table_driven_helper.go` | 純粋な文字列整形 |
| `cancel_propagation.go` | 親 context のキャンセルをポーリングに伝える |
