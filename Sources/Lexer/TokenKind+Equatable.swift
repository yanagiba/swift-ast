/*
   Copyright 2015-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

extension Token.Kind: Equatable {
  public static func ==(lhs: Token.Kind, rhs: Token.Kind) -> Bool {
    return lhs.isEqual(to: rhs)
  }

  public func isEqual(toKindOf kind: Token.Kind) -> Bool {
    switch (self, kind) {
    case (.invalid, .invalid):
      return true
    case (.eof, .eof):
      return true
    case (.lineFeed, .lineFeed):
      return true
    case (.arrow, .arrow):
      return true
    case (.assignmentOperator, .assignmentOperator):
      return true
    case (.Any, .Any):
        return true
    case (.at, .at):
      return true
    case (.hash, .hash):
      return true
    case (.colon, .colon):
      return true
    case (.comma, .comma):
      return true
    case (.dot, .dot):
      return true
    case (.semicolon, .semicolon):
      return true
    case (.underscore, .underscore):
      return true
    case (.binaryQuestion, .binaryQuestion):
      return true
    case (.postfixExclaim, .postfixExclaim):
      return true
    case (.rightChevron, .rightChevron):
      return true
    case (.postfixQuestion, .postfixQuestion):
      return true
    case (.prefixAmp, .prefixAmp):
      return true
    case (.leftChevron, .leftChevron):
      return true
    case (.prefixQuestion, .prefixQuestion):
      return true
    case (.leftParen, .leftParen):
      return true
    case (.rightParen, .rightParen):
      return true
    case (.leftBrace, .leftBrace):
      return true
    case (.rightBrace, .rightBrace):
      return true
    case (.leftSquare, .leftSquare):
      return true
    case (.rightSquare, .rightSquare):
      return true
    case (.prefixOperator, .prefixOperator):
      return true
    case (.binaryOperator, .binaryOperator):
      return true
    case (.postfixOperator, .postfixOperator):
      return true
    case (.identifier, .identifier):
      return true
    case (.implicitParameterName, .implicitParameterName):
      return true
    case (.integerLiteral, .integerLiteral):
      return true
    case (.floatingPointLiteral, .floatingPointLiteral):
      return true
    case (.staticStringLiteral, .staticStringLiteral):
      return true
    case (.interpolatedStringLiteralHead, .interpolatedStringLiteralHead):
      return true
    case (.booleanLiteral, .booleanLiteral):
      return true
    case (.convenience, .convenience):
      return true
    case (.dynamic, .dynamic):
      return true
    case (.final, .final):
      return true
    case (.lazy, .lazy):
      return true
    case (.mutating, .mutating):
      return true
    case (.nonmutating, .nonmutating):
      return true
    case (.optional, .optional):
      return true
    case (.override, .override):
      return true
    case (.required, .required):
      return true
    case (.static, .static):
      return true
    case (.unowned, .unowned):
      return true
    case (.weak, .weak):
      return true
    case (.fileprivate, .fileprivate):
      return true
    case (.internal, .internal):
      return true
    case (.private, .private):
      return true
    case (.public, .public):
      return true
    case (.open, .open):
      return true
    case (.as, .as):
      return true
    case (.associativity, .associativity):
      return true
    case (.break, .break):
      return true
    case (.catch, .catch):
      return true
    case (.case, .case):
      return true
    case (.class, .class):
      return true
    case (.continue, .continue):
      return true
    case (.default, .default):
      return true
    case (.defer, .defer):
      return true
    case (.deinit, .deinit):
      return true
    case (.didSet, .didSet):
      return true
    case (.do, .do):
      return true
    case (.enum, .enum):
      return true
    case (.extension, .extension):
      return true
    case (.fallthrough, .fallthrough):
      return true
    case (.else, .else):
      return true
    case (.for, .for):
      return true
    case (.func, .func):
      return true
    case (.get, .get):
      return true
    case (.guard, .guard):
      return true
    case (.if, .if):
      return true
    case (.import, .import):
      return true
    case (.in, .in):
      return true
    case (.indirect, .indirect):
      return true
    case (.infix, .infix):
      return true
    case (.init, .init):
      return true
    case (.inout, .inout):
      return true
    case (.is, .is):
      return true
    case (.let, .let):
      return true
    case (.left, .left):
      return true
    case (.nil, .nil):
      return true
    case (.none, .none):
      return true
    case (.operator, .operator):
      return true
    case (.postfix, .postfix):
      return true
    case (.prefix, .prefix):
      return true
    case (.protocol, .protocol):
      return true
    case (.Protocol, .Protocol):
      return true
    case (.precedence, .precedence):
      return true
    case (.repeat, .repeat):
      return true
    case (.rethrows, .rethrows):
      return true
    case (.return, .return):
      return true
    case (.right, .right):
      return true
    case (.safe, .safe):
      return true
    case (.set, .set):
      return true
    case (.Self, .Self):
      return true
    case (.self, .self):
      return true
    case (.struct, .struct):
      return true
    case (.subscript, .subscript):
      return true
    case (.super, .super):
      return true
    case (.switch, .switch):
      return true
    case (.throw, .throw):
      return true
    case (.throws, .throws):
      return true
    case (.try, .try):
      return true
    case (.typealias, .typealias):
      return true
    case (.unsafe, .unsafe):
      return true
    case (.var, .var):
      return true
    case (.where, .where):
      return true
    case (.while, .while):
      return true
    case (.willSet, .willSet):
      return true
    case (.Type, .Type):
      return true
    default:
      return false
    }
  }

  public func isEqual(to kind: Token.Kind) -> Bool {
    guard isEqual(toKindOf: kind) else {
      return false
    }

    switch (self, kind) {
    case let (.invalid(lhs), .invalid(rhs)):
      return lhs.diagnosticMessage == rhs.diagnosticMessage
    case let (.prefixOperator(lhs), .prefixOperator(rhs)):
      return lhs == rhs
    case let (.binaryOperator(lhs), .binaryOperator(rhs)):
      return lhs == rhs
    case let (.postfixOperator(lhs), .postfixOperator(rhs)):
      return lhs == rhs
    case let (.identifier(lhs), .identifier(rhs)):
      return lhs == rhs
    case let (.implicitParameterName(lhs), .implicitParameterName(rhs)):
      return lhs == rhs
    case let (.integerLiteral(lhi, lhr), .integerLiteral(rhi, rhr)):
      return lhi == rhi && lhr == rhr
    case let (.floatingPointLiteral(lhd, lhr), .floatingPointLiteral(rhd, rhr)):
      return lhd == rhd && lhr == rhr
    case let (.staticStringLiteral(lhs, lhr), .staticStringLiteral(rhs, rhr)):
      return lhs == rhs && lhr == rhr
    case let (
      .interpolatedStringLiteralHead(lhs, lhr),
      .interpolatedStringLiteralHead(rhs, rhr)
    ):
      return lhs == rhs && lhr == rhr
    case let (.booleanLiteral(lhs), .booleanLiteral(rhs)):
      return lhs == rhs
    default:
      return true
    }
  }
}
