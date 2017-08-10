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

class SequenceExpressionFoldingTests: XCTestCase {
  func testMultiplicationHigherThanAddition() {
    semaSeqExprFoldingAndTest("1+2*3", testFlat: { seqExpr in
      XCTAssertTrue(seqExpr is SequenceExpression)
    }, testFolded: { expr in
      XCTAssertTrue(expr is SequenceExpression)
    })
  }

  private func semaSeqExprFoldingAndTest(
    _ content: String,
    testFlat: (SequenceExpression) -> Void,
    testFolded: (Expression) -> Void
  ) {
    let topLevelDecl = parse(content)
    guard let seqExpr = topLevelDecl.statements.first as? SequenceExpression else {
      XCTFail("Failed in parsing a sequence expression with content `\(content)`.")
      return
    }
    testFlat(seqExpr)
    let seqExprFolding = SequenceExpressionFolding()
    let collection = seqExprFolding.fold([topLevelDecl])
    guard let newTopLevelDecl = collection.first?.translationUnit,
      let foldedExpr = newTopLevelDecl.statements.first as? Expression
    else {
      XCTFail("Failed in folding sequence expression.")
      return
    }
    testFolded(foldedExpr)
  }

  static var allTests = [
    ("testMultiplicationHigherThanAddition", testMultiplicationHigherThanAddition),
  ]
}
