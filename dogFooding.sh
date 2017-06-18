#!/bin/bash

set -e

make

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

.build/debug/swift-ast $@ $allFiles
