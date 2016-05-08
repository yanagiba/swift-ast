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

import util

enum ContextualKeywordType: Equatable {
  case InfixOperatorDeclaration
  case ComputedVariable
  case VariableObserver
  case Metatype
  case DeclarationModifier
}

func ==(lhs: ContextualKeywordType, rhs: ContextualKeywordType) -> Bool {
  switch (lhs, rhs) {
  case
    (.InfixOperatorDeclaration, .InfixOperatorDeclaration),
    (.ComputedVariable, .ComputedVariable),
    (.VariableObserver, .VariableObserver),
    (.Metatype, .Metatype),
    (.DeclarationModifier, .DeclarationModifier):
    return true
  default:
    return false
  }
}

enum KeywordType: Equatable {
  case Declaration
  case Statement
  case Expression
  case Pattern
  case Contextual(ContextualKeywordType)
}

func ==(lhs: KeywordType, rhs: KeywordType) -> Bool {
  switch (lhs, rhs) {
  case
    (.Declaration, .Declaration),
    (.Statement, .Statement),
    (.Expression, .Expression),
    (.Pattern, .Pattern):
    return true
  case let (.Contextual(x), .Contextual(y)):
    return x == y
  default:
    return false
  }
}

enum PunctuatorType: Equatable {
  case LeftParen
  case RightParen
  case LeftBrace
  case RightBrace
  case LeftSquare
  case RightSquare
  // case LeftSquareLit // TODO: [#
  // case RightSquareLit // TODO: #]
  case Period
  case Comma
  case Colon
  case Semi
  case Equal
  case At
  case Pound
  case Amp
  case Arrow
  case Backtick
  case Exclaim
  case Question
}

func ==(lhs: PunctuatorType, rhs: PunctuatorType) -> Bool {
  switch (lhs, rhs) {
  case
    (.LeftParen, .LeftParen),
    (.RightParen, .RightParen),
    (.LeftBrace, .LeftBrace),
    (.RightBrace, .RightBrace),
    (.LeftSquare, .LeftSquare),
    (.RightSquare, .RightSquare),
    (.Period, .Period),
    (.Comma, .Comma),
    (.Colon, .Colon),
    (.Semi, .Semi),
    (.Equal, .Equal),
    (.At, .At),
    (.Pound, .Pound),
    (.Amp, .Amp),
    (.Arrow, .Arrow),
    (.Backtick, .Backtick),
    (.Exclaim, .Exclaim),
    (.Question, .Question):
    return true
  default:
    return false
  }
}

extension PunctuatorType: CustomStringConvertible {
  var description: String {
    switch self {
    case .LeftParen:
      return "("
    case .RightParen:
      return ")"
    case .LeftBrace:
      return "{"
    case .RightBrace:
      return "}"
    case .LeftSquare:
      return "["
    case .RightSquare:
      return "]"
    case .Period:
      return "."
    case .Comma:
      return ","
    case .Colon:
      return ":"
    case .Semi:
      return ";"
    case .Equal:
      return "="
    case .At:
      return "@"
    case .Pound:
      return "#"
    case .Amp:
      return "&"
    case .Arrow:
      return "->"
    case .Backtick:
      return "`"
    case .Exclaim:
      return "!"
    case .Question:
      return "?"
    }
  }
}

enum Token: Equatable {
  case Invalid(invalidTokenString: String)

  // identifiers
  case Identifier(String)
  case BacktickIdentifier(String)

  // Keywords
  case Keyword(String, KeywordType)
  case Punctuator(PunctuatorType)

  // literals

  /// numberic literals

  //// integer literals
  case BinaryIntegerLiteral(String)
  case OctalIntegerLiteral(String)
  case DecimalIntegerLiteral(String)
  case HexadecimalIntegerLiteral(String)

  //// floating-point literals
  case DecimalFloatingPointLiteral(String)
  case HexadecimalFloatingPointLiteral(String)

  /// string literals
  case StaticStringLiteral(String)
  case InterpolatedStringLiteral(String)

  /// boolean literals
  case TrueBooleanLiteral
  case FalseBooleanLiteral

  /// nil literal
  case NilLiteral

  // comments
  case Comment(String)

  // whitespaces
  case Space // " " U+0020
  case LineFeed // "\n" U+000A
  case CarriageReturn // "\r" U+000D
  case HorizontalTab // "\t" U+0009
  // case VerticalTab(length: Int) // "\v" U+000B // TODO: \v is not available in swift string literal, maybe use u{8}
  case FormFeed // "\f" U+000C
  case Null // "\0" U+0000

  // operators
  case Operator(String)

}

