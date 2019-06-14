/*
   Copyright 2015-2019 Ryuichi Intellectual Property and the Yanagiba project contributors

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

extension Token.Kind {

  public func isEqual(toKindOf kind: Token.Kind) -> Bool {
    switch (self, kind) {
    case (.invalid, .invalid),
      (.eof, .eof),
      (.lineFeed, .lineFeed),
      (.arrow, .arrow),
      (.assignmentOperator, .assignmentOperator),
      (.Any, .Any),
      (.at, .at),
      (.hash, .hash),
      (.backslash, .backslash),
      (.colon, .colon),
      (.comma, .comma),
      (.dot, .dot),
      (.semicolon, .semicolon),
      (.underscore, .underscore),
      (.binaryQuestion, .binaryQuestion),
      (.postfixExclaim, .postfixExclaim),
      (.rightChevron, .rightChevron),
      (.postfixQuestion, .postfixQuestion),
      (.prefixAmp, .prefixAmp),
      (.leftChevron, .leftChevron),
      (.prefixQuestion, .prefixQuestion),
      (.leftParen, .leftParen),
      (.rightParen, .rightParen),
      (.leftBrace, .leftBrace),
      (.rightBrace, .rightBrace),
      (.leftSquare, .leftSquare),
      (.rightSquare, .rightSquare),
      (.prefixOperator, .prefixOperator),
      (.binaryOperator, .binaryOperator),
      (.postfixOperator, .postfixOperator),
      (.identifier, .identifier),
      (.implicitParameterName, .implicitParameterName),
      (.bindingReference, .bindingReference),
      (.integerLiteral, .integerLiteral),
      (.floatingPointLiteral, .floatingPointLiteral),
      (.staticStringLiteral, .staticStringLiteral),
      (.interpolatedStringLiteralHead, .interpolatedStringLiteralHead),
      (.booleanLiteral, .booleanLiteral),
      (.convenience, .convenience),
      (.dynamic, .dynamic),
      (.final, .final),
      (.lazy, .lazy),
      (.mutating, .mutating),
      (.nonmutating, .nonmutating),
      (.optional, .optional),
      (.override, .override),
      (.required, .required),
      (.static, .static),
      (.unowned, .unowned),
      (.weak, .weak),
      (.fileprivate, .fileprivate),
      (.internal, .internal),
      (.private, .private),
      (.public, .public),
      (.open, .open),
      (.as, .as),
      (.associativity, .associativity),
      (.break, .break),
      (.catch, .catch),
      (.case, .case),
      (.class, .class),
      (.continue, .continue),
      (.default, .default),
      (.defer, .defer),
      (.deinit, .deinit),
      (.didSet, .didSet),
      (.do, .do),
      (.enum, .enum),
      (.extension, .extension),
      (.fallthrough, .fallthrough),
      (.else, .else),
      (.for, .for),
      (.func, .func),
      (.get, .get),
      (.guard, .guard),
      (.if, .if),
      (.import, .import),
      (.in, .in),
      (.indirect, .indirect),
      (.infix, .infix),
      (.`init`, .`init`),
      (.inout, .inout),
      (.is, .is),
      (.let, .let),
      (.left, .left),
      (.nil, .nil),
      (.none, .none),
      (.operator, .operator),
      (.postfix, .postfix),
      (.prefix, .prefix),
      (.protocol, .protocol),
      (.Protocol, .Protocol),
      (.precedence, .precedence),
      (.repeat, .repeat),
      (.rethrows, .rethrows),
      (.return, .return),
      (.right, .right),
      (.safe, .safe),
      (.set, .set),
      (.Self, .Self),
      (.self, .self),
      (.struct, .struct),
      (.subscript, .subscript),
      (.super, .super),
      (.switch, .switch),
      (.throw, .throw),
      (.throws, .throws),
      (.try, .try),
      (.typealias, .typealias),
      (.unsafe, .unsafe),
      (.var, .var),
      (.where, .where),
      (.while, .while),
      (.willSet, .willSet),
      (.Type, .Type):
      return true
    default:
      return false
    }
  }

  public func isEqual(to: Token.Kind) -> Bool { // swift-lint:rule_configure(CYCLOMATIC_COMPLEXITY=18)
    return self == to
  }
}
