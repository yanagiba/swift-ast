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

import XCTest

@testable import Parser

class ParserErrorKindTests : XCTestCase {
  func testAttributes() {
    parseProblematic("@ let a = 1", .fatal, .missingAttributeName)
  }

  func testCodeBlock() {
    parseProblematic("defer", .fatal, .leftBraceExpected("code block"))
    parseProblematic("defer { print(i)", .fatal, .rightBraceExpected("code block"))
  }

  func testDeclarations() { // swift-lint:suppress(high_ncss)
    parseProblematic("class foo { return }", .fatal, .badDeclaration)

    // protocol declaration
    parseProblematic("protocol foo { var }", .fatal, .missingPropertyMemberName)
    parseProblematic("protocol foo { var bar }", .fatal, .missingTypeForPropertyMember)
    parseProblematic("protocol foo { var bar: Bar }", .fatal, .missingGetterSetterForPropertyMember)
    parseProblematic("protocol foo { var bar: Bar { get { return _bar } } }", .fatal, .protocolPropertyMemberWithBody)
    parseProblematic("protocol foo { func foo() { return _foo } }", .fatal, .protocolMethodMemberWithBody)
    parseProblematic("protocol foo { subscript() -> Self {} }", .fatal, .missingProtocolSubscriptGetSetSpecifier)
    parseProblematic("protocol Foo { associatedtype }", .fatal, .missingProtocolAssociatedTypeName)
    parseProblematic("protocol Foo { bar }", .fatal, .badProtocolMember)
    parseProblematic("protocol {}", .fatal, .missingProtocolName)
    parseProblematic("protocol foo ", .fatal, .leftBraceExpected("protocol declaration body"))

    // precedence-group declaration
    parseProblematic("precedencegroup foo { higherThan bar }", .fatal, .missingColonAfterAttributeNameInPrecedenceGroup)
    parseProblematic("precedencegroup foo { higherThan: }", .fatal, .missingPrecedenceGroupRelation("higherThan"))
    parseProblematic("precedencegroup foo { lowerThan: }", .fatal, .missingPrecedenceGroupRelation("lowerThan"))
    parseProblematic("precedencegroup foo { assignment: 1 }", .fatal, .expectedBooleanAfterPrecedenceGroupAssignment)
    parseProblematic("precedencegroup foo { assignment: }", .fatal, .expectedBooleanAfterPrecedenceGroupAssignment)
    parseProblematic("precedencegroup foo { assgnmnt: }", .fatal, .unknownPrecedenceGroupAttribute("assgnmnt"))
    parseProblematic("precedencegroup foo { associativity: }", .fatal, .expectedPrecedenceGroupAssociativity)
    parseProblematic("precedencegroup foo { associativity: up }", .fatal, .expectedPrecedenceGroupAssociativity)
    parseProblematic("precedencegroup foo { return }", .fatal, .expectedPrecedenceGroupAttribute)
    parseProblematic("precedencegroup foo", .fatal, .leftBraceExpected("precedence group declaration"))
    parseProblematic("precedencegroup", .fatal, .missingPrecedenceName)

    // operator declaration
    parseProblematic("infix operator a", .fatal, .expectedValidOperator)
    parseProblematic("infix operator", .fatal, .expectedValidOperator)
    parseProblematic("infix operator ?", .fatal, .expectedValidOperator)
    parseProblematic("prefix operator &", .fatal, .expectedValidOperator)
    parseProblematic("prefix operator <", .fatal, .expectedValidOperator)
    parseProblematic("prefix operator ?", .fatal, .expectedValidOperator)
    parseProblematic("postfix operator !", .fatal, .expectedValidOperator)
    parseProblematic("postfix operator >", .fatal, .expectedValidOperator)
    parseProblematic("postfix operator ?", .fatal, .expectedValidOperator)
    parseProblematic("operator <!>", .fatal, .operatorDeclarationHasNoFixity)
    parseProblematic("fileprivate operator <!>", .fatal, .operatorDeclarationHasNoFixity)
    parseProblematic("infix operator <!>:", .fatal, .expectedOperatorNameAfterInfixOperator)
    parseProblematic("infix operator <!> {}", .warning, .operatorHasBody)

    // subscript declaration
    parseProblematic("subscript()", .fatal, .expectedArrowSubscript)

    // extension declaration
    parseProblematic("extension {}", .fatal, .missingExtensionName)
    parseProblematic("extension foo", .fatal, .leftBraceExpected("extension declaration body"))

    // class declaration
    parseProblematic("class {}", .fatal, .missingClassName)
    parseProblematic("class foo", .fatal, .leftBraceExpected("class declaration body"))

    // struct declaration
    parseProblematic("struct {}", .fatal, .missingStructName)
    parseProblematic("struct foo", .fatal, .leftBraceExpected("struct declaration body"))

    // enum declaration
    parseProblematic("indirect enum Foo: String { case a = \"A\" }", .fatal, .indirectWithRawValueStyle)
    parseProblematic("indirect", .fatal, .enumExpectedAfterIndirect)
    parseProblematic("enum Foo { case i = 1 }", .fatal, .missingTypeForRawValueEnumDeclaration)
    parseProblematic("enum Foo { case j(Int) indirect case i = 1 }", .fatal, .indirectWithRawValueStyle)
    parseProblematic("enum Foo: Int { case j = 1 case i(Int) }", .fatal, .unionStyleMixWithRawValueStyle)
    // parseProblematic("enum Foo { @a }", .fatal, .expectedEnumDeclarationCaseMember)
    parseProblematic("enum Foo { case }", .fatal, .expectedCaseName)
    parseProblematic("enum Foo { case = }", .fatal, .expectedCaseName)
    parseProblematic("enum Foo: Int { case i = j }", .fatal, .nonliteralEnumCaseRawValue)
    parseProblematic("enum Foo: Int { case i = 1, j = 2, k(Int) }", .fatal, .unionStyleMixWithRawValueStyle)
    parseProblematic("enum { case foo }", .fatal, .missingEnumName)
    parseProblematic("enum Foo case", .fatal, .leftBraceExpected("enum declaration body"))

    // func declaration
    parseProblematic("func foo(:)", .fatal, .unnamedParameter)
    parseProblematic("func foo(a)", .fatal, .expectedParameterType)
    parseProblematic("func foo", .fatal, .expectedParameterOpenParenthesis)
    parseProblematic("func foo(foo: Foo", .fatal, .expectedParameterCloseParenthesis)
    parseProblematic("prefix prefix func foo()", .error, .duplicatedFunctionModifiers)
    parseProblematic("prefix postfix func foo()", .error, .duplicatedFunctionModifiers)
    parseProblematic("prefix infix func foo()", .error, .duplicatedFunctionModifiers)
    parseProblematic("func ()", .fatal, .missingFunctionName)
    parseProblematic("func ?()", .fatal, .missingFunctionName)

    // func declaration
    parseProblematic("typealias", .fatal, .missingTypealiasName)
    parseProblematic("typealias =", .fatal, .missingTypealiasName)
    parseProblematic("typealias foo", .fatal, .expectedEqualInTypealias)

    // var/let declaration
    parseProblematic("var foo: Int { willSet() {} }", .fatal, .expectedAccesorName("willSet"))
    parseProblematic("var foo: Int { didSet() {} }", .fatal, .expectedAccesorName("didSet"))
    parseProblematic("var foo: Int { didSet {} willSet() {} }", .fatal, .expectedAccesorName("willSet"))
    parseProblematic("var foo: Int { willSet {} didSet() {} }", .fatal, .expectedAccesorName("didSet"))
    parseProblematic("var foo: Int { willSet(bar }", .fatal, .expectedAccesorNameCloseParenthesis("willSet"))
    parseProblematic("var foo: Int { didSet(bar }", .fatal, .expectedAccesorNameCloseParenthesis("didSet"))
    // parseProblematic("var foo: Int ( willSet {}}", .fatal, .leftBraceExpected("willSet/didSet block")) // TODO
    // parseProblematic("var foo: Int ( didSet {}}", .fatal, .leftBraceExpected("willSet/didSet block")) // TODO
    parseProblematic("var foo: Int { willSet {}", .fatal, .rightBraceExpected("willSet/didSet block"))
    parseProblematic("var foo: Int { didSet {}", .fatal, .rightBraceExpected("willSet/didSet block"))
    parseProblematic("var foo: Int { set() {}", .fatal, .expectedAccesorName("setter"))
    parseProblematic("var foo: Int { set(bar }", .fatal, .expectedAccesorNameCloseParenthesis("setter"))
    // parseProblematic("var foo: Int ( get {}}", .fatal, .leftBraceExpected("getter/setter block")) // TODO
    // parseProblematic("var foo: Int ( set {}}", .fatal, .leftBraceExpected("getter/setter block")) // TODO
    parseProblematic("var foo: Int { get {}", .fatal, .rightBraceExpected("getter/setter block"))
    parseProblematic("var foo: Int { set {}", .fatal, .rightBraceExpected("getter/setter block"))
    parseProblematic("var foo: Int { set {} }", .fatal, .varSetWithoutGet)

    // import declaration
    parseProblematic("import", .fatal, .missingModuleNameImportDecl)
  }

