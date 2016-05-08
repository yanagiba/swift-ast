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

public typealias ElementName = String

public class TupleTypeElement {
    public let name: ElementName?
    public let type: Type
    public let attributes: [Attribute]
    public let isInOutParameter: Bool

    public init(type: Type, name: ElementName? = nil, attributes: [Attribute] = [], isInOutParameter: Bool = false) {
        self.name = name
        self.type = type
        self.attributes = attributes
        self.isInOutParameter = isInOutParameter
    }

    public func inspect() -> String {
        let attr = attributes.isEmpty ? "" : "\(attributes.map { "@\($0.name)" }.joined(separator: " ")) "
        let inoutStr = isInOutParameter ? "inout " : ""
        let nameStr = name == nil ? "" : "\(name): "
        return "\(attr)\(inoutStr)\(nameStr)\(type.inspect())"
    }
}

public class TupleType: Type {
    private let _elements: [TupleTypeElement]

    public init(elements: [TupleTypeElement]) {
        _elements = elements
    }

    public var elements: [TupleTypeElement] {
        return _elements
    }

    public func inspect() -> String {
        return "(\(_elements.map { $0.inspect() }.joined(separator: ", ")))"
    }
}
