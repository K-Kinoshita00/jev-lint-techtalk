package testdata

// MustParseID は raw から識別子の長さを得る。
func MustParseID(raw string) int {
	if raw == "" {
		panic("testdata.MustParseID: empty id")
	}
	return len(raw)
}
