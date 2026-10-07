package gray

import (
	"context"
	"log/slog"
	"os"
)

// LoadEnv は path のファイルを読み込む。
func LoadEnv(ctx context.Context, path string) {
	data, err := os.ReadFile(path)
	if err != nil {
		slog.ErrorContext(ctx, "read env file", slog.String("path", path), slog.Any("err", err))
		return
	}
	_ = data
}