  func testExpressions() {
    parseProblematic("foo ? bar abc", .fatal, .expectedColonAfterTrueExpr)
    parseProblematic("&", .fatal, .expectedIdentifierForInOutExpr)
    parseProblematic("foo[a, b, c", .fatal, .expectedCloseSquareExprList)
    parseProblematic("foo(~: Foo)", .fatal, .expectedParameterNameFuncCall)
    parseProblematic("foo(a, b, c", .fatal, .expectedCloseParenFuncCall)
    // parseProblematic("foo.init(foo::)", .fatal, .expectedArgumentLabel) // TODO
    // parseProblematic("foo.init(foo:bar)", .fatal, .expectedColonAfterArgumentLabel) // TODO
    parseProblematic("foo.1_2.23", .fatal, .expectedTupleIndexExplicitMemberExpr)
    parseProblematic("foo.", .fatal, .expectedMemberNameExplicitMemberExpr)
    parseProblematic("let foo = *", .fatal, .expectedExpr)
    parseProblematic("let foo = (-: 3)", .fatal, .expectedTupleArgumentLabel)
    parseProblematic("let foo = (a: 3", .fatal, .expectedCloseParenTuple)
    parseProblematic("super._", .fatal, .expectedIdentifierAfterSuperDotExpr)
    parseProblematic("super[a, b, c", .fatal, .expectedCloseSquareExprList)
    parseProblematic("super", .fatal, .expectedDotOrSubscriptAfterSuper)
    parseProblematic("self._", .fatal, .expectedIdentifierAfterSelfDotExpr)
    parseProblematic("self[a, b, c", .fatal, .expectedCloseSquareExprList)
    parseProblematic("_ = \\foo", .fatal, .expectedKeyPathComponent)
    parseProblematic("_ = \\foo.", .fatal, .expectedKeyPathComponentIdentifierOrPostfix)
    parseProblematic("_ = \\foo.bar.", .fatal, .expectedKeyPathComponentIdentifierOrPostfix)
    parseProblematic("_ = #func", .fatal, .expectedObjectLiteralIdentifier)
    parseProblematic("_ = #abc", .fatal, .expectedObjectLiteralIdentifier)
    parseProblematic("_ = #keyPath", .fatal, .expectedOpenParenKeyPathStringExpr)
    parseProblematic("_ = #keyPath(a", .fatal, .expectedCloseParenKeyPathStringExpr)
    parseProblematic("_ = #selector", .fatal, .expectedOpenParenSelectorExpr)
    parseProblematic("_ = #selector(getter)", .fatal, .expectedColonAfterPropertyKeywordSelectorExpr("getter"))
    parseProblematic("_ = #selector(setter)", .fatal, .expectedColonAfterPropertyKeywordSelectorExpr("setter"))
    parseProblematic("_ = #selector(a", .fatal, .expectedCloseParenSelectorExpr)
    parseProblematic("_ = [:", .fatal, .expectedCloseSquareDictionaryLiteral)
    parseProblematic("_ = [a:b,c:d", .fatal, .expectedCloseSquareDictionaryLiteral)
    parseProblematic("_ = [a:b,c", .fatal, .expectedColonDictionaryLiteral)
    parseProblematic("_ = [a,b,c", .fatal, .expectedCloseSquareArrayLiteral)
    parseProblematic("_ = \"\\($0})\"", .fatal, .extraTokenStringInterpolation)
    // parseProblematic("_ = \"\\(\"a\\(!)\")\"", .fatal, .expectedStringInterpolation) // TODO
    parseProblematic("_ = \"\\($0)", .fatal, .expectedStringInterpolation)
    // parseProblematic("""
    // _ = \"\"\"
    // foo
    // bar\"\"\"
    // """, .fatal, .newLineExpectedAtTheClosingOfMultilineStringLiteral)
    parseProblematic("""
    _ = \"\"\"
    \\(1)
    bar\"\"\"
    """, .fatal, .newLineExpectedAtTheClosingOfMultilineStringLiteral)
    parseProblematic("""
    _ = \"\"\"
      \\(1)
    bar
      \"\"\"
    """, .fatal, .insufficientIndentationOfLineInMultilineStringLiteral)
    parseProblematic("foo { _, in }", .fatal, .expectedClosureParameterName)
    parseProblematic("foo { _ in print()", .fatal, .rightBraceExpected("closure expression"))
    parseProblematic("_ = ._", .fatal, .expectedIdentifierAfterDot)
  }

