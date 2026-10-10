package testdata

import (
	"context"
	"time"
)

// PollUntil は ok が true になるまで、または ctx が終了するまで定期的に ok を呼ぶ。
func PollUntil(ctx context.Context, interval time.Duration, ok func() bool) error {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		if ok() {
			return nil
		}
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
		}
	}
}
