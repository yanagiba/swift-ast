/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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

import Diagnostic

public enum TokenInvalidReason : DiagnosticKind {
  case reserved
  case badChar
  case badNumber
  case unexpectedEndOfFile
  case dotOperatorRequiresTwoDots
  case identifierHeadExpected
  case closingBacktickExpected
  case digitCharExpected
  case unicodeLiteralExpected
  case newLineExpectedAtTheBeinningOfMultilineStringLiteral
  case insufficientIndentationOfLineInMultilineStringLiteral
  case newLineExpectedAtTheClosingOfMultilineStringLiteral
  case invalidEscapeSequenceInStringLiteral
  case newlineEscapesNotAllowedOnLastLine
  case newlineEscapesNotSupportedInStringLiteral

  public var diagnosticMessage: String {
    switch self {
    case .reserved:
      return "Reserved token"
    case .badChar:
      return "Illegal character"
    case .badNumber:
      return "Illegal number"
    case .unexpectedEndOfFile:
      return "Unexpected end of file"
    case .dotOperatorRequiresTwoDots:
      return "Dot operator requires two dots as prefix"
    case .identifierHeadExpected:
      return "Missing identifier head character"
    case .closingBacktickExpected:
      return "Missing closing backtick"
    case .digitCharExpected:
      return "Missing digit character"
    case .unicodeLiteralExpected:
      return "Illegal unicode literal"
    case .newLineExpectedAtTheBeinningOfMultilineStringLiteral:
      return "multi-line string literal content must begin on a new line"
    case .insufficientIndentationOfLineInMultilineStringLiteral:
      return "insufficient indentation of line in multi-line string literal"
    case .newLineExpectedAtTheClosingOfMultilineStringLiteral:
      return "multi-line string literal closing delimiter must begin on a new line"
    case .invalidEscapeSequenceInStringLiteral:
      return "invalid escape sequence in string literal"
    case .newlineEscapesNotAllowedOnLastLine:
      return "newline escape is not allowed on the line immediately following the close \"\"\""
    case .newlineEscapesNotSupportedInStringLiteral:
      return "newline escape is not supported in single-line string literal"
    }
  }
}
