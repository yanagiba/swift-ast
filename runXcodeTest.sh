#!/usr/bin/env bash

make xcodegen
WORKING_DIRECTORY=$(PWD) xcodebuild -project swift-ast.xcodeproj -scheme swift-ast-Package clean
WORKING_DIRECTORY=$(PWD) xcodebuild -project swift-ast.xcodeproj -scheme swift-ast-Package -sdk macosx10.14 -destination arch=x86_64 -configuration Debug -enableCodeCoverage YES test
