/*
   Copyright 2015 Ryuichi Saito, LLC

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

/*
Parser error: Missing identifier.
Parser error: Statements must be separated by line breaks or semicolons.
Parser error: Statements must be separated by line breaks or semicolons.

(top-level-declaration
  (import-declaration 'Foundation' kind=Module)
  (import-declaration 'UIKit' kind=Module)
  (import-declaration 'Darwin' kind=Module)
  (import-declaration 'foo.bar' kind=Module)
  (import-declaration 'UIKit.UIViewController' kind=Class)
  (import-declaration 'Darwin.glob' kind=Func)
  (import-declaration 'x.y.z' kind=Struct attributes=a,b,c,d)
  (import-declaration 'klass' kind=Module)
  (import-declaration 'foo' kind=Module))
*/
