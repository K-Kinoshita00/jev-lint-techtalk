.PHONY: verify tidy jev-baseline demo-jev-adequacy demo-claude-adequacy

verify:
	go build -o /dev/null ./testdata
	go test ./demo/...

tidy:
	go mod tidy

jev-baseline:
	./scripts/run-jev-baseline.sh
	./scripts/render-jev-baseline-md.sh

demo-jev-choice2:
	./scripts/run-jev-choice2.sh