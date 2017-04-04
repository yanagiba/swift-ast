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

@testable import AST

class ParserLiteralExpressionTests: XCTestCase {
  func testNilLiteral() {
    parseExpressionAndTest("nil", "nil", testClosure: { expr in
      guard let nilExpr = expr as? LiteralExpression, case .nil = nilExpr else {
        XCTFail("Failed in getting a nil literal")
        return
      }
    })
  }

  func testTrueBooleanLiteral() {
    parseExpressionAndTest("true", "true", testClosure: { expr in
      guard let boolExpr = expr as? LiteralExpression, case .boolean(let bool) = boolExpr else {
        XCTFail("Failed in getting a boolean literal")
        return
      }
      XCTAssertTrue(bool)
    })
  }

  func testFalseBooleanLiteral() {
    parseExpressionAndTest("false", "false", testClosure: { expr in
      guard let boolExpr = expr as? LiteralExpression, case .boolean(let bool) = boolExpr else {
        XCTFail("Failed in getting a boolean literal")
        return
      }
      XCTAssertFalse(bool)
    })
  }

  func testIntegerLiteral() {
    let testIntegers: [(testString: String, expectedInt: Int)] = [
      ("0b0", 0),
      ("0b1", 1),
      ("0o1217", 655),
      ("0o01_67_24_35", 488733),
      ("300_200_100", 3_0020_0100),
      ("-123", -123),
      ("0xFF_eb_ca_DA", 4293642970),
      ("-0xA", -10),
    ]
    for t in testIntegers {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        guard let intExpr = expr as? LiteralExpression, case let .integer(int, rawText) = intExpr else {
          XCTFail("Failed in getting an integer literal")
          return
        }
        XCTAssertEqual(int, t.expectedInt)
        XCTAssertEqual(rawText, t.testString)
      })
    }
  }

  func testFloatingPointLiteral() {
    let testFloats: [(testString: String, expectedDouble: Double)] = [
      ("10_0.000_3", 100.0003),
      ("300_200_100e13", 300200100e13),
      ("0x9.A_Fp+30", 0x9.AFp+30),
      ("-0xa_1.eaP-1_5", -0xa1.eaP-15),
    ]
    for t in testFloats {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        guard let floatExpr = expr as? LiteralExpression, case let .floatingPoint(double, rawText) = floatExpr else {
          XCTFail("Failed in getting a floating point literal")
          return
        }
        XCTAssertEqual(double, t.expectedDouble)
        XCTAssertEqual(rawText, t.testString)
      })
    }
  }

  func testStaticStringLiteral() {
    let testStrings: [(testString: String, expectedString: String)] = [
      ("\"\"", ""),
      ("\"      \"", "      "),
      ("\"a\"", "a"),
      ("\"The quick brown fox jumps over the lazy dog\"", "The quick brown fox jumps over the lazy dog"),
      ("\"\\0\\\\\\t\\n\\r\\\"\\\'\"", "\0\\\t\n\r\"\'"),
    ]
    for t in testStrings {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        guard let strExpr = expr as? LiteralExpression, case let .staticString(str, raw) = strExpr else {
          XCTFail("Failed in getting a static string literal")
          return
        }
        XCTAssertEqual(str, t.expectedString)
        XCTAssertEqual(raw, t.testString)
      })
    }
  }

  func testInterpolatedStringLiteral() {
    let testStrings: [(testString: String, expectedExpressions: [Expression])] = [
      ( // integer literal
        "\"1 2 \\(3)\"",
        [
          LiteralExpression.staticString("1 2 ", ""),
          LiteralExpression.integer(3, "3"),
        ]),
      ( // static string literal
        "\"1 2 \\(\"3\")\"",
        [
          LiteralExpression.staticString("1 2 ", ""),
          LiteralExpression.staticString("3", "\"3\""),
        ]),
      ( // nested interpolated string
        "\"\\(\"\\(3)\")\"",
        [
          LiteralExpression.interpolatedString([
            LiteralExpression.integer(3, "3")
          ], "\"\\(3)\""),
        ]),
      ( // two-level nested interpolated string
        "\"\\(\"\\(\"\\(\"3\")\")\")\"",
        [
          LiteralExpression.interpolatedString([
            LiteralExpression.interpolatedString([
              LiteralExpression.staticString("3", "\"3\"")
            ], "\"\\(\"3\")\""),
          ], "\"\\(\"\\(\"3\")\")\""),
        ]),
      ( // heading and tailing static strings
        "\"1 2 \\(3) 4 5\"",
        [
          LiteralExpression.staticString("1 2 ", ""),
          LiteralExpression.integer(3, "3"),
          LiteralExpression.staticString(" 4 5", ""),
        ]),
      ( // multiple interpolated strings in parallel
        "\"\\(\"helloworld\")a\\(\"foo\")\\(\"bar\")z\"",
        [
          LiteralExpression.staticString("helloworld", "\"helloworld\""),
          LiteralExpression.staticString("a", ""),
          LiteralExpression.staticString("foo", "\"foo\""),
          LiteralExpression.staticString("bar", "\"bar\""),
          LiteralExpression.staticString("z", ""),
        ]),
      (
        "\"1 2 \\(\"1 + 2\")\"",
        [
          LiteralExpression.staticString("1 2 ", ""),
          LiteralExpression.staticString("1 + 2", "\"1 + 2\""),
        ]),
      (
        "\"1 2 \\(x)\"",
        [
          LiteralExpression.staticString("1 2 ", ""),
          IdentifierExpression.identifier("x", nil),
        ]),
      (
        "\"1 2 \\(\"3\") \\(\"1 + 2\") \\(x) 456\"",
        [
          LiteralExpression.staticString("1 2 ", ""),
          LiteralExpression.staticString("3", "\"3\""),
          LiteralExpression.staticString(" ", ""),
          LiteralExpression.staticString("1 + 2", "\"1 + 2\""),
          LiteralExpression.staticString(" ", ""),
          IdentifierExpression.identifier("x", nil),
          LiteralExpression.staticString(" 456", ""),
        ]),
      ( // having fun
        "\"\\(\"foo\\(123)()(\\(\"abc\\(\"😂\")xyz)\")\\(789)bar\")\"",
        //    \"foo\\(123)()(\\(\"abc\\(\"😂\")xyz)\")\\(789)bar\"
        /* "\("foo\(123)()(\("abc\("😂")xyz)")\(789)bar")"
              "foo\(123)()(\("abc\("😂")xyz)")\(789)bar"
              foo      ()(         😂              bar
                 \(123)   \("abc\("😂")xyz)")
                                \("😂")      \(789)
         - foo
         - |
           - 123
         - ()(
         - |
           - abc
           - |
             - 😂
           - xyz)
         - |
           - 789
         - bar
         */
        [
          LiteralExpression.interpolatedString([
            LiteralExpression.staticString("foo", ""),
            LiteralExpression.integer(123, "123"),
            LiteralExpression.staticString("()(", ""),
            LiteralExpression.interpolatedString([
              LiteralExpression.staticString("abc", ""),
              LiteralExpression.staticString("😂", "\"😂\""),
              LiteralExpression.staticString("xyz)", ""),
            ], "\"abc\\(\"😂\")xyz)\""),
            LiteralExpression.integer(789, "789"),
            LiteralExpression.staticString("bar", ""),
          ], "\"foo\\(123)()(\\(\"abc\\(\"😂\")xyz)\")\\(789)bar\""),
        ]),
    ]

    func testInterpolatedStringExpressions(exprs: [Expression], expected: [Expression]) {
      // keep this with the minimal code to make the tests pass, and add more handlings when needed
      guard exprs.count == expected.count else {
          XCTFail("Parsed interpolated string literal doesn't contain the matching expressions as expected.")
          return
      }

      for (index, e) in exprs.enumerated() {
        let expectedExpr = expected[index]
        if let literalExpr = expectedExpr as? LiteralExpression {
          switch literalExpr {
          case let .integer(i, r):
            guard let ee = e as? LiteralExpression, case let .integer(ei, er) = ee, i == ei, r == er else {
              XCTFail("Failed in parsing a correct integer literal, expected: \(i)")
              return
            }
          case let .staticString(s, r):
            guard let ee = e as? LiteralExpression, case let .staticString(es, er) = ee, s == es, r == er else {
              XCTFail("Failed in parsing a correct static string literal, expected: \(s)")
              return
            }
          case let .interpolatedString(ises, r):
            guard let ee = e as? LiteralExpression, case let .interpolatedString(ees, er) = ee, r == er else {
              XCTFail("Failed in parsing a correct interpolated string literal, expected: \(r)")
              return
            }
            testInterpolatedStringExpressions(exprs: ees, expected: ises)
          default:
            XCTFail("Literal expression case not handled")
          }
        } else if let identifierExpr = expectedExpr as? IdentifierExpression {
          switch identifierExpr {
          case let .identifier(name, nil):
            guard let ee = e as? IdentifierExpression, case let .identifier(en, nil) = ee, name == en else {
              XCTFail("Failed in parsing a correct identifier expression, expected: \(name)")
              return
            }
          default:
            XCTFail("Identifier expression case not handled")
          }
        } else {
          XCTFail("Expression case not handled")
        }
      }
    }

    for t in testStrings {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        guard let strExpr = expr as? LiteralExpression, case let .interpolatedString(exprs, rawText) = strExpr else {
          XCTFail("Failed in getting an interpolated string literal")
          return
        }
        testInterpolatedStringExpressions(exprs: exprs, expected: t.expectedExpressions)
        XCTAssertEqual(rawText, t.testString)
      })
    }
  }

  func testInterpolatedStringExpressionsContainFunctionCallExpr() {
    parseExpressionAndTest(
      "\"\\(casesText.joined())\"",
      "\"\\(casesText.joined())\"")
    parseExpressionAndTest(
      "\"\\(casesText.joined(separator: \", \"))\"",
      "\"\\(casesText.joined(separator: \", \"))\"")
    parseExpressionAndTest(
      "\"(\\(casesText.joined(separator: \", \")))\"",
      "\"(\\(casesText.joined(separator: \", \")))\"")
    parseExpressionAndTest(
      "\"(\\(casesText.joined(separator: \", \"))foo)\"",
      "\"(\\(casesText.joined(separator: \", \"))foo)\"")
    parseExpressionAndTest(
      "\"(\\(casesText.map { $0.upperCased() }))\"",
      "\"(\\(casesText.map { $0.upperCased() }))\"")
    parseExpressionAndTest(
      "\"(\\(casesText.map { $0.upperCased() }.foo))\"",
      "\"(\\(casesText.map { $0.upperCased() }.foo))\"")
    parseExpressionAndTest(
      "\"(\\(casesText.map { $0.upperCased() }.foo()))\"",
      "\"(\\(casesText.map { $0.upperCased() }.foo()))\"")
  }

  func testEmptyInterpolatedTextItem() {
    // TODO: "\()"
    // TODO: expected to be an error
  }

  func testEmptyArrayLiteral() {
    parseExpressionAndTest("[   ]", "[]", testClosure: { expr in
      guard let arrayExpr = expr as? LiteralExpression, case .array(let exprs) = arrayExpr else {
        XCTFail("Failed in getting an array literal")
        return
      }
      XCTAssertTrue(exprs.isEmpty)
    })
  }

  func testSimpleArrayLiteral() {
    parseExpressionAndTest("[1, 2, 3]", "[1, 2, 3]", testClosure: { expr in
      guard let arrayExpr = expr as? LiteralExpression, case .array(let exprs) = arrayExpr else {
        XCTFail("Failed in getting an array literal")
        return
      }
      guard exprs.count == 3 else {
        XCTFail("Array literal doesn't contain 3 elements")
        return
      }
      for i in 0..<3 {
        guard let literalExpr = exprs[i] as? LiteralExpression, case .integer(let ei, _) = literalExpr, ei == i + 1 else {
          XCTFail("Element in array literal is not correct parsed")
          return
        }
      }
    })
  }

  func testArrayEndingWithComma() {
    parseExpressionAndTest("[1, 2, 3, ]", "[1, 2, 3]", testClosure: { expr in
      guard let arrayExpr = expr as? LiteralExpression, case .array(let exprs) = arrayExpr else {
        XCTFail("Failed in getting an array literal")
        return
      }
      guard exprs.count == 3 else {
        XCTFail("Array literal doesn't contain 3 elements")
        return
      }
    })
  }

  func testArrayWithArrays() {
    parseExpressionAndTest("[[1, 2, 3], [7, 8, 9]]", "[[1, 2, 3], [7, 8, 9]]", testClosure: { expr in
      guard let arrayExpr = expr as? LiteralExpression, case .array(let exprs) = arrayExpr else {
        XCTFail("Failed in getting an array literal")
        return
      }
      guard exprs.count == 2 else {
        XCTFail("Array literal doesn't contain 2 elements")
        return
      }
    })
  }

  func testArrayWithDictionaries() {
    parseExpressionAndTest("[[\"foo\": true, \"bar\": false]]", "[[\"foo\": true, \"bar\": false]]", testClosure: { expr in
      guard let arrayExpr = expr as? LiteralExpression, case .array(let exprs) = arrayExpr else {
        XCTFail("Failed in getting an array literal")
        return
      }
      guard exprs.count == 1 else {
        XCTFail("Array literal doesn't contain one element")
        return
      }
    })
  }

  func testArrayLiteralContainsAllLiterals() {
    parseExpressionAndTest(
      "[nil, 1, 1.23, \"foo\", \"\\(1)\", true, [1, 2, 3], [1: true, 2: false, 3: true, 4: false], #file]",
      "[nil, 1, 1.23, \"foo\", \"\\(1)\", true, [1, 2, 3], [1: true, 2: false, 3: true, 4: false], #file]",
      testClosure: { expr in
      guard let arrayExpr = expr as? LiteralExpression, case .array(let exprs) = arrayExpr else {
        XCTFail("Failed in getting an array literal")
        return
      }
      guard exprs.count == 9 else {
        XCTFail("Array literal doesn't contain nine elements")
        return
      }
    })
  }

  func testEmptyDictionaryLiteral() {
    parseExpressionAndTest("[ : ]", "[:]", testClosure: { expr in
      guard let dictExpr = expr as? LiteralExpression, case .dictionary(let exprs) = dictExpr else {
        XCTFail("Failed in getting a dictionary literal")
        return
      }
      XCTAssertTrue(exprs.isEmpty)
    })
  }

  func testSimpleDictionaryLiteral() {
    parseExpressionAndTest("[\"foo\": true, \"bar\": false]", "[\"foo\": true, \"bar\": false]", testClosure: { expr in
      guard let dictExpr = expr as? LiteralExpression, case .dictionary(let exprs) = dictExpr else {
        XCTFail("Failed in getting a dictionary literal")
        return
      }
      guard exprs.count == 2 else {
        XCTFail("Dictionary literal doesn't contain 2 entries")
        return
      }
      guard let keyExpr1 = exprs[0].key as? LiteralExpression,
        let valueExpr1 = exprs[0].value as? LiteralExpression,
        case .staticString(let es1, _) = keyExpr1,
        case .boolean(let eb1) = valueExpr1,
        es1 == "foo",
        eb1 else {
        XCTFail("First entry in dictinoary literal is not correct parsed")
        return
      }
      guard let keyExpr2 = exprs[1].key as? LiteralExpression,
        let valueExpr2 = exprs[1].value as? LiteralExpression,
        case .staticString(let es2, _) = keyExpr2,
        case .boolean(let eb2) = valueExpr2,
        es2 == "bar",

        !eb2 else {
        XCTFail("Second entry in dictinoary literal is not correct parsed")
        return
      }
    })
  }

  func testDictinoaryEndingWithComma() {
    parseExpressionAndTest("[\"foo\": true, \"bar\": false, ]", "[\"foo\": true, \"bar\": false]", testClosure: { expr in
      guard let dictExpr = expr as? LiteralExpression, case .dictionary(let exprs) = dictExpr else {
        XCTFail("Failed in getting a dictionary literal")
        return
      }
      guard exprs.count == 2 else {
        XCTFail("Dictionary literal doesn't contain 2 entries")
        return
      }
    })
  }

  func testDictionaryWithDictionaries() {
    parseExpressionAndTest(
      "[[\"foo\": true, \"bar\": false]: 1, 2: [\"foo\": true, \"bar\": false]]",
      "[[\"foo\": true, \"bar\": false]: 1, 2: [\"foo\": true, \"bar\": false]]",
      testClosure: { expr in
      guard let dictExpr = expr as? LiteralExpression, case .dictionary(let exprs) = dictExpr else {
        XCTFail("Failed in getting a dictionary literal")
        return
      }
      guard exprs.count == 2 else {
        XCTFail("Dictionary literal doesn't contain 2 entries")
        return
      }
    })
  }

  func testDictionaryWithArrays() {
    parseExpressionAndTest(
      "[[1, 2, 3]: \"foo\", \"\\(1 + 2)\": [7, 8, 9]]",
      "[[1, 2, 3]: \"foo\", \"\\(1 + 2)\": [7, 8, 9]]",
      testClosure: { expr in
      guard let dictExpr = expr as? LiteralExpression, case .dictionary(let exprs) = dictExpr else {
        XCTFail("Failed in getting a dictionary literal")
        return
      }
      guard exprs.count == 2 else {
        XCTFail("Dictionary literal doesn't contain 2 entries")
        return
      }
    })
  }

  func testDictionaryLiteralContainsAllLiterals() {
    parseExpressionAndTest(
      "[nil: 1, 1.23: \"foo\", \"\\(1 + 2)\": true, [1, 2, 3]: [1: true, 2: false, 3: true, 4: false], #line: [1: true]]",
      "[nil: 1, 1.23: \"foo\", \"\\(1 + 2)\": true, [1, 2, 3]: [1: true, 2: false, 3: true, 4: false], #line: [1: true]]",
      testClosure: { expr in
      guard let dictExpr = expr as? LiteralExpression, case .dictionary(let exprs) = dictExpr else {
        XCTFail("Failed in getting a dictionary literal")
        return
      }
      guard exprs.count == 5 else {
        XCTFail("Dictionary literal doesn't contain 5 entries")
        return
      }
    })
  }

  func testMagicLiterals() {
    let testStrings: [(testString: String, expectedExpr: LiteralExpression)] = [
      ("#file", .staticString("TODO", "#file")),
      ("#line", .integer(-1, "#line")),
      ("#column", .integer(-1, "#column")),
      ("#function", .staticString("TODO", "#function")),
    ]
    for t in testStrings {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        switch t.expectedExpr {
        case let .integer(i, r):
          guard let ee = expr as? LiteralExpression, case let .integer(ei, er) = ee, i == ei, r == er else {
            XCTFail("Failed in parsing a correct integer literal, expected: \(i)")
            return
          }
        case let .staticString(s, r):
          guard let ee = expr as? LiteralExpression, case let .staticString(es, er) = ee, s == es, r == er else {
            XCTFail("Failed in parsing a correct static string literal, expected: \(s)")
            return
          }
        default:
          XCTFail("Literal expression case not handled")
        }
      })
    }
  }

  static var allTests = [
    ("testNilLiteral", testNilLiteral),
    ("testTrueBooleanLiteral", testTrueBooleanLiteral),
    ("testFalseBooleanLiteral", testFalseBooleanLiteral),
    ("testIntegerLiteral", testIntegerLiteral),
    ("testFloatingPointLiteral", testFloatingPointLiteral),
    ("testStaticStringLiteral", testStaticStringLiteral),
    ("testInterpolatedStringLiteral", testInterpolatedStringLiteral),
    ("testInterpolatedStringExpressionsContainFunctionCallExpr", testInterpolatedStringExpressionsContainFunctionCallExpr),
    ("testEmptyInterpolatedTextItem", testEmptyInterpolatedTextItem),
    ("testEmptyArrayLiteral", testEmptyArrayLiteral),
    ("testSimpleArrayLiteral", testSimpleArrayLiteral),
    ("testArrayEndingWithComma", testArrayEndingWithComma),
    ("testArrayWithArrays", testArrayWithArrays),
    ("testArrayWithDictionaries", testArrayWithDictionaries),
    ("testArrayLiteralContainsAllLiterals", testArrayLiteralContainsAllLiterals),
    ("testEmptyDictionaryLiteral", testEmptyDictionaryLiteral),
    ("testSimpleDictionaryLiteral", testSimpleDictionaryLiteral),
    ("testDictinoaryEndingWithComma", testDictinoaryEndingWithComma),
    ("testDictionaryWithDictionaries", testDictionaryWithDictionaries),
    ("testDictionaryWithArrays", testDictionaryWithArrays),
    ("testDictionaryLiteralContainsAllLiterals", testDictionaryLiteralContainsAllLiterals),
    ("testMagicLiterals", testMagicLiterals),
  ]
}
