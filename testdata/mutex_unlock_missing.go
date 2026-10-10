package testdata

import "sync"

// SafeMap は文字列キーで int を保持する。
type SafeMap struct {
	mu sync.Mutex
	m  map[string]int
}

func (s *SafeMap) Set(key string, v int) error {
	s.mu.Lock()
	if s.m == nil {
		return errNilMap
	}
	s.m[key] = v
	s.mu.Unlock()
	return nil
}

var errNilMap = &mapNotInitError{}

type mapNotInitError struct{}

func (e *mapNotInitError) Error() string { return "testdata.SafeMap: map not initialized" }
