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

@testable import AST
@testable import Parser

class ParserDeinitializerDeclarationTests: XCTestCase {
  func testDeinit() {
    parseDeclarationAndTest(
      "deinit { NSNotificationCenter.removeObserver(self) }",
      "deinit {\nNSNotificationCenter.removeObserver(self)\n}",
      testClosure: { decl in
      guard let deinitDecl = decl as? DeinitializerDeclaration else {
        XCTFail("Failed in getting a deinitializer declaration.")
        return
      }

      XCTAssertTrue(deinitDecl.attributes.isEmpty)
      XCTAssertEqual(deinitDecl.body.textDescription, "{\nNSNotificationCenter.removeObserver(self)\n}")
    })
  }

  func testAttributes() {
    parseDeclarationAndTest(
      "@a @b @c deinit {}",
      "@a @b @c deinit {}",
      testClosure: { decl in
      guard let deinitDecl = decl as? DeinitializerDeclaration else {
        XCTFail("Failed in getting a deinitializer declaration.")
        return
      }

      XCTAssertEqual(deinitDecl.attributes.count, 3)
      XCTAssertEqual(deinitDecl.attributes.textDescription, "@a @b @c")
      XCTAssertEqual(deinitDecl.body.textDescription, "{}")
    })
  }

  func testSourceRange() {
    parseDeclarationAndTest(
      "deinit { NSNotificationCenter.removeObserver(self) }",
      "deinit {\nNSNotificationCenter.removeObserver(self)\n}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 53))
      }
    )
    parseDeclarationAndTest(
      "@a @b @c deinit {}",
      "@a @b @c deinit {}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 19))
      }
    )
  }

  static var allTests = [
    ("testDeinit", testDeinit),
    ("testAttributes", testAttributes),
    ("testSourceRange", testSourceRange),
  ]
}
