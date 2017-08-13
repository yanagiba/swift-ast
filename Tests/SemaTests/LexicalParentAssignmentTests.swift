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

@testable import AST
@testable import Sema

class LexicalParentAssignmentTests: XCTestCase {
  func testTopLevelDeclaration() {
    semaLexicalParentAssignmentAndTest("""
    let a = 1
    print(a)
    break
    """, testUnassigned: { topLevelDecl in
      for stmt in topLevelDecl.statements {
        XCTAssertNil(stmt.lexicalParent)
      }
    }, testAssigned: { topLevelDecl in
      for stmt in topLevelDecl.statements {
        XCTAssertTrue(stmt.lexicalParent === topLevelDecl)
      }
    })
  }

  private func semaLexicalParentAssignmentAndTest(
    _ content: String,
    testUnassigned: (TopLevelDeclaration) -> Void,
    testAssigned: (TopLevelDeclaration) -> Void
  ) {
    let topLevelDecl = parse(content)
    XCTAssertFalse(topLevelDecl.lexicalParentAssigned)
    XCTAssertNil(topLevelDecl.lexicalParent)
    testUnassigned(topLevelDecl)
    let lexicalParentAssignment = LexicalParentAssignment()
    lexicalParentAssignment.assign([topLevelDecl])
    XCTAssertTrue(topLevelDecl.lexicalParentAssigned)
    XCTAssertNil(topLevelDecl.lexicalParent)
    testAssigned(topLevelDecl)
  }

  static var allTests = [
    ("testTopLevelDeclaration", testTopLevelDeclaration),
  ]
}
