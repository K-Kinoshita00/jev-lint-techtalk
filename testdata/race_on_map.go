package testdata

// Hit は key のカウントを 1 増やす。
func Hit(counts map[string]int, key string) {
	counts[key]++
}
