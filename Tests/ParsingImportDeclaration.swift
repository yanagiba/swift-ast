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

import Spectre

@testable import ast
@testable import parser

func specParsingImportDeclaration() {
    let parser = Parser()

    describe("Parse import decl") {
        $0.it("should an import decl") {
            let testModuleNames = [
                "ast": "1:11",
                "    ast": "1:15",
                "\t\n\n\n\n\n\tast": "6:5"
            ]
            for (testModuleName, endLocation) in testModuleNames {
                let (astContext, errors) = parser.parse("import \(testModuleName)")
                try expect(errors.count) == 0
                let nodes = astContext.topLevelDeclaration.statements
                try expect(nodes.count) == 1
                guard let node = nodes[0] as? ImportDeclaration else {
                    throw failure("Node is not a ImportDeclaration.")
                }
                try expect(node.module) == "ast"
                try expect(node.attributes.count) == 0
                try expect(node.importKind) == .Module
                try expect(node.testSourceRangeDescription) == "test/parser[1:1-\(endLocation)]"
            }
        }
    }

    describe("Parse import decl with missing identifier") {
        $0.it("should have an error with missing identifier") {
            let (astContext, errors) = parser.parse("import ;import ast")
            try expect(errors.count) == 1
            try expect(errors[0]) == "Missing identifier."
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? ImportDeclaration else {
                throw failure("Node is not a ImportDeclaration.")
            }
            try expect(node.module) == "ast"
        }
    }

    describe("Parse import decl with backtick identifier") {
        $0.it("should have an identifier") {
            let (astContext, errors) = parser.parse("import `class`")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? ImportDeclaration else {
                throw failure("Node is not a ImportDeclaration.")
            }
            try expect(node.module) == "class"
        }
    }

    describe("Parse import decl with contextual keyword as identifier") {
        $0.it("should have an identifier") {
            let (astContext, errors) = parser.parse("import set; import mutating;")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 2
            guard let node1 = nodes[0] as? ImportDeclaration, node2 = nodes[1] as? ImportDeclaration else {
                throw failure("Nodes are not ImportDeclaration.")
            }
            try expect(node1.module) == "set"
            try expect(node2.module) == "mutating"
        }
    }

    describe("Parse import decl with reserved keyword") {
        $0.it("should result in a missing identifier error") {
            let (astContext, errors) = parser.parse("import class")
            try expect(errors.count) == 1
            try expect(errors[0]) == "Missing identifier."
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 0
        }
    }

    describe("Parse import decl with one attribute") {
        $0.it("should have an import decl with one attribute") {
            let (astContext, errors) = parser.parse("@testable import ast")
            try expect(errors.count) == 0
            let stmts = astContext.topLevelDeclaration.statements
            try expect(stmts.count) == 1
            guard let importDecl = stmts[0] as? ImportDeclaration else {
                throw failure("Node is not a ImportDeclaration.")
            }
            try expect(importDecl.module) == "ast"
            let attributes = importDecl.attributes
            try expect(attributes.count) == 1
            try expect(attributes[0].name) == "testable"
        }
    }

    describe("Parse import decl with multiple attributes") {
        $0.it("should have an import decl with four attributes") {
            let (astContext, errors) = parser.parse("@testable @attr1 @attr2 @attr3 import ast")
            try expect(errors.count) == 0
            let stmts = astContext.topLevelDeclaration.statements
            try expect(stmts.count) == 1
            guard let importDecl = stmts[0] as? ImportDeclaration else {
                throw failure("Node is not a ImportDeclaration.")
            }
            try expect(importDecl.module) == "ast"
            let attributes = importDecl.attributes
            try expect(attributes.count) == 4
            try expect(attributes[0].name) == "testable"
            try expect(attributes[1].name) == "attr1"
            try expect(attributes[2].name) == "attr2"
            try expect(attributes[3].name) == "attr3"
        }
    }

    describe("Parse import decl with one submodule") {
        $0.it("should have an import decl with one submodule") {
            let (astContext, errors) = parser.parse("import ast.decl")
            try expect(errors.count) == 0
            let stmts = astContext.topLevelDeclaration.statements
            try expect(stmts.count) == 1
            guard let importDecl = stmts[0] as? ImportDeclaration else {
                throw failure("Node is not a ImportDeclaration.")
            }
            try expect(importDecl.attributes.count) == 0
            try expect(importDecl.module) == "ast"
            let submodules = importDecl.submodules
            try expect(submodules.count) == 1
            try expect(submodules[0]) == "decl"
        }
    }

    describe("Parse import decl with multiple submodules") {
        $0.it("should have an import decl with multiple submodules") {
            let (astContext, errors) = parser.parse("import ast.node.decl.foo")
            try expect(errors.count) == 0
            let stmts = astContext.topLevelDeclaration.statements
            try expect(stmts.count) == 1
            guard let importDecl = stmts[0] as? ImportDeclaration else {
                throw failure("Node is not a ImportDeclaration.")
            }
            try expect(importDecl.attributes.count) == 0
            try expect(importDecl.module) == "ast"
            let submodules = importDecl.submodules
            try expect(submodules.count) == 3
            try expect(submodules[0]) == "node"
            try expect(submodules[1]) == "decl"
            try expect(submodules[2]) == "foo"
        }
    }

    describe("Parse import decl with import kind") {
        $0.it("should have an import decl with import kind") {
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
                try expect(errors.count) == 0
                let stmts = astContext.topLevelDeclaration.statements
                try expect(stmts.count) == 1
                guard let importDecl = stmts[0] as? ImportDeclaration else {
                    throw failure("Node is not a ImportDeclaration.")
                }
                try expect(importDecl.attributes.count) == 0
                try expect(importDecl.module) == "foo"
                let submodules = importDecl.submodules
                try expect(submodules.count) == 1
                try expect(submodules[0]) == "bar"
                try expect(importDecl.importKind) == testKind
            }

        }
    }

    describe("Parse import decl with import kind and no submodules") {
        $0.it("should throw error when import kind is presented but submodules are missing") {
            let (astContext, errors) = parser.parse("import class UIKit")
            try expect(errors.count) == 1
            try expect(errors[0]) == "Missing module name in import declaration."
            let stmts = astContext.topLevelDeclaration.statements
            try expect(stmts.count) == 1
            guard let importDecl = stmts[0] as? ImportDeclaration else {
                throw failure("Node is not a ImportDeclaration.")
            }
            try expect(importDecl.attributes.count) == 0
            try expect(importDecl.module) == "UIKit"
            try expect(importDecl.submodules.count) == 0
            try expect(importDecl.importKind) == .Class
        }
    }
}
