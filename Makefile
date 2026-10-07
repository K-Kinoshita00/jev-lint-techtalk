.PHONY: verify tidy jev-baseline

verify:
	go build -o /dev/null ./testdata/good ./testdata/bad ./testdata/gray

tidy:
	go mod tidy

jev-baseline:
	./scripts/run-jev-baseline.sh
	./scripts/render-jev-baseline-md.sh
