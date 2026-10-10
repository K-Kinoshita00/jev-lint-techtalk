package testdata

import (
	"context"
	"time"
)

var bg = context.Background()

// ScheduleCleanup は delay 経過後に fn を実行する。
func ScheduleCleanup(delay time.Duration, fn func()) {
	go func() {
		timer := time.NewTimer(delay)
		defer timer.Stop()
		select {
		case <-bg.Done():
			return
		case <-timer.C:
			fn()
		}
	}()
}
