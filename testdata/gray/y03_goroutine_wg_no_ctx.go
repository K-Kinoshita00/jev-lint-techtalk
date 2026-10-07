package gray

import "sync"

// FlushBuffers は別 goroutine で work を実行し完了を待つ。
func FlushBuffers(work func()) {
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		defer wg.Done()
		work()
	}()
	wg.Wait()
}
