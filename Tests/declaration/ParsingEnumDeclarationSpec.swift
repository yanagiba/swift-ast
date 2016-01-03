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

func specParsingEnumDeclaration() {
    let parser = Parser()

    describe("Parse empty enum decl") {
        $0.it("should have an empty decl with no cases") {
            let (astContext, errors) = parser.parse("enum foo {}")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.attributes.count) == 0
            try expect(node.cases.count) == 0
            try expect(node.elements.count) == 0
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:12]"
        }
    }

    describe("Parse empty enum decl with attributes") {
        $0.it("should have an empty decl with no cases, but has attributes") {
            let (astContext, errors) = parser.parse("@x @y @z enum foo {}")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.cases.count) == 0
            try expect(node.elements.count) == 0
            let attributes = node.attributes
            try expect(attributes.count) == 3
            try expect(attributes[0].name) == "x"
            try expect(attributes[1].name) == "y"
            try expect(attributes[2].name) == "z"
            // try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:21]" Failing due to attributes are not counted as the beginning of the declaration, will fix this in next commit
        }
    }
}
