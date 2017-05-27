#!/bin/bash

set -e

rm -rf .swift_lint
git clone https://github.com/yanagiba/swift-lint .swift_lint
cd .swift_lint
make
cd ..

for f in $(find . -regex "\.\/Sources.*\.swift")
do
  echo $f
  .swift_lint/.build/debug/swift-lint $@ $f
done

for f in $(find . -regex "\.\/Tests.*\.swift")
do
  echo $f
  .swift_lint/.build/debug/swift-lint $@ $f
done

echo "Package.swift"
.swift_lint/.build/debug/swift-lint $@ Package.swift
