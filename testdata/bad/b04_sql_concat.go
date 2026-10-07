package bad

import "database/sql"

// FindByName は name に一致するユーザーを検索する。
func FindByName(db *sql.DB, name string) (*sql.Rows, error) {
	query := "SELECT id FROM users WHERE name = '" + name + "'"
	return db.Query(query)
}
