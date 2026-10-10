# jev-lint

JEV（TypeSafe AI）向け Go リンター PoC 用のデモコーパス。

## 前提

- Go 1.22+
- API キーは `.env` または環境変数（リンター実装時）。本コーパス単体では不要。

## コーパス構成

`testdata/*.go` に 30 ファイルを置いている。パッケージ名は `testdata`。good / gray / bad の区分と、検出されるべき軸は [testdata/README.md](testdata/README.md)。

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
go build -o /dev/null ./testdata
```

`testdata` パッケージがコンパイルできることを確認する。
