# Swift Abstract Syntax Tree

[![Travis CI Status](https://api.travis-ci.org/yanagiba/swift-ast.svg?branch=master)](https://travis-ci.org/yanagiba/swift-ast)

The Swift Abstract Syntax Tree is an initiative to parse
[Swift Programming Language](https://swift.org/about/) in Swift itself.
The output of this utility is the corresponding
[Abstract Syntax Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree) (AST)
of the source code.

The AST produced in this tool is intended to be consumed in various scenarios.
For example, linting tools like [swift-lint](https://github.com/yanagiba/swift-lint)
can traverse the AST and find patterns of
[code smells](https://en.wikipedia.org/wiki/Code_smell).

Refactoring and code manipulation can leverage this AST as well.

Other ideas could be llvm-codegen or jvm-codegen (thinking about JSwift) that
consumes the AST and converts them into binary or bytecode, which will make it
a fully working compiler. (If you are working on this, send me your github repo
link to ryuichi@ryuichisaito.com.)

* * *

## A Work In Progress

The Swift Abstract Syntax Tree is still in early design and development. Many
features are incomplete or partially implemented. Some with technical limitations.

However, the framework of the project is set up already, so pull requests for
new features, issues and comments for existing implementations are welcomed.

Please also be advised that the Swift language is under rapid development, its
syntax is not stable. So the details are subject to change in order to
catch up as Swift evolves.

## Requirements

- [Swift Development Snapshot](https://swift.org/download/)

## Installing

### Standalone Tool

To use it as a standalone tool, clone this repository to your local machine by

```bash
git clone https://github.com/yanagiba/swift-ast
```

Go to the repository folder, run the following command:

```bash
make && make install
```

For Mac users, it will prompt for `sudo` passcode. This will automatically finds
the path for the current swift you are using, and install the executable to
the correct location.

### Embed Into Your Project

Add the swift-ast dependency to your SPM dependencies in Package.swift:

```swift
import PackageDescription

let package = Package(
  name: "ASTVisitor",
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

When `swift-ast` is installed along with the `swift` binary, then it can also
be triggered like:

```bash
swift ast path/to/foobar.swift
```

### Retrieve AST in Your Code

#### Loop Through AST Nodes

Import the two modules, and then parse the code for AST:

```swift
import ast
import parser

let parser = Parser()
let (astContext, errors) = parser.parse(fileContent)
for error in errors {
  // output errors
}
for node in astContext.topLevelDeclaration.statements {
  // consume nodes
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

### Running Integration Tests

All integration tests files can be found under
[Integrations](Integrations) folder. In addition,
a utility script `run_integrations.sh` can help to run integration tests easily:

```bash
./run_integrations.sh Integrations/a.swift Integrations/b.swift
```

## Known Limitations

- Linux is not supported due to the
  [Foundation](https://github.com/apple/swift-corelibs-foundation)
  is not complete, check out Apple's
  [status page](https://github.com/apple/swift-corelibs-foundation/blob/master/Docs/Status.md)
  for updates.
- Emoji, many Asian language characters, and some European special characters
  won't be parsed correctly. Major features have higher priority, and we will
  come back to address this later.

## Contact

Ryuichi Saito

- http://github.com/ryuichis
- ryuichi@ryuichisaito.com

## License

Swift Abstract Syntax Tree is available under the Apache License 2.0.
See the [LICENSE](LICENSE) file for more info.
