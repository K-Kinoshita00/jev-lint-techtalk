package testdata

import "time"

// WaitSignal は ch または timeout のいずれかを待つ。
func WaitSignal(ch chan struct{}, timeout time.Duration) bool {
	timer := time.NewTimer(timeout)
	defer timer.Stop()
	select {
	case <-ch:
		return true
	case <-timer.C:
		return false
	}
}
