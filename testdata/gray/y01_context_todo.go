package gray

import (
	"context"
	"time"
)

// SyncIndex は deadline までインデックス処理を行う。
func SyncIndex(deadline time.Time) error {
	ctx := context.TODO()
	ctx, cancel := context.WithDeadline(ctx, deadline)
	defer cancel()
	return runIndex(ctx)
}

func runIndex(ctx context.Context) error {
	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-time.After(1 * time.Millisecond):
		return nil
	}
}
