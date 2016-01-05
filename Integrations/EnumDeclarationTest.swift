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

enum EmptyEnum {}
@a @b @c enum EmptyEnumWithAttributes {}
public enum PublicEmptyEnum {}
@x private enum PrivateEmptyEnumWithAttributeX {}
enum foo {
  case A
}
enum bar {
  case a
  case X,
   Y
   , Z;case A,B,        C;case
   set
}
enum foo {
  case A = 1
  case B = "abc", C = false
}
indirect enum foo {}
@a indirect enum bar{}

internal (set) enum CannotApplyModifierEnum {}
weak enum A {}
lazy enum B {}
enum MissingSeparator { case A case B case C }

/*
Parser error: 'internal' modifier cannot be applied to this declaration.
Parser error: 'weak' modifier cannot be applied to this declaration.
Parser error: 'lazy' modifier cannot be applied to this declaration.
Parser error: Statements must be separated by line breaks or semicolons.

(top-level-declaration path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=1:1-89:1
  (enum-declaration 'EmptyEnum' access='default' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=17:1-17:18)
  (enum-declaration 'EmptyEnumWithAttributes' attributes=a,b,c access='default' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=18:1-18:41)
  (enum-declaration 'PublicEmptyEnum' access='public' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=19:1-19:31)
  (enum-declaration 'PrivateEmptyEnumWithAttributeX' attributes=x access='private' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=20:1-20:50)
  (enum-declaration 'foo' access='default' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=21:1-23:2
    (enum-case-declaration
      (enum-case-element-declaration 'A')))
  (enum-declaration 'bar' access='default' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=24:1-30:2
    (enum-case-declaration
      (enum-case-element-declaration 'a'))
    (enum-case-declaration
      (enum-case-element-declaration 'X')
      (enum-case-element-declaration 'Y')
      (enum-case-element-declaration 'Z'))
    (enum-case-declaration
      (enum-case-element-declaration 'A')
      (enum-case-element-declaration 'B')
      (enum-case-element-declaration 'C'))
    (enum-case-declaration
      (enum-case-element-declaration 'set')))
  (enum-declaration 'foo' access='default' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=31:1-34:2
    (enum-case-declaration
      (enum-case-element-declaration 'A' raw-value=1))
    (enum-case-declaration
      (enum-case-element-declaration 'B' raw-value=abc)
      (enum-case-element-declaration 'C' raw-value=false)))
  (enum-declaration 'foo' modifiers=indirect access='default' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=35:1-35:21)
  (enum-declaration 'bar' attributes=a modifiers=indirect access='default' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=36:1-36:23)
  (enum-declaration 'CannotApplyModifierEnum' access='default' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=38:1-38:47)
  (enum-declaration 'A' modifiers=weak access='default' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=39:1-39:15)
  (enum-declaration 'B' modifiers=lazy access='default' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=40:1-40:15)
  (enum-declaration 'MissingSeparator' access='default' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/EnumDeclarationTest.swift range=41:1-41:47
    (enum-case-declaration
      (enum-case-element-declaration 'A'))
    (enum-case-declaration
      (enum-case-element-declaration 'B'))
    (enum-case-declaration
      (enum-case-element-declaration 'C'))))
*/
