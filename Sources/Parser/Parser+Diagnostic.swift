/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

import Diagnostic

extension Parser {
  func _raiseFatal(_ kind: ParserErrorKind) -> Error {
    return _diagnosticPool.appendFatal(
      kind: kind, sourceLocatable: _lexer.look())
  }

  func _raiseError(_ kind: ParserErrorKind) throws {
    try _diagnosticPool.appendError(kind: kind, sourceLocatable: _lexer.look())
  }

  func _raiseWarning(_ kind: ParserErrorKind) throws {
    try _diagnosticPool.appendWarning(
      kind: kind, sourceLocatable: _lexer.look())
  }

  var _diagnosticPool: DiagnosticPool {
    return .shared
  }
}

public enum ParserErrorKind : DiagnosticKind {
  case dummy

  // attributes
  case attributeIdentifierExpected

  // code block
  case leftBraceExpectedForCodeBlock
  case rightBraceExpectedForCodeBlock

  // declarations
  case badDeclaration
  /// enum declaration
  case enumExpectedAfterIndirect
  /// protocol declaration
  case missingPropertyMemberName
  case missingTypeForPropertyMember

  case leftBraceExpectedForDeclarationBody
  case missingExtensionName
  case missingClassName
  case missingStructName
  case indirectWithRawValueStyle
  case missingEnumName
  case leftBraceExpectedForEnumCase
  case missingTypealiasName

  public var diagnosticMessage: String {
    switch self {
    case .dummy:
      return "Dummy diagnostic message"
    case .attributeIdentifierExpected:
      return "Expected an attribute identifier"
    case .leftBraceExpectedForCodeBlock:
      return "Missing opening brace for code block"
    case .rightBraceExpectedForCodeBlock:
      return "Missing closing brace for code block"
    case .badDeclaration:
      return "Failed in parsing a declaration"
    case .enumExpectedAfterIndirect:
      return "Missing `enum` keyword after `indirect` for indirect enumeration declaration"
    case .missingPropertyMemberName:
      return "Missing property member name"
    case .missingTypeForPropertyMember:
      return "Missing property member type"
    case .leftBraceExpectedForDeclarationBody:
      return "Missing opening brace for declaration body"
    case .missingExtensionName:
      return "Missing extension declaration name"
    case .missingClassName:
      return "Missing class declaration name"
    case .missingStructName:
      return "Missing struct declaration name"
    case .indirectWithRawValueStyle:
      return "`indirect` is invalid in raw-value style enum declaration"
    case .missingEnumName:
      return "Missing enum declaration name"
    case .leftBraceExpectedForEnumCase:
      return "Missing opening brace for enum case"
    case .missingTypealiasName:
      return "Missing typealias declaration name"
    }
  }
}
