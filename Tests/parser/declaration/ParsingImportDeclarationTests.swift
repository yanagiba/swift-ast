/*
   Copyright 2015 Ryuichi Saito, LLC

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

class ParsingImportDeclarationTests: XCTestCase {
    let parser = Parser()

    func testParseImportDecl() {
        let testModuleNames = [
            "ast": "1:11",
            "    ast": "1:15",
            "\t\n\n\n\n\n\tast": "6:5"
        ]
        for (testModuleName, endLocation) in testModuleNames {
            let (astContext, errors) = parser.parse("import \(testModuleName)")
            XCTAssertEqual(errors.count, 0)
            let nodes = astContext.topLevelDeclaration.statements
            XCTAssertEqual(nodes.count, 1)
            guard let node = nodes[0] as? ImportDeclaration else {
                XCTFail("Node is not a ImportDeclaration.")
                return
            }
            XCTAssertEqual(node.module, "ast")
            XCTAssertEqual(node.attributes.count, 0)
            XCTAssertEqual(node.importKind, ImportKind.Module)
            XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-\(endLocation)]")
        }
    }

    func testParseImportDeclWithMissingIdentifierShouldEmitError() {
        let (astContext, errors) = parser.parse("import ;import ast")
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], "Missing identifier.")
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? ImportDeclaration else {
            XCTFail("Node is not a ImportDeclaration.")
            return
        }
        XCTAssertEqual(node.module, "ast")
    }

    func testParseImportDeclWithBacktickIdentifier() {
        let (astContext, errors) = parser.parse("import `class`")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? ImportDeclaration else {
            XCTFail("Node is not a ImportDeclaration.")
            return
        }
        XCTAssertEqual(node.module, "class")
    }

    func testParseImportDeclWithContextualKeywordAsIdentifier() {
        let (astContext, errors) = parser.parse("import set; import mutating;")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 2)
        guard let node1 = nodes[0] as? ImportDeclaration, node2 = nodes[1] as? ImportDeclaration else {
            XCTFail("Nodes are not ImportDeclaration.")
            return
        }
        XCTAssertEqual(node1.module, "set")
        XCTAssertEqual(node2.module, "mutating")
    }

    func testParseImportDeclWithReservedKeywordShouldEmitMissingIdentifierError() {
        let (astContext, errors) = parser.parse("import class")
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], "Missing identifier.")
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 0)
    }

    func testParseImportDeclWithOneAttribute() {
        let (astContext, errors) = parser.parse("@testable import ast")
        XCTAssertEqual(errors.count, 0)
        let stmts = astContext.topLevelDeclaration.statements
        XCTAssertEqual(stmts.count, 1)
        guard let importDecl = stmts[0] as? ImportDeclaration else {
            XCTFail("Node is not a ImportDeclaration.")
            return
        }
        XCTAssertEqual(importDecl.module, "ast")
        let attributes = importDecl.attributes
        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes[0].name, "testable")
        XCTAssertEqual(importDecl.testSourceRangeDescription, "test/parser[1:1-1:21]")
    }

    func testParseImportDeclWithMultipleAttributes() {
        let (astContext, errors) = parser.parse("@testable @attr1 @attr2 @attr3 import ast")
        XCTAssertEqual(errors.count, 0)
        let stmts = astContext.topLevelDeclaration.statements
        XCTAssertEqual(stmts.count, 1)
        guard let importDecl = stmts[0] as? ImportDeclaration else {
            XCTFail("Node is not a ImportDeclaration.")
            return
        }
        XCTAssertEqual(importDecl.module, "ast")
        let attributes = importDecl.attributes
        XCTAssertEqual(attributes.count, 4)
        XCTAssertEqual(attributes[0].name, "testable")
        XCTAssertEqual(attributes[1].name, "attr1")
        XCTAssertEqual(attributes[2].name, "attr2")
        XCTAssertEqual(attributes[3].name, "attr3")
        XCTAssertEqual(importDecl.testSourceRangeDescription, "test/parser[1:1-1:42]")
    }

    func testParseImportDeclWithOneSubmodule() {
        let (astContext, errors) = parser.parse("import ast.decl")
        XCTAssertEqual(errors.count, 0)
        let stmts = astContext.topLevelDeclaration.statements
        XCTAssertEqual(stmts.count, 1)
        guard let importDecl = stmts[0] as? ImportDeclaration else {
            XCTFail("Node is not a ImportDeclaration.")
            return
        }
        XCTAssertEqual(importDecl.attributes.count, 0)
        XCTAssertEqual(importDecl.module, "ast")
        let submodules = importDecl.submodules
        XCTAssertEqual(submodules.count, 1)
        XCTAssertEqual(submodules[0], "decl")
    }

    func testParseImportDeclWithMultipleSubmodules() {
        let (astContext, errors) = parser.parse("import ast.node.decl.foo")
        XCTAssertEqual(errors.count, 0)
        let stmts = astContext.topLevelDeclaration.statements
        XCTAssertEqual(stmts.count, 1)
        guard let importDecl = stmts[0] as? ImportDeclaration else {
            XCTFail("Node is not a ImportDeclaration.")
            return
        }
        XCTAssertEqual(importDecl.attributes.count, 0)
        XCTAssertEqual(importDecl.module, "ast")
        let submodules = importDecl.submodules
        XCTAssertEqual(submodules.count, 3)
        XCTAssertEqual(submodules[0], "node")
        XCTAssertEqual(submodules[1], "decl")
        XCTAssertEqual(submodules[2], "foo")
    }

    func testParseImportDeclWithImportKind() {
        let testKinds: [String: ImportKind] = [
            "typealias": .Typealias,
            "struct": .Struct,
            "class": .Class,
            "enum": .Enum,
            "protocol": .Protocol,
            "var": .Var,
            "func": .Func
        ]
        for (testKindString, testKind) in testKinds {
            let (astContext, errors) = parser.parse("import \(testKindString) foo.bar")
            XCTAssertEqual(errors.count, 0)
            let stmts = astContext.topLevelDeclaration.statements
            XCTAssertEqual(stmts.count, 1)
            guard let importDecl = stmts[0] as? ImportDeclaration else {
                XCTFail("Node is not a ImportDeclaration.")
                return
            }
            XCTAssertEqual(importDecl.attributes.count, 0)
            XCTAssertEqual(importDecl.module, "foo")
            let submodules = importDecl.submodules
            XCTAssertEqual(submodules.count, 1)
            XCTAssertEqual(submodules[0], "bar")
            XCTAssertEqual(importDecl.importKind, testKind)
        }
    }

    func testParseImportDeclWithImportKindButNoSubmodulesShouldEmitError() {
        let (astContext, errors) = parser.parse("import class UIKit")
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], "Missing module name in import declaration.")
        let stmts = astContext.topLevelDeclaration.statements
        XCTAssertEqual(stmts.count, 1)
        guard let importDecl = stmts[0] as? ImportDeclaration else {
            XCTFail("Node is not a ImportDeclaration.")
            return
        }
        XCTAssertEqual(importDecl.attributes.count, 0)
        XCTAssertEqual(importDecl.module, "UIKit")
        XCTAssertEqual(importDecl.submodules.count, 0)
        XCTAssertEqual(importDecl.importKind, ImportKind.Class)
    }

    func testParseImportDeclEndingWithAPeriodShouldEmitError() {
        let (astContext, errors) = parser.parse("import foo.bar.")
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], "Postfix '.' is reserved.")
        let stmts = astContext.topLevelDeclaration.statements
        XCTAssertEqual(stmts.count, 1)
        guard let importDecl = stmts[0] as? ImportDeclaration else {
            XCTFail("Node is not a ImportDeclaration.")
            return
        }
        XCTAssertEqual(importDecl.attributes.count, 0)
        XCTAssertEqual(importDecl.module, "foo")
        XCTAssertEqual(importDecl.submodules.count, 1)
        XCTAssertEqual(importDecl.submodules[0], "bar")
    }

    func testParseImportDeclWithAccessLevelModifierShouldEmitError() {
        let testPrefixes = [
            "public": "public",
            "internal": "internal",
            "private": "private",
            "public (set)": "public",
            "internal (set)": "internal",
            "private (set)": "private",
            "@a public": "public",
            "@bar internal": "internal",
            "@x private": "private",
            "@a public (set)": "public",
            "@bar internal (set)": "internal",
            "@x private (set)": "private"
        ]
        for (testPrefix, errorModifier) in testPrefixes {
            let (astContext, errors) = parser.parse("\(testPrefix) import foo")
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors[0], "'\(errorModifier)' modifier cannot be applied to this declaration.")
            let nodes = astContext.topLevelDeclaration.statements
            XCTAssertEqual(nodes.count, 1)
            guard let node = nodes[0] as? ImportDeclaration else {
                XCTFail("Node is not a ImportDeclaration.")
                return
            }
            XCTAssertEqual(node.module, "foo")
        }
    }
}
