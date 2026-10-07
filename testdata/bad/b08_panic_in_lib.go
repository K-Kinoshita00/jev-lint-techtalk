package bad

// MustParseID は raw から識別子の長さを得る。
func MustParseID(raw string) int {
	if raw == "" {
		panic("bad.MustParseID: empty id")
	}
	return len(raw)
}
