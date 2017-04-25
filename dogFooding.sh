#!/bin/bash

set -e

make
for f in $(find . -regex ".*\.swift")
do
  .build/debug/swift-ast $@ $f
done
