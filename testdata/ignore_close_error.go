package testdata

import (
	"context"
	"os"
)

// TruncateFile は path のファイルを切り詰める。
func TruncateFile(ctx context.Context, path string) error {
	if err := ctx.Err(); err != nil {
		return err
	}
	f, err := os.OpenFile(path, os.O_WRONLY|os.O_TRUNC, 0o644)
	if err != nil {
		return err
	}
	defer func() { _ = f.Close() }()
	return nil
}
