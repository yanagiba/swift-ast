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
    parseProblematic("defer", .fatal, .leftBraceExpectedForCodeBlock)
    parseProblematic("defer { print(i)", .fatal, .rightBraceExpectedForCodeBlock)
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
    parseProblematic("protocol foo ", .fatal, .leftBraceExpectedForDeclarationBody)

    // enum declaration
    parseProblematic("indirect", .fatal, .enumExpectedAfterIndirect)

  }

  static var allTests = [
    ("testAttributes", testAttributes),
    ("testCodeBlock", testCodeBlock),
    ("testDeclarations", testDeclarations),
  ]
}
