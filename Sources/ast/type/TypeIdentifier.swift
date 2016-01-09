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

public typealias TypeName = String

public class NamedType {
    public let name: TypeName
    public let generic: GenericArgumentClause?

    public init(name: TypeName, generic: GenericArgumentClause?) {
        self.name = name
        self.generic = generic
    }

    public convenience init(name: TypeName) {
        self.init(name: name, generic: nil)
    }
}

public class TypeIdentifier: Type {
    private let _namedType: [NamedType]

    public init(namedTypes: [NamedType]) {
        _namedType = namedTypes
    }

    public var namedTypes: [NamedType] {
        return _namedType
    }

    public var names: [TypeName] {
        return _namedType.map({ $0.name })
    }
}