  func testPlaygroundLiterals() {
    parseProblematic("_ = #colorLiteral", .fatal, .expectedOpenParenPlaygroundLiteral("colorLiteral"))
    parseProblematic("_ = #fileLiteral", .fatal, .expectedOpenParenPlaygroundLiteral("fileLiteral"))
    parseProblematic("_ = #imageLiteral", .fatal, .expectedOpenParenPlaygroundLiteral("imageLiteral"))
    parseProblematic(
      "_ = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1",
      .fatal,
      .expectedCloseParenPlaygroundLiteral("colorLiteral"))
    parseProblematic(
      "_ = #fileLiteral(resourceName: \"foo\"",
      .fatal,
      .expectedCloseParenPlaygroundLiteral("fileLiteral"))
    parseProblematic(
      "_ = #imageLiteral(resourceName: \"foo\"",
      .fatal,
      .expectedCloseParenPlaygroundLiteral("imageLiteral"))
    parseProblematic(
      "_ = #colorLiteral(",
      .fatal,
      .expectedKeywordPlaygroundLiteral("colorLiteral", "red"))
    parseProblematic(
      "_ = #colorLiteral(red: 0, ",
      .fatal,
      .expectedKeywordPlaygroundLiteral("colorLiteral", "green"))
    parseProblematic(
      "_ = #colorLiteral(red: 0, green: 0, ",
      .fatal,
      .expectedKeywordPlaygroundLiteral("colorLiteral", "blue"))
    parseProblematic(
      "_ = #colorLiteral(red: 0, green: 0, blue: 0, ",
      .fatal,
      .expectedKeywordPlaygroundLiteral("colorLiteral", "alpha"))
    parseProblematic(
      "_ = #fileLiteral(",
      .fatal,
      .expectedKeywordPlaygroundLiteral("fileLiteral", "resourceName"))
    parseProblematic(
      "_ = #imageLiteral(",
      .fatal,
      .expectedKeywordPlaygroundLiteral("imageLiteral", "resourceName"))
    parseProblematic(
      "_ = #colorLiteral(red:",
      .fatal,
      .expectedExpressionPlaygroundLiteral("colorLiteral", "red"),
      { ds in ds.count == 2 ? ds[1] : ds[0] })
    parseProblematic(
      "_ = #colorLiteral(red: 0, green:",
      .fatal,
      .expectedExpressionPlaygroundLiteral("colorLiteral", "green"),
      { ds in ds.count == 2 ? ds[1] : ds[0] })
    parseProblematic(
      "_ = #colorLiteral(red: 0, green: 0, blue:",
      .fatal,
      .expectedExpressionPlaygroundLiteral("colorLiteral", "blue"),
      { ds in ds.count == 2 ? ds[1] : ds[0] })
    parseProblematic(
      "_ = #colorLiteral(red: 0, green: 0, blue: 0, alpha:",
      .fatal,
      .expectedExpressionPlaygroundLiteral("colorLiteral", "alpha"),
      { ds in ds.count == 2 ? ds[1] : ds[0] })
    parseProblematic(
      "_ = #fileLiteral(resourceName:",
      .fatal,
      .expectedExpressionPlaygroundLiteral("fileLiteral", "resourceName"),
      { ds in ds.count == 2 ? ds[1] : ds[0] })
    parseProblematic(
      "_ = #imageLiteral(resourceName:",
      .fatal,
      .expectedExpressionPlaygroundLiteral("imageLiteral", "resourceName"),
      { ds in ds.count == 2 ? ds[1] : ds[0] })
    parseProblematic(
      "_ = #colorLiteral(red",
      .fatal,
      .expectedColonAfterKeywordPlaygroundLiteral("colorLiteral", "red"))
    parseProblematic(
      "_ = #colorLiteral(red: 0, green",
      .fatal,
      .expectedColonAfterKeywordPlaygroundLiteral("colorLiteral", "green"))
    parseProblematic(
      "_ = #colorLiteral(red: 0, green: 0, blue",
      .fatal,
      .expectedColonAfterKeywordPlaygroundLiteral("colorLiteral", "blue"))
    parseProblematic(
      "_ = #colorLiteral(red: 0, green: 0, blue: 0, alpha",
      .fatal,
      .expectedColonAfterKeywordPlaygroundLiteral("colorLiteral", "alpha"))
    parseProblematic(
      "_ = #fileLiteral(resourceName",
      .fatal,
      .expectedColonAfterKeywordPlaygroundLiteral("fileLiteral", "resourceName"))
    parseProblematic(
      "_ = #imageLiteral(resourceName",
      .fatal,
      .expectedColonAfterKeywordPlaygroundLiteral("imageLiteral", "resourceName"))
    parseProblematic(
      "_ = #colorLiteral(red: 0",
      .fatal,
      .expectedCommaBeforeKeywordPlaygroundLiteral("colorLiteral", "green"))
    parseProblematic(
      "_ = #colorLiteral(red: 0, green: 0",
      .fatal,
      .expectedCommaBeforeKeywordPlaygroundLiteral("colorLiteral", "blue"))
    parseProblematic(
      "_ = #colorLiteral(red: 0, green: 0, blue: 0",
      .fatal,
      .expectedCommaBeforeKeywordPlaygroundLiteral("colorLiteral", "alpha"))
  }

