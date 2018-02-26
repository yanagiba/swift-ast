/*
   Copyright 2016-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

import Source
import AST
import Lexer

extension Parser {
  func parseGenericParameterClause() throws -> GenericParameterClause? {
    guard _matchLeftChevron() else {
      return nil
    }
    var parameters: [GenericParameterClause.GenericParameter] = []
    repeat {
      let param = try parseGenericParameter()
      parameters.append(param)
    } while _lexer.match(.comma)
    try assert(_matchRightChevron(), orError: .expectedRightChevron("generic parameter list"))
    return GenericParameterClause(parameterList: parameters)
  }

  private func parseGenericParameter() throws -> GenericParameterClause.GenericParameter {
    guard let name = readNamedIdentifier() else {
      throw _raiseFatal(.expectedGenericsParameterName)
    }
    guard _lexer.match(.colon) else {
      return .identifier(name)
    }
    let typeTokenRange = getLookedRange()
    switch _lexer.read([.dummyIdentifier, .protocol, .Any]) {
    case .identifier(let idTypeName, false):
      let firstType = try parseIdentifierType(.name(idTypeName), typeTokenRange)
      if testAmp() {
        let type = try parseProtocolCompositionType(firstType)
        return .protocolConformance(name, type)
      } else {
        return .typeConformance(name, firstType)
      }
    case .protocol:
      let type = try parseOldSyntaxProtocolCompositionType(typeTokenRange.start)
      return .protocolConformance(name, type)
    case .Any:
      // TODO: should we do it this way,
      // or allow .typeConformance to take any `Type` type
      let typeName = TypeIdentifier.TypeName(name: .name("Any"))
      let typeIdentifierForAny = TypeIdentifier(names: [typeName])
      return .typeConformance(name, typeIdentifierForAny)
    default:
      throw _raiseFatal(.expectedGenericTypeRestriction(name.textDescription))
    }
  }

  func parseGenericWhereClause() throws -> GenericWhereClause? {
    guard _lexer.match(.where) else {
      return nil
    }
    var requirements: [GenericWhereClause.Requirement] = []
    repeat {
      let requirement = try parseRequirement()
      requirements.append(requirement)
    } while _lexer.match(.comma)
    return GenericWhereClause(requirementList: requirements)
  }

  private func parseRequirement() throws -> GenericWhereClause.Requirement {
    let idTypeRange = getLookedRange()
    let idTypeName: Identifier
    switch _lexer.read([.dummyIdentifier, .Self]) {
    case .identifier(let id, _):
      idTypeName = .name(id)
    case .Self:
      idTypeName = .name("Self")
    default:
      throw _raiseFatal(.expectedGenericRequirementName)
    }

    let idType = try parseIdentifierType(idTypeName, idTypeRange)
    switch _lexer.read([.colon, .dummyBinaryOperator]) {
    case .colon:
      let typeStartLocation = getStartLocation()
      if let name = readNamedIdentifier() {
        let firstType = try parseIdentifierType(name, idTypeRange)
        if testAmp() {
          let type = try parseProtocolCompositionType(firstType)
          return .protocolConformance(idType, type)
        } else {
          return .typeConformance(idType, firstType)
        }
      } else if _lexer.match(.protocol) {
        let type = try parseOldSyntaxProtocolCompositionType(typeStartLocation)
        return .protocolConformance(idType, type)
      } else {
        throw _raiseFatal(.expectedGenericTypeRestriction(idType.textDescription))
      }
    case .binaryOperator("=="):
      let type = try parseType()
      return .sameType(idType, type)
    case .assignmentOperator:
      throw _raiseFatal(.requiresDoubleEqualForSameTypeRequirement)
    default:
      throw _raiseFatal(.expectedRequirementDelimiter)
    }
  }

  func parseGenericArgumentClause() -> GenericArgumentClause? {
    let openChevronCp = _lexer.checkPoint()
    let openChevronDiagnosticCp = _diagnosticPool.checkPoint()

    let startLocation = getStartLocation()
    guard _matchLeftChevron() else {
      return nil
    }

    var types: [Type] = []
    repeat {
      do {
        let type = try parseType()
        types.append(type)
      } catch {
        _lexer.restore(fromCheckpoint: openChevronCp)
        _diagnosticPool.restore(fromCheckpoint: openChevronDiagnosticCp)
        return nil
      }
    } while _lexer.match(.comma)

    let endLocation = getEndLocation()
    guard _matchRightChevron() else {
      _lexer.restore(fromCheckpoint: openChevronCp)
      _diagnosticPool.restore(fromCheckpoint: openChevronDiagnosticCp)
      return nil
    }

    var genericArg = GenericArgumentClause(argumentList: types)
    genericArg.sourceRange = SourceRange(start: startLocation, end: endLocation)
    return genericArg
  }

  private func _matchLeftChevron() -> Bool {
    return _lexer.matchUnicodeScalar("<", splitOperator: false)
  }

  private func _matchRightChevron() -> Bool {
    return _lexer.matchUnicodeScalar(">")
  }
}
