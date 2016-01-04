/*
   Copyright 2015-2016 Ryuichi Saito, LLC

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

import Foundation
import UIKit    ;    import Darwin
import foo.bar
import class UIKit.UIViewController
import func Darwin.glob
@a @b @c @d import struct x.y.z

import
import class UIKit
import klass UIKit.UIViewController
import foo.
public import bar
internal (set) import a

/*
Parser error: Missing identifier.
Parser error: Statements must be separated by line breaks or semicolons.
Parser error: Statements must be separated by line breaks or semicolons.
Parser error: Postfix '.' is reserved.
Parser error: 'public' modifier cannot be applied to this declaration.
Parser error: 'internal' modifier cannot be applied to this declaration.

(top-level-declaration path=/Users/ryuichis/Projects/L/swift-ast/Integrations/ImportDeclarationTest.swift range=1:1-53:1
  (import-declaration 'Foundation' kind=Module path=/Users/ryuichis/Projects/L/swift-ast/Integrations/ImportDeclarationTest.swift range=17:1-17:18)
  (import-declaration 'UIKit' kind=Module path=/Users/ryuichis/Projects/L/swift-ast/Integrations/ImportDeclarationTest.swift range=18:1-18:13)
  (import-declaration 'Darwin' kind=Module path=/Users/ryuichis/Projects/L/swift-ast/Integrations/ImportDeclarationTest.swift range=18:22-18:35)
  (import-declaration 'foo.bar' kind=Module path=/Users/ryuichis/Projects/L/swift-ast/Integrations/ImportDeclarationTest.swift range=19:1-19:15)
  (import-declaration 'UIKit.UIViewController' kind=Class path=/Users/ryuichis/Projects/L/swift-ast/Integrations/ImportDeclarationTest.swift range=20:1-20:36)
  (import-declaration 'Darwin.glob' kind=Func path=/Users/ryuichis/Projects/L/swift-ast/Integrations/ImportDeclarationTest.swift range=21:1-21:24)
  (import-declaration 'x.y.z' kind=Struct attributes=a,b,c,d path=/Users/ryuichis/Projects/L/swift-ast/Integrations/ImportDeclarationTest.swift range=22:1-22:32)
  (import-declaration 'klass' kind=Module path=/Users/ryuichis/Projects/L/swift-ast/Integrations/ImportDeclarationTest.swift range=26:1-26:13)
  (import-declaration 'foo' kind=Module path=/Users/ryuichis/Projects/L/swift-ast/Integrations/ImportDeclarationTest.swift range=27:1-27:12)
  (import-declaration 'bar' kind=Module path=/Users/ryuichis/Projects/L/swift-ast/Integrations/ImportDeclarationTest.swift range=28:1-28:18)
  (import-declaration 'a' kind=Module path=/Users/ryuichis/Projects/L/swift-ast/Integrations/ImportDeclarationTest.swift range=29:1-29:24))
*/
