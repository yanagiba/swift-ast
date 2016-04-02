/*
   Copyright 2015 Ryuichi Saito, LLC

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

public enum ImportKind: String {
  case Module

  case Typealias
  case Struct
  case Class
  case Enum
  case `Protocol`
  case Var
  case Func
}

public class ImportDeclaration: Declaration {
    private let _module: String
    private let _submodules: [String]
    private let _importKind: ImportKind
    private let _attributes: [Attribute]

    public init(module: String, submodules: [String] = [], importKind: ImportKind = .Module, attributes: [Attribute] = []) {
        _module = module
        _submodules = submodules
        _importKind = importKind
        _attributes = attributes

        super.init()
    }

    public var module: String {
        return _module
    }

    public var attributes: [Attribute] {
        return _attributes
    }

    public var submodules: [String] {
        return _submodules
    }

    public var importKind: ImportKind {
        return _importKind
    }

    public override func inspect(indent: Int = 0) -> String {
        var modules = _module
        for submodule in _submodules {
            modules += ".\(submodule)"
        }
        var attrs = ""
        if !_attributes.isEmpty {
            let attrList = _attributes.map({ return $0.name }).joined(separator: ",")
            attrs = " attributes=\(attrList)"
        }
        return "\(getIndentText(indent))(import-declaration '\(modules)' kind=\(importKind)\(attrs) \(getSourceRangeText()))".terminalColor(.Green)
    }
}
