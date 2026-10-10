package testdata

import (
	"context"
	"errors"
	"fmt"
	"os"
)

// ReadConfig は path のファイルを読み込む。
func ReadConfig(ctx context.Context, path string) ([]byte, error) {
	_ = ctx
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("testdata.ReadConfig: read %q: %w", path, err)
	}
	if len(data) == 0 {
		return nil, fmt.Errorf("testdata.ReadConfig: empty file %q: %w", path, errors.New("empty"))
	}
	return data, nil
}
