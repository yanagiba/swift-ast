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

import AST

extension ImportDeclaration.Kind : EnumCases {}
extension AccessLevelModifier : EnumCases {}
extension MutationModifier : EnumCases {}

protocol EnumCases : Hashable {
  static var cases: [Self] { get }
}

extension EnumCases {
  static var cases: [Self] {
    return Array(AnySequence({ () -> AnyIterator<Self> in
      var raw = 0
      return AnyIterator({ () -> Self? in
        let current: Self = withUnsafePointer(to: &raw) {
          $0.withMemoryRebound(to: Self.self, capacity: 1) { $0.pointee }
        }
        guard current.hashValue == raw else {
          return nil
        }
        raw += 1
        return current
      })
    }))
  }
}
