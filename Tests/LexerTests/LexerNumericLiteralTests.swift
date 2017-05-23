/*
   Copyright 2015-2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

class LexerNumericLiteralTests: XCTestCase {

  func testBinaryLiterals() {
    let binaries: [(testString: String, expectedInt: Int)] = [
      ("0b0", 0),
      ("0b1", 1),
      ("0b01", 1),
      ("0b1010", 10),
      ("0b01_10_01_10", 102),
      ("-0b1", -1),
      ("-0b10_10_10_10", -170),
    ]
    for binary in binaries {
      lexAndTest(binary.testString) { t in
        guard case let .integerLiteral(i, rawRepresentation: r) = t else {
          XCTFail("Cannot lex an integer literal.")
          return
        }
        XCTAssertEqual(i, binary.expectedInt)
        XCTAssertEqual(r, binary.testString)
      }
    }
  }

  func testOctalLiterals() {
    let octals: [(testString: String, expectedInt: Int)] = [
      ("0o0", 0),
      ("0o1", 1),
      ("0o7", 7),
      ("0o01", 1),
      ("0o1217", 655),
      ("0o01_67_24_35", 488733),
      ("-0o7", -7),
      ("-0o10_23_45_67", -2177399),
    ]
    for octal in octals {
      lexAndTest(octal.testString) { t in
        guard case let .integerLiteral(i, rawRepresentation: r) = t else {
          XCTFail("Cannot lex an integer literal.")
          return
        }
        XCTAssertEqual(i, octal.expectedInt)
        XCTAssertEqual(r, octal.testString)
      }
    }
  }

  func testDecimalLiterals() {
    let decimals: [(testString: String, expectedInt: Int)] = [
      ("0", 0),
      ("1", 1),
      ("000", 0),
      ("0_00", 0),
      ("01", 1),
      ("09", 9),
      ("100", 100),
      ("300_200_100", 3_0020_0100),
      ("-123", -123),
      ("-1_000_000_000", -10_0000_0000),
    ]
    for decimal in decimals {
      lexAndTest(decimal.testString) { t in
        guard case let .integerLiteral(i, rawRepresentation: r) = t else {
          XCTFail("Cannot lex an integer literal.")
          return
        }
        XCTAssertEqual(i, decimal.expectedInt)
        XCTAssertEqual(r, decimal.testString)
      }
    }
  }

  func testHexadecimalLiterals() {
    let hexadecimals: [(testString: String, expectedInt: Int)] = [
      ("0x0", 0),
      ("0x1", 1),
      ("0x9", 9),
      ("0xa1", 161),
      ("0x1f1A", 7962),
      ("0xFF_eb_ca_DA", 4293642970),
      ("-0xA", -10),
      ("-0x19_EC_BA_67", -434944615),
    ]
    for hex in hexadecimals {
      lexAndTest(hex.testString) { t in
        guard case let .integerLiteral(i, rawRepresentation: r) = t else {
          XCTFail("Cannot lex an integer literal.")
          return
        }
        XCTAssertEqual(i, hex.expectedInt)
        XCTAssertEqual(r, hex.testString)
      }
    }
  }

  func testDecimalFloatingLiterals() {
    let decimals: [(testString: String, expectedDouble: Double)] = [
      ("0.0", 0),
      ("0E2", 0),
      ("1.1", 1.1),
      ("1.0001", 1.0001),
      ("10_0.3_00", 100.3),
      ("10_0.000_3", 100.0003),
      ("300_200_100e13", 300200100e13),
      ("-123E-135", -123e-135),
      // ("-1_000_000_000.000_001e+1_0_0", -1.000000000001e109), // the floating precision cannot be this accurate, 1000000000 + 1e-6 gets calculated into 1000000000.0
      ("15e0", 15),
    ]
    for decimal in decimals {
      lexAndTest(decimal.testString) { t in
        guard case let .floatingPointLiteral(d, rawRepresentation: r) = t else {
          XCTFail("Cannot lex a double literal.")
          return
        }
        XCTAssertEqualWithAccuracy(d, decimal.expectedDouble, accuracy: 0.000000001)
        XCTAssertEqual(r, decimal.testString)
      }
    }
  }

  func testHexadecimalFloatingLiterals() {
    let hexadecimals: [(testString: String, expectedDouble: Double)] = [
      ("0x0.1p2", 0x0.1p2),
      ("-0x1P10", -0x1P10),
      ("0x9.A_Fp+30", 0x9.AFp+30),
      ("-0xa_1.eaP-1_5", -0xa1.eaP-15),
      ("0x1p0", 1),
    ]
    for hex in hexadecimals {
      lexAndTest(hex.testString) { t in
        guard case let .floatingPointLiteral(d, rawRepresentation: r) = t else {
          XCTFail("Cannot lex a double literal.")
          return
        }
        XCTAssertEqualWithAccuracy(d, hex.expectedDouble, accuracy: 0.000000001)
        XCTAssertEqual(r, hex.testString)
      }
    }
  }

  static var allTests = [
    ("testBinaryLiterals", testBinaryLiterals),
    ("testOctalLiterals", testOctalLiterals),
    ("testDecimalLiterals", testDecimalLiterals),
    ("testHexadecimalLiterals", testHexadecimalLiterals),
    ("testDecimalFloatingLiterals", testDecimalFloatingLiterals),
    ("testHexadecimalFloatingLiterals", testHexadecimalFloatingLiterals),
  ]
}
