package testdata

import (
	"context"
	"sync"
)

// RunWorkers は n 個の worker を ctx 終了まで動かす。
func RunWorkers(ctx context.Context, n int) error {
	var wg sync.WaitGroup

	for i := 0; i < n; i++ {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			select {
			case <-ctx.Done():
				return
			case <-workerTick(id):
			}
		}(i)
	}

	done := make(chan struct{})
	go func() {
		wg.Wait()
		close(done)
	}()

	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-done:
		return nil
	}
}

func workerTick(id int) <-chan struct{} {
	ch := make(chan struct{})
	close(ch)
	return ch
}
