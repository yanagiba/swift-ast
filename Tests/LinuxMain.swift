/*
   Copyright 2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

import XCTest

import CanaryTests
import LexerTests
import ParserTests
import ASTVisitorTests
import IntegrationTests

var tests = [XCTestCaseEntry]()
tests += CanaryTests.allTests()
tests += LexerTests.allTests()
tests += ParserTests.allTests()
tests += ASTVisitorTests.allTests()
tests += IntegrationTests.allTests()
XCTMain(tests)
