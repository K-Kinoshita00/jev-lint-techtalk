.PHONY: verify tidy jev-baseline demo-jev-adequacy demo-claude-adequacy

verify:
	go build -o /dev/null ./testdata

tidy:
	go mod tidy

demo-jev-choice2:
	./scripts/run-jev-choice2.sh