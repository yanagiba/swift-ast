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
import ast

extension Parser {
    /*
    type →
    - [x] array-type |
    - [x] dictionary-type |
    - [x] function-type |
    - [x] type-identifier |
    - [ ] tuple-type |
    - [x] optional-type |
    - [x] implicitly-unwrapped-optional-type |
    - [ ] protocol-composition-type |
    - [ ] metatype-type
    */
    func parseType() throws -> Type {
        let result = parseType(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let type = result.type else {
            throw ParserError.InternalError // TODO: better error handling
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return type
    }

    private func parseType(head: Token?, tokens: [Token]) -> (type: Type?, advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        var usedTokens = [Token]()

        let atomicTypeResult = parseAtomicType(remainingHeadToken, tokens: remainingTokens)
        if let atomicType = atomicTypeResult.type {
            var resultType = atomicType

            for _ in 0..<atomicTypeResult.advancedBy {
                if let usedToken = remainingHeadToken {
                    usedTokens.append(usedToken)
                }
                remainingHeadToken = remainingTokens.popLast()
            }

            // see if the type is wrapped into optional types
            let isLastUsedTokenWhitespace = usedTokens.popLast()?.isWhitespace() ?? false
            if let token = remainingHeadToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .Question && !isLastUsedTokenWhitespace {
                resultType = OptionalType(type: resultType)

                remainingTokens = skipWhitespacesForTokens(remainingTokens)
                remainingHeadToken = remainingTokens.popLast()
            }
            else if let token = remainingHeadToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .Exclaim && !isLastUsedTokenWhitespace {
                resultType = ImplicitlyUnwrappedOptionalType(type: resultType)

                remainingTokens = skipWhitespacesForTokens(remainingTokens)
                remainingHeadToken = remainingTokens.popLast()
            }
            else if let token = remainingHeadToken, case let .Operator(operatorString) = token {
                for eachOperator in operatorString.characters {
                    if eachOperator == "!" {
                        resultType = ImplicitlyUnwrappedOptionalType(type: resultType)
                    }
                    else if eachOperator == "?" {
                        resultType = OptionalType(type: resultType)
                    }
                    else {
                        // TODO: error handling
                    }
                }

                remainingTokens = skipWhitespacesForTokens(remainingTokens)
                remainingHeadToken = remainingTokens.popLast()
            }

            // check to see if it is a function type
            var functionThrowingMarker: FunctionThrowingMarker = .Nothrowing
            if let token = remainingHeadToken, case let .Keyword(keywordName, _) = token where keywordName == "throws" || keywordName == "rethrows" {
                if keywordName == "throws" {
                    functionThrowingMarker = .Throwing
                }
                else {
                    functionThrowingMarker = .Rethrowing
                }

                remainingTokens = skipWhitespacesForTokens(remainingTokens)
                remainingHeadToken = remainingTokens.popLast()
            }
            if let token = remainingHeadToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .Arrow {
                remainingTokens = skipWhitespacesForTokens(remainingTokens)
                remainingHeadToken = remainingTokens.popLast()

                let returnTypeResult = parseType(remainingHeadToken, tokens: remainingTokens)
                if let returnType = returnTypeResult.type {
                    resultType = FunctionType(parameterType: resultType, returnType: returnType, throwingMarker: functionThrowingMarker)

                    for _ in 0..<returnTypeResult.advancedBy {
                        remainingHeadToken = remainingTokens.popLast()
                    }
                    remainingHeadToken = remainingTokens.popLast()
                }
            }

            return (resultType, tokens.count - remainingTokens.count)
        }

        return (nil, 0)
    }

    // TODO: give a better name, currently it parses type identifier, array type, dictionary type,
    // TODO: tuple type, protocol composition type, and metatype type
    private func parseAtomicType(head: Token?, tokens: [Token]) -> (type: Type?, advancedBy: Int) {
        let dictTypeResult = parseDictionaryType(head, tokens: tokens)
        if let dictType = dictTypeResult.dictionaryType {
            return (dictType, dictTypeResult.advancedBy)
        }

        let arrayTypeResult = parseArrayType(head, tokens: tokens)
        if let arrayType = arrayTypeResult.arrayType {
            return (arrayType, arrayTypeResult.advancedBy)
        }

        let protocolCompositionTypeResult = parseProtocolCompositionType(head, tokens: tokens)
        if let protocolCompositionType = protocolCompositionTypeResult.protocolCompositionType {
            return (protocolCompositionType, protocolCompositionTypeResult.advancedBy)
        }

        let typeIdentifierResult = parseTypeIdentifier(head, tokens: tokens)
        if let typeIdentifier = typeIdentifierResult.typeIdentifier {
            return (typeIdentifier, typeIdentifierResult.advancedBy)
        }

        return (nil, 0)
    }

    /*
    - [_] type-identifier → type-name generic-argument-clause/opt/ | type-name generic-argument-clause/opt/ `.` type-identifier
    - [x] type-name → identifier
    */
    func parseTypeIdentifier() throws -> TypeIdentifier {
        let result = parseTypeIdentifier(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let typeIdentifier = result.typeIdentifier else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return typeIdentifier
    }

    private func parseTypeIdentifier(head: Token?, tokens: [Token]) -> (typeIdentifier: TypeIdentifier?, advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        guard let typeName = readIdentifier(includeContextualKeywords: true, forToken: remainingHeadToken) else {
            return (nil, 0)
        }
        remainingTokens = skipWhitespacesForTokens(remainingTokens)
        remainingHeadToken = remainingTokens.popLast()

        var namedTypes = [NamedType]()
        namedTypes.append(NamedType(name: typeName))

        while let token = remainingHeadToken {
            if case let .Punctuator(type) = token where type == .Period {
                remainingTokens = skipWhitespacesForTokens(remainingTokens)
                remainingHeadToken = remainingTokens.popLast()
                if let subTypeName = readIdentifier(includeContextualKeywords: true, forToken: remainingHeadToken) {
                    namedTypes.append(NamedType(name: subTypeName))
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    continue
                }
            }
            break
        }

        return (TypeIdentifier(namedTypes: namedTypes), tokens.count - remainingTokens.count)
    }

    /*
    - [x] array-type → `[` type `]`
    */
    func parseArrayType() throws -> ArrayType {
        let result = parseArrayType(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let arrayType = result.arrayType else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return arrayType
    }

    private func parseArrayType(head: Token?, tokens: [Token]) -> (arrayType: ArrayType?, advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let token = remainingHeadToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .LeftSquare {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            let typeResult = parseType(remainingHeadToken, tokens: remainingTokens)
            if let type = typeResult.type {
                for _ in 0..<typeResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                if let token = remainingHeadToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .RightSquare {
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    return (ArrayType(type: type), tokens.count - remainingTokens.count)
                }
            }
        }

        return (nil, 0)
    }

    /*
    - [x] dictionary-type → `[` type `:` type `]`
    */
    func parseDictionaryType() throws -> DictionaryType {
        let result = parseDictionaryType(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let dictionaryType = result.dictionaryType else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return dictionaryType
    }

    private func parseDictionaryType(head: Token?, tokens: [Token]) -> (dictionaryType: DictionaryType?, advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let token = remainingHeadToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .LeftSquare {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            let keyTypeResult = parseType(remainingHeadToken, tokens: remainingTokens)
            if let keyType = keyTypeResult.type {
                for _ in 0..<keyTypeResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                if let token = remainingHeadToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .Colon {
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    let valueTypeResult = parseType(remainingHeadToken, tokens: remainingTokens)
                    if let valueType = valueTypeResult.type {
                        for _ in 0..<valueTypeResult.advancedBy {
                            remainingHeadToken = remainingTokens.popLast()
                        }

                        if let token = remainingHeadToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .RightSquare {
                            remainingTokens = skipWhitespacesForTokens(remainingTokens)
                            remainingHeadToken = remainingTokens.popLast()
                            return (DictionaryType(keyType: keyType, valueType: valueType), tokens.count - remainingTokens.count)
                        }
                    }
                }
            }
        }

        return (nil, 0)
    }

    /*
    - [x] protocol-composition-type → `protocol` `<` protocol-identifier-list/opt/ `>`
    - [x] protocol-identifier-list → protocol-identifier | protocol-identifier `,` protocol-identifier-list
    - [x] protocol-identifier → type-identifier
    */
    func parseProtocolCompositionType() throws -> ProtocolCompositionType {
        let result = parseProtocolCompositionType(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let protocolCompositionType = result.protocolCompositionType else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return protocolCompositionType
    }

    private func parseProtocolCompositionType(head: Token?, tokens: [Token]) -> (protocolCompositionType: ProtocolCompositionType?, advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let token = remainingHeadToken, case let .Keyword(keywordName, _) = token where keywordName == "protocol" {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            if let token = remainingHeadToken, case let .Operator(operatorString) = token where operatorString == "<>" {
                remainingTokens = skipWhitespacesForTokens(remainingTokens)
                remainingHeadToken = remainingTokens.popLast()

                return (ProtocolCompositionType(protocols: []), tokens.count - remainingTokens.count)
            }

            if let token = remainingHeadToken, case let .Operator(operatorString) = token where operatorString == "<" {
                remainingTokens = skipWhitespacesForTokens(remainingTokens)
                remainingHeadToken = remainingTokens.popLast()

                var protocolIdentifiers = [TypeIdentifier]()
                let firstProtocolIdentifierResult = parseTypeIdentifier(remainingHeadToken, tokens: remainingTokens)
                if let firstProtocolIdentifier = firstProtocolIdentifierResult.typeIdentifier {
                    protocolIdentifiers.append(firstProtocolIdentifier)

                    for _ in 0..<firstProtocolIdentifierResult.advancedBy {
                        remainingHeadToken = remainingTokens.popLast()
                    }

                    while let token = remainingHeadToken {
                        if case let .Punctuator(type) = token where type == .Comma {
                            remainingTokens = skipWhitespacesForTokens(remainingTokens)
                            remainingHeadToken = remainingTokens.popLast()

                            let protocolIdentifierResult = parseTypeIdentifier(remainingHeadToken, tokens: remainingTokens)
                            if let protocolIdentifier = protocolIdentifierResult.typeIdentifier {
                                protocolIdentifiers.append(protocolIdentifier)

                                for _ in 0..<protocolIdentifierResult.advancedBy {
                                    remainingHeadToken = remainingTokens.popLast()
                                }

                                continue
                            }
                        }
                        break
                    }
                }

                if let token = remainingHeadToken, case let .Operator(operatorString) = token where operatorString == ">" {
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    return (ProtocolCompositionType(protocols: protocolIdentifiers), tokens.count - remainingTokens.count)
                }
            }
        }

        return (nil, 0)
    }

    /*
    - [x] optional-type → type `?`
    */
    func parseOptionalType() throws -> OptionalType {
        let result = parseType(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let optionalType = result.type as? OptionalType else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return optionalType
    }

    /*
    - [x] implicitly-unwrapped-optional-type → type `!`
    */
    func parseImplicitlyUnwrappedOptionalType() throws -> ImplicitlyUnwrappedOptionalType {
        let result = parseType(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let implicitlyUnwrappedOptionalType = result.type as? ImplicitlyUnwrappedOptionalType else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return implicitlyUnwrappedOptionalType
    }

    /*
    - [x] function-type → type `throws`/opt/ `->` type
    - [x] function-type → type `rethrows` `->` type
    */
    func parseFunctionType() throws -> FunctionType {
        let result = parseType(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let functionType = result.type as? FunctionType else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return functionType
    }

    /*
    - [x] type-inheritance-clause → : class-requirement , type-inheritance-list
    - [x] type-inheritance-clause → : class-requirement
    - [x] type-inheritance-clause → : type-inheritance-list
    - [x] type-inheritance-list → type-identifier | type-identifier , type-inheritance-list
    - [x] class-requirement → class
    */
    func parseTypeInheritanceClause() throws -> TypeInheritanceClause {
        guard let token = currentToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .Colon else {
            return []
        }
        skipWhitespaces()

        guard let typeIdentifier = parseEachTypeInheritance() else {
            throw ParserError.MissingIdentifier
        }

        var list = TypeInheritanceClause()
        list.append(typeIdentifier)

        while let token = currentToken {
            if case let .Punctuator(type) = token where type == .Comma {
                skipWhitespaces()
                if let typeIdentifier = parseEachTypeInheritance() {
                    list.append(typeIdentifier)
                    //skipWhitespaces()
                    continue
                }
            }
            break
        }

        return list
    }

    private func parseEachTypeInheritance() -> String? {
        if let token = currentToken, case let .Keyword(keywordName, _) = token where keywordName == "class" {
            skipWhitespaces()
            return "class"
        }
        else if let typeIdentifier = try? parseTypeIdentifier() {
            return typeIdentifier.names.joinWithSeparator(".")
        }
        else {
            return nil
        }
    }
}
