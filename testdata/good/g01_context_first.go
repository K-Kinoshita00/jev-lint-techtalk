package good

import (
	"context"
	"fmt"
)

// FetchUser は userID に対応するデータを返す。
func FetchUser(ctx context.Context, userID string) (string, error) {
	if userID == "" {
		return "", fmt.Errorf("good.FetchUser: empty userID")
	}
	select {
	case <-ctx.Done():
		return "", ctx.Err()
	default:
	}
	return "user-" + userID, nil
}
