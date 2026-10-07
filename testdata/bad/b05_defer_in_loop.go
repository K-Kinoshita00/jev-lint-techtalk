package bad

import (
	"os"
)

// ReadMany は paths のファイルサイズ合計（バイト）を返す。
func ReadMany(paths []string) (int, error) {
	total := 0
	for _, p := range paths {
		f, err := os.Open(p)
		if err != nil {
			return 0, err
		}
		defer f.Close()
		info, err := f.Stat()
		if err != nil {
			return 0, err
		}
		total += int(info.Size())
	}
	return total, nil
}
