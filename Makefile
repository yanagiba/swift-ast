BUILD_DIR=.build/debug

.PHONY: all clean build test snapshot

all: build

clean:
	swift package clean
	rm -rf swift-ast_github_issue_*

build:
	swift build

test: build
	swift test

snapshot: build
	RECORD_SNAPSHOTS=1 swift test --filter IntegrationTests
