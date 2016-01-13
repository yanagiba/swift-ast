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

public class EnumCaseElementDeclaration: Declaration {
    private let _name: String
    private let _rawValueString: String?
    private let _union: TupleType?

    public init(name: String, rawValue: String? = nil, union: TupleType? = nil) {
        _name = name
        _rawValueString = rawValue
        _union = union
    }

    public var name: String {
        return _name
    }

    public var rawValue: String? {
        return _rawValueString
    }

    public var union: TupleType? {
        return _union
    }

    public override func inspect(indent: Int = 0) -> String {
        var rawValueText = ""
        if let rawValueString = _rawValueString {
            rawValueText = " raw-value=\(rawValueString)"
        }
        var tupleTypeText = ""
        if let _ = _union {
            tupleTypeText = " union=(TODO)"
        }
        return "\(getIndentText(indent))(enum-case-element-declaration '\(_name)'\(tupleTypeText)\(rawValueText))".terminalColor(.Yellow)
    }
}

public class EnumCaseDelcaration: Declaration {
    private let _elements: [EnumCaseElementDeclaration]
    private let _attributes: [Attribute]
    private let _modifiers: [String]

    public init(elements: [EnumCaseElementDeclaration], attributes: [Attribute] = [], modifiers: [String] = []) {
        _elements = elements
        _attributes = attributes
        _modifiers = modifiers
    }

    public convenience init(element: EnumCaseElementDeclaration, attributes: [Attribute] = [], modifiers: [String] = []) {
        self.init(elements: [element], attributes: attributes, modifiers: modifiers)
    }

    public var elements: [EnumCaseElementDeclaration] {
        return _elements
    }

    public var attributes: [Attribute] {
        return _attributes
    }

    public var modifiers: [String] {
        return _modifiers
    }

    public override func inspect(indent: Int = 0) -> String {
        let attrs = toInspectionText(_attributes.map({ return $0.name }), "attributes")
        let mdfrs = toInspectionText(_modifiers, "modifiers")
        var inspectionText = "\(getIndentText(indent))(enum-case-declaration\(attrs)\(mdfrs)".terminalColor(.White)
        for element in _elements {
            inspectionText += "\n\(element.inspect(indent + 1))"
        }
        inspectionText += ")".terminalColor(.White)
        return inspectionText
    }
}

public class EnumDeclaration: Declaration {
    private let _name: String
    private let _genericParameter: GenericParameterClause?
    private let _accessLevel: AccessLevel
    private let _cases: [EnumCaseDelcaration]
    private let _attributes: [Attribute]
    private let _modifiers: [String]
    private let _typeInheritance: [String]

    public init(
        name: String,
        genericParameter: GenericParameterClause? = nil,
        cases: [EnumCaseDelcaration] = [],
        attributes: [Attribute] = [],
        modifiers: [String] = [],
        accessLevel: AccessLevel = .Default,
        typeInheritance: [String] = []) {
        _name = name
        _genericParameter = genericParameter
        _cases = cases
        _attributes = attributes
        _modifiers = modifiers
        _accessLevel = accessLevel
        _typeInheritance = typeInheritance

        super.init()
    }

    public var name: String {
        return _name
    }

    public var genericParameter: GenericParameterClause? {
        return _genericParameter
    }

    public var attributes: [Attribute] {
        return _attributes
    }

    public var modifiers: [String] {
        return _modifiers
    }

    public var accessLevel: AccessLevel {
        return _accessLevel
    }

    public var cases: [EnumCaseDelcaration] {
        return _cases
    }

    public var elements: [EnumCaseElementDeclaration] {
        return _cases.flatMap { $0.elements }
    }

    public var typeInheritance: [String] {
        return _typeInheritance
    }

    public override func inspect(indent: Int = 0) -> String {
        let attrs = toInspectionText(_attributes.map({ return $0.name }), "attributes")
        let mdfrs = toInspectionText(_modifiers, "modifiers")
        let inheritance = toInspectionText(_typeInheritance, "type-inheritance")
        var inspectionText = "\(getIndentText(indent))(enum-declaration '\(_name)'\(inheritance)\(attrs)\(mdfrs) access='\(_accessLevel)' \(getSourceRangeText())".terminalColor(.Green)
        for enumCase in _cases {
            inspectionText += "\n\(enumCase.inspect(indent + 1))"
        }
        inspectionText += ")".terminalColor(.Green)
        return inspectionText
    }
}

private func toInspectionText(array: [String], _ keyName: String) -> String {
    if array.isEmpty {
        return ""
    }

    let inspectionText = array.joinWithSeparator(",")
    return " \(keyName)=\(inspectionText)"
}
