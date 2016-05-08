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

import XCTest

@testable import parser
@testable import ast

class ParsingLiteralExpressionTests: XCTestCase {
  let parser = Parser()

  func testParseNilLiteralExpression() {
    parser.setupTestCode("nil")
    guard let literalExpr = try? parser.parseLiteralExpression() else {
      XCTFail("Failed in getting a literal expression.")
      return
    }
    guard literalExpr is NilLiteralExpression else {
      XCTFail("Failed in getting a nil expression.")
      return
    }
  }

  func testParseBinaryIntegerLiteralExpression() {
    let testStrings = [
      "0b0": 0,
      "0b1": 0,
      "0b01": 0,
      "0b1010": 0,
      "0b01_10_01_10": 0,
      "-0b1": 0,
      "-0b10_10_10_10": 0
    ]
    for (testString, evaluatedResult) in testStrings {
      parser.setupTestCode(testString)
      guard let literalExpr = try? parser.parseLiteralExpression() else {
        XCTFail("Failed in getting a literal expression.")
        return
      }
      guard let integerLiteralExpr = literalExpr as? IntegerLiteralExpression else {
        XCTFail("Failed in getting an integer expression.")
        return
      }
      guard case let literalKind = integerLiteralExpr.kind where literalKind == .Binary else  {
        XCTFail("Failed in getting a binary integer expression.")
        return
      }
      XCTAssertEqual(integerLiteralExpr.rawString, testString)
      XCTAssertEqual(integerLiteralExpr.integerValue, evaluatedResult) // TODO: needs to be updated once evaluation is done
    }
  }

  func testParseOctalIntegerLiteralExpression() {
    let testStrings = [
      "0o0": 0,
      "0o1": 0,
      "0o7": 0,
      "0o01": 0,
      "0o1217": 0,
      "0o01_67_24_35": 0,
      "-0o7": 0,
      "-0o10_23_45_67": 0
    ]
    for (testString, evaluatedResult) in testStrings {
      parser.setupTestCode(testString)
      guard let literalExpr = try? parser.parseLiteralExpression() else {
        XCTFail("Failed in getting a literal expression.")
        return
      }
      guard let integerLiteralExpr = literalExpr as? IntegerLiteralExpression else {
        XCTFail("Failed in getting an integer expression.")
        return
      }
      guard case let literalKind = integerLiteralExpr.kind where literalKind == .Octal else  {
        XCTFail("Failed in getting an octal integer expression.")
        return
      }
      XCTAssertEqual(integerLiteralExpr.rawString, testString)
      XCTAssertEqual(integerLiteralExpr.integerValue, evaluatedResult) // TODO: needs to be updated once evaluation is done
    }
  }

  func testParseDecimalIntegerLiteralExpression() {
    let testStrings = [
      "0": 0,
      "1": 0,
      "100": 0,
      "300_200_100": 0,
      "-123": 0,
      "-1_000_000_000": 0
    ]
    for (testString, evaluatedResult) in testStrings {
      parser.setupTestCode(testString)
      guard let literalExpr = try? parser.parseLiteralExpression() else {
        XCTFail("Failed in getting a literal expression.")
        return
      }
      guard let integerLiteralExpr = literalExpr as? IntegerLiteralExpression else {
        XCTFail("Failed in getting an integer expression.")
        return
      }
      guard case let literalKind = integerLiteralExpr.kind where literalKind == .Decimal else  {
        XCTFail("Failed in getting a decimal integer expression.")
        return
      }
      XCTAssertEqual(integerLiteralExpr.rawString, testString)
      XCTAssertEqual(integerLiteralExpr.integerValue, evaluatedResult) // TODO: needs to be updated once evaluation is done
    }
  }

  func testParseHexadecimalIntegerLiteralExpression() {
    let testStrings = [
      "0x0": 0,
      "0x1": 0,
      "0x9": 0,
      "0xa1": 0,
      "0x1f1A": 0,
      "0xFF_eb_ca_DA": 0,
      "-0xA": 0,
      "-0x19_EC_BA_67": 0
    ]
    for (testString, evaluatedResult) in testStrings {
      parser.setupTestCode(testString)
      guard let literalExpr = try? parser.parseLiteralExpression() else {
        XCTFail("Failed in getting a literal expression.")
        return
      }
      guard let integerLiteralExpr = literalExpr as? IntegerLiteralExpression else {
        XCTFail("Failed in getting an integer expression.")
        return
      }
      guard case let literalKind = integerLiteralExpr.kind where literalKind == .Hexadecimal else  {
        XCTFail("Failed in getting a hexadecimal integer expression.")
        return
      }
      XCTAssertEqual(integerLiteralExpr.rawString, testString)
      XCTAssertEqual(integerLiteralExpr.integerValue, evaluatedResult) // TODO: needs to be updated once evaluation is done
    }
  }

