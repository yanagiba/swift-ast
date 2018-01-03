/*
   Copyright 2015-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

import Source
import Diagnostic

public struct Token {
  public enum Kind {
    case invalid(TokenInvalidReason)

    case eof, lineFeed
    // punctuations
    case arrow, colon, comma, dot, semicolon, underscore
    case at, hash, backslash
    case leftParen, rightParen
    case leftBrace, rightBrace
    case leftSquare, rightSquare
    //
    case leftChevron, rightChevron
    case prefixAmp
    case postfixExclaim
    case prefixQuestion, binaryQuestion, postfixQuestion
    // operators
    case assignmentOperator
    case prefixOperator(String), binaryOperator(String), postfixOperator(String)
    // value references
    case identifier(String, Bool)
    case implicitParameterName(Int)
    // literals
    case integerLiteral(Int, rawRepresentation: String)
    case floatingPointLiteral(Double, rawRepresentation: String)
    case staticStringLiteral(String, rawRepresentation: String)
    case interpolatedStringLiteralHead(String, rawRepresentation: String) // NOTE: this stops at the opening \(,
                                                                          // and we will let parser figure out when to
                                                                          // close this string literal
    case booleanLiteral(Bool)
    // modifier
    case convenience, dynamic, final, lazy, mutating, nonmutating
    case optional, override, required, `static`, unowned, weak
    case `internal`, `private`, `public`, `fileprivate`, `open`
    // keywords
    case `Any`, `Self`
    case `as`, associativity, `break`, `catch`, `case`, `class`, `continue`
    case `default`, `defer`, `deinit`, didSet, `do`, `enum`
    case `extension`, `else`, `fallthrough`, `for`, `func`, get, `guard`, `if`
    case `import`, `in`, indirect, infix, `init`, `inout`, `is`, `let`
    case left, `nil`, none, `operator`, postfix, prefix, `protocol`, `Protocol`
    case precedence, `repeat`, `rethrows`, `return`, right, safe, `self`, set
    case `struct`, `subscript`, `super`, `switch`, `throw`, `throws`, `try`
    case `typealias`, unsafe, `var`, `where`, `while`, willSet, `Type`
  }

  public let kind: Kind
  public let sourceRange: SourceRange
  let roles: [Role] // TODO: wondering if this can be implemented in other ways
}

extension Token : SourceLocatable {
}
