#!/usr/bin/env bash

swift package generate-xcodeproj
WORKING_DIRECTORY=$(PWD) xcodebuild -project swift-ast.xcodeproj -scheme swift-ast clean
WORKING_DIRECTORY=$(PWD) xcodebuild -project swift-ast.xcodeproj -scheme swift-ast -sdk macosx10.12 -destination arch=x86_64 -configuration Debug -enableCodeCoverage YES test
