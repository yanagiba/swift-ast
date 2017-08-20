/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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

class SourceReaderTests : XCTestCase {
  func testReading() {
    testPath(#file)
  }

  func testReadingFromCurrentPath() {
    if isXcode9 { return }

    testPath("Tests/SourceTests/SourceReaderTests.swift")
  }

  func testReadingFromParentPath() {
    if isXcode9 { return }

    let currentDirectory = FileManager.default.currentDirectoryPath
    if let parentDir = currentDirectory.components(separatedBy: "/").last {
      testPath("../\(parentDir)/Tests/SourceTests/SourceReaderTests.swift")
    }
  }

  private func testPath(_ path: String) {
    do {
      let sourceFile = try SourceReader.read(at: path)
      XCTAssertTrue(sourceFile.identifier.hasSuffix("Tests/SourceTests/SourceReaderTests.swift"))
      XCTAssertTrue(sourceFile.content.contains("Ryuichi Sai"))
      XCTAssertTrue(sourceFile.content.contains("SourceReaderTests"))
      XCTAssertTrue(sourceFile.content.contains("XCTAssertTrue(sourceFile.content.contains"))
      XCTAssertTrue(sourceFile.content.contains("(\"testReading\", testReading),"))
    } catch {
      XCTFail("Failed in reading file \(path)")
    }
  }

  private var isXcode9: Bool {
    return FileManager.default.currentDirectoryPath == "/private/tmp"
  }

  static var allTests = [
    ("testReading", testReading),
    ("testReadingFromCurrentPath", testReadingFromCurrentPath),
    ("testReadingFromParentPath", testReadingFromParentPath),
  ]
}
