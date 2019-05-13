#!/usr/bin/env bash

make xcodegen
WORKING_DIRECTORY=$(PWD) xcodebuild -project swift-ast.xcodeproj -scheme swift-ast-Package clean > /dev/null 2>&1
WORKING_DIRECTORY=$(PWD) xcodebuild -project swift-ast.xcodeproj -scheme swift-ast-Package -sdk macosx10.14 -destination arch=x86_64 -configuration Debug -enableCodeCoverage YES test > /dev/null 2>&1