  func testParseDecimalFloatLiteralExpression() {
    let testStrings = [
      "0.0": 0.0,
      "1.1": 0.0,
      "10_0.3_00": 0.0,
      "300_200_100e13": 0.0,
      "-123E+135": 0.0,
      "-1_000_000_000.000_001e-1_0_0": 0.0
    ]
    for (testString, evaluatedResult) in testStrings {
      parser.setupTestCode(testString)
      guard let literalExpr = try? parser.parseLiteralExpression() else {
        XCTFail("Failed in getting a literal expression.")
        return
      }
      guard let floatLiteralExpr = literalExpr as? FloatLiteralExpression else {
        XCTFail("Failed in getting a float expression.")
        return
      }
      guard case let literalKind = floatLiteralExpr.kind where literalKind == .Decimal else  {
        XCTFail("Failed in getting a decimal float expression.")
        return
      }
      XCTAssertEqual(floatLiteralExpr.rawString, testString)
      XCTAssertEqual(floatLiteralExpr.floatValue, evaluatedResult) // TODO: needs to be updated once evaluation is done
    }
  }

  func testParseHexadecimalFloatLiteralExpression() {
    let testStrings = [
      "0x0.1p2": 0.0,
      "-0x1P10": 0.0,
      "0x9.A_Fp+30": 0.0,
      "-0xa_1.eaP-1_5": 0.0
    ]
    for (testString, evaluatedResult) in testStrings {
      parser.setupTestCode(testString)
      guard let literalExpr = try? parser.parseLiteralExpression() else {
        XCTFail("Failed in getting a literal expression.")
        return
      }
      guard let floatLiteralExpr = literalExpr as? FloatLiteralExpression else {
        XCTFail("Failed in getting a float expression.")
        return
      }
      guard case let literalKind = floatLiteralExpr.kind where literalKind == .Hexadecimal else  {
        XCTFail("Failed in getting a hexadecimal float expression.")
        return
      }
      XCTAssertEqual(floatLiteralExpr.rawString, testString)
      XCTAssertEqual(floatLiteralExpr.floatValue, evaluatedResult) // TODO: needs to be updated once evaluation is done
    }
  }

  func testParseBooleanLiteralExpression() {
    let testStrings = [
      "true": true,
      "false": false
    ]
    for (testString, evaluatedResult) in testStrings {
      parser.setupTestCode(testString)
      guard let literalExpr = try? parser.parseLiteralExpression() else {
        XCTFail("Failed in getting a literal expression.")
        return
      }
      guard let boolLiteralExpr = literalExpr as? BooleanLiteralExpression else {
        XCTFail("Failed in getting a boolean expression.")
        return
      }
      if evaluatedResult {
        guard case let literalKind = boolLiteralExpr.kind where literalKind == .True else  {
          XCTFail("Failed in getting a true type boolean literal expression.")
          return
        }
      }
      else {
        guard case let literalKind = boolLiteralExpr.kind where literalKind == .False else  {
          XCTFail("Failed in getting a false type boolean literal expression.")
          return
        }
      }
      XCTAssertEqual(boolLiteralExpr.booleanValue, evaluatedResult) // TODO: needs to be updated once evaluation is done
    }
  }

  func testParseStaticStringLiteralExpression() {
    parser.setupTestCode("\"1 2 3\"")
    guard let literalExpr = try? parser.parseLiteralExpression() else {
      XCTFail("Failed in getting a literal expression.")
      return
    }
    guard let stringLiteralExpr = literalExpr as? StringLiteralExpression else {
      XCTFail("Failed in getting a string literal expression.")
      return
    }
    guard case let literalKind = stringLiteralExpr.kind where literalKind == .Ordinary else  {
      XCTFail("Failed in getting a ordinary type string literal expression.")
      return
    }
    XCTAssertEqual(stringLiteralExpr.stringValue, "1 2 3")
  }

