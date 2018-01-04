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

extension Token.Kind {
  public static let dummyIdentifier: Token.Kind = .identifier("", false)
  public static let dummyIntegerLiteral: Token.Kind = .integerLiteral(0, rawRepresentation: "")
  public static let dummyFloatingPointLiteral: Token.Kind = .floatingPointLiteral(0, rawRepresentation: "")
  public static let dummyBooleanLiteral: Token.Kind = .booleanLiteral(true)
  public static let dummyStaticStringLiteral: Token.Kind = .staticStringLiteral("", rawRepresentation: "")
  public static let dummyInterpolatedStringLiteralHead: Token.Kind =
    .interpolatedStringLiteralHead("", rawRepresentation: "")
  public static let dummyImplicitParameterName: Token.Kind = .implicitParameterName(0)
  public static let dummyPrefixOperator: Token.Kind = .prefixOperator("")
  public static let dummyBinaryOperator: Token.Kind = .binaryOperator("")
  public static let dummyPostfixOperator: Token.Kind = .postfixOperator("")
}
