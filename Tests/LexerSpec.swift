/*
   Copyright 2015 Ryuichi Saito, LLC

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

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import Foundation

import Spectre

@testable import source
@testable import parser

extension Lexer {
  func lex(text: String) -> LexicalContext {
    let testSourceFile = SourceFile(path: "", content: text)
    return lex(testSourceFile)
  }
}

extension LexicalContext {
  var onlyTokens: [Token] {
    return tokens.map { $0.0 }
  }
}

func specLexer() {
  let lexer = Lexer()

  describe("Empty string") {
    $0.it("Should be empty lexical context") {
      let lexicalContext = lexer.lex("")
      try expect(lexicalContext.onlyTokens.count) == 0
    }
  }

  describe("Invlid token") {
    $0.it("Should contain only one invalid token, and token is not a whitespace") {
      let lexicalContext = lexer.lex("\u{7}")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      let token = tokens[0]
      try expect(token) == Token.Invalid(invalidTokenString: "\u{7}")
      try expect(token.description) == "\u{7}"
      try expect(token.isWhitespace()) == false
    }
  }

  describe("Lex one line feed") {
    $0.it("Should contain only one line feed token, and token is a whitespace") {
      let lexicalContext = lexer.lex("\n")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      let token = tokens[0]
      try expect(token) == Token.LineFeed
      try expect(token.description) == "\n"
      try expect(token.isWhitespace()) == true
    }
  }

  describe("Lex three line feeds") {
    $0.it("Should contain only one line feed token, and token is a whitespace") {
      let lexicalContext = lexer.lex("\n\n\n")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 3
      for token in tokens {
        try expect(token) == Token.LineFeed
        try expect(token.description) == "\n"
        try expect(token.isWhitespace()) == true
      }
    }
  }

  describe("Lex one carriage return") {
    $0.it("Should contain only one carriage return token, and token is a whitespace") {
      let lexicalContext = lexer.lex("\r")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      let token = tokens[0]
      try expect(token) == Token.CarriageReturn
      try expect(token.description) == "\r"
      try expect(token.isWhitespace()) == true
    }
  }

  describe("Lex one carriage return if it is a CR+LF") {
    $0.it("Should contain only one carriage return token, and token is a whitespace") {
      let lexicalContext = lexer.lex("\r\n")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 2
      try expect(tokens[0]) == Token.CarriageReturn
      try expect(tokens[1]) == Token.LineFeed
    }
  }

  describe("Lex one horizontal tab") {
    $0.it("Should contain only one horizontal tab token, and token is a whitespace") {
      let lexicalContext = lexer.lex("\t")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      let token = tokens[0]
      try expect(token) == Token.HorizontalTab
      try expect(token.description) == "\t"
      try expect(token.isWhitespace()) == true
    }
  }

  describe("Lex one form feed") {
    $0.it("Should contain only one form feed token, and token is a whitespace") {
      let lexicalContext = lexer.lex("\u{000C}")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      let token = tokens[0]
      try expect(token) == Token.FormFeed
      try expect(token.description) == "\u{000C}"
      try expect(token.isWhitespace()) == true
    }
  }

  describe("Lex one null") {
    $0.it("Should contain only one null token, and token is a whitespace") {
      let lexicalContext = lexer.lex("\0")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      let token = tokens[0]
      try expect(token) == Token.Null
      try expect(token.description) == "\0"
      try expect(token.isWhitespace()) == true
    }
  }

  describe("Lex one nil") {
    $0.it("Should contain only one nil token") {
      let lexicalContext = lexer.lex("nil")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      let token = tokens[0]
      try expect(token) == Token.NilLiteral
      try expect(token.description) == "nil"
      try expect(token.isWhitespace()) == false
    }
  }

  describe("Lex two nils") {
    $0.it("Should contain only two nils token") {
      let lexicalContext = lexer.lex("nil nil")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 3
      try expect(tokens[0]) == Token.NilLiteral
      try expect(tokens[1]) == Token.Space
      try expect(tokens[2]) == Token.NilLiteral
    }
  }

  describe("Lex binary literals") {
    $0.it("Should contain correct binary literal tokens") {
      let testStrings = ["0b0", "0b1", "0b01", "0b1010", "0b01_10_01_10", "-0b1", "-0b10_10_10_10"]
      for testString in testStrings {
        let lexicalContext = lexer.lex(testString)
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.BinaryIntegerLiteral(testString)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
      }
    }
  }

  describe("Lex octal literals") {
    $0.it("Should contain correct octal literal tokens") {
      let testStrings = ["0o0", "0o1", "0o7", "0o01", "0o1217", "0o01_67_24_35", "-0o7", "-0o10_23_45_67"]
      for testString in testStrings {
        let lexicalContext = lexer.lex(testString)
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.OctalIntegerLiteral(testString)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
      }
    }
  }

  describe("Lex decimal literals") {
    $0.it("Should contain correct decimal literal tokens") {
      let testStrings = ["0", "1", "100", "300_200_100", "-123", "-1_000_000_000"]
      for testString in testStrings {
        let lexicalContext = lexer.lex(testString)
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.DecimalIntegerLiteral(testString)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
      }
    }
  }

  describe("Lex hexadcimal literals") {
    $0.it("Should contain correct hexadcimal literal tokens") {
      let testStrings = ["0x0", "0x1", "0x9", "0xa1", "0x1f1A", "0xFF_eb_ca_DA", "-0xA", "-0x19_EC_BA_67"]
      for testString in testStrings {
        let lexicalContext = lexer.lex(testString)
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.HexadecimalIntegerLiteral(testString)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
      }
    }
  }

  describe("Lex decimal floating literals") {
    $0.it("Should contain correct decimal floating literal tokens") {
      let testStrings = ["0.0", "1.1", "10_0.3_00", "300_200_100e13", "-123E+135", "-1_000_000_000.000_001e-1_0_0"]
      for testString in testStrings {
        let lexicalContext = lexer.lex(testString)
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.DecimalFloatingPointLiteral(testString)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
      }
    }
  }

  describe("Lex hexadcimal floating literals") {
    $0.it("Should contain correct hexadcimal floating literal tokens") {
      let testStrings = ["0x0.1p2", "-0x1P10", "0x9.A_Fp+30", "-0xa_1.eaP-1_5"]
      for testString in testStrings {
        let lexicalContext = lexer.lex(testString)
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.HexadecimalFloatingPointLiteral(testString)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
      }
    }
  }

  describe("Lex empty string literal token") {
    $0.it("Should contain only one string literal token") {
      let lexicalContext = lexer.lex("\"\"")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      let token = tokens[0]
      try expect(token) == Token.StaticStringLiteral("")
      try expect(token.description) == "\"\""
      try expect(token.isWhitespace()) == false
    }
  }

  describe("Lex a string literal with single character token") {
    $0.it("Should contain only a string literal with single character token") {
      let lexicalContext = lexer.lex("\"a\"")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      let token = tokens[0]
      try expect(token) == Token.StaticStringLiteral("a")
      try expect(token.description) == "\"a\""
      try expect(token.isWhitespace()) == false
    }
  }

  describe("Lex a string literal with empty characters token") {
    $0.it("Should contain only a string literal with empty characters token") {
      let lexicalContext = lexer.lex("\"   \"")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      let token = tokens[0]
      try expect(token) == Token.StaticStringLiteral("   ")
      try expect(token.description) == "\"   \""
      try expect(token.isWhitespace()) == false
    }
  }

  describe("Lex string literals with spaces tokens") {
    $0.it("Should contain two string literals deided by two space tokens") {
      let lexicalContext = lexer.lex("\"   \"  \"abc\"")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 4
      try expect(tokens[0]) == Token.StaticStringLiteral("   ")
      try expect(tokens[1]) == Token.Space
      try expect(tokens[2]) == Token.Space
      try expect(tokens[3]) == Token.StaticStringLiteral("abc")
    }
  }

  describe("Lex two string literals") {
    $0.it("Should contain two string literals deided by two space tokens") {
      let lexicalContext = lexer.lex("\"   \"\"abc\"")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 2
      try expect(tokens[0]) == Token.StaticStringLiteral("   ")
      try expect(tokens[1]) == Token.StaticStringLiteral("abc")
    }
  }

  describe("Lex two string literals with an identifier in between") {
    $0.it("Should contain two string literals deided by two space tokens") {
      let lexicalContext = lexer.lex("\"   \"xyz\"abc\"")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 3
      try expect(tokens[0]) == Token.StaticStringLiteral("   ")
      try expect(tokens[1]) == Token.Identifier("xyz")
      try expect(tokens[2]) == Token.StaticStringLiteral("abc")
    }
  }

  describe("Lex escaped characters inside the string literal") {
    $0.it("Should contain one string literal that contains escaped characters") {
      let lexicalContext = lexer.lex("\"\\0\\\\\\t\\n\\r\\\"\\\'\"")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      try expect(tokens[0]) == Token.StaticStringLiteral("\\0\\\\\\t\\n\\r\\\"\\\'")
    }
  }

  describe("Lex interpolated text inside the string literal") {
    $0.it("Should contain one string literal that contains escaped characters") {
      let lexicalContext = lexer.lex("\"\\(\"3\")\"")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      try expect(tokens[0]) == Token.InterpolatedStringLiteral("\\(\"3\")")
    }
  }

  describe("Lex string literals inside Swift Programming Language book") {
    $0.it("Should contain string literals from Swfit PL book") {
      try expect(lexer.lex("\"1 2 3\"").onlyTokens[0]) == Token.StaticStringLiteral("1 2 3")
      try expect(lexer.lex("\"1 2 \\(3)\"").onlyTokens[0]) == Token.InterpolatedStringLiteral("1 2 \\(3)")
      try expect(lexer.lex("\"1 2 \\(\"3\")\"").onlyTokens[0]) == Token.InterpolatedStringLiteral("1 2 \\(\"3\")")
      try expect(lexer.lex("\"1 2 \\(\"1 + 2\")\"").onlyTokens[0]) == Token.InterpolatedStringLiteral("1 2 \\(\"1 + 2\")")
      try expect(lexer.lex("\"1 2 \\(x)\"").onlyTokens[0]) == Token.InterpolatedStringLiteral("1 2 \\(x)")
    }
  }

  describe("Lex double quote inside the string literal") {
    $0.it("Should contain one string literals that contains a double quote") {
      let content = "o\\\"o"
      let lexicalContext = lexer.lex("\"\(content)\"")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      try expect(tokens[0]) == Token.StaticStringLiteral(content)
    }
  }

  describe("Lex string literal with correct ending double quote") {
    $0.it("Two string literals that could confuse aggressive regular expression matching") {
      let lexicalContext = lexer.lex("\"\\(\"helloworld\")foo\\(\"bar\")\"()\"()\"")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 4
      try expect(tokens[0]) == Token.InterpolatedStringLiteral("\\(\"helloworld\")foo\\(\"bar\")")
      try expect(tokens[1]) == Token.Punctuator(.LeftParen)
      try expect(tokens[2]) == Token.Punctuator(.RightParen)
      try expect(tokens[3]) == Token.StaticStringLiteral("()")
    }
  }

  describe("Lex one true token") {
    $0.it("Should contain only one true token") {
      let lexicalContext = lexer.lex("true")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      let token = tokens[0]
      try expect(token) == Token.TrueBooleanLiteral
      try expect(token.description) == "true"
      try expect(token.isWhitespace()) == false
    }
  }

  describe("Lex one false token") {
    $0.it("Should contain only one false token") {
      let lexicalContext = lexer.lex("false")
      let tokens = lexicalContext.onlyTokens
      try expect(tokens.count) == 1
      let token = tokens[0]
      try expect(token) == Token.FalseBooleanLiteral
      try expect(token.description) == "false"
      try expect(token.isWhitespace()) == false
    }
  }

  describe("Lex a identifiers") {
    $0.it("Should contain only one identifier token") {
      let testStrings = [
        "nill",
        "klass"
      ]
      for testString in testStrings {
        let lexicalContext = lexer.lex(testString)
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.Identifier(testString)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
      }
    }
  }

  describe("Lex backtick identifier") {
    $0.it("Should contain only one backtick identifier token") {
      let testStrings = [
        "nil",
        "class",
        "_class",
        "true"
      ]
      for testString in testStrings {
        let lexicalContext = lexer.lex("`\(testString)`")
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.BacktickIdentifier(testString)
        try expect(token.description) == "`\(testString)`"
        try expect(token.isWhitespace()) == false
      }
    }
  }

  describe("Lex comments") {
    $0.it("Should contain correct comment tokens") {
      let testStrings = [
        "//\n",
        "/* another /* asdf */ fun stuff */",
        "/*\nhello world awesome\n\n/*asdfqwerty */\n\n*/",
        "//// just for fun /*asdf\n",
        "/* qwe //sdflkjalksdfj */",
        "/**/"
      ]
      for testString in testStrings {
        let lexicalContext = lexer.lex(testString)
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.Comment(testString)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == true
      }
    }
  }

  describe("Lex keywords") {
    $0.it("Should contain keyword tokens") {
      let patternKeywords = [
        "_"
      ]

      for testString in patternKeywords {
        let lexicalContext = lexer.lex(testString)
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.Keyword(testString, .Pattern)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
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
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.Keyword(testString, .Declaration)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
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
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.Keyword(testString, .Statement)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
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
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.Keyword(testString, .Expression)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
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
        try expect(tokens.count) == 1
        let token = tokens[0]
        if case let Token.Keyword(keyword, _) = token { // TODO: contextualKeywordType is not tested
          try expect(keyword) == testString
        }
        else {
          throw failure("token is not a keyword")
        }
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
      }
    }
  }

  describe("Lex punctuations") {
    $0.it("Should contain correct punctuation tokens") {
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
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.Punctuator(testType)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
      }
    }
  }

  describe("Lex operators") {
    $0.it("Should contain correct operator tokens") {
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
        "<>",
        ">>>",
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
        let tokens = lexicalContext.onlyTokens
        try expect(tokens.count) == 1
        let token = tokens[0]
        try expect(token) == Token.Operator(testString)
        try expect(token.description) == testString
        try expect(token.isWhitespace()) == false
      }
    }
  }

  describe("Quick tests") {
    $0.it("\\n \\n") {
      let lexicalContext = lexer.lex("\n \n")
      try expect(lexicalContext.description) == "\n \n"
    }

    $0.it("  \\n\\n \\n") {
      let lexicalContext = lexer.lex("  \n\n \n")
      try expect(lexicalContext.description) == "  \n\n \n"
    }

    $0.it("This has a lot of things ;)") {
      let lexicalContext = lexer.lex("\u{7}  true false \n\n \n \t\t\t nil `nil` nilnil \r\n nil \0\0 \r\r\r \n")
      try expect(lexicalContext.description) == "\u{7}  true false \n\n \n \t\t\t nil `nil` nilnil \r\n nil \0\0 \r\r\r \n"
    }
  }
}
