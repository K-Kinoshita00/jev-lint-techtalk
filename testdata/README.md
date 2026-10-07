# testdata

| パス | 件数 |
|------|------|
| `good/` | 10 |
| `bad/` | 10 |
| `gray/` | 10 |

評価用の意図・ラベル: [../docs/corpus-annotations.md](../docs/corpus-annotations.md)（ソース内コメントは JEV バイアス回避のため中立な日本語 godoc のみ）

各ディレクトリは独立した Go パッケージ（`good` / `bad` / `gray`）。ルートで `go build ./...` によりコンパイル確認する。
