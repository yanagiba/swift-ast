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

@testable import source
@testable import ast
@testable import parser

extension Parser {
  public func parse(text: String) -> (astContext: ASTContext, errors: [String]) {
    let testSourceFile = SourceFile(path: "test/parser", content: text)
    return parse(testSourceFile)
  }
}

extension Statement {
  var testSourceRangeDescription: String {
    return "\(sourceRange.start.path)[\(sourceRange.start.line):\(sourceRange.start.column)-\(sourceRange.end.line):\(sourceRange.end.column)]"
  }
}

func specParser() {
    let parser = Parser()

    describe("Parse empty file") {
        $0.it("should get translation unit with empty nodes") {
            let (astContext, errors) = parser.parse("")
            try expect(errors.count) == 0
            try expect(astContext.topLevelDeclaration.testSourceRangeDescription) == "<unknown>[0:0-0:0]"
            try expect(astContext.topLevelDeclaration.statements.count) == 0
        }
    }

    describe("Skip statements separators") {
        $0.it("should be two import decls") {
            let testSeparators = [";", "\n", "\r", "\r\n", ";;;", "\n\n\n", "  \n   "]
            for testSeparator in testSeparators {
                let (astContext, errors) = parser.parse("import ast\(testSeparator)import ast")
                try expect(errors.count) == 0
                let nodes = astContext.topLevelDeclaration.statements
                try expect(nodes.count) == 2
                guard let node1 = nodes[0] as? ImportDeclaration, node2 = nodes[1] as? ImportDeclaration else {
                    throw failure("Nodes are not ImportDeclaration.")
                }
                try expect(node1.module) == "ast"
                try expect(node2.module) == "ast"
            }
        }
    }

    describe("Parse two import decls with missing separators in between") {
        $0.it("should have an error with missing separators") {
            let (astContext, errors) = parser.parse("import foo import bar")
            try expect(errors.count) == 1
            try expect(errors[0]) == "Statements must be separated by line breaks or semicolons."
            try expect(astContext.topLevelDeclaration.testSourceRangeDescription) == "test/parser[1:1-1:22]"
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 2
            guard let node1 = nodes[0] as? ImportDeclaration, node2 = nodes[1] as? ImportDeclaration else {
                throw failure("Nodes are not ImportDeclaration.")
            }
            try expect(node1.module) == "foo"
            try expect(node1.testSourceRangeDescription) == "test/parser[1:1-1:11]"
            try expect(node2.module) == "bar"
            try expect(node2.testSourceRangeDescription) == "test/parser[1:12-1:22]"
        }
    }
}
