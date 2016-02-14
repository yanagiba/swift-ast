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
    - [x] generic-parameter-clause → `<` generic-parameter-list requirement-clause/opt/ `>`
    - [x] generic-parameter-list → generic-parameter | generic-parameter `,` generic-parameter-list
    - [x] generic-parameter → type-name
    - [x] generic-parameter → type-name `:` type-identifier
    - [x] generic-parameter → type-name `:` protocol-composition-type
    - [x] requirement-clause → `where` requirement-list
    - [x] requirement-list → requirement | requirement `,` requirement-list
    - [x] requirement → conformance-requirement | same-type-requirement
    - [x] conformance-requirement → type-identifier `:` type-identifier
    - [x] conformance-requirement → type-identifier `:` protocol-composition-type
    - [x] same-type-requirement → type-identifier `==` type
    */
    func parseGenericParameterClause() throws -> GenericParameterClause {
        let result = parseGenericParameterClause(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let genericParameterClause = result.genericParameterClause else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return genericParameterClause
    }

    func parseGenericParameterClause(head: Token?, tokens: [Token]) -> (genericParameterClause: GenericParameterClause?, advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let token = remainingHeadToken, case let .Operator(operatorString) = token where operatorString == "<" {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            var genericParameters: [GenericParameterClause.GenericParameter] = []

            let firstGenericParameterResult = parseGenericParameter(remainingHeadToken, tokens: remainingTokens)
            if let firstGenericParameter = firstGenericParameterResult.genericParameter {
                genericParameters.append(firstGenericParameter)

                for _ in 0..<firstGenericParameterResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                while let token = remainingHeadToken, case let .Punctuator(type) = token where type == .Comma {
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    let genericParameterResult = parseGenericParameter(remainingHeadToken, tokens: remainingTokens)
                    guard let genericParameter = genericParameterResult.genericParameter else {
                        // TODO: also throw errors
                        break
                    }
                    genericParameters.append(genericParameter)

                    for _ in 0..<genericParameterResult.advancedBy {
                        remainingHeadToken = remainingTokens.popLast()
                    }
                }

                let requirementClauseResult = parseRequirementClause(remainingHeadToken, tokens: remainingTokens)
                for _ in 0..<requirementClauseResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                if let token = remainingHeadToken, case let .Operator(operatorString) = token where operatorString == ">" {
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    return (GenericParameterClause(parameters: genericParameters, requirements: requirementClauseResult.requirementClause), tokens.count - remainingTokens.count)
                }
            }
            else {
                // TODO: error handling, at least one type is required
            }
        }

        return (nil, 0)
    }

    private func parseGenericParameter(head: Token?, tokens: [Token]) -> (genericParameter: GenericParameterClause.GenericParameter?, advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        guard let typeName = readIdentifier(includeContextualKeywords: true, forToken: remainingHeadToken) else {
            return (nil, 0)
        }
        remainingTokens = skipWhitespacesForTokens(remainingTokens)
        remainingHeadToken = remainingTokens.popLast()

        if let token = remainingHeadToken, case let .Punctuator(type) = token where type == .Colon {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            let typeIdentifierResult = parseTypeIdentifier(remainingHeadToken, tokens: remainingTokens)
            if let typeIdentifier = typeIdentifierResult.typeIdentifier {
                for _ in 0..<typeIdentifierResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }
                return (GenericParameterClause.GenericParameter(typeName: typeName, typeIdentifier: typeIdentifier), tokens.count - remainingTokens.count)
            }

            let protocolCompositionTypeResult = parseProtocolCompositionType(remainingHeadToken, tokens: remainingTokens)
            if let protocolCompositionType = protocolCompositionTypeResult.protocolCompositionType {
                for _ in 0..<protocolCompositionTypeResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }
                return (GenericParameterClause.GenericParameter(typeName: typeName, protocolCompositionType: protocolCompositionType), tokens.count - remainingTokens.count)
            }
        }

        return (GenericParameterClause.GenericParameter(typeName: typeName), tokens.count - remainingTokens.count)
    }

    private func parseRequirementClause(head: Token?, tokens: [Token]) -> (requirementClause: [GenericParameterClause.Requirement], advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        var requirementList: [GenericParameterClause.Requirement] = []

        if let token = remainingHeadToken, case let .Keyword(keywordName, _) = token where keywordName == "where" {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            let firstRequirementResult = parseRequirement(remainingHeadToken, tokens: remainingTokens)
            if let firstRequirement = firstRequirementResult.requirement {
                requirementList.append(firstRequirement)

                for _ in 0..<firstRequirementResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                while let token = remainingHeadToken, case let .Punctuator(type) = token where type == .Comma {
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    let requirementResult = parseRequirement(remainingHeadToken, tokens: remainingTokens)
                    guard let requirement = requirementResult.requirement else {
                        // TODO: also throw errors
                        break
                    }
                    requirementList.append(requirement)

                    for _ in 0..<requirementResult.advancedBy {
                        remainingHeadToken = remainingTokens.popLast()
                    }
                }
            }
            else {
                // TODO: error handling, at least one type is required
            }
        }

        return (requirementList, tokens.count - remainingTokens.count)
    }

    private func parseRequirement(head: Token?, tokens: [Token]) -> (requirement: GenericParameterClause.Requirement?, advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        let typeIdentifierResult = parseTypeIdentifier(remainingHeadToken, tokens: remainingTokens)
        guard let typeIdentifier = typeIdentifierResult.typeIdentifier else {
            return (nil, 0)
        }
        for _ in 0..<typeIdentifierResult.advancedBy {
            remainingHeadToken = remainingTokens.popLast()
        }

        if let token = remainingHeadToken, case let .Punctuator(type) = token where type == .Colon {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            let conformanceTypeIdentifierResult = parseTypeIdentifier(remainingHeadToken, tokens: remainingTokens)
            if let conformanceTypeIdentifier = conformanceTypeIdentifierResult.typeIdentifier {
                for _ in 0..<conformanceTypeIdentifierResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }
                let requirement = GenericParameterClause.Requirement(
                    requirementType: .Conformance, typeIdentifier: typeIdentifier, type: conformanceTypeIdentifier)
                return (requirement, tokens.count - remainingTokens.count)
            }

            let conformanceProtocolCompositionTypeResult = parseProtocolCompositionType(remainingHeadToken, tokens: remainingTokens)
            if let conformanceProtocolCompositionType = conformanceProtocolCompositionTypeResult.protocolCompositionType {
                for _ in 0..<conformanceProtocolCompositionTypeResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }
                let requirement = GenericParameterClause.Requirement(
                    requirementType: .Conformance, typeIdentifier: typeIdentifier, type: conformanceProtocolCompositionType)
                return (requirement, tokens.count - remainingTokens.count)
            }
        }

        if let token = remainingHeadToken, case let .Operator(operatorString) = token where operatorString == "==" {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            let sameTypeResult = parseType(remainingHeadToken, tokens: remainingTokens)
            guard let sameType = sameTypeResult.type else {
                return (nil, 0) // TODO: error handling
            }

            for _ in 0..<sameTypeResult.advancedBy {
                remainingHeadToken = remainingTokens.popLast()
            }

            let requirement = GenericParameterClause.Requirement(
                requirementType: .SameType, typeIdentifier: typeIdentifier, type: sameType)
            return (requirement, tokens.count - remainingTokens.count)
        }

        return (nil, 0)
    }

    /*
    - [x] generic-argument-clause → `<` generic-argument-list `>`
    - [x] generic-argument-list → generic-argument | generic-argument `,` generic-argument-list
    - [x] generic-argument → type
    */
    func parseGenericArgumentClause() throws -> GenericArgumentClause {
        let result = parseGenericArgumentClause(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let genericArgumentClause = result.genericArgumentClause else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return genericArgumentClause
    }

    func parseGenericArgumentClause(head: Token?, tokens: [Token]) -> (genericArgumentClause: GenericArgumentClause?, advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let token = remainingHeadToken, case let .Operator(operatorString) = token where operatorString == "<" {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            var types = [Type]()
            let firstTypeResult = parseType(remainingHeadToken, tokens: remainingTokens)
            if let firstType = firstTypeResult.type {
                types.append(firstType)

                for _ in 0..<firstTypeResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                while let token = remainingHeadToken, case let .Punctuator(type) = token where type == .Comma {
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    let typeResult = parseType(remainingHeadToken, tokens: remainingTokens)
                    guard let type = typeResult.type else {
                        break
                    }
                    types.append(type)

                    for _ in 0..<typeResult.advancedBy {
                        remainingHeadToken = remainingTokens.popLast()
                    }
                }

                if let token = remainingHeadToken, case let .Operator(operatorString) = token where operatorString == ">" {
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    return (GenericArgumentClause(types: types), tokens.count - remainingTokens.count - (remainingHeadToken == nil ? 1 : 0))
                }
            }
            else {
                // TODO: error handling, at least one type is required
            }
        }

        return (nil, 0)
    }

}
