package testdata

import "strings"

// NormalizeEmail は raw を整形して小文字にする。
func NormalizeEmail(raw string) string {
	return strings.ToLower(strings.TrimSpace(raw))
}
