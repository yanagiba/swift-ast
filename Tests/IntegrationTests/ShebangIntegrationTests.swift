/*
   Copyright 2017 Ryuichi Intellectual Property and the Yanagiba project contributors

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

@testable import Frontend
@testable import Parser

class ShebangIntegrationTests : XCTestCase {
  func testShebangPrint() {
    testIntegration("ShebangResources", "ShebangPrint") { source -> String in
      let parser = Parser(source: source)
      guard let topLevelDecl = try? parser.parse() else {
        return "error: failed in parsing the source \(source.identifier)."
      }
      return topLevelDecl.ttyPrint
    }
  }

  func testShebangDump() {
    testIntegration("ShebangResources", "ShebangDump") { source -> String in
      let parser = Parser(source: source)
      guard let topLevelDecl = try? parser.parse() else {
        return "error: failed in parsing the source \(source.identifier)."
      }
      return topLevelDecl.ttyDump
    }
  }

  static var allTests = [
    ("testShebangPrint", testShebangPrint),
    ("testShebangDump", testShebangDump),
  ]
}
