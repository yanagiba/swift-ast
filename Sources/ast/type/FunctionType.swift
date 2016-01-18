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

import source

public enum FunctionThrowingMarker: String { // TODO: this needs to be re-considered when work on function declaration
    case Throwing
    case Rethrowing
    case Nothrowing
}

public class FunctionType: Type {
    private let _parameter: Type
    private let _return: Type
    private let _throwingMarker: FunctionThrowingMarker

    public init(parameterType: Type, returnType: Type, throwingMarker: FunctionThrowingMarker) {
        _parameter = parameterType
        _return = returnType
        _throwingMarker = throwingMarker
    }

    public convenience init(parameterType: Type, returnType: Type) {
        self.init(parameterType: parameterType, returnType: returnType, throwingMarker: .Nothrowing)
    }

    public var parameterType: Type {
        return _parameter
    }

    public var returnType: Type {
        return _return
    }

    public var throwingMarker: FunctionThrowingMarker {
        return _throwingMarker
    }

    public func inspect() -> String {
        var throwingStr: String
        switch _throwingMarker {
        case .Throwing:
            throwingStr = " throws"
        case .Rethrowing:
            throwingStr = " rethrows"
        default:
            throwingStr = ""
        }
        return "(\(_parameter.inspect())\(throwingStr) -> \(_return.inspect()))"
    }
}
