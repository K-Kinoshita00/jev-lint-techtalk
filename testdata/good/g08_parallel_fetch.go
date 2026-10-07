package good

import (
	"context"
	"sync"
)

// FetchParallel は各 id を並列に取得する。
func FetchParallel(ctx context.Context, ids []string) ([]string, error) {
	out := make([]string, len(ids))
	var wg sync.WaitGroup
	var mu sync.Mutex
	var firstErr error

	for i, id := range ids {
		wg.Add(1)
		go func(i int, id string) {
			defer wg.Done()
			v, err := FetchUser(ctx, id)
			if err != nil {
				mu.Lock()
				if firstErr == nil {
					firstErr = err
				}
				mu.Unlock()
				return
			}
			mu.Lock()
			out[i] = v
			mu.Unlock()
		}(i, id)
	}
	wg.Wait()
	if firstErr != nil {
		return nil, firstErr
	}
	return out, nil
}
