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

import XCTest

@testable import ast
@testable import parser

class ParsingTypeAliasDeclarationTests: XCTestCase {
    let parser = Parser()

    func testParseSimpleTypeAliasDecl() {
        let (astContext, errors) = parser.parse("typealias MyColor = NSColor")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? TypeAliasDeclaration else {
            XCTFail("Node is not a TypeAliasDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "MyColor")
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        guard let typeIdentifier = node.type as? TypeIdentifier else {
            XCTFail("Failed in getting a type identifier.")
            return
        }
        XCTAssertEqual(typeIdentifier.names.count, 1)
        XCTAssertEqual(typeIdentifier.names[0], "NSColor")
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:28]")
    }

    func testParseSimpleTypeAliasDeclWithAttributes() {
        let (astContext, errors) = parser.parse("@x @y @z typealias MyColor = NSColor")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? TypeAliasDeclaration else {
            XCTFail("Node is not a TypeAliasDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "MyColor")
        XCTAssertEqual(node.attributes.count, 3)
        XCTAssertEqual(node.attributes[0].name, "x")
        XCTAssertEqual(node.attributes[1].name, "y")
        XCTAssertEqual(node.attributes[2].name, "z")
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        guard let typeIdentifier = node.type as? TypeIdentifier else {
            XCTFail("Failed in getting a type identifier.")
            return
        }
        XCTAssertEqual(typeIdentifier.names.count, 1)
        XCTAssertEqual(typeIdentifier.names[0], "NSColor")
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:37]")
    }

    func testParseSimpleTypeAliasDeclWithAccessLevelModifier() {
        let testPrefixes: [String: AccessLevel] = [
            "public": .Public,
            "internal": .Internal,
            "private  ": .Private,
            "@a   public": .Public,
            "@bar internal    ": .Internal,
            "@x private": .Private
        ]
        for (testPrefix, testModifierType) in testPrefixes {
            let (astContext, errors) = parser.parse("\(testPrefix) typealias MyColor = UIColor")
            XCTAssertEqual(errors.count, 0)
            let nodes = astContext.topLevelDeclaration.statements
            XCTAssertEqual(nodes.count, 1)
            guard let node = nodes[0] as? TypeAliasDeclaration else {
                XCTFail("Node is not a TypeAliasDeclaration.")
                return
            }
            XCTAssertEqual(node.name, "MyColor")
            XCTAssertEqual(node.accessLevel, testModifierType)
            guard let typeIdentifier = node.type as? TypeIdentifier else {
                XCTFail("Failed in getting a type identifier.")
                return
            }
            XCTAssertEqual(typeIdentifier.names.count, 1)
            XCTAssertEqual(typeIdentifier.names[0], "UIColor")
            XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:\(29 + testPrefix.characters.count)]")
        }
    }

    func testParseSomeTypeAliasDeclWithComplexType() {
        let testPrefixes: [String: Type.Type] = [
            "protocol<A, B>": ProtocolCompositionType.self,
            "A -> B": FunctionType.self,
            "()": TupleType.self,
            "(A, B, ())": TupleType.self,
            "[A: B]": DictionaryType.self,
            "A?": OptionalType.self
        ]
        for (testTypeStr, testType) in testPrefixes {
            let (astContext, errors) = parser.parse("typealias MyColor = \(testTypeStr)")
            XCTAssertEqual(errors.count, 0)
            let nodes = astContext.topLevelDeclaration.statements
            XCTAssertEqual(nodes.count, 1)
            guard let node = nodes[0] as? TypeAliasDeclaration else {
                XCTFail("Node is not a TypeAliasDeclaration.")
                return
            }
            XCTAssertEqual(node.name, "MyColor")
            XCTAssertTrue(Mirror(reflecting: node.type).subjectType == testType)
        }
    }

    func testParseTwoTypeAliasDeclsWithNewLineInBetween() {
        let (astContext, errors) = parser.parse("typealias A = B \ntypealias X = Y      ")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 2)
        guard let node1 = nodes[0] as? TypeAliasDeclaration, node2 = nodes[1] as? TypeAliasDeclaration else {
            XCTFail("Nodes are not type alias decls.")
            return
        }
        XCTAssertEqual(node1.name, "A")
        XCTAssertEqual(node1.testSourceRangeDescription, "test/parser[1:1-1:16]")
        XCTAssertEqual(node2.name, "X")
        XCTAssertEqual(node2.testSourceRangeDescription, "test/parser[2:1-2:16]")
    }

    func testParseTwoTypeAliasDeclWithMissingSeparatorShouldEmitError() {
        let (astContext, errors) = parser.parse("typealias A = B typealias X = Y        ")
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], "Statements must be separated by line breaks or semicolons.")
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 2)
        guard let node1 = nodes[0] as? TypeAliasDeclaration, node2 = nodes[1] as? TypeAliasDeclaration else {
            XCTFail("Nodes are not type alias decls.")
            return
        }
        XCTAssertEqual(node1.name, "A")
        XCTAssertEqual(node1.testSourceRangeDescription, "test/parser[1:1-1:16]")
        XCTAssertEqual(node2.name, "X")
        XCTAssertEqual(node2.testSourceRangeDescription, "test/parser[1:17-1:32]")
    }
}