  func testParseInterpolatedStringLiteralExpression() {
    let testStrings = [
      "\"1 2 \\(3)\"": "1 2 \\(3)",
      "\"1 2 \\(\"3\")\"": "1 2 \\(\"3\")",
      "\"1 2 \\(\"1 + 2\")\"": "1 2 \\(\"1 + 2\")",
      "\"1 2 \\(x)\"": "1 2 \\(x)"
    ]
    for (testString, evaluatedResult) in testStrings {
      parser.setupTestCode(testString)
      guard let literalExpr = try? parser.parseLiteralExpression() else {
        XCTFail("Failed in getting a literal expression.")
        return
      }
      guard let stringLiteralExpr = literalExpr as? StringLiteralExpression else {
        XCTFail("Failed in getting a string literal expression.")
        return
      }
      guard case let literalKind = stringLiteralExpr.kind where literalKind == .Interpolated else  {
        XCTFail("Failed in getting an interpolated type string literal expression.")
        return
      }
      XCTAssertEqual(stringLiteralExpr.stringValue, evaluatedResult) // TODO: needs to be updated once evaluation is done
    }
  }

  func testParseArrayLiteralExpression() {
    parser.setupTestCode("[nil, 1, 1.23, \"foo\", \"\\(1 + 2)\", true, [1, 2, 3], [1: true, 2: false, 3: true, 4: false], __FILE__]")
    guard let literalExpr = try? parser.parseLiteralExpression() else {
      XCTFail("Failed in getting a literal expression.")
      return
    }
    guard let arrayLiteralExpr = literalExpr as? ArrayLiteralExpression else {
      XCTFail("Failed in getting an array literal expression.")
      return
    }
    let items = arrayLiteralExpr.items
    XCTAssertEqual(items.count, 9)
    XCTAssertTrue(items[0] is NilLiteralExpression)
    XCTAssertTrue(items[1] is IntegerLiteralExpression)
    XCTAssertTrue(items[2] is FloatLiteralExpression)
    XCTAssertTrue(items[3] is StringLiteralExpression)
    XCTAssertTrue(items[4] is StringLiteralExpression)
    XCTAssertTrue(items[5] is BooleanLiteralExpression)
    XCTAssertTrue(items[6] is ArrayLiteralExpression)
    XCTAssertTrue(items[7] is DictionaryLiteralExpression)
    XCTAssertTrue(items[8] is SpecialLiteralExpression)
  }

  func testParseDictionaryLiteralExpression() {
    parser.setupTestCode("[nil: 1, 1.23: \"foo\", \"\\(1 + 2)\": true, [1, 2, 3]: [1: true, 2: false, 3: true, 4: false], __FILE__: [1: true]]")
    guard let literalExpr = try? parser.parseLiteralExpression() else {
      XCTFail("Failed in getting a literal expression.")
      return
    }
    guard let dictLiteralExpr = literalExpr as? DictionaryLiteralExpression else {
      XCTFail("Failed in getting a dictionary literal expression.")
      return
    }
    let items = dictLiteralExpr.items
    XCTAssertEqual(items.count, 5)
    XCTAssertTrue(items[0].0 is NilLiteralExpression)
    XCTAssertTrue(items[0].1 is IntegerLiteralExpression)
    XCTAssertTrue(items[1].0 is FloatLiteralExpression)
    XCTAssertTrue(items[1].1 is StringLiteralExpression)
    XCTAssertTrue(items[2].0 is StringLiteralExpression)
    XCTAssertTrue(items[2].1 is BooleanLiteralExpression)
    XCTAssertTrue(items[3].0 is ArrayLiteralExpression)
    XCTAssertTrue(items[3].1 is DictionaryLiteralExpression)
    XCTAssertTrue(items[4].0 is SpecialLiteralExpression)
    XCTAssertTrue(items[4].1 is DictionaryLiteralExpression)
  }

  func testParseSpecialIdentifierLiteralExpression() {
    let testStrings: [String: SpecialLiteralExpression.Kind] = [
      "__FILE__": .File,
      "__LINE__": .Line,
      "__COLUMN__": .Column,
      "__FUNCTION__": .Function,
    ]
    for (testString, specialLiteralExpressionKind) in testStrings {
      parser.setupTestCode(testString)
      guard let literalExpr = try? parser.parseLiteralExpression() else {
        XCTFail("Failed in getting a literal expression.")
        return
      }
      guard let specialLiteralExpression = literalExpr as? SpecialLiteralExpression else {
        XCTFail("Failed in getting a special literal expression.")
        return
      }
      guard case let literalKind = specialLiteralExpression.kind where literalKind == specialLiteralExpressionKind else  {
        XCTFail("Failed in getting a \(specialLiteralExpressionKind) type special literal expression.")
        return
      }
    }
  }
}
