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

public class GenericArgumentClause {
    public let types: [Type]

    public init(types: [Type]) {
        self.types = types
    }

    public func inspect() -> String {
        return ""
    }
}

public class GenericParameterClause {
    public class GenericParameter {
        public let typeName: TypeName
        public let typeIdentifier: TypeIdentifier?
        public let protocolCompositionType: ProtocolCompositionType?

        public init(typeName: TypeName, typeIdentifier: TypeIdentifier? = nil, protocolCompositionType: ProtocolCompositionType? = nil) {
            self.typeName = typeName
            self.typeIdentifier = typeIdentifier
            self.protocolCompositionType = protocolCompositionType
        }
    }

    public class Requirement {
        public enum RequirementType: String {
            case Conformance
            case SameType
        }

        public let requirementType: RequirementType
        public let typeIdentifier: TypeIdentifier
        public let type: Type

        public init(requirementType: RequirementType, typeIdentifier: TypeIdentifier, type: Type) {
            self.requirementType = requirementType
            self.typeIdentifier = typeIdentifier
            self.type = type
        }
    }

    public let parameters: [GenericParameter]
    public let requirements: [Requirement]

    public init(parameters: [GenericParameter], requirements: [Requirement] = []) {
        self.parameters = parameters
        self.requirements = requirements
    }

    public func inspect() -> String {
        return ""
    }
}
