/*
   Copyright 2016 Ryuichi Saito, LLC

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

import Spectre

@testable import parser
@testable import ast

func specInOutExpression() {
  let parser = Parser()

  describe("Parse an in-out expression") {
    $0.it("should return an in-out expression") {
      parser.setupTestCode("&foo")
      guard let inOutExpr = try? parser.parseInOutExpression() else {
        throw failure("Failed in getting an in-out expression.")
      }
      try expect(inOutExpr.identifier) == "foo"
    }
  }
}
