package testdata

import (
	"os"
)

// WriteToken は token を path に書き込む。
func WriteToken(path, token string) {
	_ = os.WriteFile(path, []byte(token), 0o600)
}
