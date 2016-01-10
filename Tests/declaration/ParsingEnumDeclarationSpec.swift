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
            try expect(node.modifiers.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.typeInheritance.count) == 0
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
            try expect(node.modifiers.count) == 0
            try expect(node.typeInheritance.count) == 0
            try expect(node.cases.count) == 0
            try expect(node.elements.count) == 0
            let attributes = node.attributes
            try expect(attributes.count) == 3
            try expect(attributes[0].name) == "x"
            try expect(attributes[1].name) == "y"
            try expect(attributes[2].name) == "z"
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:21]"
        }
    }

    describe("Parse empty enum decl with access level modifier") {
        $0.it("should have an empty decl with access level modifier") {
            let testPrefixes: [String: AccessLevel] = [
                "public": .Public,
                "internal": .Internal,
                "private  ": .Private,
                "@a   public": .Public,
                "@bar internal    ": .Internal,
                "@x private": .Private
            ]
            for (testPrefix, testModifierType) in testPrefixes {
                let (astContext, errors) = parser.parse("\(testPrefix) enum foo {}")
                try expect(errors.count) == 0
                let nodes = astContext.topLevelDeclaration.statements
                try expect(nodes.count) == 1
                guard let node = nodes[0] as? EnumDeclaration else {
                    throw failure("Node is not a EnumDeclaration.")
                }
                try expect(node.name) == "foo"
                try expect(node.modifiers.count) == 0
                try expect(node.accessLevel) == testModifierType
                try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:\(13 + testPrefix.characters.count)]"
            }
        }
    }

    describe("Parse enum decl with access level modifier for setters") {
        $0.it("should throw error that access level modifier cannot be applied to this declaration") {
            let testPrefixes = [
                "public ( set       )": "public",
                "internal(   set )": "internal",
                "private (  set )    ": "private",
                "@a public (set)": "public",
                "@bar internal (set)": "internal",
                "@x private (set)": "private"
            ]
            for (testPrefix, errorModifier) in testPrefixes {
                let (astContext, errors) = parser.parse("\(testPrefix) enum foo {}")
                try expect(errors.count) == 1
                try expect(errors[0]) == "'\(errorModifier)' modifier cannot be applied to this declaration."
                let nodes = astContext.topLevelDeclaration.statements
                try expect(nodes.count) == 1
                guard let node = nodes[0] as? EnumDeclaration else {
                    throw failure("Node is not a EnumDeclaration.")
                }
                try expect(node.name) == "foo"
                try expect(node.accessLevel) == .Default
                try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:\(13 + testPrefix.characters.count)]"
            }
        }
    }

    describe("Parse enum decl with one case that has one element") {
        $0.it("should have one enum decl with one case one element") {
            let (astContext, errors) = parser.parse("enum foo { case A }")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.modifiers.count) == 0
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.typeInheritance.count) == 0
            try expect(node.cases.count) == 1
            try expect(node.cases[0].elements.count) == 1
            try expect(node.cases[0].elements[0].name) == "A"
            try expect(node.cases[0].elements[0].rawValue).to.beNil()
            try expect(node.elements.count) == 1
            try expect(node.elements[0].name) == "A"
            try expect(node.elements[0].rawValue).to.beNil()
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:20]"
        }
    }

    describe("Parse enum decl with two cases that each has one element") {
        $0.it("should have one enum decl with two cases that each has one element") {
            let (astContext, errors) = parser.parse("enum foo { case A\n case set }")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.cases.count) == 2
            try expect(node.cases[0].elements.count) == 1
            try expect(node.cases[0].elements[0].name) == "A"
            try expect(node.cases[1].elements.count) == 1
            try expect(node.cases[1].elements[0].name) == "set"
            try expect(node.elements.count) == 2
            try expect(node.elements[0].name) == "A"
            try expect(node.elements[1].name) == "set"
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-2:12]"
        }
    }

    describe("Parse enum decl with one case that has two elements") {
        $0.it("should have one enum decl with one case two elements") {
            let (astContext, errors) = parser.parse("enum foo { case A, B }")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.cases.count) == 1
            try expect(node.cases[0].elements.count) == 2
            try expect(node.cases[0].elements[0].name) == "A"
            try expect(node.cases[0].elements[1].name) == "B"
            try expect(node.elements.count) == 2
            try expect(node.elements[0].name) == "A"
            try expect(node.elements[1].name) == "B"
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:23]"
        }
    }

    describe("Parse enum decl with two cases that each has three elements and one element respectively") {
        $0.it("should have one enum decl with two cases that each has three elements and one element respectively") {
            let (astContext, errors) = parser.parse("enum foo { case A, B, C\n case set }")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.cases.count) == 2
            try expect(node.cases[0].elements.count) == 3
            try expect(node.cases[0].elements[0].name) == "A"
            try expect(node.cases[0].elements[1].name) == "B"
            try expect(node.cases[0].elements[2].name) == "C"
            try expect(node.cases[1].elements.count) == 1
            try expect(node.cases[1].elements[0].name) == "set"
            try expect(node.elements.count) == 4
            try expect(node.elements[0].name) == "A"
            try expect(node.elements[1].name) == "B"
            try expect(node.elements[2].name) == "C"
            try expect(node.elements[3].name) == "set"
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-2:12]"
        }
    }

    describe("Parse enum decl with two cases separated by semicolon") {
        $0.it("should have one enum decl with two cases") {
            let (astContext, errors) = parser.parse("enum foo { case A, B, C; case set }")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.cases.count) == 2
            try expect(node.cases[0].elements.count) == 3
            try expect(node.cases[1].elements.count) == 1
        }
    }

    describe("Parse enum decl with two cases but no separator in between") {
        $0.it("should have one enum decl with two cases and one error") {
            let (astContext, errors) = parser.parse("enum foo { case A, B, C case set }")
            try expect(errors.count) == 1
            try expect(errors[0]) == "Statements must be separated by line breaks or semicolons."
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.cases.count) == 2
            try expect(node.cases[0].elements.count) == 3
            try expect(node.cases[1].elements.count) == 1
        }
    }

    describe("Parse enum decl with cases that has raw value") {
        $0.it("should have one enum decl with several cases that has raw value") {
            let (astContext, errors) = parser.parse("enum foo { case A = 1\ncase B = \"abc\"\ncase C = false }")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.cases.count) == 3
            try expect(node.elements.count) == 3
            try expect(node.elements[0].name) == "A"
            try expect(node.elements[0].union).to.beNil()
            guard let elementRawValue0 = node.elements[0].rawValue else {
                throw failure("Element 0 doesn't have raw value.")
            }
            try expect(elementRawValue0) == "1"
            try expect(node.elements[1].name) == "B"
            try expect(node.elements[1].union).to.beNil()
            guard let elementRawValue1 = node.elements[1].rawValue else {
                throw failure("Element 1 doesn't have raw value.")
            }
            try expect(elementRawValue1) == "abc"
            try expect(node.elements[2].name) == "C"
            try expect(node.elements[2].union).to.beNil()
            guard let elementRawValue2 = node.elements[2].rawValue else {
                throw failure("Element 2 doesn't have raw value.")
            }
            try expect(elementRawValue2) == "false"
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-3:17]"
        }
    }

    describe("Parse enum decl with case that has elements that haves raw value") {
        $0.it("should have one enum decl with several cases that has raw value") {
            let (astContext, errors) = parser.parse("enum foo { case A = 1, B = \"abc\", C = false }")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.cases.count) == 1
            try expect(node.elements.count) == 3
            try expect(node.elements[0].name) == "A"
            try expect(node.elements[0].union).to.beNil()
            guard let elementRawValue0 = node.elements[0].rawValue else {
                throw failure("Element 0 doesn't have raw value.")
            }
            try expect(elementRawValue0) == "1"
            try expect(node.elements[1].name) == "B"
            try expect(node.elements[1].union).to.beNil()
            guard let elementRawValue1 = node.elements[1].rawValue else {
                throw failure("Element 1 doesn't have raw value.")
            }
            try expect(elementRawValue1) == "abc"
            try expect(node.elements[2].name) == "C"
            try expect(node.elements[2].union).to.beNil()
            guard let elementRawValue2 = node.elements[2].rawValue else {
                throw failure("Element 2 doesn't have raw value.")
            }
            try expect(elementRawValue2) == "false"
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:46]"
        }
    }

    describe("Parse enum decl with cases that has tuple type") {
        $0.it("should have one enum decl with several cases that has tuple type") {
            let (astContext, errors) = parser.parse("enum foo { case A(String)\ncase B(Int, ())\ncase C(foo: [Int], bar: (String, String)) }")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.cases.count) == 3
            try expect(node.elements.count) == 3
            try expect(node.elements[0].name) == "A"
            try expect(node.elements[0].rawValue).to.beNil()
            guard let elementUnion0 = node.elements[0].union else {
                throw failure("Element 0 doesn't have a union.")
            }
            try expect(elementUnion0.elements.count) == 1
            try expect(node.elements[1].name) == "B"
            try expect(node.elements[1].rawValue).to.beNil()
            guard let elementUnion1 = node.elements[1].union else {
                throw failure("Element 1 doesn't have a union.")
            }
            try expect(elementUnion1.elements.count) == 2
            try expect(node.elements[2].name) == "C"
            try expect(node.elements[2].rawValue).to.beNil()
            guard let elementUnion2 = node.elements[2].union else {
                throw failure("Element 2 doesn't have a union.")
            }
            try expect(elementUnion2.elements.count) == 2
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-3:44]"
        }
    }

    describe("Parse enum decl with case that has elements that haves tuple type") {
        $0.it("should have one enum decl with several cases that has tuple type") {
            let (astContext, errors) = parser.parse("enum foo { case A(String), B(Int, ()), C(foo: [Int], bar: (String, String)) }")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.cases.count) == 1
            try expect(node.elements.count) == 3
            try expect(node.elements[0].name) == "A"
            try expect(node.elements[0].rawValue).to.beNil()
            guard let elementUnion0 = node.elements[0].union else {
                throw failure("Element 0 doesn't have a union.")
            }
            try expect(elementUnion0.elements.count) == 1
            try expect(node.elements[1].name) == "B"
            try expect(node.elements[1].rawValue).to.beNil()
            guard let elementUnion1 = node.elements[1].union else {
                throw failure("Element 1 doesn't have a union.")
            }
            try expect(elementUnion1.elements.count) == 2
            try expect(node.elements[2].name) == "C"
            try expect(node.elements[2].rawValue).to.beNil()
            guard let elementUnion2 = node.elements[2].union else {
                throw failure("Element 2 doesn't have a union.")
            }
            try expect(elementUnion2.elements.count) == 2
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:78]"
        }
    }

    describe("Parse empty enum decl with `indirect` modifier") {
        $0.it("should have an empty decl with `indirect` modifier with no cases") {
            let (astContext, errors) = parser.parse("indirect enum foo {}")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.modifiers.count) == 1
            try expect(node.modifiers[0]) == "indirect"
            try expect(node.typeInheritance.count) == 0
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.cases.count) == 0
            try expect(node.elements.count) == 0
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:21]"
        }
    }

    describe("Parse empty enum decl with `indirect` modifier and attributes") {
        $0.it("should have an empty decl with `indirect` modifier and attributes but no cases") {
            let (astContext, errors) = parser.parse("@x @y @z indirect enum foo {}")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.modifiers.count) == 1
            try expect(node.modifiers[0]) == "indirect"
            try expect(node.typeInheritance.count) == 0
            try expect(node.cases.count) == 0
            try expect(node.elements.count) == 0
            let attributes = node.attributes
            try expect(attributes.count) == 3
            try expect(attributes[0].name) == "x"
            try expect(attributes[1].name) == "y"
            try expect(attributes[2].name) == "z"
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:30]"
        }
    }

    describe("Parse empty enum decl with modifiers other than `indirect`") {
        $0.it("should have errors since only `indirect` modifier is allowed for enum") {
            let modifiers = [
                "convenience",
                "dynamic",
                "final",
                "infix",
                "lazy",
                "mutating",
                "nonmutating",
                "optional",
                "override",
                "postfix",
                "prefix",
                "required",
                "unowned",
                "weak"
            ]
            for testModifier in modifiers {
                let (astContext, errors) = parser.parse("\(testModifier) enum foo {}")
                try expect(errors.count) == 1

                let nodes = astContext.topLevelDeclaration.statements
                try expect(nodes.count) == 1
                try expect(errors[0]) == "'\(testModifier)' modifier cannot be applied to this declaration."
                guard let node = nodes[0] as? EnumDeclaration else {
                    throw failure("Node is not a EnumDeclaration.")
                }
                try expect(node.name) == "foo"
                try expect(node.modifiers.count) == 1
                try expect(node.modifiers[0]) == testModifier
                try expect(node.attributes.count) == 0
                try expect(node.accessLevel) == .Default
                try expect(node.cases.count) == 0
                try expect(node.elements.count) == 0
                try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:\(13 + testModifier.characters.count)]"
            }
        }
    }

    describe("Parse empty enum decl with one type inheritance") {
        $0.it("should have an empty decl with one type inheritance") {
            let (astContext, errors) = parser.parse("enum foo: a {}")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.modifiers.count) == 0
            try expect(node.typeInheritance.count) == 1
            try expect(node.typeInheritance[0]) == "a"
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.cases.count) == 0
            try expect(node.elements.count) == 0
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:15]"
        }
    }

    describe("Parse empty enum decl with multiple type inheritances") {
        $0.it("should have an empty decl with three type inheritances") {
            let (astContext, errors) = parser.parse("enum foo: a, b . c .d  , f {}")
            try expect(errors.count) == 0
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.modifiers.count) == 0
            try expect(node.typeInheritance.count) == 3
            try expect(node.typeInheritance[0]) == "a"
            try expect(node.typeInheritance[1]) == "b.c.d"
            try expect(node.typeInheritance[2]) == "f"
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.cases.count) == 0
            try expect(node.elements.count) == 0
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:30]"
        }
    }

    describe("Parse empty enum decl with class requirement inheritance") {
        $0.it("should have an empty decl with no type inheritances, but throw error") {
            let (astContext, errors) = parser.parse("enum foo: class {}")
            try expect(errors.count) == 1
            try expect(errors[0]) == "'class' requirement only applies to protocols."
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.modifiers.count) == 0
            try expect(node.typeInheritance.count) == 0
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.cases.count) == 0
            try expect(node.elements.count) == 0
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:19]"
        }
    }

    describe("Parse empty enum decl with class requirement inheritance and other type inheritances") {
        $0.it("should have an empty decl with three type inheritances, but also throw error") {
            let (astContext, errors) = parser.parse("enum foo: class,  a.a.c, b  , c {}")
            try expect(errors.count) == 1
            try expect(errors[0]) == "'class' requirement only applies to protocols."
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.modifiers.count) == 0
            try expect(node.typeInheritance.count) == 3
            try expect(node.typeInheritance[0]) == "a.a.c"
            try expect(node.typeInheritance[1]) == "b"
            try expect(node.typeInheritance[2]) == "c"
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.cases.count) == 0
            try expect(node.elements.count) == 0
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:35]"
        }
    }
    describe("Parse empty enum decl with class requirement inheritance in the middle") {
        $0.it("should have an empty decl with three type inheritances, but also throw error") {
            let (astContext, errors) = parser.parse("enum foo: a.a.c, b  ,class,   c {}")
            try expect(errors.count) == 1
            try expect(errors[0]) == "'class' requirement only applies to protocols."
            let nodes = astContext.topLevelDeclaration.statements
            try expect(nodes.count) == 1
            guard let node = nodes[0] as? EnumDeclaration else {
                throw failure("Node is not a EnumDeclaration.")
            }
            try expect(node.name) == "foo"
            try expect(node.modifiers.count) == 0
            try expect(node.typeInheritance.count) == 3
            try expect(node.typeInheritance[0]) == "a.a.c"
            try expect(node.typeInheritance[1]) == "b"
            try expect(node.typeInheritance[2]) == "c"
            try expect(node.attributes.count) == 0
            try expect(node.accessLevel) == .Default
            try expect(node.cases.count) == 0
            try expect(node.elements.count) == 0
            try expect(node.testSourceRangeDescription) == "test/parser[1:1-1:35]"
        }
    }

}
