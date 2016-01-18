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

public class TypeAliasDeclaration: Declaration {
    public let name: String
    public let type: Type
    public let accessLevel: AccessLevel
    public let attributes: [Attribute]

    public init(
        name: String,
        type: Type,
        attributes: [Attribute] = [],
        accessLevel: AccessLevel = .Default) {
        self.name = name
        self.type = type
        self.attributes = attributes
        self.accessLevel = accessLevel

        super.init()
    }

    public override func inspect(indent: Int = 0) -> String {
        var attrs = ""
        if !attrs.isEmpty {
            attrs = " attribtues=\(attributes.map({ return $0.name }).joinWithSeparator(","))"
        }
        return "\(getIndentText(indent))(type-alias-declaration '\(name)'\(attrs) access='\(accessLevel)' type='\(type.inspect())'\(getSourceRangeText()))".terminalColor(.Green)
    }
}
