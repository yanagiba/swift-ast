/*
   Copyright 2016 Ryuichi Saito, LLC

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

import Spectre

@testable import parser
@testable import ast

func specLiteralExpression() {
  let parser = Parser()

  describe("Parse a nil literal expression") {
    $0.it("should return a nil literal expression") {
      parser.setupTestCode("nil")
      guard let literalExpr = try? parser.parseLiteralExpression() else {
        throw failure("Failed in getting a literal expression.")
      }
      guard literalExpr is NilLiteralExpression else {
        throw failure("Failed in getting a nil expression.")
      }
    }
  }

  describe("Parse a binary integer literal expression") {
    $0.it("should return an integer literal expression with binary") {
      let testStrings = [
        "0b0": 0,
        "0b1": 0,
        "0b01": 0,
        "0b1010": 0,
        "0b01_10_01_10": 0,
        "-0b1": 0,
        "-0b10_10_10_10": 0
      ]
      for (testString, evaluatedResult) in testStrings {
        parser.setupTestCode(testString)
        guard let literalExpr = try? parser.parseLiteralExpression() else {
          throw failure("Failed in getting a literal expression.")
        }
        guard let integerLiteralExpr = literalExpr as? IntegerLiteralExpression else {
          throw failure("Failed in getting an integer expression.")
        }
        guard case let literalKind = integerLiteralExpr.kind where literalKind == .Binary else  {
          throw failure("Failed in getting a binary integer expression.")
        }
        try expect(integerLiteralExpr.rawString) == testString
        try expect(integerLiteralExpr.integerValue) == evaluatedResult // TODO: needs to be updated once evaluation is done
      }
    }
  }

  describe("Parse an octal integer literal expression") {
    $0.it("should return an integer literal expression with octal") {
      let testStrings = [
        "0o0": 0,
        "0o1": 0,
        "0o7": 0,
        "0o01": 0,
        "0o1217": 0,
        "0o01_67_24_35": 0,
        "-0o7": 0,
        "-0o10_23_45_67": 0
      ]
      for (testString, evaluatedResult) in testStrings {
        parser.setupTestCode(testString)
        guard let literalExpr = try? parser.parseLiteralExpression() else {
          throw failure("Failed in getting a literal expression.")
        }
        guard let integerLiteralExpr = literalExpr as? IntegerLiteralExpression else {
          throw failure("Failed in getting an integer expression.")
        }
        guard case let literalKind = integerLiteralExpr.kind where literalKind == .Octal else  {
          throw failure("Failed in getting an octal integer expression.")
        }
        try expect(integerLiteralExpr.rawString) == testString
        try expect(integerLiteralExpr.integerValue) == evaluatedResult // TODO: needs to be updated once evaluation is done
      }
    }
  }

  describe("Parse a decimal integer literal expression") {
    $0.it("should return an integer literal expression with decimal") {
      let testStrings = [
        "0": 0,
        "1": 0,
        "100": 0,
        "300_200_100": 0,
        "-123": 0,
        "-1_000_000_000": 0
      ]
      for (testString, evaluatedResult) in testStrings {
        parser.setupTestCode(testString)
        guard let literalExpr = try? parser.parseLiteralExpression() else {
          throw failure("Failed in getting a literal expression.")
        }
        guard let integerLiteralExpr = literalExpr as? IntegerLiteralExpression else {
          throw failure("Failed in getting an integer expression.")
        }
        guard case let literalKind = integerLiteralExpr.kind where literalKind == .Decimal else  {
          throw failure("Failed in getting a decimal integer expression.")
        }
        try expect(integerLiteralExpr.rawString) == testString
        try expect(integerLiteralExpr.integerValue) == evaluatedResult // TODO: needs to be updated once evaluation is done
      }
    }
  }

  describe("Parse a hexadecimal integer literal expression") {
    $0.it("should return an integer literal expression with hexadecimal") {
      let testStrings = [
        "0x0": 0,
        "0x1": 0,
        "0x9": 0,
        "0xa1": 0,
        "0x1f1A": 0,
        "0xFF_eb_ca_DA": 0,
        "-0xA": 0,
        "-0x19_EC_BA_67": 0
      ]
      for (testString, evaluatedResult) in testStrings {
        parser.setupTestCode(testString)
        guard let literalExpr = try? parser.parseLiteralExpression() else {
          throw failure("Failed in getting a literal expression.")
        }
        guard let integerLiteralExpr = literalExpr as? IntegerLiteralExpression else {
          throw failure("Failed in getting an integer expression.")
        }
        guard case let literalKind = integerLiteralExpr.kind where literalKind == .Hexadecimal else  {
          throw failure("Failed in getting a hexadecimal integer expression.")
        }
        try expect(integerLiteralExpr.rawString) == testString
        try expect(integerLiteralExpr.integerValue) == evaluatedResult // TODO: needs to be updated once evaluation is done
      }
    }
  }

  describe("Parse a decimal float literal expression") {
    $0.it("should return a float literal expression with decimal") {
      let testStrings = [
        "0.0": 0.0,
        "1.1": 0.0,
        "10_0.3_00": 0.0,
        "300_200_100e13": 0.0,
        "-123E+135": 0.0,
        "-1_000_000_000.000_001e-1_0_0": 0.0
      ]
      for (testString, evaluatedResult) in testStrings {
        parser.setupTestCode(testString)
        guard let literalExpr = try? parser.parseLiteralExpression() else {
          throw failure("Failed in getting a literal expression.")
        }
        guard let floatLiteralExpr = literalExpr as? FloatLiteralExpression else {
          throw failure("Failed in getting a float expression.")
        }
        guard case let literalKind = floatLiteralExpr.kind where literalKind == .Decimal else  {
          throw failure("Failed in getting a decimal float expression.")
        }
        try expect(floatLiteralExpr.rawString) == testString
        try expect(floatLiteralExpr.floatValue) == evaluatedResult // TODO: needs to be updated once evaluation is done
      }
    }
  }

  describe("Parse a hexadecimal float literal expression") {
    $0.it("should return a float literal expression with hexadecimal") {
      let testStrings = [
        "0x0.1p2": 0.0,
        "-0x1P10": 0.0,
        "0x9.A_Fp+30": 0.0,
        "-0xa_1.eaP-1_5": 0.0
      ]
      for (testString, evaluatedResult) in testStrings {
        parser.setupTestCode(testString)
        guard let literalExpr = try? parser.parseLiteralExpression() else {
          throw failure("Failed in getting a literal expression.")
        }
        guard let floatLiteralExpr = literalExpr as? FloatLiteralExpression else {
          throw failure("Failed in getting a float expression.")
        }
        guard case let literalKind = floatLiteralExpr.kind where literalKind == .Hexadecimal else  {
          throw failure("Failed in getting a hexadecimal float expression.")
        }
        try expect(floatLiteralExpr.rawString) == testString
        try expect(floatLiteralExpr.floatValue) == evaluatedResult // TODO: needs to be updated once evaluation is done
      }
    }
  }

  describe("Parse a boolean literal expression") {
    $0.it("should return a boolean literal expression") {
      let testStrings = [
        "true": true,
        "false": false
      ]
      for (testString, evaluatedResult) in testStrings {
        parser.setupTestCode(testString)
        guard let literalExpr = try? parser.parseLiteralExpression() else {
          throw failure("Failed in getting a literal expression.")
        }
        guard let boolLiteralExpr = literalExpr as? BooleanLiteralExpression else {
          throw failure("Failed in getting a boolean expression.")
        }
        if evaluatedResult {
          guard case let literalKind = boolLiteralExpr.kind where literalKind == .True else  {
            throw failure("Failed in getting a true type boolean literal expression.")
          }
        }
        else {
          guard case let literalKind = boolLiteralExpr.kind where literalKind == .False else  {
            throw failure("Failed in getting a false type boolean literal expression.")
          }
        }
        try expect(boolLiteralExpr.booleanValue) == evaluatedResult // TODO: needs to be updated once evaluation is done
      }
    }
  }

  describe("Parse a static string literal expression") {
    $0.it("should return a static string literal expression") {
      parser.setupTestCode("\"1 2 3\"")
      guard let literalExpr = try? parser.parseLiteralExpression() else {
        throw failure("Failed in getting a literal expression.")
      }
      guard let stringLiteralExpr = literalExpr as? StringLiteralExpression else {
        throw failure("Failed in getting a string literal expression.")
      }
      guard case let literalKind = stringLiteralExpr.kind where literalKind == .Ordinary else  {
        throw failure("Failed in getting a ordinary type string literal expression.")
      }
      try expect(stringLiteralExpr.stringValue) == "1 2 3"
    }
  }

  describe("Parse an interpolated string literal expression") {
    $0.it("should return an interpolated string literal expression") {
      let testStrings = [
        "\"1 2 \\(3)\"": "1 2 \\(3)",
        "\"1 2 \\(\"3\")\"": "1 2 \\(\"3\")",
        "\"1 2 \\(\"1 + 2\")\"": "1 2 \\(\"1 + 2\")",
        "\"1 2 \\(x)\"": "1 2 \\(x)"
      ]
      for (testString, evaluatedResult) in testStrings {
        parser.setupTestCode(testString)
        guard let literalExpr = try? parser.parseLiteralExpression() else {
          throw failure("Failed in getting a literal expression.")
        }
        guard let stringLiteralExpr = literalExpr as? StringLiteralExpression else {
          throw failure("Failed in getting a string literal expression.")
        }
        guard case let literalKind = stringLiteralExpr.kind where literalKind == .Interpolated else  {
          throw failure("Failed in getting an interpolated type string literal expression.")
        }
        try expect(stringLiteralExpr.stringValue) == evaluatedResult // TODO: needs to be updated once evaluation is done
      }
    }
  }

  describe("Parse an array literal expression") {
    $0.it("should return an array literal expression") {
      parser.setupTestCode("[nil, 1, 1.23, \"foo\", \"\\(1 + 2)\", true, [1, 2, 3], [1: true, 2: false, 3: true, 4: false], __FILE__]")
      guard let literalExpr = try? parser.parseLiteralExpression() else {
        throw failure("Failed in getting a literal expression.")
      }
      guard let arrayLiteralExpr = literalExpr as? ArrayLiteralExpression else {
        throw failure("Failed in getting an array literal expression.")
      }
      let items = arrayLiteralExpr.items
      try expect(items.count) == 9
      try expect(items[0] is NilLiteralExpression).to.beTrue()
      try expect(items[1] is IntegerLiteralExpression).to.beTrue()
      try expect(items[2] is FloatLiteralExpression).to.beTrue()
      try expect(items[3] is StringLiteralExpression).to.beTrue()
      try expect(items[4] is StringLiteralExpression).to.beTrue()
      try expect(items[5] is BooleanLiteralExpression).to.beTrue()
      try expect(items[6] is ArrayLiteralExpression).to.beTrue()
      try expect(items[7] is DictionaryLiteralExpression).to.beTrue()
      try expect(items[8] is SpecialLiteralExpression).to.beTrue()
    }
  }

  describe("Parse a dictionary literal expression") {
    $0.it("should return a dictionary literal expression") {
      parser.setupTestCode("[nil: 1, 1.23: \"foo\", \"\\(1 + 2)\": true, [1, 2, 3]: [1: true, 2: false, 3: true, 4: false], __FILE__: [1: true]]")
      guard let literalExpr = try? parser.parseLiteralExpression() else {
        throw failure("Failed in getting a literal expression.")
      }
      guard let dictLiteralExpr = literalExpr as? DictionaryLiteralExpression else {
        throw failure("Failed in getting a dictionary literal expression.")
      }
      let items = dictLiteralExpr.items
      try expect(items.count) == 5
      try expect(items[0].0 is NilLiteralExpression).to.beTrue()
      try expect(items[0].1 is IntegerLiteralExpression).to.beTrue()
      try expect(items[1].0 is FloatLiteralExpression).to.beTrue()
      try expect(items[1].1 is StringLiteralExpression).to.beTrue()
      try expect(items[2].0 is StringLiteralExpression).to.beTrue()
      try expect(items[2].1 is BooleanLiteralExpression).to.beTrue()
      try expect(items[3].0 is ArrayLiteralExpression).to.beTrue()
      try expect(items[3].1 is DictionaryLiteralExpression).to.beTrue()
      try expect(items[4].0 is SpecialLiteralExpression).to.beTrue()
      try expect(items[4].1 is DictionaryLiteralExpression).to.beTrue()
    }
  }

  describe("Parse a special identifier literal expression") {
    $0.it("should return a special identifier literal expression") {
      let testStrings: [String: SpecialLiteralExpression.Kind] = [
        "__FILE__": .File,
        "__LINE__": .Line,
        "__COLUMN__": .Column,
        "__FUNCTION__": .Function,
      ]
      for (testString, specialLiteralExpressionKind) in testStrings {
        parser.setupTestCode(testString)
        guard let literalExpr = try? parser.parseLiteralExpression() else {
          throw failure("Failed in getting a literal expression.")
        }
        guard let specialLiteralExpression = literalExpr as? SpecialLiteralExpression else {
          throw failure("Failed in getting a special literal expression.")
        }
        guard case let literalKind = specialLiteralExpression.kind where literalKind == specialLiteralExpressionKind else  {
          throw failure("Failed in getting a \(specialLiteralExpressionKind) type special literal expression.")
        }
      }
    }
  }
}
