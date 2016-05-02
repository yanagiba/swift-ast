/*
   Copyright 2015-2016 Ryuichi Saito, LLC

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

@testable import source
@testable import parser

import Foundation

import XCTest

private extension Lexer {
  private func lex(_ text: String) -> LexicalContext {
    let testSourceFile = SourceFile(path: "test/lexer", content: text)
    return lex(source: testSourceFile)
  }
}

private extension LexicalContext {
  private var onlyTokens: [Token] {
    return tokens.map { $0.0 }
  }
}

private extension SourceRange {
  private var testDescription: String {
    return "\(start.path):\(start.line):\(start.column)-\(end.path):\(end.line):\(end.column)"
  }
}

class LexerTests: XCTestCase {
  let lexer = Lexer()

  func testLexEmptyString() {
    let lexicalContext = lexer.lex("")
    XCTAssertEqual(lexicalContext.tokens.count, 0)
  }

  func testLexInvalidToken() {
    let lexicalContext = lexer.lex("\u{7}")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    let token = tokens[0].0
    XCTAssertEqual(token, Token.Invalid(invalidTokenString: "\u{7}"))
    XCTAssertEqual(token.description, "\u{7}")
    XCTAssertFalse(token.isWhitespace())
    let range = tokens[0].1
    XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:2")
  }

  func testLexOneLineFeed() {
    let lexicalContext = lexer.lex("\n")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    let token = tokens[0].0
    XCTAssertEqual(token, Token.LineFeed)
    XCTAssertEqual(token.description, "\n")
    XCTAssertTrue(token.isWhitespace())
    let range = tokens[0].1
    XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:2:1")
  }

  func testLexThreeLineFeeds() {
    let lexicalContext = lexer.lex("\n\n\n")
    let tokens = lexicalContext.onlyTokens
    XCTAssertEqual(tokens.count, 3)
    for token in tokens {
      XCTAssertEqual(token, Token.LineFeed)
      XCTAssertEqual(token.description, "\n")
      XCTAssertTrue(token.isWhitespace())
    }
  }

  func testLexOneCarriageReturn() {
    let lexicalContext = lexer.lex("\r")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    let token = tokens[0].0
    XCTAssertEqual(token, Token.CarriageReturn)
    XCTAssertEqual(token.description, "\r")
    XCTAssertTrue(token.isWhitespace())
    let range = tokens[0].1
    XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:2:1")
  }

  func testLexOneCarriageReturnForCRLF() {
    let lexicalContext = lexer.lex("\r\n")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 2)
    XCTAssertEqual(tokens[0].0, Token.CarriageReturn)
    XCTAssertEqual(tokens[1].0, Token.LineFeed)
    XCTAssertEqual(tokens[0].1.testDescription, "test/lexer:1:1-test/lexer:2:1")
    XCTAssertEqual(tokens[1].1.testDescription, "test/lexer:1:1-test/lexer:2:1")
  }

  func testLexneHorizontalTab() {
    let lexicalContext = lexer.lex("\t")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    let token = tokens[0].0
    XCTAssertEqual(token, Token.HorizontalTab)
    XCTAssertEqual(token.description, "\t")
    XCTAssertTrue(token.isWhitespace())
    let range = tokens[0].1
    XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:2")
  }

  func testLexOneFormFeed() {
    let lexicalContext = lexer.lex("\u{000C}")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    let token = tokens[0].0
    XCTAssertEqual(token, Token.FormFeed)
    XCTAssertEqual(token.description, "\u{000C}")
    XCTAssertTrue(token.isWhitespace())
    let range = tokens[0].1
    XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:2")
  }

  func testLexOneNull() {
    let lexicalContext = lexer.lex("\0")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    let token = tokens[0].0
    XCTAssertEqual(token, Token.Null)
    XCTAssertEqual(token.description, "\0")
    XCTAssertTrue(token.isWhitespace())
    let range = tokens[0].1
    XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:2")
  }

  func testLexOneNil() {
    let lexicalContext = lexer.lex("nil")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    let token = tokens[0].0
    XCTAssertEqual(token, Token.NilLiteral)
    XCTAssertEqual(token.description, "nil")
    XCTAssertFalse(token.isWhitespace())
    let range = tokens[0].1
    XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:4")
  }

  func testLexTwoNils() {
    let lexicalContext = lexer.lex("nil nil")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 3)
    XCTAssertEqual(tokens[0].0, Token.NilLiteral)
    XCTAssertEqual(tokens[0].1.testDescription, "test/lexer:1:1-test/lexer:1:4")
    XCTAssertEqual(tokens[1].0, Token.Space)
    XCTAssertEqual(tokens[1].1.testDescription, "test/lexer:1:4-test/lexer:1:5")
    XCTAssertEqual(tokens[2].0, Token.NilLiteral)
    XCTAssertEqual(tokens[2].1.testDescription, "test/lexer:1:5-test/lexer:1:8")
  }

  func testLexBinaryLiterals() {
    let testStrings = ["0b0", "0b1", "0b01", "0b1010", "0b01_10_01_10", "-0b1", "-0b10_10_10_10"]
    for testString in testStrings {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.tokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0].0
      XCTAssertEqual(token, Token.BinaryIntegerLiteral(testString))
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
      let range = tokens[0].1
      XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:\(1 + testString.utf16.count)")
    }
  }

  func testLexOctalLiterals() {
    let testStrings = ["0o0", "0o1", "0o7", "0o01", "0o1217", "0o01_67_24_35", "-0o7", "-0o10_23_45_67"]
    for testString in testStrings {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.tokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0].0
      XCTAssertEqual(token, Token.OctalIntegerLiteral(testString))
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
      let range = tokens[0].1
      XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:\(1 + testString.utf16.count)")
    }
  }

  func testLexDecimalLiterals() {
    let testStrings = ["0", "1", "100", "300_200_100", "-123", "-1_000_000_000"]
    for testString in testStrings {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.tokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0].0
      XCTAssertEqual(token, Token.DecimalIntegerLiteral(testString))
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
      let range = tokens[0].1
      XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:\(1 + testString.utf16.count)")
    }
  }

  func testLexHexadecimalLiterals() {
    let testStrings = ["0x0", "0x1", "0x9", "0xa1", "0x1f1A", "0xFF_eb_ca_DA", "-0xA", "-0x19_EC_BA_67"]
    for testString in testStrings {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.tokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0].0
      XCTAssertEqual(token, Token.HexadecimalIntegerLiteral(testString))
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
      let range = tokens[0].1
      XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:\(1 + testString.utf16.count)")
    }
  }

  func testLexDecimalFloatingLiterals() {
    let testStrings = ["0.0", "1.1", "10_0.3_00", "300_200_100e13", "-123E+135", "-1_000_000_000.000_001e-1_0_0"]
    for testString in testStrings {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.tokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0].0
      XCTAssertEqual(token, Token.DecimalFloatingPointLiteral(testString))
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
      let range = tokens[0].1
      XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:\(1 + testString.utf16.count)")
    }
  }

  func testLexHexadecimalFloatingLiterals() {
    let testStrings = ["0x0.1p2", "-0x1P10", "0x9.A_Fp+30", "-0xa_1.eaP-1_5"]
    for testString in testStrings {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.tokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0].0
      XCTAssertEqual(token, Token.HexadecimalFloatingPointLiteral(testString))
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
      let range = tokens[0].1
      XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:\(1 + testString.utf16.count)")
    }
  }

  func testLexEmptyStringLiteral() {
    let lexicalContext = lexer.lex("\"\"")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    let token = tokens[0].0
    XCTAssertEqual(token, Token.StaticStringLiteral(""))
    XCTAssertEqual(token.description, "\"\"")
    XCTAssertFalse(token.isWhitespace())
    let range = tokens[0].1
    XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:3")
  }

  func testLexStringLiteralWithSingleCharacter() {
    let lexicalContext = lexer.lex("\"a\"")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    let token = tokens[0].0
    XCTAssertEqual(token, Token.StaticStringLiteral("a"))
    XCTAssertEqual(token.description, "\"a\"")
    XCTAssertFalse(token.isWhitespace())
    let range = tokens[0].1
    XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:4")
  }

  func testLexStringLiteralWithEmptyCharacters() {
    let lexicalContext = lexer.lex("\"   \"")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    let token = tokens[0].0
    XCTAssertEqual(token, Token.StaticStringLiteral("   "))
    XCTAssertEqual(token.description, "\"   \"")
    XCTAssertFalse(token.isWhitespace())
    let range = tokens[0].1
    XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:6")
  }

  func testLexStringLiteralsWithSpacesInBetween() {
    let lexicalContext = lexer.lex("\"   \"  \"abc\"")
    let tokens = lexicalContext.onlyTokens
    XCTAssertEqual(tokens.count, 4)
    XCTAssertEqual(tokens[0], Token.StaticStringLiteral("   "))
    XCTAssertEqual(tokens[1], Token.Space)
    XCTAssertEqual(tokens[2], Token.Space)
    XCTAssertEqual(tokens[3], Token.StaticStringLiteral("abc"))
  }

  func testLexTwoStringLiterals() {
    let lexicalContext = lexer.lex("\"   \"\"abc\"")
    let tokens = lexicalContext.onlyTokens
    XCTAssertEqual(tokens.count, 2)
    XCTAssertEqual(tokens[0], Token.StaticStringLiteral("   "))
    XCTAssertEqual(tokens[1], Token.StaticStringLiteral("abc"))
  }

  func testLexTwoStringLiteralsWithAnIdentifierInBetween() {
    let lexicalContext = lexer.lex("\"   \"xyz\"abc\"")
    let tokens = lexicalContext.onlyTokens
    XCTAssertEqual(tokens.count, 3)
    XCTAssertEqual(tokens[0], Token.StaticStringLiteral("   "))
    XCTAssertEqual(tokens[1], Token.Identifier("xyz"))
    XCTAssertEqual(tokens[2], Token.StaticStringLiteral("abc"))
  }

  func testLexEscapedCharactersInsideStringLiteral() {
    let lexicalContext = lexer.lex("\"\\0\\\\\\t\\n\\r\\\"\\\'\"")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    XCTAssertEqual(tokens[0].0, Token.StaticStringLiteral("\\0\\\\\\t\\n\\r\\\"\\\'"))
    XCTAssertEqual(tokens[0].1.testDescription, "test/lexer:1:1-test/lexer:1:17")
  }

  func testLexInterpolatedTextInsideStringLiteral() {
    let lexicalContext = lexer.lex("\"\\(\"3\")\"")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    XCTAssertEqual(tokens[0].0, Token.InterpolatedStringLiteral("\\(\"3\")"))
    XCTAssertEqual(tokens[0].1.testDescription, "test/lexer:1:1-test/lexer:1:9")
  }

  func testLexStringLiteralsFromSwiftPLBook() {
    XCTAssertEqual(lexer.lex("\"1 2 3\"").onlyTokens[0], Token.StaticStringLiteral("1 2 3"))
    XCTAssertEqual(lexer.lex("\"1 2 \\(3)\"").onlyTokens[0], Token.InterpolatedStringLiteral("1 2 \\(3)"))
    XCTAssertEqual(lexer.lex("\"1 2 \\(\"3\")\"").onlyTokens[0], Token.InterpolatedStringLiteral("1 2 \\(\"3\")"))
    XCTAssertEqual(lexer.lex("\"1 2 \\(\"1 + 2\")\"").onlyTokens[0], Token.InterpolatedStringLiteral("1 2 \\(\"1 + 2\")"))
    XCTAssertEqual(lexer.lex("\"1 2 \\(x)\"").onlyTokens[0], Token.InterpolatedStringLiteral("1 2 \\(x)"))
  }

  func testLexDoubleQuoteInsideStringLiteral() {
    let content = "o\\\"o"
    let lexicalContext = lexer.lex("\"\(content)\"")
    let tokens = lexicalContext.onlyTokens
    XCTAssertEqual(tokens.count, 1)
    XCTAssertEqual(tokens[0], Token.StaticStringLiteral(content))
  }

  func testLexStringLiteralWithEndingDoubleQuote() {
    let lexicalContext = lexer.lex("\"\\(\"helloworld\")foo\\(\"bar\")\"()\"()\"")
    let tokens = lexicalContext.onlyTokens
    XCTAssertEqual(tokens.count, 4)
    XCTAssertEqual(tokens[0], Token.InterpolatedStringLiteral("\\(\"helloworld\")foo\\(\"bar\")"))
    XCTAssertEqual(tokens[1], Token.Punctuator(.LeftParen))
    XCTAssertEqual(tokens[2], Token.Punctuator(.RightParen))
    XCTAssertEqual(tokens[3], Token.StaticStringLiteral("()"))
  }

  func testLexOneTrueToken() {
    let lexicalContext = lexer.lex("true")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    let token = tokens[0].0
    XCTAssertEqual(token, Token.TrueBooleanLiteral)
    XCTAssertEqual(token.description, "true")
    XCTAssertFalse(token.isWhitespace())
    let range = tokens[0].1
    XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:5")
  }

  func testLexOneFalseToken() {
    let lexicalContext = lexer.lex("false")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 1)
    let token = tokens[0].0
    XCTAssertEqual(token, Token.FalseBooleanLiteral)
    XCTAssertEqual(token.description, "false")
    XCTAssertFalse(token.isWhitespace())
    let range = tokens[0].1
    XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:6")
  }

  func testLexIdentifiers() {
    let testStrings = [
      "nill",
      "klass"
    ]
    for testString in testStrings {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.tokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0].0
      XCTAssertEqual(token, Token.Identifier(testString))
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
      let range = tokens[0].1
      XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:\(1 + testString.utf16.count)")
    }
  }

  func testLexBacktickIdentifier() {
    let testStrings = [
      "nil",
      "class",
      "_class",
      "true"
    ]
    for testString in testStrings {
      let lexicalContext = lexer.lex("`\(testString)`")
      let tokens = lexicalContext.tokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0].0
      XCTAssertEqual(token, Token.BacktickIdentifier(testString))
      XCTAssertEqual(token.description, "`\(testString)`")
      XCTAssertFalse(token.isWhitespace())
      let range = tokens[0].1
      XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:\(1 + 2 + testString.utf16.count)")
    }
  }

  func testLexComments() {
    let testStrings: [String: String] = [
      "//\n": "2:1",
      "/* another /* asdf */ fun stuff */": "1:35",
      "/*\nhello world awesome\n\n/*asdfqwerty */\n\n*/": "6:3",
      "//// just for fun /*asdf\n": "2:1",
      "/* qwe //sdflkjalksdfj */": "1:26",
      "/**/": "1:5"
    ]
    for (testString, endLocation) in testStrings {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.tokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0].0
      XCTAssertEqual(token, Token.Comment(testString))
      XCTAssertEqual(token.description, testString)
      XCTAssertTrue(token.isWhitespace())
      let range = tokens[0].1
      XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:\(endLocation)")
    }
  }

  func testLexKeywords() {
    let patternKeywords = [
      "_"
    ]

    for testString in patternKeywords {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.onlyTokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0]
      XCTAssertEqual(token, Token.Keyword(testString, .Pattern))
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
    }

    let declKeywords = [
      "class",
      "deinit",
      "enum",
      "extension",
      "func",
      "import",
      "init",
      "inout",
      "internal",
      "let",
      "operator",
      "private",
      "protocol",
      "public",
      "static",
      "struct",
      "subscript",
      "typealias",
      "var"
    ]

    for testString in declKeywords {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.tokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0].0
      XCTAssertEqual(token, Token.Keyword(testString, .Declaration))
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
      let range = tokens[0].1
      XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:\(1 + testString.utf16.count)")
    }

    let stmtKeywords = [
      "break",
      "case",
      "continue",
      "default",
      "defer",
      "do",
      "else",
      "fallthrough",
      "for",
      "guard",
      "if",
      "in",
      "repeat",
      "return",
      "switch",
      "where",
      "while"
    ]

    for testString in stmtKeywords {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.tokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0].0
      XCTAssertEqual(token, Token.Keyword(testString, .Statement))
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
      let range = tokens[0].1
      XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:\(1 + testString.utf16.count)")
    }

    let exprKeywords = [
      "as",
      "catch",
      "dynamicType",
      // "false", FalseBooleanLiteral
      "is",
      // "nil", NilLiteral
      "rethrows",
      "super",
      "self",
      "Self",
      "throw",
      "throws",
      // "true", TrueBooleanLiteral
      "try",
      "__COLUMN__",
      "__FILE__",
      "__FUNCTION__",
      "__LINE__"
    ]

    for testString in exprKeywords {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.onlyTokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0]
      XCTAssertEqual(token, Token.Keyword(testString, .Expression))
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
    }

    let contextualKeywords = [
      "associativity",
      "convenience",
      "dynamic",
      "didSet",
      "final",
      "get",
      "infix",
      "indirect",
      "lazy",
      "left",
      "mutating",
      "none",
      "nonmutating",
      "optional",
      "override",
      "postfix",
      "precedence",
      "prefix",
      "Protocol",
      "required",
      "right",
      "set",
      "Type",
      "unowned",
      "weak",
      "willSet"
    ]

    for testString in contextualKeywords {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.onlyTokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0]
      guard case let Token.Keyword(keyword, _) = token else { // TODO: contextualKeywordType is not tested
        XCTFail("token is not a keyword")
        return
      }
      XCTAssertEqual(keyword, testString)
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
    }
  }

  func testLexPunctuations() {
    let testStrings: [String: PunctuatorType] = [
      "(": .LeftParen,
      ")": .RightParen,
      "{": .LeftBrace,
      "}": .RightBrace,
      "[": .LeftSquare,
      "]": .RightSquare,
      ".": .Period,
      ",": .Comma,
      ":": .Colon,
      ";": .Semi,
      "=": .Equal,
      "@": .At,
      "#": .Pound,
      "&": .Amp,
      "->": .Arrow,
      "`": .Backtick,
      "!": .Exclaim,
      "?": .Question
    ]
    for (testString, testType) in testStrings {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.tokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0].0
      XCTAssertEqual(token, Token.Punctuator(testType))
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
      let range = tokens[0].1
      XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:\(1 + testString.utf16.count)")
    }
  }

  func testLexOperators() {
    let testStrings = [
      // regular operators
      "/",
      "-",
      "+",
      "--",
      "++",
      "+=",
      "=-",
      "==",
      "!*",
      "*<",
      "<!>",
      ">?>?>",
      "&|^~?",
      // dot operators
      "..",
      "...",
      ".......................",
      "../",
      "...++",
      "..--"
    ]
    for testString in testStrings {
      let lexicalContext = lexer.lex(testString)
      let tokens = lexicalContext.tokens
      XCTAssertEqual(tokens.count, 1)
      let token = tokens[0].0
      XCTAssertEqual(token, Token.Operator(testString))
      XCTAssertEqual(token.description, testString)
      XCTAssertFalse(token.isWhitespace())
      let range = tokens[0].1
      XCTAssertEqual(range.testDescription, "test/lexer:1:1-test/lexer:1:\(1 + testString.utf16.count)")
    }
  }

  func testLexLessThanGreaterThanOperatorsShouldBeSplitIntoTwoTokens() {
    let lexicalContext = lexer.lex("<>")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 2)
    XCTAssertEqual(tokens[0].0, Token.Operator("<"))
    XCTAssertEqual(tokens[0].1.testDescription, "test/lexer:1:1-test/lexer:1:2")
    XCTAssertEqual(tokens[1].0, Token.Operator(">"))
    XCTAssertEqual(tokens[1].1.testDescription, "test/lexer:1:2-test/lexer:1:3")
  }

  func testLexSeveralComplexOperatorsMixTogether() {
    let lexicalContext = lexer.lex(">>>!!>>")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 7)
    XCTAssertEqual(tokens[0].0, Token.Operator(">"))
    XCTAssertEqual(tokens[0].1.testDescription, "test/lexer:1:1-test/lexer:1:2")
    XCTAssertEqual(tokens[1].0, Token.Operator(">"))
    XCTAssertEqual(tokens[1].1.testDescription, "test/lexer:1:2-test/lexer:1:3")
    XCTAssertEqual(tokens[2].0, Token.Operator(">"))
    XCTAssertEqual(tokens[2].1.testDescription, "test/lexer:1:3-test/lexer:1:4")
    XCTAssertEqual(tokens[3].0, Token.Operator("!"))
    XCTAssertEqual(tokens[3].1.testDescription, "test/lexer:1:4-test/lexer:1:5")
    XCTAssertEqual(tokens[4].0, Token.Operator("!"))
    XCTAssertEqual(tokens[4].1.testDescription, "test/lexer:1:5-test/lexer:1:6")
    XCTAssertEqual(tokens[5].0, Token.Operator(">"))
    XCTAssertEqual(tokens[5].1.testDescription, "test/lexer:1:6-test/lexer:1:7")
    XCTAssertEqual(tokens[6].0, Token.Operator(">"))
    XCTAssertEqual(tokens[6].1.testDescription, "test/lexer:1:7-test/lexer:1:8")
  }

  func testLexMultipleExclaimOrQuestionPunctuationsWithNoWhitespaceOnTheLeftNeedsToBeSplitIntoMultiplePostfixOperators() {
    let lexicalContext = lexer.lex("foo?!?!")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 5)
    XCTAssertEqual(tokens[0].0, Token.Identifier("foo"))
    XCTAssertEqual(tokens[0].1.testDescription, "test/lexer:1:1-test/lexer:1:4")
    XCTAssertEqual(tokens[1].0, Token.Punctuator(PunctuatorType.Question))
    XCTAssertEqual(tokens[1].1.testDescription, "test/lexer:1:4-test/lexer:1:5")
    XCTAssertEqual(tokens[2].0, Token.Punctuator(PunctuatorType.Exclaim))
    XCTAssertEqual(tokens[2].1.testDescription, "test/lexer:1:5-test/lexer:1:6")
    XCTAssertEqual(tokens[3].0, Token.Punctuator(PunctuatorType.Question))
    XCTAssertEqual(tokens[3].1.testDescription, "test/lexer:1:6-test/lexer:1:7")
    XCTAssertEqual(tokens[4].0, Token.Punctuator(PunctuatorType.Exclaim))
    XCTAssertEqual(tokens[4].1.testDescription, "test/lexer:1:7-test/lexer:1:8")
  }

  func testLexMultipleExclaimOrQuestionPunctuationsWithWhitespaceOnTheLeftWillBeTreatedAsOneCustomOperator() {
    let lexicalContext = lexer.lex("foo ?!?!")
    let tokens = lexicalContext.tokens
    XCTAssertEqual(tokens.count, 3)
    XCTAssertEqual(tokens[0].0, Token.Identifier("foo"))
    XCTAssertEqual(tokens[0].1.testDescription, "test/lexer:1:1-test/lexer:1:4")
    XCTAssertEqual(tokens[1].0, Token.Space)
    XCTAssertEqual(tokens[1].1.testDescription, "test/lexer:1:4-test/lexer:1:5")
    XCTAssertEqual(tokens[2].0, Token.Operator("?!?!"))
    XCTAssertEqual(tokens[2].1.testDescription, "test/lexer:1:5-test/lexer:1:9")
  }

  func testLexOtherSamples() {
    XCTAssertEqual(lexer.lex("\n \n").description, "\n \n")
    XCTAssertEqual(lexer.lex("  \n\n \n").description, "  \n\n \n")
    XCTAssertEqual(
      lexer.lex("\u{7}  true false \n\n \n \t\t\t nil `nil` nilnil \r\n nil \0\0 \r\r\r \n").description,
      "\u{7}  true false \n\n \n \t\t\t nil `nil` nilnil \r\n nil \0\0 \r\r\r \n")
  }
}
