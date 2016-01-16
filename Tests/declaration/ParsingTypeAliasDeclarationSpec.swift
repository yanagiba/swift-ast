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
}
