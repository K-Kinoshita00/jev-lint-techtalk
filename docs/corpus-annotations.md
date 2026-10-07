# コーパス注釈（NG・グレー）

JEV リンター PoC 用 `testdata/` の意図をまとめる。
人手ラベル・テックトークの ground truth として使う。

## ソースコメント方針

- **`testdata/**/\*.go`** … JEV の `state` にそのまま入るため、**評価ヒント（問題点・許容理由・ベストプラクティス宣伝）は書かない**。中立な日本語 godoc のみ。
- **本ドキュメント** … NG / グレー / good の意図・争点・期待ラベルを記載する。

## カテゴリ凡例

| タグ       | 意味                               |
| ---------- | ---------------------------------- |
| `ctx`      | context の受け渡し・キャンセル     |
| `err`      | エラーハンドリング                 |
| `conc`     | 並行性（goroutine / mutex / race） |
| `sec`      | セキュリティ・機微情報             |
| `resource` | リソース解放（defer / Close）      |
| `api`      | 公開 API の設計                    |

---

## 確実な NG（`testdata/bad/`）

| ファイル                      | 主な問題                                                    | タグ              | 期待する指摘（要約）                                   |
| ----------------------------- | ----------------------------------------------------------- | ----------------- | ------------------------------------------------------ |
| `b01_no_context_param.go`     | 待ちうる処理があるのに `context.Context` を取らない公開関数 | `ctx`, `api`      | キャンセル・タイムアウト不可。呼び出し側が制御できない |
| `b02_swallow_error.go`        | `os.WriteFile` のエラーを完全無視                           | `err`             | 書き込み失敗に気づけない                               |
| `b03_leaky_goroutine.go`      | fire-and-forget の `go` + HTTP。終了待ち・キャンセルなし    | `conc`, `ctx`     | プロセス終了時にリーク、過剰並列の温床                 |
| `b04_sql_concat.go`           | ユーザー入力を SQL 文字列連結                               | `sec`             | SQL インジェクション                                   |
| `b05_defer_in_loop.go`        | ループ内 `defer` で FD が関数終了まで解放されない           | `resource`        | 大量ファイルで FD 枯渇                                 |
| `b06_log_secret.go`           | パスワードを平文ログ出力                                    | `sec`             | 認証情報漏えい                                         |
| `b07_mutex_unlock_missing.go` | `m == nil` 時に `Lock` したまま `return`                    | `conc`, `err`     | デッドロック                                           |
| `b08_panic_in_lib.go`         | ライブラリ関数が入力不備で `panic`                          | `api`, `err`      | 呼び出し側が回復不能                                   |
| `b09_race_on_map.go`          | mutex なし map 更新                                         | `conc`            | データレース                                           |
| `b10_ignore_close_error.go`   | `Close` を `_` で捨てる（書き込み系で重要になりうる）       | `err`, `resource` | ディスク flush 失敗の見逃し                            |

### NG 詳細

#### `b01_no_context_param.go`

- **不適切な点**: `LoadSettings` が sleep 相当の I/O 境界を持つ API として `context` なし。
- **望ましい方向**: `LoadSettings(ctx context.Context, userID string)`.

#### `b02_swallow_error.go`

- **不適切な点**: 戻り値なし関数で永続化失敗を握りつぶす。
- **望ましい方向**: `error` を返すか、呼び出し元へ伝播。

#### `b03_leaky_goroutine.go`

- **不適切な点**: リクエスト寿命と goroutine 寿命が無関係。
- **望ましい方向**: `context` または `WaitGroup` / shutdown 機構。

#### `b04_sql_concat.go`

- **不適切な点**: プレースホルダ未使用。
- **望ましい方向**: `db.QueryContext(ctx, "... WHERE name = ?", name)`。

#### `b05_defer_in_loop.go`

- **不適切な点**: `defer` は関数スコープ。ループ回数分スタックする。
- **望ましい方向**: 匿名関数で 1 イテレーション 1 スコープ、または即 `Close()`。

#### `b06_log_secret.go`

- **不適切な点**: 認証秘密をログに含める。
- **望ましい方向**: user ID のみ、structured log、マスク。

#### `b07_mutex_unlock_missing.go`

- **不適切な点**: エラー経路で `Unlock` しない。
- **望ましい方向**: `defer s.mu.Unlock()` を `Lock` 直後に置く。

#### `b08_panic_in_lib.go`

- **不適切な点**: 通常入力で panic。
- **望ましい方向**: `(int, error)` を返す。

#### `b09_race_on_map.go`

- **不適切な点**: 並行呼び出しで map が未定義動作。
- **望ましい方向**: mutex、`sync.Map`、または所有 goroutine 一本化。

#### `b10_ignore_close_error.go`

- **不適切な点**: Close 失敗を無視。
- **望ましい方向**: `if err := f.Close(); err != nil { return err }`（必要ならラップ）。

---

## グレー（`testdata/gray/`）

文脈（CLI 専用 / テスト / 低 QPS など）によって **許容〜要修正** が変わる例。
JEV では **Noul が中間付近になりやすい** 想定。

