package testdata

import "sync"

// Cache は文字列キーで文字列値を保持する。
type Cache struct {
	mu sync.RWMutex
	m  map[string]string
}

func (c *Cache) Get(key string) (string, bool) {
	c.mu.Lock()
	defer c.mu.Unlock()
	v, ok := c.m[key]
	return v, ok
}

func (c *Cache) Set(key, val string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.m == nil {
		c.m = make(map[string]string)
	}
	c.m[key] = val
}