  func testGenerics() {
    parseProblematic("init<A, B() {}", .error, .expectedRightChevron("generic parameter list"))
    parseProblematic("init<A,>() {}", .fatal, .expectedGenericsParameterName)
    parseProblematic("init<A:>() {}", .fatal, .expectedGenericTypeRestriction("A"))
    parseProblematic("extension Foo where == Bar", .fatal, .expectedGenericRequirementName)
    parseProblematic("extension Foo where Self:", .fatal, .expectedGenericTypeRestriction("Self"))
    parseProblematic("extension Foo where Self =", .fatal, .requiresDoubleEqualForSameTypeRequirement)
    parseProblematic("extension Foo where Self -", .fatal, .expectedRequirementDelimiter)
  }

  func testPatterns() {
    parseProblematic("for func in _ {}", .fatal, .expectedPattern)
    parseProblematic("switch foo { case ._ }", .fatal, .expectedCaseNamePattern)
    parseProblematic("switch foo { case (let a, let b }", .fatal, .expectedTuplePatternCloseParenthesis)
    parseProblematic("for (a,b,?:foo) in _ {}", .fatal, .expectedIdentifierTuplePattern)
  }

  func testStatements() {
    parseProblematic("print(a) print(b)", .error, .statementSameLineWithoutSemicolon)
    parseProblematic("#sourceLocation", .fatal, .expectedOpenParenSourceLocation)
    parseProblematic("#foo", .fatal, .expectedValidCompilerCtrlKeyword)
    parseProblematic("#func", .fatal, .expectedValidCompilerCtrlKeyword)
    // parseProblematic("foo: return bar", .fatal, .invalidLabelOnStatement)
    parseProblematic("switch foo ", .fatal, .leftBraceExpected("switch statement"))
    parseProblematic("switch foo { case a }", .fatal, .expectedCaseColon)
    parseProblematic("switch foo { default }", .fatal, .expectedDefaultColon)
    parseProblematic("switch foo { case a: }", .fatal, .caseStmtWithoutBody("case"))
    parseProblematic("switch foo { default: }", .fatal, .caseStmtWithoutBody("default"))
    parseProblematic("switch foo { default: break", .fatal, .rightBraceExpected("switch statement"))
    parseProblematic("repeat {}", .fatal, .expectedWhileAfterRepeatBody)
    parseProblematic("if case .foo == bar {}", .fatal, .expectedEqualInConditionalBinding)
    parseProblematic("if #availability", .fatal, .expectedAvailableKeyword)
    parseProblematic("if #available", .fatal, .expectedOpenParenAvailabilityCondition)
    parseProblematic("if #available(iOS 1_0.23)", .fatal, .expectedMinorVersionAvailability)
    parseProblematic("if #available(iOS _)", .fatal, .expectedAvailabilityVersionNumber)
    parseProblematic("if #available()", .fatal, .attributeAvailabilityPlatform)
    parseProblematic("if #available(newtonOS)", .fatal, .attributeAvailabilityPlatform)
    parseProblematic("if #available(iOS 10.0", .fatal, .expectedCloseParenAvailabilityCondition)
    parseProblematic("for a im", .fatal, .expectedForEachIn)
    parseProblematic("guard foo { return }", .fatal, .expectedElseAfterGuard)
  }

