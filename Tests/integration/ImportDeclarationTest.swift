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
  (import-declaration 'Foundation')
  (import-declaration 'UIKit')
  (import-declaration 'Darwin')
  (import-declaration 'foo.bar')
  (import-declaration 'UIKit.UIViewController' kind=class)
  (import-declaration 'Darwin.glob' kind=func)
  (import-declaration 'x.y.z' kind=struct attributes=a,b,c,d)
  (import-declaration 'klass')
  (import-declaration 'foo'))
*/
