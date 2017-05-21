/*
   Copyright 2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

@testable import Parser
@testable import AST

class ParserTypeInheritanceClauseTests: XCTestCase {
  func testClassRequirement() {
    parseTypeInheritanceClauseAndTest(": class") {
      XCTAssertTrue($0.classRequirement)
      XCTAssertTrue($0.typeInheritanceList.isEmpty)
      XCTAssertEqual($0.textDescription, ": class")
    }
  }

  func testTypeInheritanceList() {
    parseTypeInheritanceClauseAndTest(": A") {
      XCTAssertFalse($0.classRequirement)
      XCTAssertEqual($0.typeInheritanceList.count, 1)
      XCTAssertEqual($0.textDescription, ": A")
    }
  }

  func testTypeInheritanceListWithMultipleTypes() {
    parseTypeInheritanceClauseAndTest(": A, B, C") {
      XCTAssertFalse($0.classRequirement)
      XCTAssertEqual($0.typeInheritanceList.count, 3)
      XCTAssertEqual($0.textDescription, ": A, B, C")
    }
  }

  func testBothClassAndTypeInheritanceList() {
    parseTypeInheritanceClauseAndTest(":class, A, B, C") {
      XCTAssertTrue($0.classRequirement)
      XCTAssertEqual($0.typeInheritanceList.count, 3)
      XCTAssertEqual($0.textDescription, ": class, A, B, C")
    }
  }

  func testNoColon() {
    let typeParser = getParser("A, B, C")
    let nilExpectation = expectation(description: "Expect type inheritance clause to be nil.")
    do {
      if let _ = try typeParser.parseTypeInheritanceClause() {
        XCTFail("Should not get a type inheritance clause.")
      } else {
        nilExpectation.fulfill()
      }
    } catch {
      XCTFail("Caught exception when getting a type inheritance clause.")
    }
    waitForExpectations(timeout: 3)
  }

  func testClassRequirementMustBeTheFirst() {
    let typeParser = getParser(": A, class, B")
    let nilExpectation = expectation(description: "Expect type inheritance clause to be nil.")
    do {
      _ = try typeParser.parseTypeInheritanceClause()
      XCTFail("Should not get a type inheritance clause.")
    } catch {
      nilExpectation.fulfill()
    }
    waitForExpectations(timeout: 3)
  }

  static var allTests = [
    ("testClassRequirement", testClassRequirement),
    ("testTypeInheritanceList", testTypeInheritanceList),
    ("testBothClassAndTypeInheritanceList", testBothClassAndTypeInheritanceList),
    ("testTypeInheritanceListWithMultipleTypes", testTypeInheritanceListWithMultipleTypes),
    ("testNoColon", testNoColon),
    ("testClassRequirementMustBeTheFirst", testClassRequirementMustBeTheFirst),
  ]
}

fileprivate func parseTypeInheritanceClauseAndTest(_ content: String,
  closure: (TypeInheritanceClause) -> Void) {
  let typeParser = getParser(content)
  do {
    if let typeInheritanceClause = try typeParser.parseTypeInheritanceClause() {
      closure(typeInheritanceClause)
    } else {
      XCTFail("Failed in getting a type inheritance clause.")
    }
  } catch {
    XCTFail("Caught exception when getting a type inheritance clause.")
  }
}
