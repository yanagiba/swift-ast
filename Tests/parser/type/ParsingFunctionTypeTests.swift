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

@testable import parser
@testable import ast

class ParsingFunctionTypeTests: XCTestCase {
  let parser = Parser()

  func testParseFunctionType() {
    parser.setupTestCode("foo -> bar")
    guard let functionType = try? parser.parseFunctionType() else {
      XCTFail("Failed in getting a function type.")
      return
    }
    guard let parameterType = functionType.parameterType as? TypeIdentifier, returnType = functionType.returnType as? TypeIdentifier else {
      XCTFail("Failed in getting type identifiers.")
      return
    }
    XCTAssertEqual(parameterType.names.count, 1)
    XCTAssertEqual(parameterType.names[0], "foo")
    XCTAssertEqual(returnType.names.count, 1)
    XCTAssertEqual(returnType.names[0], "bar")
    XCTAssertEqual(functionType.throwingMarker, FunctionThrowingMarker.Nothrowing)
  }

  func testParseFunctionTypeThatThrowsException() {
    parser.setupTestCode("foo throws -> bar")
    guard let functionType = try? parser.parseFunctionType() else {
      XCTFail("Failed in getting a function type.")
      return
    }
    guard let parameterType = functionType.parameterType as? TypeIdentifier, returnType = functionType.returnType as? TypeIdentifier else {
      XCTFail("Failed in getting type identifiers.")
      return
    }
    XCTAssertEqual(parameterType.names.count, 1)
    XCTAssertEqual(parameterType.names[0], "foo")
    XCTAssertEqual(returnType.names.count, 1)
    XCTAssertEqual(returnType.names[0], "bar")
    XCTAssertEqual(functionType.throwingMarker, FunctionThrowingMarker.Throwing)
  }

  func testParseFunctionTypeThatRethrowsException() {
    parser.setupTestCode("foo rethrows -> bar")
    guard let functionType = try? parser.parseFunctionType() else {
      XCTFail("Failed in getting a function type.")
      return
    }
    guard let parameterType = functionType.parameterType as? TypeIdentifier, returnType = functionType.returnType as? TypeIdentifier else {
      XCTFail("Failed in getting type identifiers.")
      return
    }
    XCTAssertEqual(parameterType.names.count, 1)
    XCTAssertEqual(parameterType.names[0], "foo")
    XCTAssertEqual(returnType.names.count, 1)
    XCTAssertEqual(returnType.names[0], "bar")
    XCTAssertEqual(functionType.throwingMarker, FunctionThrowingMarker.Rethrowing)
  }

  func testParseFunctionTypeThatReturnsFunctionType() { // a -> b -> c should be understood as a -> (b -> c)
    parser.setupTestCode("a -> b -> c")
    guard let outterFunctionType = try? parser.parseFunctionType() else {
      XCTFail("Failed in getting a function type.")
      return
    }
    guard let innerFunctionType = outterFunctionType.returnType as? FunctionType else {
      XCTFail("Failed in getting a function type.")
      return
    }
    guard let
      parameterType = outterFunctionType.parameterType as? TypeIdentifier,
      innerParameterType = innerFunctionType.parameterType as? TypeIdentifier,
      innerReturnType = innerFunctionType.returnType as? TypeIdentifier
    else {
      XCTFail("Failed in getting type identifiers.")
      return
    }
    XCTAssertEqual(parameterType.names.count, 1)
    XCTAssertEqual(parameterType.names[0], "a")
    XCTAssertEqual(innerParameterType.names.count, 1)
    XCTAssertEqual(innerParameterType.names[0], "b")
    XCTAssertEqual(innerReturnType.names.count, 1)
    XCTAssertEqual(innerReturnType.names[0], "c")
  }

  // TODO: more comprehensive tests for function type are needed
  // TODO: e.g. autoclosures, variadic parameters, in-out parameters, curried functions, etc, etc
}
