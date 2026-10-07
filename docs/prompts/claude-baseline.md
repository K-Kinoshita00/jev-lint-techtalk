# Claude ベースライン用プロンプト

1 ファイルごとに **新規チャット** を開き、ソース全文を ```go``` に貼る。

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
```go
（testdata のファイル全文）
```
```

結果は [../baseline-claude.md](../baseline-claude.md) に集約する。
