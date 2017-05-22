BUILD_DIR=.build/debug

.PHONY: all clean build test xcodegen

all: build

clean:
	swift package clean
	rm -rf swift-ast_github_issue_*

build:
	swift build

test: build
	swift test

xcodegen:
	swift package generate-xcodeproj --enable-code-coverage
