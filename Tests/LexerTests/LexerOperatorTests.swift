/*
   Copyright 2015-2016 Ryuichi Laboratories and the Yanagiba project contributors

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

@testable import Lexer
@testable import Source

class LexerOperatorTests: XCTestCase {
  let punctuators = ["/", "=", "-", "+", "!", "*", "%", "<", ">", "&", "|", "^", "~", "?"]

  func testSinglePunctuatorAsPrefix() {
    punctuators.forEach { p in
      let asPrefix = "\(p)foo"
      lexAndTest(asPrefix) { t in
        switch p {
        case "=":
          XCTAssertEqual(t, .assignmentOperator)
        case "<":
          XCTAssertEqual(t, .leftChevron)
        case "&":
          XCTAssertEqual(t, .prefixAmp)
        case "?":
          XCTAssertEqual(t, .prefixQuestion)
        default:
          XCTAssertEqual(t, .prefixOperator(p))
        }
      }
      lexAndTest(asPrefix, index: 1, expectedColumn: 2) { t in
        XCTAssertEqual(t, .identifier("foo", false))
      }
    }
  }

  func testSinglePunctuatorAsBinary() {
    let spaces = [
      ("", 4, 5),
      (" ", 5, 7),
      ("   ", 7, 11),
    ]

    var combinations: [(String, (String, Int, Int))] = []
    for p in punctuators {
      for s in spaces {
        if s.0 == "" && (p == "?" || p == "!") {
          continue
        }
        combinations.append((p, s))
      }
    }

    for (p, s) in combinations {
      let asBinary = "foo\(s.0)\(p)\(s.0)bar"
      lexAndTest(asBinary) { t in
        XCTAssertEqual(t, .identifier("foo", false))
      }
      lexAndTest(asBinary, index: 1, expectedColumn: s.1) { t in
        switch p {
        case "=":
          XCTAssertEqual(t, .assignmentOperator)
        case "?":
          XCTAssertEqual(t, .binaryQuestion)
        default:
          XCTAssertEqual(t, .binaryOperator(p))
        }
      }
      lexAndTest(asBinary, index: 2, expectedColumn: s.2) { t in
        XCTAssertEqual(t, .identifier("bar", false))
      }
    }
  }

  func testSinglePunctuatorAsPostfix() {
    punctuators.forEach { p in
      let asPostfix = "bar\(p)"
      lexAndTest(asPostfix) { t in
        XCTAssertEqual(t, .identifier("bar", false))
      }
      lexAndTest(asPostfix, index: 1, expectedColumn: 4) { t in
        switch p {
        case "=":
          XCTAssertEqual(t, .assignmentOperator) // TODO: this might be an issue?
        case "?":
          XCTAssertEqual(t, .postfixQuestion)
        case "!":
          XCTAssertEqual(t, .postfixExclaim)
        case ">":
          XCTAssertEqual(t, .rightChevron)
        default:
          XCTAssertEqual(t, .postfixOperator(p))
        }
      }
    }
  }

  func testOperators() {
    punctuators.forEach { p in
      let pp = p == "/" ? "/=" : "\(p)\(p)"

      let asPrefix = "\(pp)foo"
      lexAndTest(asPrefix) { t in
        XCTAssertEqual(t, .prefixOperator(pp))
      }

      let asBinary = "foo\(pp)bar"
      lexAndTest(asBinary, index: 1, expectedColumn: 4) { t in
        XCTAssertEqual(t, .binaryOperator(pp))
      }

      let asBinaryWithSpace = "foo \(pp) bar"
      lexAndTest(asBinaryWithSpace, index: 1, expectedColumn: 5) { t in
        XCTAssertEqual(t, .binaryOperator(pp))
      }

      let asPostfix = "bar\(pp)"
      lexAndTest(asPostfix, index: 1, expectedColumn: 4) { t in
        XCTAssertEqual(t, .postfixOperator(pp))
      }
    }
  }

  func testDotOperators() { //  swift-lint:suppress(high_ncss)
    let ps = ["", "."] + punctuators
    ps.forEach { p in
      let count = p.count
      let pp = "..\(p)"

      let asPrefix = "\(pp)foo"
      lexAndTest(asPrefix) { t in
        XCTAssertEqual(t, .prefixOperator(pp))
      }
      lexAndTest(asPrefix, index: 1, expectedColumn: 3 + count) { t in
        XCTAssertEqual(t, .identifier("foo", false))
      }

      let asBinary = "foo\(pp)bar"
      lexAndTest(asBinary) { t in
        XCTAssertEqual(t, .identifier("foo", false))
      }
      lexAndTest(asBinary, index: 1, expectedColumn: 4) { t in
        XCTAssertEqual(t, .binaryOperator(pp))
      }
      lexAndTest(asBinary, index: 2, expectedColumn: 6 + count) { t in
        XCTAssertEqual(t, .identifier("bar", false))
      }

      let asBinaryWithSpace = "foo \(pp) bar"
      lexAndTest(asBinaryWithSpace) { t in
        XCTAssertEqual(t, .identifier("foo", false))
      }
      lexAndTest(asBinaryWithSpace, index: 1, expectedColumn: 5) { t in
        XCTAssertEqual(t, .binaryOperator(pp))
      }
      lexAndTest(asBinaryWithSpace, index: 2, expectedColumn: 8 + count) { t in
        XCTAssertEqual(t, .identifier("bar", false))
      }

      let asPostfix = "bar\(pp)"
      lexAndTest(asPostfix) { t in
        XCTAssertEqual(t, .identifier("bar", false))
      }
      lexAndTest(asPostfix, index: 1, expectedColumn: 4) { t in
        XCTAssertEqual(t, .postfixOperator(pp))
      }
    }
  }

  static var allTests = [
    ("testSinglePunctuatorAsPrefix", testSinglePunctuatorAsPrefix),
    ("testSinglePunctuatorAsBinary", testSinglePunctuatorAsBinary),
    ("testSinglePunctuatorAsPostfix", testSinglePunctuatorAsPostfix),
    ("testOperators", testOperators),
    ("testDotOperators", testDotOperators),
  ]
}
