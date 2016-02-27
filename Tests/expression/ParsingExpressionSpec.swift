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

func specExpression() {
  let parser = Parser()

  describe("Parse identifier expression") {
    $0.it("should return an identifier expression") {
      parser.setupTestCode("foo")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
    }
  }

  describe("Parse literal expression") {
    let testLiteralExpressions = [
      "nil",
      "1",
      "1.23",
      "\"foo\"",
      "\"\\(1 + 2)\"",
      "true",
      "[1, 2, 3]",
      "[1: true, 2: false, 3: true, 4: false]",
      "__FILE__"
    ]
    for testLiteral in testLiteralExpressions {
      $0.it("should return an identifier expression") {
        parser.setupTestCode(testLiteral)
        guard let expr = try? parser.parseExpression() else {
          throw failure("Failed in getting an expression.")
        }
        guard expr is LiteralExpression else {
          throw failure("Failed in getting a literal expression.")
        }
      }
    }
  }

  describe("Parse self expression") {
    let testLiteralExpressions = [
      "self",
      "self.foo",
      "self[0, 1]",
      "self.init"
    ]
    for testLiteral in testLiteralExpressions {
      $0.it("should return an identifier expression") {
        parser.setupTestCode(testLiteral)
        guard let expr = try? parser.parseExpression() else {
          throw failure("Failed in getting an expression.")
        }
        guard expr is SelfExpression else {
          throw failure("Failed in getting a self expression.")
        }
      }
    }
  }

  describe("Parse superclass expression") {
    let testLiteralExpressions = [
      "super.foo",
      "super[0, 1]",
      "super.init"
    ]
    for testLiteral in testLiteralExpressions {
      $0.it("should return an identifier expression") {
        parser.setupTestCode(testLiteral)
        guard let expr = try? parser.parseExpression() else {
          throw failure("Failed in getting an expression.")
        }
        guard expr is SuperclassExpression else {
          throw failure("Failed in getting a superclass expression.")
        }
      }
    }
  }

  describe("Parse closure expression") {
    $0.it("should return closure expression") {
      parser.setupTestCode("{ $0 > $1 }")
      /*
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is ClosureExpression else {
        throw failure("Failed in getting a closure expression.")
      }
      */
    }
  }

  describe("Parse an implicit member expression") {
    $0.it("should return an implicit member expression") {
      parser.setupTestCode(".foo")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is ImplicitMemberExpression else {
        throw failure("Failed in getting an implicit member expression.")
      }
    }
  }

  describe("Parse a parenthesized expression") {
    $0.it("should return a parenthesized expression") {
      parser.setupTestCode("( _, foo: 0, bar: 2.3) ")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is ParenthesizedExpression else {
        throw failure("Failed in getting a parenthesized expression.")
      }
    }
  }

  describe("Parse a wildcard expression") {
    $0.it("should return a wildcard expression") {
      parser.setupTestCode("_ ")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is WildcardExpression else {
        throw failure("Failed in getting a wildcard expression.")
      }
    }
  }

  describe("Parse a postfix operator expression") {
    $0.it("should return a postfix operator expression") {
      parser.setupTestCode("happy^-^")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is PostfixOperatorExpression else {
        throw failure("Failed in getting a postfix operator expression.")
      }
    }
  }

  describe("Parse a function call expression") {
    $0.it("should return a function call expression") {
      parser.setupTestCode("foo(x, y: 1, z: true)")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is FunctionCallExpression else {
        throw failure("Failed in getting a function call expression.")
      }
    }
  }

  describe("Parse an explicit member expression") {
    $0.it("should return an explicit member expression") {
      let testMembers = ["0", "1", "foo", "bar"]
      for testMember in testMembers {
        parser.setupTestCode("foo.\(testMember)")
        guard let expr = try? parser.parseExpression() else {
          throw failure("Failed in getting an expression.")
        }
        guard expr is ExplicitMemberExpression else {
          throw failure("Failed in getting an explicit member expression.")
        }
      }
    }
  }

  describe("Parse an initializer expression") {
    $0.it("should return an initializer expression") {
      parser.setupTestCode("foo.init")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is InitializerExpression else {
        throw failure("Failed in getting an initializer expression.")
      }
    }
  }

  describe("Parse a postfix self expression") {
    $0.it("should return a postfix self expression") {
      parser.setupTestCode("foo.self")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is PostfixSelfExpression else {
        throw failure("Failed in getting a postfix self expression.")
      }
    }
  }

  describe("Parse a dynamic type expression") {
    $0.it("should return a dynamic type expression") {
      parser.setupTestCode("foo.dynamicType")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is DynamicTypeExpression else {
        throw failure("Failed in getting a dynamic type expression.")
      }
    }
  }

  describe("Parse a subscript expression") {
    $0.it("should return a subscript expression") {
      parser.setupTestCode("foo[0, 1, 5]")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is SubscriptExpression else {
        throw failure("Failed in getting a subscript expression.")
      }
    }
  }

  describe("Parse a forced value expression") {
    $0.it("should return a forced value expression") {
      parser.setupTestCode("foo!")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is ForcedValueExpression else {
        throw failure("Failed in getting a forced value expression.")
      }
    }
  }

  describe("Parse an optional chaining expression") {
    $0.it("should return an optional chaining expression") {
      parser.setupTestCode("foo?")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is OptionalChainingExpression else {
        throw failure("Failed in getting an optional chaining expression.")
      }
    }
  }

  describe("Parse a prefix operator expression") {
    $0.it("should return a prefix operator expression") {
      parser.setupTestCode("^-^happy")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is PrefixOperatorExpression else {
        throw failure("Failed in getting a prefix operator expression.")
      }
    }
  }

  describe("Parse an in-out expression") {
    $0.it("should return an in-out expression") {
      parser.setupTestCode("&a")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is InOutExpression else {
        throw failure("Failed in getting an in-out expression.")
      }
    }
  }

  describe("Parse a try operator expression") {
    $0.it("should return a try operator expression") {
      parser.setupTestCode("try foo")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is TryOperatorExpression else {
        throw failure("Failed in getting a try operator expression.")
      }
    }
  }

  describe("Parse a binary operator expression") {
    $0.it("should return a binary operator expression") {
      parser.setupTestCode("foo == bar")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is BinaryOperatorExpression else {
        throw failure("Failed in getting a binary operator expression.")
      }
    }
  }

  describe("Parse an assignment operator expression") {
    $0.it("should return an assignment operator expression") {
      parser.setupTestCode("a = 1")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is AssignmentOperatorExpression else {
        throw failure("Failed in getting an assignment operator expression.")
      }
    }
  }

  describe("Parse binary expressions") {
    $0.it("should return a binary expression with embedded binary expressions") {
      parser.setupTestCode("1 + 2 * 3 - 4")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }

      guard let biExpr1 = expr as? BinaryOperatorExpression else {
        throw failure("Failed in getting a binary operator expression.")
      }
      try expect(biExpr1.binaryOperator) == "-"
      try expect(biExpr1.rightExpression is IntegerLiteralExpression).to.beTrue()

      guard let biExpr2 = biExpr1.leftExpression as? BinaryOperatorExpression else {
        throw failure("Failed in getting a binary operator expression.")
      }
      try expect(biExpr2.binaryOperator) == "*"
      try expect(biExpr2.rightExpression is IntegerLiteralExpression).to.beTrue()

      guard let biExpr3 = biExpr2.leftExpression as? BinaryOperatorExpression else {
        throw failure("Failed in getting a binary operator expression.")
      }
      try expect(biExpr3.binaryOperator) == "+"
      try expect(biExpr3.leftExpression is IntegerLiteralExpression).to.beTrue()
      try expect(biExpr3.rightExpression is IntegerLiteralExpression).to.beTrue()
    }
  }
}
