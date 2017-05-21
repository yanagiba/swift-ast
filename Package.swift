/*
   Copyright 2015-2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

import PackageDescription

let package = Package(
  name: "swift-ast",
  targets: [
    Target(
      name: "Source"
    ),
    Target(
      name: "Diagnostic",
      dependencies: [
        "Source",
      ]
    ),
    Target(
      name: "AST",
      dependencies: [
        "Source",
        "Diagnostic",
      ]
    ),
    Target(
      name: "Lexer",
      dependencies: [
        "Source",
        "Diagnostic",
      ]
    ),
    Target(
      name: "Parser",
      dependencies: [
        "Source",
        "Diagnostic",
        "AST",
        "Lexer",
      ]
    ),
    Target(
      name: "Frontend",
      dependencies: [
        "AST",
        "Lexer",
        "Parser",
      ]
    ),
    Target(
      name: "swift-ast",
      dependencies: [
        "Frontend",
      ]
    ),

    // MARK: Tests

    Target(
      name: "CanaryTests"
    ),
    Target(
      name: "SourceTests",
      dependencies: [
        "Source",
      ]
    ),
    Target(
      name: "DiagnosticTests",
      dependencies: [
        "Diagnostic",
      ]
    ),
    Target(
      name: "ASTTests",
      dependencies: [
        "AST",
      ]
    ),
    Target(
      name: "ASTVisitorTests",
      dependencies: [
        "AST",
      ]
    ),
    Target(
      name: "LexerTests",
      dependencies: [
        "Lexer",
      ]
    ),
    Target(
      name: "ParserTests",
      dependencies: [
        "Parser",
      ]
    ),
    Target(
      name: "IntegrationTests",
      dependencies: [
        "Frontend",
      ]
    ),
  ]
)
