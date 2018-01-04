/*
   Copyright 2017-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

class DefaultTraverseImplementationTests : XCTestCase {
  struct DefaultVisitor : ASTVisitor {}
  private let defaultVisitor = DefaultVisitor()

  func testVisitTopLevelDeclaration() {
    let node = TopLevelDeclaration()
    do {
      let result = try defaultVisitor.traverse(node)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting TopLevelDeclaration")
    }
  }

  func testVisitCodeBlock() {
    let node = CodeBlock()
    do {
      let result = try defaultVisitor.traverse(node)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting CodeBlock")
    }
  }

  // Declarations

  func testVisitClassDeclaration() {
    let node = ClassDeclaration(
      name: .name("test"),
      members: [
        .declaration(StructDeclaration(name: .name("test"))),
        .compilerControl(CompilerControlStatement(kind: .endif)),
      ]
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting ClassDeclaration")
    }
  }

  func testVisitConstantDeclaration() {
    let node = ConstantDeclaration(initializerList: [
      PatternInitializer(pattern: WildcardPattern()),
      PatternInitializer(
        pattern: WildcardPattern(), initializerExpression: WildcardExpression())
    ])
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting ConstantDeclaration")
    }
  }

  func testVisitDeinitializerDeclaration() {
    let node = DeinitializerDeclaration(body: CodeBlock())
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting DeinitializerDeclaration")
    }
  }

  func testVisitEnumDeclaration() {
    let node = EnumDeclaration(
      name: .name("test"),
      members: [
        .declaration(StructDeclaration(name: .name("test"))),
        .compilerControl(CompilerControlStatement(kind: .endif)),
        .rawValue(EnumDeclaration.RawValueStyleEnumCase(cases: [])),
      ]
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting EnumDeclaration")
    }
  }

  func testVisitExtensionDeclaration() {
    let node = ExtensionDeclaration(
      type: TypeIdentifier(),
      typeInheritanceClause: nil,
      members: [
        .declaration(StructDeclaration(name: .name("test"))),
        .compilerControl(CompilerControlStatement(kind: .endif)),
      ]
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting ExtensionDeclaration")
    }
  }

  func testVisitFunctionDeclaration() {
    let node = FunctionDeclaration(
      name: .name("test"),
      signature: FunctionSignature(
        parameterList: [
          FunctionSignature.Parameter(
            localName: .name("test"),
            typeAnnotation: TypeAnnotation(type: AnyType())
          ),
          FunctionSignature.Parameter(
            localName: .name("test"),
            typeAnnotation: TypeAnnotation(type: AnyType()),
            defaultArgumentClause: WildcardExpression()
          ),
        ]
      ),
      body: CodeBlock()
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting FunctionDeclaration")
    }
  }

  func testVisitImportDeclaration() {
    let node = ImportDeclaration(path: [])
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting ImportDeclaration")
    }
  }

  func testVisitInitializerDeclaration() {
    let node = InitializerDeclaration(
      parameterList: [
        FunctionSignature.Parameter(
          localName: .name("test"),
          typeAnnotation: TypeAnnotation(type: AnyType())
        ),
        FunctionSignature.Parameter(
          localName: .name("test"),
          typeAnnotation: TypeAnnotation(type: AnyType()),
          defaultArgumentClause: WildcardExpression()
        ),
      ],
      body: CodeBlock()
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting InitializerDeclaration")
    }
  }

  func testVisitOperatorDeclaration() {
    let node = OperatorDeclaration(kind: .prefix("test"))
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting OperatorDeclaration")
    }
  }

  func testVisitPrecedenceGroupDeclaration() {
    let node = PrecedenceGroupDeclaration(name: .name("test"))
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting PrecedenceGroupDeclaration")
    }
  }

  func testVisitProtocolDeclaration() {
    let node = ProtocolDeclaration(
      name: .name("test"),
      members: [
        .associatedType(ProtocolDeclaration.AssociativityTypeMember(name: .name("test"))),
        .method(ProtocolDeclaration.MethodMember(
          name: .name("test"),
          signature: FunctionSignature(
            parameterList: [
              FunctionSignature.Parameter(
                localName: .name("test"),
                typeAnnotation: TypeAnnotation(type: AnyType())
              ),
              FunctionSignature.Parameter(
                localName: .name("test"),
                typeAnnotation: TypeAnnotation(type: AnyType()),
                defaultArgumentClause: WildcardExpression()
              ),
            ]
          )
        )),
        .initializer(ProtocolDeclaration.InitializerMember(
          parameterList: [
            FunctionSignature.Parameter(
              localName: .name("test"),
              typeAnnotation: TypeAnnotation(type: AnyType())
            ),
            FunctionSignature.Parameter(
              localName: .name("test"),
              typeAnnotation: TypeAnnotation(type: AnyType()),
              defaultArgumentClause: WildcardExpression()
            ),
          ]
        )),
        .subscript(ProtocolDeclaration.SubscriptMember(
          parameterList: [
            FunctionSignature.Parameter(
              localName: .name("test"),
              typeAnnotation: TypeAnnotation(type: AnyType())
            ),
            FunctionSignature.Parameter(
              localName: .name("test"),
              typeAnnotation: TypeAnnotation(type: AnyType()),
              defaultArgumentClause: WildcardExpression()
            ),
          ],
          resultType: AnyType(),
          getterSetterKeywordBlock: GetterSetterKeywordBlock(
            getter: GetterSetterKeywordBlock.GetterKeywordClause()
          )
        )),
        .compilerControl(CompilerControlStatement(kind: .endif)),
      ]
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting ProtocolDeclaration")
    }
  }

  func testVisitStructDeclaration() {
    let node = StructDeclaration(
      name: .name("test"),
      members: [
        .declaration(StructDeclaration(name: .name("test"))),
        .compilerControl(CompilerControlStatement(kind: .endif)),
      ]
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting StructDeclaration")
    }
  }

  func testVisitSubscriptDeclarationWithCodeBlock() {
    let node = SubscriptDeclaration(
      parameterList: [
        FunctionSignature.Parameter(
          localName: .name("test"),
          typeAnnotation: TypeAnnotation(type: AnyType())
        ),
        FunctionSignature.Parameter(
          localName: .name("test"),
          typeAnnotation: TypeAnnotation(type: AnyType()),
          defaultArgumentClause: WildcardExpression()
        ),
      ],
      resultType: AnyType(),
      codeBlock: CodeBlock()
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting SubscriptDeclaration with code block")
    }
  }

  func testVisitSubscriptDeclarationWithGetterSetterBlock() {
    let node = SubscriptDeclaration(
      resultType: AnyType(),
      getterSetterBlock: GetterSetterBlock(
        getter: GetterSetterBlock.GetterClause(codeBlock: CodeBlock()),
        setter: GetterSetterBlock.SetterClause(codeBlock: CodeBlock())
      )
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting SubscriptDeclaration with getter-setter block")
    }
  }

  func testVisitSubscriptDeclarationWithGetterSetterKeywordBlock() {
    let node = SubscriptDeclaration(
      resultType: AnyType(),
      getterSetterKeywordBlock: GetterSetterKeywordBlock(
        getter: GetterSetterKeywordBlock.GetterKeywordClause()
      )
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting SubscriptDeclaration with getter-setter block")
    }
  }

  func testVisitTypealiasDeclaration() {
    let node = TypealiasDeclaration(name: .name("test"), assignment: AnyType())
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting TypealiasDeclaration")
    }
  }

  func testVisitVariableDeclarationWithInitializerList() {
    let node = VariableDeclaration(initializerList: [
      PatternInitializer(pattern: WildcardPattern()),
      PatternInitializer(
        pattern: WildcardPattern(), initializerExpression: WildcardExpression())
    ])
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting VariableDeclaration")
    }
  }

  func testVisitVariableDeclarationWithCodeBlock() {
    let node = VariableDeclaration(
      variableName: .name("test"),
      typeAnnotation: TypeAnnotation(type: AnyType()),
      codeBlock: CodeBlock()
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting VariableDeclaration")
    }
  }

  func testVisitVariableDeclarationWithGetterSetterBlock() {
    let node = VariableDeclaration(
      variableName: .name("test"),
      typeAnnotation: TypeAnnotation(type: AnyType()),
      getterSetterBlock: GetterSetterBlock(
        getter: GetterSetterBlock.GetterClause(codeBlock: CodeBlock()),
        setter: GetterSetterBlock.SetterClause(codeBlock: CodeBlock())
      )
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting VariableDeclaration")
    }
  }

  func testVisitVariableDeclarationWithWillSetDidSetBlock() {
    let node = VariableDeclaration(
      variableName: .name("test"),
      initializer: WildcardExpression(),
      willSetDidSetBlock: WillSetDidSetBlock(
        willSetClause: WillSetDidSetBlock.WillSetClause(codeBlock: CodeBlock()),
        didSetClause: WillSetDidSetBlock.DidSetClause(codeBlock: CodeBlock())
      )
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting VariableDeclaration")
    }
  }

  func testVisitVariableDeclarationWithGetterSetterKeywordBlock() {
    let node = VariableDeclaration(
      variableName: .name("test"),
      typeAnnotation: TypeAnnotation(type: AnyType()),
      getterSetterKeywordBlock: GetterSetterKeywordBlock(
        getter: GetterSetterKeywordBlock.GetterKeywordClause()
      )
    )
    do {
      let result = try defaultVisitor.traverse(node as Declaration)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting VariableDeclaration")
    }
  }

  // Statements

  func testVisitBreakStatement() {
    let node = BreakStatement()
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting BreakStatement")
    }
  }

  func testVisitCompilerControlStatement() {
    let node = CompilerControlStatement(kind: .endif)
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting CompilerControlStatement")
    }
  }

  func testVisitContinueStatement() {
    let node = ContinueStatement()
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting ContinueStatement")
    }
  }

  func testVisitDeferStatement() {
    let node = DeferStatement(codeBlock: CodeBlock())
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting DeferStatement")
    }
  }

  func testVisitDoStatement() {
    let node = DoStatement(
      codeBlock: CodeBlock(),
      catchClauses: [
        DoStatement.CatchClause(
          whereExpression: WildcardExpression(),
          codeBlock: CodeBlock()
        )
      ]
    )
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting DoStatement")
    }
  }

  func testVisitFallthroughStatement() {
    let node = FallthroughStatement()
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting FallthroughStatement")
    }
  }

  func testVisitForInStatement() {
    let node = ForInStatement(
      matchingPattern: WildcardPattern(),
      collection: WildcardExpression(),
      whereClause: WildcardExpression(),
      codeBlock: CodeBlock()
    )
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting ForInStatement")
    }
  }

  func testVisitGuardStatement() {
    let node = GuardStatement(
      conditionList: [
        .expression(WildcardExpression()),
        .case(WildcardPattern(), WildcardExpression()),
        .let(WildcardPattern(), WildcardExpression()),
        .var(WildcardPattern(), WildcardExpression()),
        .availability(AvailabilityCondition(arguments: [])),
      ],
      codeBlock: CodeBlock()
    )
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting GuardStatement")
    }
  }

  func testVisitIfStatement() {
    let node = IfStatement(
      conditionList: [],
      codeBlock: CodeBlock(),
      elseClause: .elseif(IfStatement(
        conditionList: [],
        codeBlock: CodeBlock(),
        elseClause: .else(CodeBlock())
      ))
    )
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting IfStatement")
    }
  }

  func testVisitLabeledStatement() {
    let node = LabeledStatement(labelName: .name("test"), statement: ReturnStatement())
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting LabeledStatement")
    }
  }

  func testVisitRepeatWhileStatement() {
    let node = RepeatWhileStatement(
      conditionExpression: WildcardExpression(),
      codeBlock: CodeBlock()
    )
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting RepeatWhileStatement")
    }
  }

  func testVisitReturnStatement() {
    let node = ReturnStatement(expression: WildcardExpression())
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting ReturnStatement")
    }
  }

  func testVisitSwitchStatement() {
    let node = SwitchStatement(
      expression: WildcardExpression(),
      cases: [
        .case([SwitchStatement.Case.Item(
          pattern: WildcardPattern(),
          whereExpression: WildcardExpression())],
          [WildcardExpression()]),
        .default([WildcardExpression()]),
      ]
    )
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting SwitchStatement")
    }
  }

  func testVisitThrowStatement() {
    let node = ThrowStatement(expression: WildcardExpression())
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting ThrowStatement")
    }
  }

  func testVisitWhileStatement() {
    let node = WhileStatement(conditionList: [], codeBlock: CodeBlock())
    do {
      let result = try defaultVisitor.traverse(node as Statement)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting WhileStatement")
    }
  }

  // Expressions

  func testVisitAssignmentOperatorExpression() {
    let node = AssignmentOperatorExpression(
      leftExpression: WildcardExpression(),
      rightExpression: WildcardExpression()
    )
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting AssignmentOperatorExpression")
    }
  }

  func testVisitBinaryOperatorExpression() {
    let node = BinaryOperatorExpression(
      binaryOperator: "test",
      leftExpression: WildcardExpression(),
      rightExpression: WildcardExpression()
    )
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting BinaryOperatorExpression")
    }
  }

  func testVisitClosureExpression() {
    let node = ClosureExpression(
      signature: ClosureExpression.Signature(captureList: [
        ClosureExpression.Signature.CaptureItem(expression: WildcardExpression()),
      ]),
      statements: [
        WildcardExpression(),
      ]
    )
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting ClosureExpression")
    }
  }

  func testVisitExplicitMemberExpression() {
    let nodes = [
      ExplicitMemberExpression(kind: .tuple(WildcardExpression(), 0)),
      ExplicitMemberExpression(kind: .namedType(WildcardExpression(), .name("test"))),
      ExplicitMemberExpression(kind:
        .generic(WildcardExpression(), .name("test"), GenericArgumentClause(argumentList: []))),
      ExplicitMemberExpression(kind: .argument(WildcardExpression(), .name("test"), [])),
    ]
    do {
      for node in nodes {
        let result = try defaultVisitor.traverse(node as Expression)
        XCTAssertTrue(result)
      }
    } catch {
      XCTFail("Failed in visiting ExplicitMemberExpression")
    }
  }

  func testVisitForcedValueExpression() {
    let node = ForcedValueExpression(postfixExpression: WildcardExpression())
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting ForcedValueExpression")
    }
  }

  func testVisitFunctionCallExpression() {
    let node = FunctionCallExpression(
      postfixExpression: WildcardExpression(),
      argumentClause: [
        .expression(WildcardExpression()),
        .namedExpression(.name("test"), WildcardExpression()),
        .memoryReference(WildcardExpression()),
        .namedMemoryReference(.name("test"), WildcardExpression()),
        .operator("test"),
        .namedOperator(.name("test"), "test"),
      ],
      trailingClosure: ClosureExpression()
    )
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting FunctionCallExpression")
    }
  }

  func testVisitIdentifierExpression() {
    let node = IdentifierExpression(kind: .identifier(.name("test"), nil))
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting IdentifierExpression")
    }
  }

  func testVisitImplicitMemberExpression() {
    let node = ImplicitMemberExpression(identifier: .name("test"))
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting ImplicitMemberExpression")
    }
  }

  func testVisitInOutExpression() {
    let node = InOutExpression(identifier: .name("test"))
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting InOutExpression")
    }
  }

  func testVisitInitializerExpression() {
    let node = InitializerExpression(postfixExpression: WildcardExpression())
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting InitializerExpression")
    }
  }

  func testVisitKeyPathStringExpression() {
    let node = KeyPathStringExpression(expression: WildcardExpression())
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting KeyPathStringExpression")
    }
  }

  func testVisitLiteralExpression() {
    let nodes = [
      LiteralExpression(kind: .nil),
      LiteralExpression(kind: .interpolatedString([WildcardExpression()], "test")),
      LiteralExpression(kind: .array([WildcardExpression()])),
      LiteralExpression(kind: .dictionary([
        DictionaryEntry(key: WildcardExpression(), value: WildcardExpression())
      ])),
    ]
    do {
      for node in nodes {
        let result = try defaultVisitor.traverse(node as Expression)
        XCTAssertTrue(result)
      }
    } catch {
      XCTFail("Failed in visiting LiteralExpression")
    }
  }

  func testVisitOptionalChainingExpression() {
    let node = OptionalChainingExpression(postfixExpression: WildcardExpression())
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting OptionalChainingExpression")
    }
  }

  func testVisitParenthesizedExpression() {
    let node = ParenthesizedExpression(expression: WildcardExpression())
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting ParenthesizedExpression")
    }
  }

  func testVisitPostfixOperatorExpression() {
    let node = PostfixOperatorExpression(
      postfixOperator: "test",
      postfixExpression: WildcardExpression()
    )
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting PostfixOperatorExpression")
    }
  }

  func testVisitPostfixSelfExpression() {
    let node = PostfixSelfExpression(postfixExpression: WildcardExpression())
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting PostfixSelfExpression")
    }
  }

  func testVisitPrefixOperatorExpression() {
    let node = PrefixOperatorExpression(
      prefixOperator: "test",
      postfixExpression: WildcardExpression()
    )
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting PrefixOperatorExpression")
    }
  }

  func testVisitSelectorExpression() {
    let nodes = [
      SelectorExpression(kind: .selector(WildcardExpression())),
      SelectorExpression(kind: .getter(WildcardExpression())),
      SelectorExpression(kind: .setter(WildcardExpression())),
      SelectorExpression(kind: .selfMember(.name("test"), [])),
    ]
    do {
      for node in nodes {
        let result = try defaultVisitor.traverse(node as Expression)
        XCTAssertTrue(result)
      }
    } catch {
      XCTFail("Failed in visiting SelectorExpression")
    }
  }

  func testVisitSelfExpression() {
    let nodes = [
      SelfExpression(kind: .subscript([SubscriptArgument(expression: WildcardExpression())])),
      SelfExpression(kind: .initializer),
    ]
    do {
      for node in nodes {
        let result = try defaultVisitor.traverse(node as Expression)
        XCTAssertTrue(result)
      }
    } catch {
      XCTFail("Failed in visiting SelfExpression")
    }
  }

  func testVisitSubscriptExpression() {
    let node = SubscriptExpression(
      postfixExpression: WildcardExpression(),
      arguments: []
    )
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting SubscriptExpression")
    }
  }

  func testVisitSuperclassExpression() {
    let nodes = [
      SuperclassExpression(kind: .subscript([SubscriptArgument(expression: WildcardExpression())])),
      SuperclassExpression(kind: .initializer),
    ]
    do {
      for node in nodes {
        let result = try defaultVisitor.traverse(node as Expression)
        XCTAssertTrue(result)
      }
    } catch {
      XCTFail("Failed in visiting SuperclassExpression")
    }
  }

  func testVisitTernaryConditionalOperatorExpression() {
    let node = TernaryConditionalOperatorExpression(
      conditionExpression: WildcardExpression(),
      trueExpression: WildcardExpression(),
      falseExpression: WildcardExpression()
    )
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting TernaryConditionalOperatorExpression")
    }
  }

  func testVisitTryOperatorExpression() {
    let nodes = [
      TryOperatorExpression(kind: .try(WildcardExpression())),
      TryOperatorExpression(kind: .forced(WildcardExpression())),
      TryOperatorExpression(kind: .optional(WildcardExpression())),
    ]
    do {
      for node in nodes {
        let result = try defaultVisitor.traverse(node as Expression)
        XCTAssertTrue(result)
      }
    } catch {
      XCTFail("Failed in visiting TryOperatorExpression")
    }
  }

  func testVisitTupleExpression() {
    let node = TupleExpression(elementList: [
      TupleExpression.Element(expression: WildcardExpression()),
      TupleExpression.Element(identifier: .name("test"), expression: WildcardExpression()),
    ])
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting TupleExpression")
    }
  }

  func testVisitTypeCastingOperatorExpression() {
    let nodes = [
      TypeCastingOperatorExpression(
        kind: .check(WildcardExpression(), AnyType())),
      TypeCastingOperatorExpression(
        kind: .cast(WildcardExpression(), AnyType())),
      TypeCastingOperatorExpression(
        kind: .conditionalCast(WildcardExpression(), AnyType())),
      TypeCastingOperatorExpression(
        kind: .forcedCast(WildcardExpression(), AnyType())),
    ]
    do {
      for node in nodes {
        let result = try defaultVisitor.traverse(node as Expression)
        XCTAssertTrue(result)
      }
    } catch {
      XCTFail("Failed in visiting TypeCastingOperatorExpression")
    }
  }

  func testVisitWildcardExpression() {
    let node = WildcardExpression()
    do {
      let result = try defaultVisitor.traverse(node as Expression)
      XCTAssertTrue(result)
    } catch {
      XCTFail("Failed in visiting WildcardExpression")
    }
  }

  static var allTests = [
    ("testVisitTopLevelDeclaration", testVisitTopLevelDeclaration),
    ("testVisitCodeBlock", testVisitCodeBlock),
    ("testVisitClassDeclaration", testVisitClassDeclaration),
    ("testVisitConstantDeclaration", testVisitConstantDeclaration),
    ("testVisitDeinitializerDeclaration", testVisitDeinitializerDeclaration),
    ("testVisitEnumDeclaration", testVisitEnumDeclaration),
    ("testVisitExtensionDeclaration", testVisitExtensionDeclaration),
    ("testVisitFunctionDeclaration", testVisitFunctionDeclaration),
    ("testVisitImportDeclaration", testVisitImportDeclaration),
    ("testVisitInitializerDeclaration", testVisitInitializerDeclaration),
    ("testVisitOperatorDeclaration", testVisitOperatorDeclaration),
    ("testVisitPrecedenceGroupDeclaration", testVisitPrecedenceGroupDeclaration),
    ("testVisitProtocolDeclaration", testVisitProtocolDeclaration),
    ("testVisitStructDeclaration", testVisitStructDeclaration),
    ("testVisitSubscriptDeclarationWithCodeBlock", testVisitSubscriptDeclarationWithCodeBlock),
    ("testVisitSubscriptDeclarationWithGetterSetterBlock", testVisitSubscriptDeclarationWithGetterSetterBlock),
    ("testVisitSubscriptDeclarationWithGetterSetterKeywordBlock",
      testVisitSubscriptDeclarationWithGetterSetterKeywordBlock),
    ("testVisitTypealiasDeclaration", testVisitTypealiasDeclaration),
    ("testVisitVariableDeclarationWithInitializerList", testVisitVariableDeclarationWithInitializerList),
    ("testVisitVariableDeclarationWithCodeBlock", testVisitVariableDeclarationWithCodeBlock),
    ("testVisitVariableDeclarationWithGetterSetterBlock", testVisitVariableDeclarationWithGetterSetterBlock),
    ("testVisitVariableDeclarationWithWillSetDidSetBlock", testVisitVariableDeclarationWithWillSetDidSetBlock),
    ("testVisitVariableDeclarationWithGetterSetterKeywordBlock",
      testVisitVariableDeclarationWithGetterSetterKeywordBlock),
    ("testVisitBreakStatement", testVisitBreakStatement),
    ("testVisitCompilerControlStatement", testVisitCompilerControlStatement),
    ("testVisitContinueStatement", testVisitContinueStatement),
    ("testVisitDeferStatement", testVisitDeferStatement),
    ("testVisitDoStatement", testVisitDoStatement),
    ("testVisitFallthroughStatement", testVisitFallthroughStatement),
    ("testVisitForInStatement", testVisitForInStatement),
    ("testVisitGuardStatement", testVisitGuardStatement),
    ("testVisitIfStatement", testVisitIfStatement),
    ("testVisitLabeledStatement", testVisitLabeledStatement),
    ("testVisitRepeatWhileStatement", testVisitRepeatWhileStatement),
    ("testVisitReturnStatement", testVisitReturnStatement),
    ("testVisitSwitchStatement", testVisitSwitchStatement),
    ("testVisitThrowStatement", testVisitThrowStatement),
    ("testVisitWhileStatement", testVisitWhileStatement),
    ("testVisitAssignmentOperatorExpression", testVisitAssignmentOperatorExpression),
    ("testVisitBinaryOperatorExpression", testVisitBinaryOperatorExpression),
    ("testVisitClosureExpression", testVisitClosureExpression),
    ("testVisitExplicitMemberExpression", testVisitExplicitMemberExpression),
    ("testVisitForcedValueExpression", testVisitForcedValueExpression),
    ("testVisitFunctionCallExpression", testVisitFunctionCallExpression),
    ("testVisitIdentifierExpression", testVisitIdentifierExpression),
    ("testVisitImplicitMemberExpression", testVisitImplicitMemberExpression),
    ("testVisitInOutExpression", testVisitInOutExpression),
    ("testVisitInitializerExpression", testVisitInitializerExpression),
    ("testVisitKeyPathStringExpression", testVisitKeyPathStringExpression),
    ("testVisitLiteralExpression", testVisitLiteralExpression),
    ("testVisitOptionalChainingExpression", testVisitOptionalChainingExpression),
    ("testVisitParenthesizedExpression", testVisitParenthesizedExpression),
    ("testVisitPostfixOperatorExpression", testVisitPostfixOperatorExpression),
    ("testVisitPostfixSelfExpression", testVisitPostfixSelfExpression),
    ("testVisitPrefixOperatorExpression", testVisitPrefixOperatorExpression),
    ("testVisitSelectorExpression", testVisitSelectorExpression),
    ("testVisitSelfExpression", testVisitSelfExpression),
    ("testVisitSubscriptExpression", testVisitSubscriptExpression),
    ("testVisitSuperclassExpression", testVisitSuperclassExpression),
    ("testVisitTernaryConditionalOperatorExpression", testVisitTernaryConditionalOperatorExpression),
    ("testVisitTryOperatorExpression", testVisitTryOperatorExpression),
    ("testVisitTupleExpression", testVisitTupleExpression),
    ("testVisitTypeCastingOperatorExpression", testVisitTypeCastingOperatorExpression),
    ("testVisitWildcardExpression", testVisitWildcardExpression),
  ]
}
