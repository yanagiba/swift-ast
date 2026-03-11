/*
   Copyright 2016, 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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
@testable import Diagnostic

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
    // Helpers to reduce verbosity in test data
    func txt(_ value: String) -> InterpolationSegment { .text(value) }
    func interp(_ expr: ASTExpression) -> InterpolationSegment { .interpolation([.expression(expr)]) }
    func int(_ i: Int, _ r: String) -> LiteralExpression { LiteralExpression(kind: .integer(i, r)) }
    func str(_ s: String, _ r: String) -> LiteralExpression { LiteralExpression(kind: .staticString(s, r)) }
    func id(_ name: String) -> IdentifierExpression { IdentifierExpression(kind: .identifier(.name(name), nil)) }
    func nested(_ segments: [InterpolationSegment], _ raw: String) -> LiteralExpression {
      LiteralExpression(kind: .interpolatedString(segments, raw))
    }

    let testStrings: [(testString: String, expectedSegments: [InterpolationSegment])] = [
      ( // integer literal
        "\"1 2 \\(3)\"",
        [txt("1 2 "), interp(int(3, "3"))]
      ),
      ( // static string literal
        "\"1 2 \\(\"3\")\"",
        [txt("1 2 "), interp(str("3", "\"3\""))]
      ),
      ( // nested interpolated string
        "\"\\(\"\\(3)\")\"",
        [interp(nested([interp(int(3, "3"))], "\"\\(3)\""))]
      ),
      ( // two-level nested interpolated string
        "\"\\(\"\\(\"\\(\"3\")\")\")\"",
        [interp(nested([
          interp(nested([
            interp(str("3", "\"3\""))
          ], "\"\\(\"3\")\""))
        ], "\"\\(\"\\(\"3\")\")\"")),
        ]
      ),
      ( // heading and tailing static strings
        "\"1 2 \\(3) 4 5\"",
        [txt("1 2 "), interp(int(3, "3")), txt(" 4 5")]
      ),
      ( // multiple interpolated strings in parallel
        "\"\\(\"helloworld\")a\\(\"foo\")\\(\"bar\")z\"",
        [
          interp(str("helloworld", "\"helloworld\"")),
          txt("a"),
          interp(str("foo", "\"foo\"")),
          interp(str("bar", "\"bar\"")),
          txt("z"),
        ]
      ),
      (
        "\"1 2 \\(\"1 + 2\")\"",
        [txt("1 2 "), interp(str("1 + 2", "\"1 + 2\""))]
      ),
      (
        "\"1 2 \\(x)\"",
        [txt("1 2 "), interp(id("x"))]
      ),
      (
        "\"1 2 \\(\"3\") \\(\"1 + 2\") \\(x) 456\"",
        [
          txt("1 2 "), interp(str("3", "\"3\"")),
          txt(" "), interp(str("1 + 2", "\"1 + 2\"")),
          txt(" "), interp(id("x")),
          txt(" 456"),
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
        [interp(nested([
          txt("foo"),
          interp(int(123, "123")),
          txt("()("),
          interp(nested([
            txt("abc"),
            interp(str("😂", "\"😂\"")),
            txt("xyz)"),
          ], "\"abc\\(\"😂\")xyz)\"")),
          interp(int(789, "789")),
          txt("bar"),
        ], "\"foo\\(123)()(\\(\"abc\\(\"😂\")xyz)\")\\(789)bar\""))]
      ),
      // multiline interpolated string literals
      (
        "\"\"\"\n1 2 \\(3)\n\"\"\"",
        [txt("1 2 "), interp(int(3, "3"))]
      ),
      (
        "\"\"\"\n  1 2 \\(3)\n\"\"\"",
        [txt("  1 2 "), interp(int(3, "3"))]
      ),
      (
        "\"\"\"\n  1 2 \\(3)\n  \"\"\"",
        [txt("1 2 "), interp(int(3, "3"))]
      ),
      (
        "\"\"\"\n\\(3)\n\"\"\"",
        [interp(int(3, "3"))]
      ),
      (
        "\"\"\"\n\\(3) 4 5\n\"\"\"",
        [interp(int(3, "3")), txt(" 4 5")]
      ),
      (
        "\"\"\"\n\\(3)\n4 5\n\"\"\"",
        [interp(int(3, "3")), txt("\n4 5")]
      ),
      (
        "\"\"\"\n1\n2 \\(3) 4\n5\n\"\"\"",
        [txt("1\n2 "), interp(int(3, "3")), txt(" 4\n5")]
      ),
      (
        "\"\"\"\n 1\n 2 \\(3) 4\n 5\n \"\"\"",
        [txt("1\n2 "), interp(int(3, "3")), txt(" 4\n5")]
      ),
      (
        "\"\"\"\n1 2 \\(\"3\")\n\"\"\"",
        [txt("1 2 "), interp(str("3", "\"3\""))]
      ),
      (
        "\"\"\"\n1 2 \\(\"\"\"\n3\n\"\"\")\n\"\"\"",
        [txt("1 2 "), interp(str("3", "\"\"\"\n3\n\"\"\""))]
      ),
      (
        "\"\"\"\n\\(\"\"\"\n\\(3)\n\"\"\")\n\"\"\"",
        [interp(nested([interp(int(3, "3"))], "\"\"\"\n\\(3)\n\"\"\""))]
      ),
      (
        "\"\"\"\n\\(\"\\(\"\\(\"\"\"\n  3\n  \"\"\")\")\")\n\"\"\"",
        [interp(nested([
          interp(nested([
            interp(str("3", "\"\"\"\n  3\n  \"\"\""))
          ], "\"\\(\"\"\"\n  3\n  \"\"\")\"")),
        ], "\"\\(\"\\(\"\"\"\n  3\n  \"\"\")\")\"")),
        ]
      ),
      (
        "\"\"\"\n\\(\"helloworld\")a\\(\"foo\")\\(\"bar\")z\n\"\"\"",
        [
          interp(str("helloworld", "\"helloworld\"")),
          txt("a"),
          interp(str("foo", "\"foo\"")),
          interp(str("bar", "\"bar\"")),
          txt("z"),
        ]
      ),
      (
        "\"\"\"\n  \\(\"bar\")\n  \"\"\"",
        [interp(str("bar", "\"bar\""))]
      ),
      (
        "\"\"\"\n  \\(\"\"\"\nhelloworld\n\"\"\")a\\(\"foo\")\\(\"bar\")z\n  \"\"\"",
        [
          interp(str("helloworld", "\"\"\"\nhelloworld\n\"\"\"")),
          txt("a"),
          interp(str("foo", "\"foo\"")),
          interp(str("bar", "\"bar\"")),
          txt("z"),
        ]
      ),
      (
        "\"\"\"\n  \\(\"\"\"\n    hello\n    world\n    \"\"\")\n  a\n  \\(\"foo\")\n  \\(\"bar\")\n  z\n  \"\"\"",
        [
          interp(str("hello\nworld", "\"\"\"\n    hello\n    world\n    \"\"\"")),
          txt("\na\n"),
          interp(str("foo", "\"foo\"")),
          txt("\n"),
          interp(str("bar", "\"bar\"")),
          txt("\nz"),
        ]
      ),
      (
        "\"\"\"\n  \n  \\(\"bar\")\n  \n  \"\"\"",
        [txt("\n"), interp(str("bar", "\"bar\"")), txt("\n")]
      ),
      (
        "\"\"\"\n\n  \\(\"bar\")\n\n  \"\"\"",
        [txt("\n"), interp(str("bar", "\"bar\"")), txt("\n")]
      ),
      (
        "\"\"\"\na\\\n \\(\"bar\")\n\"\"\"",
        [txt("a "), interp(str("bar", "\"bar\""))]
      ),
      (
        "\"\"\"\n\n  \\(\"bar\")a\\\nb\n  \"\"\"",
        [txt("\n"), interp(str("bar", "\"bar\"")), txt("ab")]
      ),
    ]

    func assertSegmentsMatch( // swift-lint:suppress(high_cyclomatic_complexity)
      _ actual: [InterpolationSegment], _ expected: [InterpolationSegment]
    ) {
      guard actual.count == expected.count else {
        XCTFail("Segment count mismatch: got \(actual.count), expected \(expected.count)")
        return
      }
      for (index, (a, e)) in zip(actual, expected).enumerated() {
        switch (a, e) {
        case let (.text(aVal), .text(eVal)):
          XCTAssertEqual(aVal, eVal, "Text value mismatch at index \(index)")
        case let (.interpolation(aArgs), .interpolation(eArgs)):
          guard aArgs.count == eArgs.count else {
            XCTFail("Arg count mismatch at index \(index): got \(aArgs.count), expected \(eArgs.count)")
            return
          }
          for (argIdx, (aArg, eArg)) in zip(aArgs, eArgs).enumerated() {
            assertArgumentsMatch(aArg, eArg, context: "segment \(index), arg \(argIdx)")
          }
        default:
          XCTFail("Segment type mismatch at index \(index): got \(a), expected \(e)")
        }
      }
    }

    func assertArgumentsMatch(
      _ actual: FunctionCallExpression.Argument,
      _ expected: FunctionCallExpression.Argument,
      context: String
    ) {
      switch (actual, expected) {
      case let (.expression(aExpr), .expression(eExpr)):
        assertExpressionsMatch(aExpr, eExpr, context: context)
      case let (.namedExpression(aName, aExpr), .namedExpression(eName, eExpr)):
        XCTAssertTrue(aName.isSyntacticallyEqual(to: eName), "Label mismatch at \(context)")
        assertExpressionsMatch(aExpr, eExpr, context: context)
      default:
        XCTFail("Argument type mismatch at \(context)")
      }
    }

    func assertExpressionsMatch( // swift-lint:suppress(high_cyclomatic_complexity)
      _ actual: ASTExpression, _ expected: ASTExpression, context: String
    ) {
      if let eLit = expected as? LiteralExpression {
        guard let aLit = actual as? LiteralExpression else {
          XCTFail("Expected LiteralExpression at \(context), got \(type(of: actual))")
          return
        }
        switch (aLit.kind, eLit.kind) {
        case let (.integer(ai, ar), .integer(ei, er)):
          XCTAssertEqual(ai, ei, "Integer value mismatch at \(context)")
          XCTAssertEqual(ar, er, "Integer raw mismatch at \(context)")
        case let (.staticString(as_, ar), .staticString(es, er)):
          XCTAssertEqual(as_, es, "String value mismatch at \(context)")
          XCTAssertEqual(ar, er, "String raw mismatch at \(context)")
        case let (.interpolatedString(aSegs, aRaw), .interpolatedString(eSegs, eRaw)):
          XCTAssertEqual(aRaw, eRaw, "Interpolated string raw mismatch at \(context)")
          assertSegmentsMatch(aSegs, eSegs)
        default:
          XCTFail("Literal kind mismatch at \(context)")
        }
      } else if let eId = expected as? IdentifierExpression {
        guard let aId = actual as? IdentifierExpression,
          case let .identifier(eName, nil) = eId.kind,
          case let .identifier(aName, nil) = aId.kind,
          aName.isSyntacticallyEqual(to: eName)
        else {
          XCTFail("Identifier mismatch at \(context)")
          return
        }
      } else {
        XCTFail("Unhandled expression type at \(context)")
      }
    }

    for t in testStrings {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        guard let strExpr = expr as? LiteralExpression,
          case let .interpolatedString(segments, rawText) = strExpr.kind else {
          XCTFail("Failed in getting an interpolated string literal")
          return
        }
        assertSegmentsMatch(segments, t.expectedSegments)
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

  func testInterpolationSegmentTextDescription() {
    // .text returns the text value directly
    let textSeg: InterpolationSegment = .text("hello world")
    XCTAssertEqual(textSeg.textDescription, "hello world")

    // .interpolation with single unlabeled arg
    let singleArg: InterpolationSegment = .interpolation([
      .expression(IdentifierExpression(kind: .identifier(.name("x"), nil)))
    ])
    XCTAssertEqual(singleArg.textDescription, "\\(x)")

    // .interpolation with multiple args including label (SE-0228)
    let multiArg: InterpolationSegment = .interpolation([
      .expression(IdentifierExpression(kind: .identifier(.name("x"), nil))),
      .namedExpression(.name("format"), IdentifierExpression(kind: .identifier(.name("y"), nil)))
    ])
    XCTAssertEqual(multiArg.textDescription, "\\(x, format: y)")
  }

  func testEmptyInterpolatedTextItem() {
    var capturedError: Error?
    parseExpressionAndTest(
      "\"\\()\"", "\"\\()\"",
      errorClosure: { capturedError = $0 })
    guard let _ = capturedError as? DiagnosticStopper else {
      XCTFail("Expected empty interpolation to be rejected")
      return
    }
  }

  // MARK: - SE-0228: Multi-argument string interpolation

  func testInterpolatedStringWithTwoUnlabeledArgs() {
    // "\(x, y)" — two unlabeled arguments parsed as argument list
    parseExpressionAndTest(
      "\"\\(x, y)\"",
      "\"\\(x, y)\"",
      testClosure: { expr in
        guard let strExpr = expr as? LiteralExpression,
          case let .interpolatedString(segments, rawText) = strExpr.kind else {
          XCTFail("Failed in getting an interpolated string literal")
          return
        }
        XCTAssertEqual(rawText, "\"\\(x, y)\"")
        XCTAssertEqual(segments.count, 1)
        guard case .interpolation(let args) = segments[0] else {
          XCTFail("Expected interpolation segment")
          return
        }
        XCTAssertEqual(args.count, 2)
        guard case .expression = args[0], case .expression = args[1] else {
          XCTFail("Expected unlabeled expression arguments")
          return
        }
      })
  }

  func testInterpolatedStringWithLabeledArg() {
    // "\(x, format: .fixed(2))" — SE-0228 labeled argument
    parseExpressionAndTest(
      "\"\\(x, format: .fixed(2))\"",
      "\"\\(x, format: .fixed(2))\"",
      testClosure: { expr in
        guard let strExpr = expr as? LiteralExpression,
          case let .interpolatedString(segments, rawText) = strExpr.kind else {
          XCTFail("Failed in getting an interpolated string literal")
          return
        }
        XCTAssertEqual(rawText, "\"\\(x, format: .fixed(2))\"")
        XCTAssertEqual(segments.count, 1)
        guard case .interpolation(let args) = segments[0] else {
          XCTFail("Expected interpolation segment")
          return
        }
        XCTAssertEqual(args.count, 2)
        guard case .expression = args[0] else {
          XCTFail("Expected unlabeled first argument")
          return
        }
        guard case let .namedExpression(label, _) = args[1] else {
          XCTFail("Expected labeled second argument")
          return
        }
        XCTAssertTrue(label.isSyntacticallyEqual(to: .name("format")))
      })
  }

  func testInterpolatedStringWithSpecifierLabeledArg() {
    // "\(x, specifier: "%0.2f")" — another labeled pattern
    parseExpressionAndTest(
      "\"\\(x, specifier: \"%0.2f\")\"",
      "\"\\(x, specifier: \"%0.2f\")\"",
      testClosure: { expr in
        guard let strExpr = expr as? LiteralExpression,
          case let .interpolatedString(segments, rawText) = strExpr.kind else {
          XCTFail("Failed in getting an interpolated string literal")
          return
        }
        XCTAssertEqual(rawText, "\"\\(x, specifier: \"%0.2f\")\"")
        XCTAssertEqual(segments.count, 1)
        guard case .interpolation(let args) = segments[0] else {
          XCTFail("Expected interpolation segment")
          return
        }
        XCTAssertEqual(args.count, 2)
        guard case let .namedExpression(label, _) = args[1] else {
          XCTFail("Expected labeled second argument")
          return
        }
        XCTAssertTrue(label.isSyntacticallyEqual(to: .name("specifier")))
      })
  }

  // MARK: - Interpolation edge cases

  func testArrayLiteralInInterpolation() {
    // "\([1, 2, 3])" — array literal inside interpolation
    parseExpressionAndTest(
      "\"\\([1, 2, 3])\"",
      "\"\\([1, 2, 3])\"")
  }

  func testDictionaryLiteralInInterpolation() {
    // "\([1: "a"])" — dictionary literal inside interpolation
    parseExpressionAndTest(
      "\"\\([1: \"a\"])\"",
      "\"\\([1: \"a\"])\"")
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

  func testBareRegexLiteral() {
    let tests: [(testString: String, expectedPattern: String)] = [
      ("/abc/", "abc"),
      ("/\\d+/", "\\d+"),
      ("/hello world/", "hello world"),
      ("/[a-z]+/", "[a-z]+"),
      // Bracket-aware: / inside brackets doesn't close
      ("/[a/b]/", "[a/b]"),
      ("/(foo/bar)/", "(foo/bar)"),
      ("/a{2,3}/", "a{2,3}"),
      // Backslash escape
      ("/foo\\/bar/", "foo\\/bar"),
    ]
    for t in tests {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        guard let regexExpr = expr as? LiteralExpression,
          case let .regex(pattern, raw) = regexExpr.kind else {
          XCTFail("Failed in getting a regex literal for `\(t.testString)`")
          return
        }
        XCTAssertEqual(pattern, t.expectedPattern)
        XCTAssertEqual(raw, t.testString)
      })
    }
  }

  func testRegexLiteral() {
    let tests: [(testString: String, expectedPattern: String)] = [
      // Single-hash
      ("#/abc/#", "abc"),
      ("#/\\d+/#", "\\d+"),
      ("#/foo/bar/#", "foo/bar"),
      ("#/hello world/#", "hello world"),
      ("#/[a-z]+\\.\\d{2,}/#", "[a-z]+\\.\\d{2,}"),
      // Multi-hash
      ("##/abc/##", "abc"),
      ("##/foo/#bar/##", "foo/#bar"),
      ("###/a]b/##c/###", "a]b/##c"),
      // Multiline (single-hash)
      ("#/\nabc\n/#", "abc"),
      ("#/\nfoo\nbar\n/#", "foo\nbar"),
      ("#/\n  indented\n/#", "  indented"),
      // Multiline (multi-hash)
      ("##/\nfoo/#bar\n/##", "foo/#bar"),
    ]
    for t in tests {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        guard let regexExpr = expr as? LiteralExpression,
          case let .regex(pattern, raw) = regexExpr.kind else {
          XCTFail("Failed in getting a regex literal for `\(t.testString)`")
          return
        }
        XCTAssertEqual(pattern, t.expectedPattern)
        XCTAssertEqual(raw, t.testString)
      })
    }
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
}
