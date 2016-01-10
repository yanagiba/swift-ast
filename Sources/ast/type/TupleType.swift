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

public typealias ElementName = String

public class TupleTypeElement {
    public let name: ElementName?
    public let type: Type

    public init(type: Type, name: ElementName?) {
        self.name = name
        self.type = type
    }

    public convenience init(type: Type) {
        self.init(type: type, name: nil)
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
}