  func testTypes() {
    parseProblematic("let foo: _", .fatal, .expectedType)
    parseProblematic("let foo: [Foo", .fatal, .expectedCloseSquareArrayType)
    parseProblematic("let foo: [Foo:Bar", .fatal, .expectedCloseSquareDictionaryType)
    parseProblematic("let foo: (Foo, Bar", .fatal, .expectedCloseParenParenthesizedType)
    parseProblematic("let foo: (x y: Foo)", .fatal, .tupleTypeMultipleLabels)
    parseProblematic("let foo: (x: Foo...)", .fatal, .tupleTypeVariadicElement)
    // parseProblematic("let foo: (x)", .fatal, .expectedTypeInTuple)
    parseProblematic("let foo: F & O & _", .fatal, .expectedIdentifierTypeForProtocolComposition)
    parseProblematic("let foo: protocol", .fatal, .expectedLeftChevronProtocolComposition)
    parseProblematic("let foo: protocol<a,b", .fatal, .expectedRightChevronProtocolComposition)
    parseProblematic("let foo: protocol<a,_", .fatal, .expectedIdentifierTypeForProtocolComposition)
    parseProblematic("let foo: I throws -> J)", .fatal, .expectedFunctionTypeArguments)
    parseProblematic("let foo: () throws)", .fatal, .throwsInWrongPosition("throws"))
    parseProblematic("let foo: () rethrows)", .fatal, .throwsInWrongPosition("rethrows"))
    parseProblematic("let foo: Foo._)", .fatal, .wrongIdentifierForMetatypeType)
    parseProblematic("protocol Foo : Bar, class)", .fatal, .lateClassRequirement)
    parseProblematic("protocol Foo : class, _)", .fatal, .expectedTypeRestriction)
  }

  static var allTests = [
    ("testAttributes", testAttributes),
    ("testCodeBlock", testCodeBlock),
    ("testDeclarations", testDeclarations),
    ("testExpressions", testExpressions),
    ("testPlaygroundLiterals", testPlaygroundLiterals),
    ("testGenerics", testGenerics),
    ("testPatterns", testPatterns),
    ("testStatements", testStatements),
    ("testTypes", testTypes),
  ]
}
