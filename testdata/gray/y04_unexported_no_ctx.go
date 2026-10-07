package gray

import "strconv"

// parsePort は raw をポート番号として解釈する。
func parsePort(raw string) (int, error) {
	return strconv.Atoi(raw)
}

// ParsePort は raw を TCP ポート番号として解釈する。
func ParsePort(raw string) (int, error) {
	return parsePort(raw)
}
