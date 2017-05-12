/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

  func testDeclarations() {
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

    // operator declaration
    parseProblematic("infix operator a", .fatal, .expectedValidOperator)
    parseProblematic("infix operator", .fatal, .expectedValidOperator)
    parseProblematic("infix operator ?", .fatal, .expectedValidOperator)
    parseProblematic("operator <!>", .fatal, .operatorDeclarationHasNoFixity)
    parseProblematic("fileprivate operator <!>", .fatal, .operatorDeclarationHasNoFixity)
    parseProblematic("infix operator <!>:", .fatal, .expectedOperatorNameAfterInfixOperator)

    // enum declaration
    parseProblematic("indirect", .fatal, .enumExpectedAfterIndirect)

  }

  static var allTests = [
    ("testAttributes", testAttributes),
    ("testCodeBlock", testCodeBlock),
    ("testDeclarations", testDeclarations),
  ]
}
