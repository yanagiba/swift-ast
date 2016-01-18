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

typealias A = UIKit.UIController
typealias B = [Double]
@a @b @c typealias C = [String?: Int]
public typealias D = (String, String) -> Bool
@x private typealias E = NSImage!
typealias F = protocol<UITableViewDelegate, UITableViewDataSource>
typealias G = A.B.Protocol
typealias H = Array<Dictionary<String, Int>>

/*
(top-level-declaration path=/Users/ryuichis/Projects/L/swift-ast/Integrations/TypeAliasDeclarationTest.swift range=1:1-36:1
  (type-alias-declaration 'A' access='default' type='UIKit.UIController' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/TypeAliasDeclarationTest.swift range=17:1-17:33)
  (type-alias-declaration 'B' access='default' type='Array<Double>' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/TypeAliasDeclarationTest.swift range=18:1-18:23)
  (type-alias-declaration 'C' access='default' type='Dictionary<Optional<String>, Int>' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/TypeAliasDeclarationTest.swift range=19:1-19:38)
  (type-alias-declaration 'D' access='public' type='((String, String) -> Bool)' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/TypeAliasDeclarationTest.swift range=20:1-20:46)
  (type-alias-declaration 'E' access='private' type='ImplicitlyUnwrappedOptional<NSImage>' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/TypeAliasDeclarationTest.swift range=21:1-21:34)
  (type-alias-declaration 'F' access='default' type='Protocol<UITableViewDelegate,UITableViewDataSource>' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/TypeAliasDeclarationTest.swift range=22:1-22:67)
  (type-alias-declaration 'G' access='default' type='A.B.Protocol' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/TypeAliasDeclarationTest.swift range=23:1-23:27)
  (type-alias-declaration 'H' access='default' type='Array<<Dictionary<<String, Int>>>>' path=/Users/ryuichis/Projects/L/swift-ast/Integrations/TypeAliasDeclarationTest.swift range=24:1-24:45))
*/
