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

@testable import AST

class OptionalInPatternMatchingTests: XCTestCase {
  func testOptionalsInSwitch() {
    parseStatementAndTest("""
    switch foo {
    case .foo?, .foo(bar)?, A.b(x)?:
      break
    case (foo, bar)?:
      break
    case x?:
      break
    case _?:
      break
    }
    """,
    """
    switch foo {
    case .foo?, .foo(bar)?, A.b(x)?:
    break
    case (foo, bar)?:
    break
    case x?:
    break
    case _?:
    break
    }
    """)
  }

  func testOptionalsInCondition() {
    parseStatementAndTest("""
    if case .foo? = z {
      if case .foo(bar)? = z, case A.b(x)? = z {}
      if case (foo, bar)? = z {}
      if case x? = z {}
      if case _? = z {}
    }
    """,
    """
    if case .foo? = z {
    if case .foo(bar)? = z, case A.b(x)? = z {}
    if case (foo, bar)? = z {}
    if case x? = z {}
    if case _? = z {}
    }
    """)
  }

  static var allTests = [
    ("testOptionalsInSwitch", testOptionalsInSwitch),
    ("testOptionalsInCondition", testOptionalsInCondition),
  ]
}
