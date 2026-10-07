package good

import (
	"context"
	"log/slog"
)

// AuditLogin は userID のログイン試行を記録する。
func AuditLogin(ctx context.Context, userID string, success bool) {
	slog.InfoContext(ctx, "login attempt",
		slog.String("user_id", userID),
		slog.Bool("success", success),
	)
}
