package good

import (
	"context"
	"database/sql"
	"time"
)

// QueryWithTimeout は ctx からタイムアウトを付けて query を実行する。
func QueryWithTimeout(ctx context.Context, db *sql.DB, query string) (*sql.Rows, error) {
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	return db.QueryContext(ctx, query)
}
