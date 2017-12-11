#!/bin/bash

set -e

SWIFT_LINT_ROOT="../swift-lint"

if [ "$CI" == "true" ]; then
  rm -rf .swift_lint
  git clone https://github.com/yanagiba/swift-lint .swift_lint
  cd .swift_lint
  make
  cd ..
  SWIFT_LINT_ROOT=".swift_lint"
fi

allFiles=""

for f in $(find . -regex "\.\/Sources.*\.swift")
do
  allFiles="$allFiles $f"
done

for f in $(find . -regex "\.\/Tests.*\.swift")
do
  allFiles="$allFiles $f"
done

allFiles="$allFiles Package.swift"

$SWIFT_LINT_ROOT/.build/debug/swift-lint $@ $allFiles
