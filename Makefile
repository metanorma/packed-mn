.PHONY: build test

ifeq ($(OS),Windows_NT)
    PLATFORM=windows
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        PLATFORM=linux
    endif
    ifeq ($(UNAME_S),Darwin)
        PLATFORM=darwin
    endif
endif

rubyc:
	curl -L http://enclose.io/rubyc/rubyc-$(PLATFORM)-x64.gz | gunzip > rubyc && chmod +x rubyc

build: rubyc
	./bin/build.sh

test: build/metanorma
	./bin/test.sh