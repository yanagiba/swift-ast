/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

import XCTest

@testable import Source

func testIntegration(
  _ resourceName: String,
  _ testName: String,
  decolor: Bool = true,
  convertor convert: (SourceFile) -> String
) {
  let pwd = FileManager.default.currentDirectoryPath
  let integrationPath = "Tests/IntegrationTests"
  let testTarget = "\(resourceName)/\(testName)"
  let testPath = "\(pwd)/\(integrationPath)/\(testTarget)"
  let sourcePath = "\(testPath).source"
  let resultPath = "\(testPath).result"
  guard let sourceContent = try? String(contentsOfFile: sourcePath, encoding: .utf8),
    let resultContent = try? String(contentsOfFile: resultPath, encoding: .utf8)
  else {
    XCTFail("Failed in reading contents for \(testPath)")
    return
  }

  let sourceFile = SourceFile(
    path: "\(testTarget)Tests.swift", content: sourceContent)
  var result = convert(sourceFile)
  if decolor {
    result = result.replacingOccurrences(of: "\u{001B}[0m", with: "")
    for i in 0..<10 {
      result = result.replacingOccurrences(of: "\u{001B}[\(30+i)m", with: "")
    }
  }

  XCTAssertEqual(result, resultContent)
}
