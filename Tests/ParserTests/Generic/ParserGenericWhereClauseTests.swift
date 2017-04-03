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

class ParserGenericWhereClauseTests: XCTestCase {
  func testSingleTypeConformanceRequirement() {
    let genericParser = getParser("where S1: S2")
    do {
      let genericWhereClause = try genericParser.parseGenericWhereClause()
      if let requirements = genericWhereClause?.requirementList, requirements.count == 1 {
        XCTAssertEqual(requirements[0].textDescription, "S1: S2")
        XCTAssertEqual(genericWhereClause?.textDescription, "where S1: S2")
      } else {
        XCTFail("Failed in getting right size of requirement list.")
      }
    } catch {
      XCTFail("Failed in getting a generic where clause.")
    }
  }

  func testSingleProtocolConformanceRequirement() {
    let genericParser = getParser("where S1: T1 & T2")
    do {
      let genericWhereClause = try genericParser.parseGenericWhereClause()
      if let requirements = genericWhereClause?.requirementList, requirements.count == 1 {
        XCTAssertEqual(requirements[0].textDescription, "S1: protocol<T1, T2>")
        XCTAssertEqual(genericWhereClause?.textDescription, "where S1: protocol<T1, T2>")
      } else {
        XCTFail("Failed in getting right size of requirement list.")
      }
    } catch {
      XCTFail("Failed in getting a generic where clause.")
    }
  }

  func testSingleOldSyntaxProtocolConformanceRequirement() {
    let genericParser = getParser("where S1: protocol<T1, T2>")
    do {
      let genericWhereClause = try genericParser.parseGenericWhereClause()
      if let requirements = genericWhereClause?.requirementList, requirements.count == 1 {
        XCTAssertEqual(requirements[0].textDescription, "S1: protocol<T1, T2>")
        XCTAssertEqual(genericWhereClause?.textDescription, "where S1: protocol<T1, T2>")
      } else {
        XCTFail("Failed in getting right size of requirement list.")
      }
    } catch {
      XCTFail("Failed in getting a generic where clause.")
    }
  }

  func testSingleSameTypeRequirement() {
    let genericParser = getParser("where S1 == S2")
    do {
      let genericWhereClause = try genericParser.parseGenericWhereClause()
      if let requirements = genericWhereClause?.requirementList, requirements.count == 1 {
        XCTAssertEqual(requirements[0].textDescription, "S1 == S2")
        XCTAssertEqual(genericWhereClause?.textDescription, "where S1 == S2")
      } else {
        XCTFail("Failed in getting right size of requirement list.")
      }
    } catch {
      XCTFail("Failed in getting a generic where clause.")
    }
  }

  func testMultipleRequirements() {
    let genericParser = getParser("where S1: S2, S3: S4 & S5 & S6, S7 == S8")
    do {
      let genericWhereClause = try genericParser.parseGenericWhereClause()
      if let requirements = genericWhereClause?.requirementList, requirements.count == 3 {
        XCTAssertEqual(requirements[0].textDescription, "S1: S2")
        XCTAssertEqual(requirements[1].textDescription, "S3: protocol<S4, S5, S6>")
        XCTAssertEqual(requirements[2].textDescription, "S7 == S8")
        XCTAssertEqual(genericWhereClause?.textDescription, "where S1: S2, S3: protocol<S4, S5, S6>, S7 == S8")
      } else {
        XCTFail("Failed in getting right size of requirement list.")
      }
    } catch {
      XCTFail("Failed in getting a generic where clause.")
    }
  }

  func testSelfRequirements() {
    let genericParser = getParser("where Self.Iterator.Element == Bar, Self.Foo: Bar")
    do {
      let genericWhereClause = try genericParser.parseGenericWhereClause()
      if let requirements = genericWhereClause?.requirementList, requirements.count == 2 {
        XCTAssertEqual(requirements[0].textDescription, "Self.Iterator.Element == Bar")
        XCTAssertEqual(requirements[1].textDescription, "Self.Foo: Bar")
        XCTAssertEqual(genericWhereClause?.textDescription, "where Self.Iterator.Element == Bar, Self.Foo: Bar")
      } else {
        XCTFail("Failed in getting right size of requirement list.")
      }
    } catch {
      XCTFail("Failed in getting a generic where clause.")
    }
  }

  static var allTests = [
    ("testSingleTypeConformanceRequirement", testSingleTypeConformanceRequirement),
    ("testSingleProtocolConformanceRequirement", testSingleProtocolConformanceRequirement),
    ("testSingleOldSyntaxProtocolConformanceRequirement", testSingleOldSyntaxProtocolConformanceRequirement),
    ("testSingleSameTypeRequirement", testSingleSameTypeRequirement),
    ("testMultipleRequirements", testMultipleRequirements),
    ("testSelfRequirements", testSelfRequirements),
  ]
}
