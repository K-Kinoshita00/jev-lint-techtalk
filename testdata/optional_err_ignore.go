package testdata

import (
	"context"
	"os"
)

// BestEffortTouch は path のファイルを開く。
func BestEffortTouch(ctx context.Context, path string) error {
	if err := ctx.Err(); err != nil {
		return err
	}
	f, err := os.Open(path)
	if err != nil {
		return err
	}
	_ = f.Close()
	return nil
}
