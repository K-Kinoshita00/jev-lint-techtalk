package testdata

// SplitHostPort は input をホストとポートに分ける。
func SplitHostPort(input string) (host string, port string, err error) {
	parts := splitOnce(input, ":")
	if len(parts) != 2 {
		err = errInvalidHostPort
		return
	}
	host, port = parts[0], parts[1]
	return
}

func splitOnce(s, sep string) []string {
	for i := 0; i < len(s); i++ {
		if string(s[i]) == sep {
			return []string{s[:i], s[i+1:]}
		}
	}
	return []string{s}
}

var errInvalidHostPort = &hostPortError{}

type hostPortError struct{}

func (e *hostPortError) Error() string { return "testdata.SplitHostPort: invalid host:port" }
