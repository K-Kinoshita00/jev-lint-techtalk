package testdata

import "net/http"

// FireRequest は url に HTTP GET を送る。
func FireRequest(url string) {
	go func() {
		//nolint:gosec
		_, _ = http.Get(url)
	}()
}