func ==(lhs: Token, rhs: Token) -> Bool {
    switch (lhs, rhs) {
    case let (.Invalid(x), .Invalid(y)):
      return x == y
    case let (.BacktickIdentifier(x), .BacktickIdentifier(y)):
      return x == y
    case let (.Identifier(x), .Identifier(y)):
      return x == y
    case let (.Keyword(x, _), .Keyword(y, _)):
      return x == y
    case let (.Punctuator(xType), .Punctuator(yType)):
      return xType == yType
    case let (.BinaryIntegerLiteral(x), .BinaryIntegerLiteral(y)):
      return x == y
    case let (.OctalIntegerLiteral(x), .OctalIntegerLiteral(y)):
      return x == y
    case let (.DecimalIntegerLiteral(x), .DecimalIntegerLiteral(y)):
      return x == y
    case let (.HexadecimalIntegerLiteral(x), .HexadecimalIntegerLiteral(y)):
      return x == y
    case let (.DecimalFloatingPointLiteral(x), .DecimalFloatingPointLiteral(y)):
      return x == y
    case let (.HexadecimalFloatingPointLiteral(x), .HexadecimalFloatingPointLiteral(y)):
      return x == y
    case let (.StaticStringLiteral(x), .StaticStringLiteral(y)):
      return x == y
    case let (.InterpolatedStringLiteral(x), .InterpolatedStringLiteral(y)):
      return x == y
    case (.TrueBooleanLiteral, .TrueBooleanLiteral), (.FalseBooleanLiteral, .FalseBooleanLiteral):
      return true
    case (.NilLiteral, .NilLiteral):
      return true
    case let (.Comment(x), .Comment(y)):
      return x == y
    case
      (.Space, .Space),
      (.LineFeed, .LineFeed),
      (.CarriageReturn, .CarriageReturn),
      (.HorizontalTab, .HorizontalTab),
      (.FormFeed, .FormFeed),
      (.Null, .Null):
      return true
    case let (.Operator(x), .Operator(y)):
      return x == y
    default:
      return false
    }
}

extension Token {
  func isWhitespace() -> Bool {
    switch self {
    case .Comment(_):
      return true
    case
      .Space,
      .LineFeed,
      .CarriageReturn,
      .HorizontalTab,
      .FormFeed,
      .Null:
      return true
    case .Operator(_):
      return false // TODO: this depends on the context. e.g. ,|;|: after an operator are considered as whitespaces, currently return false for now
    default:
      return false
    }
  }
}

extension Token: CustomStringConvertible {
  var description: String {
    switch self {
    case let .Invalid(str):
      return str
    case let .BacktickIdentifier(identifier):
      return "`\(identifier)`"
    case let .Identifier(identifier):
      return identifier
    case let .Keyword(keyword, _):
      return keyword
    case let .Punctuator(punctuatorType):
      return "\(punctuatorType)"
    case let .BinaryIntegerLiteral(binaryLiteral):
      return binaryLiteral
    case let .OctalIntegerLiteral(octalLiteral):
      return octalLiteral
    case let .DecimalIntegerLiteral(decimalLiteral):
      return decimalLiteral
    case let .HexadecimalIntegerLiteral(hexadcimalLiteral):
      return hexadcimalLiteral
    case let .DecimalFloatingPointLiteral(decimalFloating):
      return decimalFloating
    case let .HexadecimalFloatingPointLiteral(hexadecimalFloating):
      return hexadecimalFloating
    case let .StaticStringLiteral(stringLiteral):
      return "\"\(stringLiteral)\""
    case let .InterpolatedStringLiteral(stringLiteral):
      return "\"\(stringLiteral)\""
    case .TrueBooleanLiteral:
      return "true"
    case .FalseBooleanLiteral:
      return "false"
    case .NilLiteral:
      return "nil"
    case let .Comment(comment):
      return comment
    case .Space:
      return " "
    case .LineFeed:
      return "\n"
    case .CarriageReturn:
      return "\r"
    case .HorizontalTab:
      return "\t"
    case .FormFeed:
      return "\u{000C}"
    case .Null:
      return "\0"
    case let .Operator(operatorString):
      return operatorString
    // default: return "TODO"
    }
  }

  private func _terminalString(with color: TerminalColor = .Default) -> String {
    return "\(self)".toTerminalString(with: color)
  }

  var inspect: String {
    switch self {
    case .Invalid(_):
      return _terminalString(with: .Red)
    case let .Keyword(_, keywordType):
      switch keywordType {
      case .Contextual(_):
        return _terminalString(with: .Yellow)
      default:
        return _terminalString(with: .Magenta)
      }
    case .Punctuator(_):
      return _terminalString(with: .Yellow)
    case .BinaryIntegerLiteral(_), .OctalIntegerLiteral(_), .DecimalIntegerLiteral(_), .HexadecimalIntegerLiteral(_),
         .DecimalFloatingPointLiteral(_), .HexadecimalFloatingPointLiteral(_):
      return _terminalString(with: .Cyan)
    case .StaticStringLiteral(_), .InterpolatedStringLiteral(_):
      return _terminalString(with: .Yellow)
    case .TrueBooleanLiteral, .FalseBooleanLiteral, .NilLiteral:
      return _terminalString(with: .Magenta)
    case .Comment(_):
      return _terminalString(with: .Green)
    case .Operator(_):
      return _terminalString(with: .Blue)
    default:
      return _terminalString()
    }
  }
}
