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

import Foundation
import XCTest

@testable import Source

class SourceFileTests : XCTestCase {
  func testFile() {
    let sourceFile = SourceFile(path: "/path/to/file", content: "hello world")
    XCTAssertEqual(sourceFile.origin, .file("/path/to/file"))
    XCTAssertEqual(sourceFile.identifier, "/path/to/file")
    XCTAssertEqual(sourceFile.content, "hello world")
  }

  func testMemoryWithGivenUUID() {
    let uuidString = "D7C59A97-D35A-4D80-AB3A-24AEACF24337"
    guard let uuid = UUID(uuidString: uuidString) else {
      XCTFail("Failed in generating a UUID string.")
      return
    }
    let sourceFile = SourceFile(uuid: uuid, content: "hello world")
    XCTAssertEqual(sourceFile.origin, .memory(uuid))
    XCTAssertEqual(sourceFile.identifier, uuidString)
    XCTAssertEqual(sourceFile.content, "hello world")
  }

  func testMemoryWithRandomUUID() {
    let sourceFile = SourceFile(content: "hello world")
    guard case .memory(let uuid) = sourceFile.origin else {
      XCTFail("Failed in generating a UUID from memory origin.")
      return
    }
    XCTAssertEqual(sourceFile.identifier, uuid.uuidString)
    XCTAssertEqual(sourceFile.content, "hello world")
  }

  static var allTests = [
    ("testFile", testFile),
    ("testMemoryWithGivenUUID", testMemoryWithGivenUUID),
    ("testMemoryWithRandomUUID", testMemoryWithRandomUUID),
  ]
}
