package testdata

import "encoding/json"

// DebugBlob は v の JSON 表現を返す。
func DebugBlob(v any) []byte {
	b, _ := json.Marshal(v)
	return b
}
