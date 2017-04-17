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

public class CompilerControlStatement : ASTNode, Statement {
  // TODO: the structure of this should be similar to an if statement,
  // that each clause should contains a list of statements,
  // but for now, each clause will be treated as one statement,
  // and flattly saved along with other statements.
  public enum Kind {
    // conditional compilation block
    case `if`(String)
    case elseif(String)
    case `else`
    case endif

    // line control
    case sourceLocation(String?, Int?)
  }

  public let kind: Kind

  public init(kind: Kind) {
    self.kind = kind
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    switch self.kind {
    case .if(let condition):
      return "#if\(condition)"
    case .elseif(let condition):
      return "#elseif\(condition)"
    case .else:
      return "#else"
    case .endif:
      return "#endif"
    case let .sourceLocation(fileName, lineNumber):
      if let fileName = fileName, let lineNumber = lineNumber {
        return "#sourceLocation(file: \"\(fileName)\", line: \(lineNumber))"
      }
      return "#sourceLocation()"
    }
  }
}
