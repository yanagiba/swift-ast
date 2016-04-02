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

@testable import ast
@testable import parser

func specParsingTypeAliasDeclaration() {
    let parser = Parser()

    describe("Parse simple typealias decl") {
        $0.it("should have a typealias decl") {
            let (astContext, errors) = parser.parse("typealias MyColor = NSColor")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? TypeAliasDeclaration else {
                throw failure("Node is not a TypeAliasDeclaration.")
            }
            try expect(node.name) == "MyColor"
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            guard let typeIdentifier = node.type as? TypeIdentifier else {
                throw failure("Failed in getting a type identifier.")
            }
            try expect(typeIdentifier.names.count) == 1
            try expect(typeIdentifier.names[0]) == "NSColor"
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:28]"
        }
    }

    describe("Parse simple typealias decl with attributes") {
        $0.it("should have a simple typealias decl with attributes") {
            let (astContext, errors) = parser.parse("@x @y @z typealias MyColor = NSColor")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? TypeAliasDeclaration else {
                throw failure("Node is not a TypeAliasDeclaration.")
            }
            try expect(node.name) == "MyColor"
            try expect(node.attributes.count) == 3
            try expect(node.attributes[0].name) == "x"
            try expect(node.attributes[1].name) == "y"
            try expect(node.attributes[2].name) == "z"
            try expect(node.accessLevel) == .Default
            guard let typeIdentifier = node.type as? TypeIdentifier else {
                throw failure("Failed in getting a type identifier.")
            }
            try expect(typeIdentifier.names.count) == 1
            try expect(typeIdentifier.names[0]) == "NSColor"
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:37]"
        }
    }

    describe("Parse simple typealias decl with access level modifier") {
        $0.it("should have a simple typealias decl with access level modifier") {
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
                try expect(errors.count) == 0
                let nodes = astContext.topLevelDeclaration.statements
                try expect(nodes.count) == 1
                guard let node = nodes[0] as? TypeAliasDeclaration else {
                    throw failure("Node is not a TypeAliasDeclaration.")
                }
                try expect(node.name) == "MyColor"
                try expect(node.accessLevel) == testModifierType
                guard let typeIdentifier = node.type as? TypeIdentifier else {
                    throw failure("Failed in getting a type identifier.")
                }
                try expect(typeIdentifier.names.count) == 1
                try expect(typeIdentifier.names[0]) == "UIColor"
                try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:\(29 + testPrefix.characters.count)]"
            }
        }
    }

    describe("Parse some typealias decls with a little bit complex type") {
        $0.it("should return these typealias correctly") {
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
                try expect(errors.count) == 0
                let nodes = astContext.topLevelDeclaration.statements
                try expect(nodes.count) == 1
                guard let node = nodes[0] as? TypeAliasDeclaration else {
                    throw failure("Node is not a TypeAliasDeclaration.")
                }
                try expect(node.name) == "MyColor"
                try expect(Mirror(reflecting: node.type).subjectType == testType).to.beTrue()
            }
        }
    }

    describe("Parse two typeaslias decls with newline in between") {
        $0.it("should get two typealias decls") {
            let (astContext, errors) = parser.parse("typealias A = B \ntypealias X = Y      ")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 2
            guard let node1 = nodes[0] as? TypeAliasDeclaration, node2 = nodes[1] as? TypeAliasDeclaration else {
                throw failure("Nodes are not type alias decls.")
            }
            try expect(node1.name) == "A"
            try expect(node1.testSourceRangeDescription) == "test/parser[1:1-1:16]"
            try expect(node2.name) == "X"
            try expect(node2.testSourceRangeDescription) == "test/parser[2:1-2:16]"
        }
    }

    describe("Parse two typeaslias decls with missing separators in between") {
        $0.it("should have an error with missing separators") {
            let (astContext, errors) = parser.parse("typealias A = B typealias X = Y        ")
            try expect(errors.count) == 1
            try expect(errors[0]) == "Statements must be separated by line breaks or semicolons."
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 2
            guard let node1 = nodes[0] as? TypeAliasDeclaration, node2 = nodes[1] as? TypeAliasDeclaration else {
                throw failure("Nodes are not type alias decls.")
            }
            try expect(node1.name) == "A"
            try expect(node1.testSourceRangeDescription) == "test/parser[1:1-1:16]"
            try expect(node2.name) == "X"
            try expect(node2.testSourceRangeDescription) == "test/parser[1:17-1:32]"
        }
    }
}
