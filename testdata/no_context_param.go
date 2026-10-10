package testdata

import "time"

// LoadSettings は userID に対応する設定を返す。
func LoadSettings(userID string) (map[string]string, error) {
	time.Sleep(10 * time.Millisecond)
	return map[string]string{"user": userID}, nil
}
