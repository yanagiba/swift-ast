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

@testable import parser
@testable import ast

func specFunctionType() {
  let parser = Parser()

  describe("Parse a nothrowing function type") {
    $0.it("should return that function type") {
      parser.setupTestCode("foo -> bar")
      guard let functionType = try? parser.parseFunctionType() else {
        throw failure("Failed in getting a function type.")
      }
      guard let parameterType = functionType.parameterType as? TypeIdentifier, returnType = functionType.returnType as? TypeIdentifier else {
        throw failure("Failed in getting type identifiers.")
      }
      try expect(parameterType.names.count) == 1
      try expect(parameterType.names[0]) == "foo"
      try expect(returnType.names.count) == 1
      try expect(returnType.names[0]) == "bar"
      try expect(functionType.throwingMarker) == .Nothrowing
    }
  }

  describe("Parse a throwing function type") {
    $0.it("should return that function type with throws") {
      parser.setupTestCode("foo throws -> bar")
      guard let functionType = try? parser.parseFunctionType() else {
        throw failure("Failed in getting a function type.")
      }
      guard let parameterType = functionType.parameterType as? TypeIdentifier, returnType = functionType.returnType as? TypeIdentifier else {
        throw failure("Failed in getting type identifiers.")
      }
      try expect(parameterType.names.count) == 1
      try expect(parameterType.names[0]) == "foo"
      try expect(returnType.names.count) == 1
      try expect(returnType.names[0]) == "bar"
      try expect(functionType.throwingMarker) == .Throwing
    }
  }

  describe("Parse a rethrowing function type") {
    $0.it("should return that function type with throws") {
      parser.setupTestCode("foo rethrows -> bar")
      guard let functionType = try? parser.parseFunctionType() else {
        throw failure("Failed in getting a function type.")
      }
      guard let parameterType = functionType.parameterType as? TypeIdentifier, returnType = functionType.returnType as? TypeIdentifier else {
        throw failure("Failed in getting type identifiers.")
      }
      try expect(parameterType.names.count) == 1
      try expect(parameterType.names[0]) == "foo"
      try expect(returnType.names.count) == 1
      try expect(returnType.names[0]) == "bar"
      try expect(functionType.throwingMarker) == .Rethrowing
    }
  }

  describe("Parse a function type like a -> b -> c") {
    $0.it("should be understood as a -> (b -> c)") {
      parser.setupTestCode("a -> b -> c")
      guard let outterFunctionType = try? parser.parseFunctionType() else {
        throw failure("Failed in getting a function type.")
      }
      guard let innerFunctionType = outterFunctionType.returnType as? FunctionType else {
        throw failure("Failed in getting a function type.")
      }
      guard let
        parameterType = outterFunctionType.parameterType as? TypeIdentifier,
        innerParameterType = innerFunctionType.parameterType as? TypeIdentifier,
        innerReturnType = innerFunctionType.returnType as? TypeIdentifier
      else {
        throw failure("Failed in getting type identifiers.")
      }
      try expect(parameterType.names.count) == 1
      try expect(parameterType.names[0]) == "a"
      try expect(innerParameterType.names.count) == 1
      try expect(innerParameterType.names[0]) == "b"
      try expect(innerReturnType.names.count) == 1
      try expect(innerReturnType.names[0]) == "c"
    }
  }

  // TODO: more comprehensive tests for function type are needed
  // TODO: e.g. autoclosures, variadic parameters, in-out parameters, curried functions, etc, etc
}
