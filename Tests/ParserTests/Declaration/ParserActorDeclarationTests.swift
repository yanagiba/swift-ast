/*
   Copyright 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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
@testable import Parser

class ParserActorDeclarationTests: XCTestCase {
  func testEmptyActor() {
    parseDeclarationAndTest("actor MyActor {}", "actor MyActor {}", testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertTrue(actorDecl.attributes.isEmpty)
      XCTAssertNil(actorDecl.accessLevelModifier)
      XCTAssertEqual(actorDecl.name.textDescription, "MyActor")
      XCTAssertNil(actorDecl.genericParameterClause)
      XCTAssertNil(actorDecl.typeInheritanceClause)
      XCTAssertNil(actorDecl.genericWhereClause)
      XCTAssertTrue(actorDecl.members.isEmpty)
    })
  }

  func testActorWithAccessLevel() {
    parseDeclarationAndTest("public actor MyActor {}", "public actor MyActor {}", testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertEqual(actorDecl.accessLevelModifier, .public)
      XCTAssertEqual(actorDecl.name.textDescription, "MyActor")
    })
  }

  func testActorWithInheritance() {
    parseDeclarationAndTest(
      "actor MyActor: SomeProtocol {}",
      "actor MyActor: SomeProtocol {}",
      testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertEqual(actorDecl.name.textDescription, "MyActor")
      XCTAssertNotNil(actorDecl.typeInheritanceClause)
    })
  }

  func testActorWithMembers() {
    parseDeclarationAndTest(
      "actor Counter { var count = 0; func increment() { count += 1 } }",
      """
      actor Counter {
      var count = 0
      func increment() {
      count += 1
      }
      }
      """,
      testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertEqual(actorDecl.name.textDescription, "Counter")
      XCTAssertEqual(actorDecl.members.count, 2)
    })
  }

  func testActorWithGenericParameter() {
    parseDeclarationAndTest(
      "actor Box<T> {}",
      "actor Box<T> {}",
      testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertEqual(actorDecl.name.textDescription, "Box")
      XCTAssertNotNil(actorDecl.genericParameterClause)
    })
  }

  func testActorWithGenericWhereClause() {
    parseDeclarationAndTest(
      "actor MyActor<T> where T: Sendable {}",
      "actor MyActor<T> where T: Sendable {}",
      testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertNotNil(actorDecl.genericParameterClause)
      XCTAssertNotNil(actorDecl.genericWhereClause)
    })
  }

  func testActorWithAttribute() {
    parseDeclarationAndTest(
      "@globalActor actor MyGlobalActor {}",
      "@globalActor actor MyGlobalActor {}",
      testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertFalse(actorDecl.attributes.isEmpty)
      XCTAssertEqual(actorDecl.name.textDescription, "MyGlobalActor")
    })
  }

  func testActorWithNonisolatedMember() {
    parseDeclarationAndTest(
      "actor MyActor { nonisolated func getId() -> String { id } }",
      """
      actor MyActor {
      nonisolated func getId() -> String {
      id
      }
      }
      """,
      testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertEqual(actorDecl.members.count, 1)
      if case .declaration(let memberDecl) = actorDecl.members[0],
         let funcDecl = memberDecl as? FunctionDeclaration {
        XCTAssertEqual(funcDecl.modifiers.count, 1)
        XCTAssertEqual(funcDecl.modifiers[0], .nonisolated)
      } else {
        XCTFail("Expected a function declaration member.")
      }
    })
  }

  func testActorWithNonisolatedUnsafeProperty() {
    parseDeclarationAndTest(
      "actor MyActor { nonisolated(unsafe) var cache: Int = 0 }",
      """
      actor MyActor {
      nonisolated(unsafe) var cache: Int = 0
      }
      """,
      testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertEqual(actorDecl.members.count, 1)
      if case .declaration(let memberDecl) = actorDecl.members[0],
         let varDecl = memberDecl as? VariableDeclaration {
        XCTAssertEqual(varDecl.modifiers.count, 1)
        XCTAssertEqual(varDecl.modifiers[0], .nonisolatedUnsafe)
      } else {
        XCTFail("Expected a variable declaration member.")
      }
    })
  }

  func testActorWithMultipleProtocols() {
    parseDeclarationAndTest(
      "actor MyActor: Sendable, CustomStringConvertible {}",
      "actor MyActor: Sendable, CustomStringConvertible {}",
      testClosure: { decl in
        guard let actorDecl = decl as? ActorDeclaration else {
          XCTFail("Failed in getting an actor declaration.")
          return
        }
        XCTAssertNotNil(actorDecl.typeInheritanceClause)
      })
  }

  func testActorWithComputedProperty() {
    parseDeclarationAndTest(
      "actor MyActor { var count: Int { get { 0 } } }",
      "actor MyActor {\nvar count: Int {\nget {\n0\n}\n}\n}",
      testClosure: { decl in
        guard let actorDecl = decl as? ActorDeclaration else {
          XCTFail("Failed in getting an actor declaration.")
          return
        }
        XCTAssertEqual(actorDecl.members.count, 1)
      })
  }

  func testActorWithSubscript() {
    parseDeclarationAndTest(
      "actor Storage { subscript(key: String) -> Int { get { 0 } } }",
      "actor Storage {\nsubscript(key: String) -> Int {\nget {\n0\n}\n}\n}",
      testClosure: { decl in
        guard let actorDecl = decl as? ActorDeclaration else {
          XCTFail("Failed in getting an actor declaration.")
          return
        }
        XCTAssertEqual(actorDecl.members.count, 1)
      })
  }

  func testActorWithDeinit() {
    parseDeclarationAndTest(
      "actor Resource { deinit { cleanup() } }",
      "actor Resource {\ndeinit {\ncleanup()\n}\n}",
      testClosure: { decl in
        guard let actorDecl = decl as? ActorDeclaration else {
          XCTFail("Failed in getting an actor declaration.")
          return
        }
        XCTAssertEqual(actorDecl.members.count, 1)
      })
  }

  func testActorWithInit() {
    parseDeclarationAndTest(
      "actor Counter { init(start: Int) { } }",
      "actor Counter {\ninit(start: Int) {}\n}",
      testClosure: { decl in
        guard let actorDecl = decl as? ActorDeclaration else {
          XCTFail("Failed in getting an actor declaration.")
          return
        }
        XCTAssertEqual(actorDecl.members.count, 1)
        if case .declaration(let memberDecl) = actorDecl.members[0] {
          XCTAssertTrue(memberDecl is InitializerDeclaration)
        } else {
          XCTFail("Expected init declaration member.")
        }
      })
  }

  func testActorWithMultipleMembers() {
    parseDeclarationAndTest(
      "actor Bank { var balance = 0; func deposit(_ amount: Int) { balance += amount }; func withdraw(_ amount: Int) { balance -= amount } }",
      "actor Bank {\nvar balance = 0\nfunc deposit(_ amount: Int) {\nbalance += amount\n}\nfunc withdraw(_ amount: Int) {\nbalance -= amount\n}\n}",
      testClosure: { decl in
        guard let actorDecl = decl as? ActorDeclaration else {
          XCTFail("Failed in getting an actor declaration.")
          return
        }
        XCTAssertEqual(actorDecl.members.count, 3)
      })
  }

  func testPackageActor() {
    parseDeclarationAndTest(
      "package actor InternalActor {}",
      "package actor InternalActor {}",
      testClosure: { decl in
        guard let actorDecl = decl as? ActorDeclaration else {
          XCTFail("Failed in getting an actor declaration.")
          return
        }
        XCTAssertEqual(actorDecl.accessLevelModifier, .packageLevel)
      })
  }
}
