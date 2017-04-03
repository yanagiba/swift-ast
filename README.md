# Swift Abstract Syntax Tree

[![Travis CI Status](https://api.travis-ci.org/yanagiba/swift-ast.svg?branch=master)](https://travis-ci.org/yanagiba/swift-ast)

The Swift Abstract Syntax Tree is an initiative to parse
[Swift Programming Language](https://swift.org/about/) in Swift itself.
The output of this utility is the corresponding
[Abstract Syntax Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree) (AST)
of the source code.

The AST produced in this tool is intended to be consumed in various scenarios.
For example, formatting tools like [swift-format](https://github.com/yanagiba/swift-format)
and linting tools like [swift-lint](https://github.com/yanagiba/swift-lint).

Refactoring, code manipulation and optimization can leverage this AST as well.

Other ideas could be llvm-codegen or jvm-codegen (thinking about JSwift) that
consumes the AST and converts them into binary or bytecode, which will make it
a fully working compiler. (If you are working on this, send me your github repo
link to ryuichi@ryuichisaito.com.)

* * *

## A Work In Progress

The Swift Abstract Syntax Tree is still in early design and development.
Many features are incomplete or partially implemented.
Some with technical limitations.

However, the framework of the project is set up already, so pull requests for
new features, issues and comments for existing implementations are welcomed.

Please also be advised that the Swift language is under rapid development,
its syntax is not stable. So the details are subject to change in order to
catch up as Swift evolves.

## Requirements

- [Swift 3.1](https://swift.org/download/)

## Installing

### Standalone Tool

To use it as a standalone tool, clone this repository to your local machine by

```bash
git clone https://github.com/yanagiba/swift-ast
```

Go to the repository folder, run the following command:

```bash
make
```

### Embed Into Your Project

Add the swift-ast dependency to `Package.swift`:

```swift
import PackageDescription

let package = Package(
  name: "MyProject",
  dependencies: [
    .Package(url: "https://github.com/yanagiba/swift-ast.git", majorVersion: 0)
  ]
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

### Retrieve AST in Your Code

#### Loop Through AST Nodes

Import the two modules, and then parse the code for AST:

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

This is a pending feature under development.

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

Ryuichi Saito

- http://github.com/ryuichis
- ryuichi@ryuichisaito.com

## License

Swift Abstract Syntax Tree is available under the Apache License 2.0.
See the [LICENSE](LICENSE) file for more info.
