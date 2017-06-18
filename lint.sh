#!/bin/bash

set -e

rm -rf .swift_lint
git clone https://github.com/yanagiba/swift-lint .swift_lint
cd .swift_lint
make
cd ..

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

.swift_lint/.build/debug/swift-lint $@ $allFiles
