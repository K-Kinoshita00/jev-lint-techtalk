# jev-lint

JEV（TypeSafe AI）向け Go リンター PoC 用のデモコーパス。

## 前提

- Go 1.22+
- API キーは `.env` または環境変数（リンター実装時）。本コーパス単体では不要。

## コーパス構成

| ディレクトリ     | 件数 | 説明                             |
| ---------------- | ---- | -------------------------------- |
| `testdata/good/` | 10   | 一般的な Go の慣習に沿った例     |
| `testdata/bad/`  | 10   | 明確な問題（NG）                 |
| `testdata/gray/` | 10   | 文脈次第・議論余地あり（グレー） |

NG・グレーの意図は [docs/corpus-annotations.md](docs/corpus-annotations.md) を参照。

## ベースライン計測

| 手段 | ドキュメント |
|------|-------------|
| golangci-lint / go vet | [docs/baseline-golangci-lint.md](docs/baseline-golangci-lint.md) |
| Claude | [docs/baseline-claude.md](docs/baseline-claude.md) |
| JEV | [docs/baseline-jev.md](docs/baseline-jev.md) |

JEV 再計測（要 `.env` に `JEV_API_KEY` / `JEV_API_URL`）:

```bash
make jev-baseline
```

## 動作確認

```bash
make verify
# または
go build -o /dev/null ./testdata/good ./testdata/bad ./testdata/gray
```

全パッケージがコンパイルできることを確認する。
