/*
   Copyright 2015-2017 Ryuichi Intellectual Property and the Yanagiba project contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import Foundation
import Frontend

var filePaths = CommandLine.arguments
filePaths.remove(at: 0)

var ttyType: TTYType = .astText
var isForGitHubIssue = false
var noHeader = false

while let first = filePaths.first, first.hasPrefix("-") {
  filePaths.remove(at: 0)
  switch first {
  case "-github-issue":
    isForGitHubIssue = true
  case "-dump-ast":
    ttyType = .astDump
  case "-print-ast":
    ttyType = .astPrint
  case "-diagnostics-only":
    ttyType = .diagnosticsOnly
  case "-no-header":
    noHeader = true
  default:
    break
  }
}

let exitCode: Int32
if isForGitHubIssue {
  exitCode = terminalMain(filePaths: filePaths, isForGitHubIssue: true)
} else {
  exitCode = terminalMain(filePaths: filePaths, ttyType: ttyType, noHeader: noHeader)
}

exit(exitCode)
