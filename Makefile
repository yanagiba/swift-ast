SWIFT_BIN=$(shell which swift)
SWIFT_AST=$(SWIFT_BIN)-ast

COPY=cp
REMOVE=rm

UNAME=$(shell uname)

ifeq ($(UNAME), Darwin)
COPY=sudo cp
REMOVE=sudo rm
endif

BUILD_DIR=.build/debug

.PHONY: all clean build test install uninstall

all: build

clean:
	swift build --clean

build:
	swift build

test: build
	./$(BUILD_DIR)/xctest

install:
	$(COPY) $(BUILD_DIR)/swift-ast $(SWIFT_AST)

uninstall:
	$(REMOVE) $(SWIFT_AST)