| ファイル                          | 争点                                                | タグ              | 許容しうる文脈                       | NG 寄りになる条件                            |
| --------------------------------- | --------------------------------------------------- | ----------------- | ------------------------------------ | -------------------------------------------- |
| `y01_context_todo.go`             | `context.TODO()` で deadline だけ付与               | `ctx`             | 移行中・CLI ワンショット             | 長寿命サービス内の本番経路                   |
| `y02_log_only_error.go`           | 読み込み失敗を返さずログのみ                        | `err`, `api`      | 起動時の `.env` 欠落を許容するツール | 再利用されるライブラリ API                   |
| `y03_goroutine_wg_no_ctx.go`      | WG のみで ctx なし                                  | `conc`, `ctx`     | プロセス終了まで必ず `Wait` する CLI | サーバシャットダウン中の非キャンセル可能処理 |
| `y04_unexported_no_ctx.go`        | 公開 API だが純粋パースのみ                         | `ctx`, `api`      | CPU のみ・即時完了                   | 内部で I/O を追加した後も ctx なし           |
| `y05_optional_err_ignore.go`      | Close エラー無視                                    | `err`, `resource` | ベストエフォートの存在確認           | データ整合性が必要な書き込み経路             |
| `y06_rwlock_always_write.go`      | 読み取りに `Lock`（`RLock` 未使用）                 | `conc`            | 低競合・実質単一 goroutine           | 読み多いキャッシュ                           |
| `y07_global_background_ctx.go`    | パッケージグローバル `Background` で goroutine 起動 | `ctx`, `conc`     | デーモンがプロセスと同寿命           | キャンセル可能なリクエストスコープ内         |
| `y08_naked_return.go`             | named return の naked return                        | `api`             | 短い 3 行程度                        | ロジック増加後の可読性低下                   |
| `y09_unbuffered_signal_chan.go`   | 無バッファ notify channel                           | `conc`            | 1 送信者・1 回通知                   | 複数 goroutine からの非ブロッキング通知      |
| `y10_json_marshal_best_effort.go` | `json.Marshal` エラー無視                           | `err`             | デバッグダンプのみ                   | 永続化・API レスポンス生成                   |

### グレー詳細（判定のヒント）

#### `y01_context_todo.go`

- TODO は「親 ctx 不明」のプレースホルダ。Deadline は付いているが **親キャンセルの伝播がない**。

#### `y02_log_only_error.go`

- 失敗を黙殺するのではなくログは出す。**呼び出し元が後続処理を続けられる** のが争点。

#### `y03_goroutine_wg_no_ctx.go`

- 待ち合わせはある。**シャットダウン deadline** がない。

#### `y04_unexported_no_ctx.go`

- 現状は `strconv` のみ。将来 I/O が入ると `b01` に近づく。

#### `y05_optional_err_ignore.go`

- `b10` と同型だが、関数コメントで **ベストエフォート** と明示。

#### `y06_rwlock_always_write.go`

- 誤りではないが **スケール時の性能 smell**。

#### `y07_global_background_ctx.go`

- `Background().Done()` は通常閉じないため、**実質キャンセル不可** の goroutine。

#### `y08_naked_return.go`

- チーム規約で禁止されることが多い **スタイル + 保守性** 問題。

#### `y09_unbuffered_signal_chan.go`

- 送信側がブロックする設計。同期手続きとして意図的なら OK。

#### `y10_json_marshal_best_effort.go`

- `b02` より弱い無視（戻りは空 slice になりうる）。用途依存。

---

## 問題なし（`testdata/good/`）

JEV では **各 Noul が低い** ことを期待する。ソースには中立な日本語 godoc のみ。

| ファイル                     | 意図（評価用）                                  | タグ          |
| ---------------------------- | ----------------------------------------------- | ------------- |
| `g01_context_first.go`       | ctx 第一引数 + `ctx.Done()` 確認                | `ctx`         |
| `g02_error_wrap.go`          | エラーを `%w` でラップして返す                  | `err`         |
| `g03_goroutine_ctx.go`       | ctx キャンセルで goroutine 終了                 | `ctx`, `conc` |
| `g04_defer_close.go`         | `defer` でファイル Close                        | `resource`    |
| `g05_timeout_query.go`       | `QueryContext` + `WithTimeout`                  | `ctx`         |
| `g06_mutex_guard.go`         | 共有状態を mutex で保護                         | `conc`        |
| `g07_structured_log.go`      | slog で user_id / success のみ（password なし） | `sec`         |
| `g08_parallel_fetch.go`      | 並列取得 + 最初のエラーを返す                   | `conc`, `err` |
| `g09_table_driven_helper.go` | 副作用なしの文字列正規化                        | `api`         |
| `g10_cancel_propagation.go`  | ticker ループで ctx を監視                      | `ctx`         |

---

## JEV 評価用の推奨 Noul（参考）

コーパス検証時に使う想定の「はい = 問題あり」命題例（instructions 草案）。

1. **ctx**: 公開または I/O 境界の関数が `context.Context` を第一引数で受け取っていない、またはキャンセルを無視している
2. **err**: エラー返回值を無視、または呼び出し元に返さない
3. **conc**: キャンセル・待ち合わせのない goroutine、またはデータレース
4. **sec**: SQL 連結、秘密情報のログ

グレー 10 件は上記 Noul で **0.4〜0.7 付近** も許容（閾値チューニング用）。
