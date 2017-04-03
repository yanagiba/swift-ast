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

class ParserGenericParameterClauseTests: XCTestCase {
  func testSingleParameter() {
    let genericParser = getParser("<S1>")
    do {
      let genericParameterClause = try genericParser.parseGenericParameterClause()
      if let types = genericParameterClause?.parameterList, types.count == 1 {
        XCTAssertEqual(types[0].textDescription, "S1")
        XCTAssertEqual(genericParameterClause?.textDescription, "<S1>")
      } else {
        XCTFail("Failed in getting right size of parameter clause.")
      }
    } catch {
      XCTFail("Failed in getting a generic parameter clause.")
    }
  }

  func testMultipleParameters() {
    let genericParser = getParser("<S1, S2, S3>")
    do {
      let genericParameterClause = try genericParser.parseGenericParameterClause()
      if let types = genericParameterClause?.parameterList, types.count == 3 {
        XCTAssertEqual(types[0].textDescription, "S1")
        XCTAssertEqual(types[1].textDescription, "S2")
        XCTAssertEqual(types[2].textDescription, "S3")
        XCTAssertEqual(genericParameterClause?.textDescription, "<S1, S2, S3>")
      } else {
        XCTFail("Failed in getting right size of parameter clause.")
      }
    } catch {
      XCTFail("Failed in getting a generic parameter clause.")
    }
  }

  func testTypeConformance() {
    let conformanceTypes = ["S2", "Any"]
    for conformanceType in conformanceTypes {
      let genericType = "S1: \(conformanceType)"
      let genericParser = getParser("<\(genericType)>")
      do {
        let genericParameterClause = try genericParser.parseGenericParameterClause()
        if let types = genericParameterClause?.parameterList, types.count == 1 {
          XCTAssertEqual(types[0].textDescription, "\(genericType)")
          XCTAssertEqual(genericParameterClause?.textDescription, "<\(genericType)>")
        } else {
          XCTFail("Failed in getting right size of parameter clause.")
        }
      } catch {
        XCTFail("Failed in getting a generic parameter clause.")
      }
    }
  }

  func testConformances() {
    let genericParser = getParser("<S1, S2: SequenceType, S3: T1 & T2, S4: protocol<T3, T4>>")
    do {
      let genericParameterClause = try genericParser.parseGenericParameterClause()
      if let types = genericParameterClause?.parameterList, types.count == 4 {
        XCTAssertEqual(types[0].textDescription, "S1")
        XCTAssertEqual(types[1].textDescription, "S2: SequenceType")
        XCTAssertEqual(types[2].textDescription, "S3: protocol<T1, T2>")
        XCTAssertEqual(types[3].textDescription, "S4: protocol<T3, T4>")
        XCTAssertEqual(genericParameterClause?.textDescription, "<S1, S2: SequenceType, S3: protocol<T1, T2>, S4: protocol<T3, T4>>")
      } else {
        XCTFail("Failed in getting right size of parameter clause.")
      }
    } catch {
      XCTFail("Failed in getting a generic parameter clause.")
    }
  }

  static var allTests = [
    ("testSingleParameter", testSingleParameter),
    ("testMultipleParameters", testMultipleParameters),
    ("testTypeConformance", testTypeConformance),
    ("testConformances", testConformances),
  ]
}
