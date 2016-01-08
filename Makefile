SWIFT_BIN=$(shell which swift)
SWIFT_AST=$(SWIFT_BIN)-ast

SWIFTC=swiftc
COPY=cp
REMOVE=rm

UNAME=$(shell uname)

ifeq ($(UNAME), Darwin)
XCODE=$(shell xcode-select -p)
SDK=$(XCODE)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk
TARGET=x86_64-apple-macosx10.10
SWIFTC=swiftc -target $(TARGET) -sdk $(SDK) -Xlinker -all_load
COPY=sudo cp
REMOVE=sudo rm
endif

BUILD_DIR=.build/debug
LIBS=$(wildcard $(BUILD_DIR)/*.a)
LDFLAGS=$(foreach lib,$(LIBS),-Xlinker $(lib))

.PHONY: all clean build test install uninstall

all: build

clean:
	swift build --clean

build:
	swift build

test: build $(BUILD_DIR)/test_runner
	./$(BUILD_DIR)/test_runner

$(BUILD_DIR)/test_runner: Tests/*.swift Tests/declaration/*.swift Tests/type/*.swift $(BUILD_DIR)/ast.a $(BUILD_DIR)/parser.a $(BUILD_DIR)/source.a $(BUILD_DIR)/util.a
	$(SWIFTC) -o $@ Tests/*.swift Tests/declaration/*.swift Tests/type/*.swift -I$(BUILD_DIR) -Xlinker $(BUILD_DIR)/Spectre.a $(LDFLAGS)

install:
	$(COPY) $(BUILD_DIR)/swift-ast $(SWIFT_AST)

uninstall:
	$(REMOVE) $(SWIFT_AST)
