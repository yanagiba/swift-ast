# Swift Abstract Syntax Tree

[![swift-ast master](https://img.shields.io/badge/swift‐ast-master-C70025.svg)](https://github.com/yanagiba/swift-ast)
[![swift-lint master](https://img.shields.io/badge/swift‐lint-master-C70025.svg)](https://github.com/yanagiba/swift-lint)
[![swift-transform pending](https://img.shields.io/badge/swift‐transform-pending-C70025.svg)](https://github.com/yanagiba/swift-transform)

[![Travis CI Status](https://api.travis-ci.org/yanagiba/swift-ast.svg?branch=master)](https://travis-ci.org/yanagiba/swift-ast)
[![codecov](https://codecov.io/gh/yanagiba/swift-ast/branch/master/graph/badge.svg)](https://codecov.io/gh/yanagiba/swift-ast)
![Swift 5.1](https://img.shields.io/badge/swift-5.1-brightgreen.svg)
![Swift Package Manager](https://img.shields.io/badge/SPM-ready-orange.svg)
![Platforms](https://img.shields.io/badge/platform-%20Linux%20|%20macOS%20-red.svg)
![License](https://img.shields.io/github/license/yanagiba/swift-ast.svg)


Swift Abstract Syntax Tree is an initiative to parse
[Swift Programming Language](https://swift.org/about/) in Swift itself.
The output of this utility is the corresponding
[Abstract Syntax Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree) (AST)
of the source code.

The AST produced in this tool is intended to be consumed in various scenarios.
For example, source-to-source transformations like [swift-transform](https://github.com/yanagiba/swift-transform)
and linting tools like [swift-lint](https://github.com/yanagiba/swift-lint).

Refactoring, code manipulation and optimization can leverage this AST as well.

Other ideas could be llvm-codegen or jvm-codegen (thinking about JSwift) that
consumes the AST and converts them into binary or bytecode.
I have some proof-of-concepts,
[llswift-poc](https://github.com/ryuichis/llswift-poc)
and
[jswift-poc](https://github.com/ryuichis/jswift-poc), respectively.
If you are interested in working on the codegens, send me email ryuichi@yanagiba.org.

Swift Abstract Syntax Tree is part of [Yanagiba Project](http://yanagiba.org).
Yanagiba umbrella project is a toolchain of compiler modules,
libraries, and utilities, written in Swift and for Swift.

* * *

## A Work In Progress

The Swift Abstract Syntax Tree is still in active development.
Though many features are implemented, some with limitations.

Pull requests for new features,
issues and comments for existing implementations are welcomed.

Please also be advised that the Swift language is under rapid development,
its syntax is not stable. So the details are subject to change in order to
catch up as Swift evolves.

## Requirements

- [Swift 5.1](https://swift.org/download/)

## Installation

### Standalone Tool

To use it as a standalone tool, clone this repository to your local machine by

```bash
git clone https://github.com/yanagiba/swift-ast
```

Go to the repository folder, run the following command:

```bash
swift build -c release
```

This will generate a `swift-ast` executable inside `.build/release` folder.

#### Adding to `swift` Path (Optional)

It is possible to copy the `swift-ast` to the `bin` folder of
your local Swift installation.

For example, if `which swift` outputs

```
/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
```

Then you can copy `swift-ast` to it by

```
cp .build/release/swift-ast /Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-ast
```

Once you have done this, you can invoke `swift-ast` by
calling `swift ast` in your terminal directly.

### Embed Into Your Project

Add the swift-ast dependency to `Package.swift`:

```swift
// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "MyPackage",
  dependencies: [
    .package(url: "https://github.com/yanagiba/swift-ast.git", from: "0.19.9")
  ],
  targets: [
    .target(name: "MyTarget", dependencies: ["SwiftAST+Tooling"]),
  ],
  swiftLanguageVersions: [.v5]
)
```

## Usage

### Command Line

Simply append the path of the file to `swift-ast`. It will dump the AST to the
console.

```bash
swift-ast path/to/Awesome.swift
```

Multiple files can be parsed with one call:

```bash
swift-ast path1/to1/foo.swift path2/to2/bar.swift ... path3/to3/main.swift
```

#### CLI Options

By default, the AST output is in a plain text format without indentation
nor color highlight to the keywords. The output format can be changed by
providing the following option:

- `-print-ast`: with indentation and color highlight
- `-dump-ast`: in a tree structure
- `-diagnostics-only`: no output other than the diagnostics information

In addition, `-github-issue` can be provided as the first argument option,
and the program will try to generate a GitHub issue template with pre-filled
content for you.

### Use AST in Your Code

#### Loop Through AST Nodes

```swift
import AST
import Parser
import Source

do {
  let sourceFile = try SourceReader.read(at: filePath)
  let parser = Parser(source: sourceFile)
  let topLevelDecl = try parser.parse()

  for stmt in topLevelDecl.statements {
    // consume statement
  }
} catch {
  // handle errors
}
```

#### Traverse AST Nodes

We provide a pre-order depth-first traversal implementation on all AST nodes.
In order to use this, simply write your visitor by conforming `ASTVisitor`
protocol with the `visit` methods for the AST nodes that are interested to you.
You can also write your own traversal implementations
to override the default behaviors.

Returning `false` from `traverse` and `visit` methods will stop the traverse.

```swift
class MyVisitor : ASTVisitor {
  func visit(_ ifStmt: IfStatement) throws -> Bool {
    // visit this if statement

    return true
  }
}
let myVisitor = MyVisitor()
let topLevelDecl = MyParse.parse()
myVisitor.traverse(topLevelDecl)
```

## Development

### Build & Run

Building the entire project can be done by simply calling:

```bash
make
```

This is equivalent to

```bash
swift build
```

The dev version of the tool can be invoked by:

```bash
.build/debug/swift-ast path/to/file.swift
```

### Running Tests

Compile and run the entire tests by:

```bash
make test
```

## Contact

Ryuichi Sai

- http://github.com/ryuichis
- ryuichi@yanagiba.org

## License

Swift Abstract Syntax Tree is available under the Apache License 2.0.
See the [LICENSE](LICENSE) file for more info.
