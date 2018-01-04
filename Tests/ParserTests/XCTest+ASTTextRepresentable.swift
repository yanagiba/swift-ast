/*
   Copyright 2018 Ryuichi Laboratories and the Yanagiba project contributors

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
import AST

func ASTTextEqual(_ lhs: ASTTextRepresentable, _ rhs: String) {
  XCTAssertEqual(lhs.textDescription, rhs)
}

func ASTTextEqual(_ lhs: ASTTextRepresentable?, _ rhs: String) {
  guard let lhs = lhs else { XCTFail("AST node is nil."); return }
  ASTTextEqual(lhs, rhs)
}

func ASTTextEqual(_ lhs: [ASTTextRepresentable], _ rhs: [String]) {
  guard lhs.count == rhs.count else { XCTFail("Diff in element count."); return }
  for (l, r) in zip(lhs, rhs) {
    ASTTextEqual(l, r)
  }
}
