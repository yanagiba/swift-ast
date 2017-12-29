/*
   Copyright 2016 Ryuichi Laboratories and the Yanagiba project contributors

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
      guard let nilExpr = expr as? LiteralExpression,
        case .nil = nilExpr.kind else {
        XCTFail("Failed in getting a nil literal")
        return
      }
    })
  }

  func testTrueBooleanLiteral() {
    parseExpressionAndTest("true", "true", testClosure: { expr in
      guard let boolExpr = expr as? LiteralExpression,
        case .boolean(let bool) = boolExpr.kind else {
        XCTFail("Failed in getting a boolean literal")
        return
      }
      XCTAssertTrue(bool)
    })
  }

  func testFalseBooleanLiteral() {
    parseExpressionAndTest("false", "false", testClosure: { expr in
      guard let boolExpr = expr as? LiteralExpression,
        case .boolean(let bool) = boolExpr.kind else {
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
        guard let intExpr = expr as? LiteralExpression,
          case let .integer(int, rawText) = intExpr.kind else {
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
        guard let floatExpr = expr as? LiteralExpression,
          case let .floatingPoint(double, rawText) = floatExpr.kind else {
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
      ("\"\"\"\n\"\"\"", ""),
      ("\"\"\"\n\n\"\"\"", ""),
      ("\"\"\"\n  \n\"\"\"", "  "),
      ("\"\"\"\n  \n  \"\"\"", ""),
      ("\"\"\"\na\n\"\"\"", "a"),
      ("\"\"\"\n\nThe quick brown fox\njumps over\nthe lazy dog\n\n\"\"\"",
        "\nThe quick brown fox\njumps over\nthe lazy dog\n"),
      ("\"\"\"\nThe quick brown fox \\\njumps over \\ \nthe lazy dog\\\t\n\n\"\"\"",
        "The quick brown fox jumps over the lazy dog"),
      ("\"\"\"\n\\0\\\\\\t\\\"\\\'\n\"\"\"", "\0\\\t\"\'"),
    ]
    for t in testStrings {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        guard let strExpr = expr as? LiteralExpression,
          case let .staticString(str, raw) = strExpr.kind else {
          XCTFail("Failed in getting a static string literal")
          return
        }
        XCTAssertEqual(str, t.expectedString)
        XCTAssertEqual(raw, t.testString)
      })
    }
  }

  func testInterpolatedStringLiteral() { /*
    swift-lint:suppress(high_cyclomatic_complexity,nested_code_block_depth)
    */
    let testStrings: [(testString: String, expectedExpressions: [Expression])] = [
      ( // integer literal
        "\"1 2 \\(3)\"",
        [
          LiteralExpression(kind: .staticString("1 2 ", "")),
          LiteralExpression(kind: .integer(3, "3")),
        ]
      ),
      ( // static string literal
        "\"1 2 \\(\"3\")\"",
        [
          LiteralExpression(kind: .staticString("1 2 ", "")),
          LiteralExpression(kind: .staticString("3", "\"3\"")),
        ]
      ),
      ( // nested interpolated string
        "\"\\(\"\\(3)\")\"",
        [
          LiteralExpression(kind: .interpolatedString([
            LiteralExpression(kind: .integer(3, "3"))
          ], "\"\\(3)\"")),
        ]
      ),
      ( // two-level nested interpolated string
        "\"\\(\"\\(\"\\(\"3\")\")\")\"",
        [
          LiteralExpression(kind: .interpolatedString([
            LiteralExpression(kind: .interpolatedString([
              LiteralExpression(kind: .staticString("3", "\"3\""))
            ], "\"\\(\"3\")\"")),
          ], "\"\\(\"\\(\"3\")\")\"")),
        ]
      ),
      ( // heading and tailing static strings
        "\"1 2 \\(3) 4 5\"",
        [
          LiteralExpression(kind: .staticString("1 2 ", "")),
          LiteralExpression(kind: .integer(3, "3")),
          LiteralExpression(kind: .staticString(" 4 5", "")),
        ]
      ),
      ( // multiple interpolated strings in parallel
        "\"\\(\"helloworld\")a\\(\"foo\")\\(\"bar\")z\"",
        [
          LiteralExpression(kind: .staticString("helloworld", "\"helloworld\"")),
          LiteralExpression(kind: .staticString("a", "")),
          LiteralExpression(kind: .staticString("foo", "\"foo\"")),
          LiteralExpression(kind: .staticString("bar", "\"bar\"")),
          LiteralExpression(kind: .staticString("z", "")),
        ]
      ),
      (
        "\"1 2 \\(\"1 + 2\")\"",
        [
          LiteralExpression(kind: .staticString("1 2 ", "")),
          LiteralExpression(kind: .staticString("1 + 2", "\"1 + 2\"")),
        ]
      ),
      (
        "\"1 2 \\(x)\"",
        [
          LiteralExpression(kind: .staticString("1 2 ", "")),
          IdentifierExpression(kind: .identifier("x", nil)),
        ]
      ),
      (
        "\"1 2 \\(\"3\") \\(\"1 + 2\") \\(x) 456\"",
        [
          LiteralExpression(kind: .staticString("1 2 ", "")),
          LiteralExpression(kind: .staticString("3", "\"3\"")),
          LiteralExpression(kind: .staticString(" ", "")),
          LiteralExpression(kind: .staticString("1 + 2", "\"1 + 2\"")),
          LiteralExpression(kind: .staticString(" ", "")),
          IdentifierExpression(kind: .identifier("x", nil)),
          LiteralExpression(kind: .staticString(" 456", "")),
        ]
      ),
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
          LiteralExpression(kind: .interpolatedString([
            LiteralExpression(kind: .staticString("foo", "")),
            LiteralExpression(kind: .integer(123, "123")),
            LiteralExpression(kind: .staticString("()(", "")),
            LiteralExpression(kind: .interpolatedString([
              LiteralExpression(kind: .staticString("abc", "")),
              LiteralExpression(kind: .staticString("😂", "\"😂\"")),
              LiteralExpression(kind: .staticString("xyz)", "")),
            ], "\"abc\\(\"😂\")xyz)\"")),
            LiteralExpression(kind: .integer(789, "789")),
            LiteralExpression(kind: .staticString("bar", "")),
          ], "\"foo\\(123)()(\\(\"abc\\(\"😂\")xyz)\")\\(789)bar\"")),
        ]
      ),
      // multiline interpolated string literals
      (
        "\"\"\"\n1 2 \\(3)\n\"\"\"",
        [
          LiteralExpression(kind: .staticString("1 2 ", "")),
          LiteralExpression(kind: .integer(3, "3")),
        ]
      ),
      (
        "\"\"\"\n  1 2 \\(3)\n\"\"\"",
        [
          LiteralExpression(kind: .staticString("  1 2 ", "")),
          LiteralExpression(kind: .integer(3, "3")),
        ]
      ),
      (
        "\"\"\"\n  1 2 \\(3)\n  \"\"\"",
        [
          LiteralExpression(kind: .staticString("1 2 ", "")),
          LiteralExpression(kind: .integer(3, "3")),
        ]
      ),
      (
        "\"\"\"\n\\(3)\n\"\"\"",
        [
          LiteralExpression(kind: .integer(3, "3")),
        ]
      ),
      (
        "\"\"\"\n\\(3) 4 5\n\"\"\"",
        [
          LiteralExpression(kind: .integer(3, "3")),
          LiteralExpression(kind: .staticString(" 4 5", "")),
        ]
      ),
      (
        "\"\"\"\n\\(3)\n4 5\n\"\"\"",
        [
          LiteralExpression(kind: .integer(3, "3")),
          LiteralExpression(kind: .staticString("\n4 5", "")),
        ]
      ),
      (
        "\"\"\"\n1\n2 \\(3) 4\n5\n\"\"\"",
        [
          LiteralExpression(kind: .staticString("1\n2 ", "")),
          LiteralExpression(kind: .integer(3, "3")),
          LiteralExpression(kind: .staticString(" 4\n5", "")),
        ]
      ),
      (
        "\"\"\"\n 1\n 2 \\(3) 4\n 5\n \"\"\"",
        [
          LiteralExpression(kind: .staticString("1\n2 ", "")),
          LiteralExpression(kind: .integer(3, "3")),
          LiteralExpression(kind: .staticString(" 4\n5", "")),
        ]
      ),
      (
        "\"\"\"\n1 2 \\(\"3\")\n\"\"\"",
        [
          LiteralExpression(kind: .staticString("1 2 ", "")),
          LiteralExpression(kind: .staticString("3", "\"3\"")),
        ]
      ),
      (
        "\"\"\"\n1 2 \\(\"\"\"\n3\n\"\"\")\n\"\"\"",
        [
          LiteralExpression(kind: .staticString("1 2 ", "")),
          LiteralExpression(kind: .staticString("3", "\"\"\"\n3\n\"\"\"")),
        ]
      ),
      (
        "\"\"\"\n\\(\"\"\"\n\\(3)\n\"\"\")\n\"\"\"",
        [
          LiteralExpression(kind: .interpolatedString([
            LiteralExpression(kind: .integer(3, "3"))
          ], "\"\"\"\n\\(3)\n\"\"\"")),
        ]
      ),
      (
        "\"\"\"\n\\(\"\\(\"\\(\"\"\"\n  3\n  \"\"\")\")\")\n\"\"\"",
        [
          LiteralExpression(kind: .interpolatedString([
            LiteralExpression(kind: .interpolatedString([
              LiteralExpression(kind: .staticString("3", "\"\"\"\n  3\n  \"\"\""))
            ], "\"\\(\"\"\"\n  3\n  \"\"\")\"")),
          ], "\"\\(\"\\(\"\"\"\n  3\n  \"\"\")\")\"")),
        ]
      ),
      (
        "\"\"\"\n\\(\"helloworld\")a\\(\"foo\")\\(\"bar\")z\n\"\"\"",
        [
          LiteralExpression(kind: .staticString("helloworld", "\"helloworld\"")),
          LiteralExpression(kind: .staticString("a", "")),
          LiteralExpression(kind: .staticString("foo", "\"foo\"")),
          LiteralExpression(kind: .staticString("bar", "\"bar\"")),
          LiteralExpression(kind: .staticString("z", "")),
        ]
      ),
      (
        "\"\"\"\n  \\(\"bar\")\n  \"\"\"",
        [
          LiteralExpression(kind: .staticString("bar", "\"bar\"")),
        ]
      ),
      (
        "\"\"\"\n  \\(\"\"\"\nhelloworld\n\"\"\")a\\(\"foo\")\\(\"bar\")z\n  \"\"\"",
        [
          LiteralExpression(kind: .staticString("helloworld", "\"\"\"\nhelloworld\n\"\"\"")),
          LiteralExpression(kind: .staticString("a", "")),
          LiteralExpression(kind: .staticString("foo", "\"foo\"")),
          LiteralExpression(kind: .staticString("bar", "\"bar\"")),
          LiteralExpression(kind: .staticString("z", "")),
        ]
      ),
      (
        "\"\"\"\n  \\(\"\"\"\n    hello\n    world\n    \"\"\")\n  a\n  \\(\"foo\")\n  \\(\"bar\")\n  z\n  \"\"\"",
        [
          LiteralExpression(kind: .staticString("hello\nworld", "\"\"\"\n    hello\n    world\n    \"\"\"")),
          LiteralExpression(kind: .staticString("\na\n", "")),
          LiteralExpression(kind: .staticString("foo", "\"foo\"")),
          LiteralExpression(kind: .staticString("\n", "")),
          LiteralExpression(kind: .staticString("bar", "\"bar\"")),
          LiteralExpression(kind: .staticString("\nz", "")),
        ]
      ),
      (
        "\"\"\"\n  \n  \\(\"bar\")\n  \n  \"\"\"",
        [
          LiteralExpression(kind: .staticString("\n", "")),
          LiteralExpression(kind: .staticString("bar", "\"bar\"")),
          LiteralExpression(kind: .staticString("\n", "")),
        ]
      ),
      (
        "\"\"\"\n\n  \\(\"bar\")\n\n  \"\"\"",
        [
          LiteralExpression(kind: .staticString("\n", "")),
          LiteralExpression(kind: .staticString("bar", "\"bar\"")),
          LiteralExpression(kind: .staticString("\n", "")),
        ]
      ),
      (
        "\"\"\"\na\\\n \\(\"bar\")\n\"\"\"",
        [
          LiteralExpression(kind: .staticString("a ", "")),
          LiteralExpression(kind: .staticString("bar", "\"bar\"")),
        ]
      ),
      (
        "\"\"\"\n\n  \\(\"bar\")a\\\nb\n  \"\"\"",
        [
          LiteralExpression(kind: .staticString("\n", "")),
          LiteralExpression(kind: .staticString("bar", "\"bar\"")),
          LiteralExpression(kind: .staticString("ab", "")),
        ]
      ),
    ]

    func testInterpolatedStringExpressions(exprs: [Expression], expected: [Expression]) { /*
      swift-lint:suppress(high_cyclomatic_complexity)
      */
      // keep this with the minimal code to make the tests pass, and add more handlings when needed
      guard exprs.count == expected.count else {
        XCTFail("""
        Parsed interpolated string literal
        \(exprs)
        doesn't contain the matching expressions as expected
        \(expected).
        """)
        return
      }

      for (index, e) in zip(exprs.indices, exprs) {
        let expectedExpr = expected[index]
        if let literalExpr = expectedExpr as? LiteralExpression {
          switch literalExpr.kind {
          case let .integer(i, r):
            guard let ee = e as? LiteralExpression,
              case let .integer(ei, er) = ee.kind, i == ei, r == er else {
              XCTFail("Failed in parsing a correct integer literal, expected: \(i)")
              return
            }
          case let .staticString(s, r):
            guard let ee = e as? LiteralExpression,
              case let .staticString(es, er) = ee.kind, s == es, r == er else {
              XCTFail("Failed in parsing a correct static string literal, expected: \(s)")
              return
            }
          case let .interpolatedString(ises, r):
            guard let ee = e as? LiteralExpression,
              case let .interpolatedString(ees, er) = ee.kind, r == er else {
              XCTFail("Failed in parsing a correct interpolated string literal, expected: \(r)")
              return
            }
            testInterpolatedStringExpressions(exprs: ees, expected: ises)
          default:
            XCTFail("Literal expression case not handled")
          }
        } else if let identifierExpr = expectedExpr as? IdentifierExpression {
          switch identifierExpr.kind {
          case let .identifier(name, nil):
            guard let ee = e as? IdentifierExpression,
              case let .identifier(en, nil) = ee.kind, name == en else {
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
        guard let strExpr = expr as? LiteralExpression,
          case let .interpolatedString(exprs, rawText) = strExpr.kind else {
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
      guard let arrayExpr = expr as? LiteralExpression,
        case .array(let exprs) = arrayExpr.kind else {
        XCTFail("Failed in getting an array literal")
        return
      }
      XCTAssertTrue(exprs.isEmpty)
    })
  }

  func testSimpleArrayLiteral() {
    parseExpressionAndTest("[1, 2, 3]", "[1, 2, 3]", testClosure: { expr in
      guard let arrayExpr = expr as? LiteralExpression,
        case .array(let exprs) = arrayExpr.kind else {
        XCTFail("Failed in getting an array literal")
        return
      }
      guard exprs.count == 3 else {
        XCTFail("Array literal doesn't contain 3 elements")
        return
      }
      for i in 0..<3 {
        guard let literalExpr = exprs[i] as? LiteralExpression,
          case .integer(let ei, _) = literalExpr.kind, ei == i + 1 else {
          XCTFail("Element in array literal is not correct parsed")
          return
        }
      }
    })
  }

  func testArrayEndingWithComma() {
    parseExpressionAndTest("[1, 2, 3, ]", "[1, 2, 3]", testClosure: { expr in
      guard let arrayExpr = expr as? LiteralExpression,
        case .array(let exprs) = arrayExpr.kind else {
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
    parseExpressionAndTest(
      "[[1, 2, 3], [7, 8, 9]]",
      "[[1, 2, 3], [7, 8, 9]]",
      testClosure: { expr in
        guard let arrayExpr = expr as? LiteralExpression,
          case .array(let exprs) = arrayExpr.kind else {
          XCTFail("Failed in getting an array literal")
          return
        }
        guard exprs.count == 2 else {
          XCTFail("Array literal doesn't contain 2 elements")
          return
        }
      }
    )
  }

  func testArrayWithDictionaries() {
    parseExpressionAndTest(
      "[[\"foo\": true, \"bar\": false]]",
      "[[\"foo\": true, \"bar\": false]]",
      testClosure: { expr in
        guard let arrayExpr = expr as? LiteralExpression,
          case .array(let exprs) = arrayExpr.kind else {
          XCTFail("Failed in getting an array literal")
          return
        }
        guard exprs.count == 1 else {
          XCTFail("Array literal doesn't contain one element")
          return
        }
      }
    )
  }

  func testArrayLiteralContainsAllLiterals() {
    parseExpressionAndTest(
      "[nil, 1, 1.23, \"foo\", \"\\(1)\", true, [1, 2, 3], [1: true, 2: false, 3: true, 4: false], #file]",
      "[nil, 1, 1.23, \"foo\", \"\\(1)\", true, [1, 2, 3], [1: true, 2: false, 3: true, 4: false], #file]",
      testClosure: { expr in
      guard let arrayExpr = expr as? LiteralExpression,
        case .array(let exprs) = arrayExpr.kind else {
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
      guard let dictExpr = expr as? LiteralExpression,
        case .dictionary(let exprs) = dictExpr.kind else {
        XCTFail("Failed in getting a dictionary literal")
        return
      }
      XCTAssertTrue(exprs.isEmpty)
    })
  }

  func testSimpleDictionaryLiteral() { // swift-lint:suppress(high_cyclomatic_complexity)
    parseExpressionAndTest("[\"foo\": true, \"bar\": false]", "[\"foo\": true, \"bar\": false]", testClosure: { expr in
      guard
        let dictExpr = expr as? LiteralExpression,
        case .dictionary(let exprs) = dictExpr.kind
      else {
        XCTFail("Failed in getting a dictionary literal")
        return
      }
      guard exprs.count == 2 else {
        XCTFail("Dictionary literal doesn't contain 2 entries")
        return
      }
      guard
        let keyExpr1 = exprs[0].key as? LiteralExpression,
        let valueExpr1 = exprs[0].value as? LiteralExpression,
        case .staticString(let es1, _) = keyExpr1.kind,
        case .boolean(let eb1) = valueExpr1.kind,
        es1 == "foo",
        eb1
      else {
        XCTFail("First entry in dictinoary literal is not correct parsed")
        return
      }
      guard
        let keyExpr2 = exprs[1].key as? LiteralExpression,
        let valueExpr2 = exprs[1].value as? LiteralExpression,
        case .staticString(let es2, _) = keyExpr2.kind,
        case .boolean(let eb2) = valueExpr2.kind,
        es2 == "bar",
        !eb2
      else {
        XCTFail("Second entry in dictinoary literal is not correct parsed")
        return
      }
    })
  }

  func testDictinoaryEndingWithComma() {
    parseExpressionAndTest(
      "[\"foo\": true, \"bar\": false, ]",
      "[\"foo\": true, \"bar\": false]",
      testClosure: { expr in
        guard let dictExpr = expr as? LiteralExpression,
          case .dictionary(let exprs) = dictExpr.kind else {
          XCTFail("Failed in getting a dictionary literal")
          return
        }
        guard exprs.count == 2 else {
          XCTFail("Dictionary literal doesn't contain 2 entries")
          return
        }
      }
    )
  }

  func testDictionaryWithDictionaries() {
    parseExpressionAndTest(
      "[[\"foo\": true, \"bar\": false]: 1, 2: [\"foo\": true, \"bar\": false]]",
      "[[\"foo\": true, \"bar\": false]: 1, 2: [\"foo\": true, \"bar\": false]]",
      testClosure: { expr in
      guard let dictExpr = expr as? LiteralExpression,
        case .dictionary(let exprs) = dictExpr.kind else {
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
      guard let dictExpr = expr as? LiteralExpression,
        case .dictionary(let exprs) = dictExpr.kind else {
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
      "[nil: 1, 1.23: \"foo\", \"\\(1 + 2)\": true, [1, 2, 3]: [1: true, 2: false, 3: true, 4: false], #line: [1: true]]", // swift-lint:suppress(long_line)
      "[nil: 1, 1.23: \"foo\", \"\\(1 + 2)\": true, [1, 2, 3]: [1: true, 2: false, 3: true, 4: false], #line: [1: true]]", // swift-lint:suppress(long_line)
      testClosure: { expr in
        guard let dictExpr = expr as? LiteralExpression,
          case .dictionary(let exprs) = dictExpr.kind else {
          XCTFail("Failed in getting a dictionary literal")
          return
        }
        guard exprs.count == 5 else {
          XCTFail("Dictionary literal doesn't contain 5 entries")
          return
        }
      }
    )
  }

  func testMagicLiterals() { // swift-lint:suppress(high_cyclomatic_complexity)
    let testStrings: [(testString: String, expectedExpr: LiteralExpression.Kind)] = [
      ("#file", .staticString("ParserTests/ParserTests.swift", "#file")),
      ("#line", .integer(1, "#line")),
      ("#column", .integer(1, "#column")),
      ("#function", .staticString("TODO", "#function")),
    ]
    for t in testStrings {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        switch t.expectedExpr {
        case let .integer(i, r):
          guard let ee = expr as? LiteralExpression,
            case let .integer(ei, er) = ee.kind, i == ei, r == er else {
            XCTFail("Failed in parsing a correct integer literal, expected: \(i)")
            return
          }
        case let .staticString(s, r):
          guard let ee = expr as? LiteralExpression,
            case let .staticString(es, er) = ee.kind, s == es, r == er else {
            XCTFail("Failed in parsing a correct static string literal, expected: \(s)")
            return
          }
        default:
          XCTFail("Literal expression case not handled")
        }
      })
    }

    // Tests for playground literals to address issue #71 and #72
    // https://github.com/yanagiba/swift-ast/issues/71
    // https://github.com/yanagiba/swift-ast/issues/72
    parseExpressionAndTest(
      "#colorLiteral(red: 0, green: 0, blue: 1, alpha: 1)",
      "#colorLiteral(red: 0, green: 0, blue: 1, alpha: 1)",
      testClosure: { expr in
        guard
          let literalExpr = expr as? LiteralExpression,
          case .playground(let playgroundLiteral) = literalExpr.kind,
          case .color = playgroundLiteral
        else {
          XCTFail("Failed in getting playground literal")
          return
        }
      }
    )
    parseExpressionAndTest(
      "#imageLiteral(resourceName: \"SomeResource\")",
      "#imageLiteral(resourceName: \"SomeResource\")",
      testClosure: { expr in
        guard
          let literalExpr = expr as? LiteralExpression,
          case .playground(let playgroundLiteral) = literalExpr.kind,
          case .image = playgroundLiteral
        else {
          XCTFail("Failed in getting playground literal")
          return
        }
      }
    )
    parseExpressionAndTest(
      "#fileLiteral(resourceName: \"SomeResource\")",
      "#fileLiteral(resourceName: \"SomeResource\")",
      testClosure: { expr in
        guard
          let literalExpr = expr as? LiteralExpression,
          case .playground(let playgroundLiteral) = literalExpr.kind,
          case .file = playgroundLiteral
        else {
          XCTFail("Failed in getting playground literal")
          return
        }
      }
    )
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("nil", 4),
      ("true", 5),
      ("false", 6),
      ("0b0", 4),
      ("0o01_67_24_35", 14),
      ("-0xFF_eb_ca_DA", 15),
      ("10_0.000_3", 11),
      ("-0xa_1.eaP-1_5", 15),
      ("\"\"", 3),
      ("\"The quick brown fox jumps over the lazy dog\"", 46),
      ("\"\\0\\\\\\t\\n\\r\\\"\\\'\"", 17),
      ("\"\\(\"helloworld\")a\\(\"foo\")\\(\"bar\")z\"", 36),
      ("\"1 2 \\(\"1 + 2\")\"", 17),
      ("[]", 3),
      ("[1, 2, 3]", 10),
      ("[:]", 4),
      ("[\"foo\": true, \"bar\": false]", 28),
      ("#file", 6),
      ("#line", 6),
      ("#column", 8),
      ("#function", 10),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
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
    ("testInterpolatedStringExpressionsContainFunctionCallExpr",
      testInterpolatedStringExpressionsContainFunctionCallExpr),
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
    ("testSourceRange", testSourceRange),
  ]
}
