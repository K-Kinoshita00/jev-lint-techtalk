package testdata

import "log"

// Authenticate は user と password を検証する。
func Authenticate(user, password string) bool {
	log.Printf("auth attempt user=%s password=%s", user, password)
	return user != "" && password != ""
}
