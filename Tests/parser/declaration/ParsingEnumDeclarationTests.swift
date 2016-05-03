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

class ParsingEnumDeclarationTests: XCTestCase {
    let parser = Parser()

    func testParseEmptyEnumDecl() {
        let (astContext, errors) = parser.parse("enum foo {}")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertNil(node.genericParameter)
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.modifiers.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.typeInheritance.count, 0)
        XCTAssertEqual(node.cases.count, 0)
        XCTAssertEqual(node.elements.count, 0)
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:12]")
    }

    func testParseEmptyEnumDeclWithAttributes() {
        let (astContext, errors) = parser.parse("@x @y @z enum foo {}")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertEqual(node.modifiers.count, 0)
        XCTAssertEqual(node.typeInheritance.count, 0)
        XCTAssertEqual(node.cases.count, 0)
        XCTAssertEqual(node.elements.count, 0)
        let attributes = node.attributes
        XCTAssertEqual(attributes.count, 3)
        XCTAssertEqual(attributes[0].name, "x")
        XCTAssertEqual(attributes[1].name, "y")
        XCTAssertEqual(attributes[2].name, "z")
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:21]")
    }

    func testParseEmptyEnumDeclWithAccessLevelModifier() {
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
            XCTAssertEqual(errors.count, 0)
            let nodes = astContext.topLevelDeclaration.statements
            XCTAssertEqual(nodes.count, 1)
            guard let node = nodes[0] as? EnumDeclaration else {
                XCTFail("Node is not a EnumDeclaration.")
                return
            }
            XCTAssertEqual(node.name, "foo")
            XCTAssertEqual(node.modifiers.count, 0)
            XCTAssertEqual(node.accessLevel, testModifierType)
            XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:\(13 + testPrefix.characters.count)]")
        }
    }

    func testParseEnumDeclWithAccessLevelModifierForSettersShouldThrowErrors() {
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
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors[0], "'\(errorModifier)' modifier cannot be applied to this declaration.")
            let nodes = astContext.topLevelDeclaration.statements
            XCTAssertEqual(nodes.count, 1)
            guard let node = nodes[0] as? EnumDeclaration else {
                XCTFail("Node is not a EnumDeclaration.")
                return
            }
            XCTAssertEqual(node.name, "foo")
            XCTAssertEqual(node.accessLevel, AccessLevel.Default)
            XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:\(13 + testPrefix.characters.count)]")
        }
    }

    func testParseEnumDeclWithOneCaseThasHasOneElement() {
        let (astContext, errors) = parser.parse("enum foo { case A }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertEqual(node.modifiers.count, 0)
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.typeInheritance.count, 0)
        XCTAssertEqual(node.cases.count, 1)
        XCTAssertEqual(node.cases[0].elements.count, 1)
        XCTAssertEqual(node.cases[0].elements[0].name, "A")
        XCTAssertNil(node.cases[0].elements[0].rawValue)
        XCTAssertEqual(node.elements.count, 1)
        XCTAssertEqual(node.elements[0].name, "A")
        XCTAssertNil(node.elements[0].rawValue)
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:20]")
    }

    func testParseEnumDeclWithTwoCasesThatEachHasOneElement() {
        let (astContext, errors) = parser.parse("enum foo { case A\n case set }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.cases.count, 2)
        XCTAssertEqual(node.cases[0].elements.count, 1)
        XCTAssertEqual(node.cases[0].elements[0].name, "A")
        XCTAssertEqual(node.cases[1].elements.count, 1)
        XCTAssertEqual(node.cases[1].elements[0].name, "set")
        XCTAssertEqual(node.elements.count, 2)
        XCTAssertEqual(node.elements[0].name, "A")
        XCTAssertEqual(node.elements[1].name, "set")
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-2:12]")
    }

    func testParseEnumDeclWithOneCaseThatHasTwoElements() {
        let (astContext, errors) = parser.parse("enum foo { case A, B }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.cases.count, 1)
        XCTAssertEqual(node.cases[0].elements.count, 2)
        XCTAssertEqual(node.cases[0].elements[0].name, "A")
        XCTAssertEqual(node.cases[0].elements[1].name, "B")
        XCTAssertEqual(node.elements.count, 2)
        XCTAssertEqual(node.elements[0].name, "A")
        XCTAssertEqual(node.elements[1].name, "B")
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:23]")
    }

    func testParseEnumDeclWithTwoCasesThatFirstOneHasThreeElementsAndLastOneHasOneElement() {
        let (astContext, errors) = parser.parse("enum foo { case A, B, C\n case set }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.cases.count, 2)
        XCTAssertEqual(node.cases[0].elements.count, 3)
        XCTAssertEqual(node.cases[0].elements[0].name, "A")
        XCTAssertEqual(node.cases[0].elements[1].name, "B")
        XCTAssertEqual(node.cases[0].elements[2].name, "C")
        XCTAssertEqual(node.cases[1].elements.count, 1)
        XCTAssertEqual(node.cases[1].elements[0].name, "set")
        XCTAssertEqual(node.elements.count, 4)
        XCTAssertEqual(node.elements[0].name, "A")
        XCTAssertEqual(node.elements[1].name, "B")
        XCTAssertEqual(node.elements[2].name, "C")
        XCTAssertEqual(node.elements[3].name, "set")
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-2:12]")
    }

    func testParseEnumDeclWithTwoCasesSeparatedBySemicolon() {
        let (astContext, errors) = parser.parse("enum foo { case A, B, C; case set }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertEqual(node.cases.count, 2)
        XCTAssertEqual(node.cases[0].elements.count, 3)
        XCTAssertEqual(node.cases[1].elements.count, 1)
    }

    func testParseEnumDeclWithTwoCasesWithoutSeparatorInBetweenShouldReturnTwoCasesButEmitError() {
        let (astContext, errors) = parser.parse("enum foo { case A, B, C case set }")
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], "Statements must be separated by line breaks or semicolons.")
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertEqual(node.cases.count, 2)
        XCTAssertEqual(node.cases[0].elements.count, 3)
        XCTAssertEqual(node.cases[1].elements.count, 1)
    }

    func testParseEnumDeclWithCasesThatHaveRawValue() {
        let (astContext, errors) = parser.parse("enum foo { case A = 1\ncase B = \"abc\"\ncase C = false }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.cases.count, 3)
        XCTAssertEqual(node.elements.count, 3)
        XCTAssertEqual(node.elements[0].name, "A")
        XCTAssertNil(node.elements[0].union)
        guard let elementRawValue0 = node.elements[0].rawValue else {
            XCTFail("Element 0 doesn't have raw value.")
            return
        }
        XCTAssertEqual(elementRawValue0, "1")
        XCTAssertEqual(node.elements[1].name, "B")
        XCTAssertNil(node.elements[1].union)
        guard let elementRawValue1 = node.elements[1].rawValue else {
            XCTFail("Element 1 doesn't have raw value.")
            return
        }
        XCTAssertEqual(elementRawValue1, "abc")
        XCTAssertEqual(node.elements[2].name, "C")
        XCTAssertNil(node.elements[2].union)
        guard let elementRawValue2 = node.elements[2].rawValue else {
            XCTFail("Element 2 doesn't have raw value.")
            return
        }
        XCTAssertEqual(elementRawValue2, "false")
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-3:17]")
    }

    func testParseEnumDeclWithCaseThatHasElementsThatHaveRawValue() {
        let (astContext, errors) = parser.parse("enum foo { case A = 1, B = \"abc\", C = false }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.cases.count, 1)
        XCTAssertEqual(node.elements.count, 3)
        XCTAssertEqual(node.elements[0].name, "A")
        XCTAssertNil(node.elements[0].union)
        guard let elementRawValue0 = node.elements[0].rawValue else {
            XCTFail("Element 0 doesn't have raw value.")
            return
        }
        XCTAssertEqual(elementRawValue0, "1")
        XCTAssertEqual(node.elements[1].name, "B")
        XCTAssertNil(node.elements[1].union)
        guard let elementRawValue1 = node.elements[1].rawValue else {
            XCTFail("Element 1 doesn't have raw value.")
            return
        }
        XCTAssertEqual(elementRawValue1, "abc")
        XCTAssertEqual(node.elements[2].name, "C")
        XCTAssertNil(node.elements[2].union)
        guard let elementRawValue2 = node.elements[2].rawValue else {
            XCTFail("Element 2 doesn't have raw value.")
            return
        }
        XCTAssertEqual(elementRawValue2, "false")
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:46]")
    }

    func testParseEnumDeclWithCasesThatHaveTupleType() {
        let (astContext, errors) = parser.parse("enum foo { case A(String)\ncase B(Int, ())\ncase C(foo: [Int], bar: (String, String)) }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.cases.count, 3)
        XCTAssertEqual(node.elements.count, 3)
        XCTAssertEqual(node.elements[0].name, "A")
        XCTAssertNil(node.elements[0].rawValue)
        guard let elementUnion0 = node.elements[0].union else {
            XCTFail("Element 0 doesn't have a union.")
            return
        }
        XCTAssertEqual(elementUnion0.elements.count, 1)
        XCTAssertEqual(node.elements[1].name, "B")
        XCTAssertNil(node.elements[1].rawValue)
        guard let elementUnion1 = node.elements[1].union else {
            XCTFail("Element 1 doesn't have a union.")
            return
        }
        XCTAssertEqual(elementUnion1.elements.count, 2)
        XCTAssertEqual(node.elements[2].name, "C")
        XCTAssertNil(node.elements[2].rawValue)
        guard let elementUnion2 = node.elements[2].union else {
            XCTFail("Element 2 doesn't have a union.")
            return
        }
        XCTAssertEqual(elementUnion2.elements.count, 2)
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-3:44]")
    }

    func testParseEnumDeclWithCaseThatHasElementsThatHaveTupleType() {
        let (astContext, errors) = parser.parse("enum foo { case A(String), B(Int, ()), C(foo: [Int], bar: (String, String)) }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.cases.count, 1)
        XCTAssertEqual(node.elements.count, 3)
        XCTAssertEqual(node.elements[0].name, "A")
        XCTAssertNil(node.elements[0].rawValue)
        guard let elementUnion0 = node.elements[0].union else {
            XCTFail("Element 0 doesn't have a union.")
            return
        }
        XCTAssertEqual(elementUnion0.elements.count, 1)
        XCTAssertEqual(node.elements[1].name, "B")
        XCTAssertNil(node.elements[1].rawValue)
        guard let elementUnion1 = node.elements[1].union else {
            XCTFail("Element 1 doesn't have a union.")
            return
        }
        XCTAssertEqual(elementUnion1.elements.count, 2)
        XCTAssertEqual(node.elements[2].name, "C")
        XCTAssertNil(node.elements[2].rawValue)
        guard let elementUnion2 = node.elements[2].union else {
            XCTFail("Element 2 doesn't have a union.")
            return
        }
        XCTAssertEqual(elementUnion2.elements.count, 2)
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:78]")
    }

    func testParseEmptyEnumDeclWithIndirectModifier() {
        let (astContext, errors) = parser.parse("indirect enum foo {}")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertEqual(node.modifiers.count, 1)
        XCTAssertEqual(node.modifiers[0], "indirect")
        XCTAssertEqual(node.typeInheritance.count, 0)
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.cases.count, 0)
        XCTAssertEqual(node.elements.count, 0)
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:21]")
    }

    func testParseEmptyEnumWithIndirectModifierAndAttributes() {
        let (astContext, errors) = parser.parse("@x @y @z indirect enum foo {}")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertEqual(node.modifiers.count, 1)
        XCTAssertEqual(node.modifiers[0], "indirect")
        XCTAssertEqual(node.typeInheritance.count, 0)
        XCTAssertEqual(node.cases.count, 0)
        XCTAssertEqual(node.elements.count, 0)
        let attributes = node.attributes
        XCTAssertEqual(attributes.count, 3)
        XCTAssertEqual(attributes[0].name, "x")
        XCTAssertEqual(attributes[1].name, "y")
        XCTAssertEqual(attributes[2].name, "z")
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:30]")
    }

    func testParseEmptyEnumDeclWithModifiersOtherThanIndirectShouldEmitErrors() {
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
            XCTAssertEqual(errors.count, 1)

            let nodes = astContext.topLevelDeclaration.statements
            XCTAssertEqual(nodes.count, 1)
            XCTAssertEqual(errors[0], "'\(testModifier)' modifier cannot be applied to this declaration.")
            guard let node = nodes[0] as? EnumDeclaration else {
                XCTFail("Node is not a EnumDeclaration.")
                return
            }
            XCTAssertEqual(node.name, "foo")
            XCTAssertEqual(node.modifiers.count, 1)
            XCTAssertEqual(node.modifiers[0], testModifier)
            XCTAssertEqual(node.attributes.count, 0)
            XCTAssertEqual(node.accessLevel, AccessLevel.Default)
            XCTAssertEqual(node.cases.count, 0)
            XCTAssertEqual(node.elements.count, 0)
            XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:\(13 + testModifier.characters.count)]")
        }
    }

    func testParseEnumDeclWithCaseThatHasOneAttribute() {
        let (astContext, errors) = parser.parse("enum foo { @a case bar }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let enumDecl = nodes[0] as? EnumDeclaration else {
            XCTFail("Failed in getting an enum declaraion.")
            return
        }
        XCTAssertEqual(enumDecl.cases.count, 1)
        let enumCase = enumDecl.cases[0]
        XCTAssertEqual(enumCase.attributes.count, 1)
        XCTAssertEqual(enumCase.attributes[0].name, "a")
        XCTAssertEqual(enumCase.modifiers.count, 0)
    }

    func testParseEnumDeclWithCaseThatHasMultipleAttributes() {
        let (astContext, errors) = parser.parse("enum foo { @a @b @c case bar }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let enumDecl = nodes[0] as? EnumDeclaration else {
            XCTFail("Failed in getting an enum declaraion.")
            return
        }
        XCTAssertEqual(enumDecl.cases.count, 1)
        let enumCase = enumDecl.cases[0]
        XCTAssertEqual(enumCase.attributes.count, 3)
        XCTAssertEqual(enumCase.attributes[0].name, "a")
        XCTAssertEqual(enumCase.attributes[1].name, "b")
        XCTAssertEqual(enumCase.attributes[2].name, "c")
        XCTAssertEqual(enumCase.modifiers.count, 0)
    }

    func testParseEnumDeclWithCaseThatHasIndirectModifier() {
        let (astContext, errors) = parser.parse("enum foo { indirect case bar }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let enumDecl = nodes[0] as? EnumDeclaration else {
            XCTFail("Failed in getting an enum declaraion.")
            return
        }
        XCTAssertEqual(enumDecl.cases.count, 1)
        let enumCase = enumDecl.cases[0]
        XCTAssertEqual(enumCase.attributes.count, 0)
        XCTAssertEqual(enumCase.modifiers.count, 1)
        XCTAssertEqual(enumCase.modifiers[0], "indirect")
    }

    func testParseEnumDeclWithCaseThatHasBothAttributesAndIndirectModifier() {
        let (astContext, errors) = parser.parse("enum foo { @a @b @c indirect case bar }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let enumDecl = nodes[0] as? EnumDeclaration else {
            XCTFail("Failed in getting an enum declaraion.")
            return
        }
        XCTAssertEqual(enumDecl.cases.count, 1)
        let enumCase = enumDecl.cases[0]
        XCTAssertEqual(enumCase.attributes.count, 3)
        XCTAssertEqual(enumCase.attributes[0].name, "a")
        XCTAssertEqual(enumCase.attributes[1].name, "b")
        XCTAssertEqual(enumCase.attributes[2].name, "c")
        XCTAssertEqual(enumCase.modifiers.count, 1)
        XCTAssertEqual(enumCase.modifiers[0], "indirect")
    }

    func testParseEnumDeclWithCaseThatHasDeclModifiersOtherThanIndirect() {
        let testModifiers = [
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
        for testModifier in testModifiers {
            let (astContext, errors) = parser.parse("enum foo { \(testModifier) case bar }")
            XCTAssertEqual(errors.count, 0)
            let nodes = astContext.topLevelDeclaration.statements
            XCTAssertEqual(nodes.count, 1)
            guard let enumDecl = nodes[0] as? EnumDeclaration else {
                XCTFail("Failed in getting an enum declaraion.")
                return
            }
            XCTAssertEqual(enumDecl.cases.count, 1)
            let enumCase = enumDecl.cases[0]
            XCTAssertEqual(enumCase.attributes.count, 0)
            XCTAssertEqual(enumCase.modifiers.count, 0)
        }
    }

    func testParseEnumDeclWithCasesThatSomeHaveAttributesSomeHaveIndirectSomeHaveBoth() {
        let (astContext, errors) = parser.parse("enum foo { @a indirect case A; indirect case B\n@x case C }")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let enumDecl = nodes[0] as? EnumDeclaration else {
            XCTFail("Failed in getting an enum declaraion.")
            return
        }
        XCTAssertEqual(enumDecl.cases.count, 3)
        let enumCase0 = enumDecl.cases[0]
        XCTAssertEqual(enumCase0.attributes.count, 1)
        XCTAssertEqual(enumCase0.attributes[0].name, "a")
        XCTAssertEqual(enumCase0.modifiers.count, 1)
        XCTAssertEqual(enumCase0.modifiers[0], "indirect")
        let enumCase1 = enumDecl.cases[1]
        XCTAssertEqual(enumCase1.attributes.count, 0)
        XCTAssertEqual(enumCase1.modifiers.count, 1)
        XCTAssertEqual(enumCase1.modifiers[0], "indirect")
        let enumCase2 = enumDecl.cases[2]
        XCTAssertEqual(enumCase2.attributes.count, 1)
        XCTAssertEqual(enumCase2.attributes[0].name, "x")
        XCTAssertEqual(enumCase2.modifiers.count, 0)
    }

    func testParseEmptyEnumDeclWithOneTypeInheritance() {
        let (astContext, errors) = parser.parse("enum foo: a {}")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertNil(node.genericParameter)
        XCTAssertEqual(node.modifiers.count, 0)
        XCTAssertEqual(node.typeInheritance.count, 1)
        XCTAssertEqual(node.typeInheritance[0], "a")
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.cases.count, 0)
        XCTAssertEqual(node.elements.count, 0)
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:15]")
    }

    func testParseEmptyEnumDeclWithMultipleTypeInheritances() {
        let (astContext, errors) = parser.parse("enum foo: a, b . c .d  , f {}")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertNil(node.genericParameter)
        XCTAssertEqual(node.modifiers.count, 0)
        XCTAssertEqual(node.typeInheritance.count, 3)
        XCTAssertEqual(node.typeInheritance[0], "a")
        XCTAssertEqual(node.typeInheritance[1], "b.c.d")
        XCTAssertEqual(node.typeInheritance[2], "f")
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.cases.count, 0)
        XCTAssertEqual(node.elements.count, 0)
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:30]")
    }

    func testParseEmptyEnumDeclWithClassRequirementInheritanceShouldHasNoTypeInheritanceButEmitError() {
        let (astContext, errors) = parser.parse("enum foo: class {}")
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], "'class' requirement only applies to protocols.")
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertNil(node.genericParameter)
        XCTAssertEqual(node.modifiers.count, 0)
        XCTAssertEqual(node.typeInheritance.count, 0)
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.cases.count, 0)
        XCTAssertEqual(node.elements.count, 0)
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:19]")
    }

    func testParseEmptyEnumDeclWithClassRequirementAndOtherTypeInheritancesShouldOnlyReturnCorrectTypeInheritancesButEmitError() {
        let (astContext, errors) = parser.parse("enum foo: class,  a.a.c, b  , c {}")
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], "'class' requirement only applies to protocols.")
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertNil(node.genericParameter)
        XCTAssertEqual(node.modifiers.count, 0)
        XCTAssertEqual(node.typeInheritance.count, 3)
        XCTAssertEqual(node.typeInheritance[0], "a.a.c")
        XCTAssertEqual(node.typeInheritance[1], "b")
        XCTAssertEqual(node.typeInheritance[2], "c")
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.cases.count, 0)
        XCTAssertEqual(node.elements.count, 0)
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:35]")
    }

    func testParseEmptyEnumDeclWithClassRequirementInheritanceInTheMiddleOfOtherTypeInheritancesShouldOnlyReturnCorrectTypeInheritancesButEmitError() {
        let (astContext, errors) = parser.parse("enum foo: a.a.c, b  ,class,   c {}")
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0], "'class' requirement only applies to protocols.")
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        XCTAssertNil(node.genericParameter)
        XCTAssertEqual(node.modifiers.count, 0)
        XCTAssertEqual(node.typeInheritance.count, 3)
        XCTAssertEqual(node.typeInheritance[0], "a.a.c")
        XCTAssertEqual(node.typeInheritance[1], "b")
        XCTAssertEqual(node.typeInheritance[2], "c")
        XCTAssertEqual(node.attributes.count, 0)
        XCTAssertEqual(node.accessLevel, AccessLevel.Default)
        XCTAssertEqual(node.cases.count, 0)
        XCTAssertEqual(node.elements.count, 0)
        XCTAssertEqual(node.testSourceRangeDescription, "test/parser[1:1-1:35]")
    }

    func testParseEmptyEnumDeclWithGenericParameterClause() {
        let (astContext, errors) = parser.parse("enum foo<T: Comparable> {}")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        guard let genericParameter = node.genericParameter else {
            XCTFail("Failed in getting a generic parameter clause.")
            return
        }
        XCTAssertEqual(genericParameter.parameters.count, 1)
        XCTAssertEqual(genericParameter.parameters[0].typeName, "T")
        XCTAssertEqual(genericParameter.requirements.count, 0)
        XCTAssertEqual(node.typeInheritance.count, 0)
    }

    func testParseEmptyEnumDeclWithGenericParameterClauseAndTypeInheritance() {
        let (astContext, errors) = parser.parse("enum foo<S1, S2>: a {}")
        XCTAssertEqual(errors.count, 0)
        let nodes = astContext.topLevelDeclaration.statements
        XCTAssertEqual(nodes.count, 1)
        guard let node = nodes[0] as? EnumDeclaration else {
            XCTFail("Node is not a EnumDeclaration.")
            return
        }
        XCTAssertEqual(node.name, "foo")
        guard let genericParameter = node.genericParameter else {
            XCTFail("Failed in getting a generic parameter clause.")
            return
        }
        XCTAssertEqual(genericParameter.parameters.count, 2)
        XCTAssertEqual(genericParameter.parameters[0].typeName, "S1")
        XCTAssertEqual(genericParameter.parameters[1].typeName, "S2")
        XCTAssertEqual(genericParameter.requirements.count, 0)
        XCTAssertEqual(node.typeInheritance.count, 1)
        XCTAssertEqual(node.typeInheritance[0], "a")
    }
}
