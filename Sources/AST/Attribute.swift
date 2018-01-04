/*
   Copyright 2017-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

public struct Attribute {
  public struct ArgumentClause {
    public enum BalancedToken {
      public typealias AnyString = String // Note: explicitly allow this to be any string

      case token(AnyString)
      case parenthesis([BalancedToken])
      case square([BalancedToken])
      case brace([BalancedToken])
    }

    public let balancedTokens: [BalancedToken]

    public init(balancedTokens: [BalancedToken] = []) {
      self.balancedTokens = balancedTokens
    }
  }

  public let name: Identifier
  public let argumentClause: ArgumentClause?

  public init(name: Identifier, argumentClause: ArgumentClause? = nil) {
    self.name = name
    self.argumentClause = argumentClause
  }
}

extension Collection where Iterator.Element == Attribute.ArgumentClause.BalancedToken {
  public var textDescription: String {
    return self.map({ $0.textDescription }).joined()
  }
}

extension Attribute.ArgumentClause.BalancedToken : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .token(let tokenString):
      return tokenString
    case .parenthesis(let tokens):
      return "(\(tokens.textDescription))"
    case .square(let tokens):
      return "[\(tokens.textDescription)]"
    case .brace(let tokens):
      return "{\(tokens.textDescription)}"
    }
  }
}

extension Attribute.ArgumentClause : ASTTextRepresentable {
  public var textDescription: String {
    return "(\(balancedTokens.textDescription))"
  }
}

extension Attribute : ASTTextRepresentable {
  public var textDescription: String {
    return "@\(name)\(argumentClause?.textDescription ?? "")"
  }
}
