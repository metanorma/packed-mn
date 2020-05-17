.PHONY: build test

ifeq ($(OS),Windows_NT)
  PLATFORM := windows
else
  UNAME_S = $(shell uname -s)
  ifeq ($(UNAME_S),Linux)
    PLATFORM := linux
  endif
  ifeq ($(UNAME_S),Darwin)
    PLATFORM := darwin
  endif
endif

rubyc:
	curl -L http://enclose.io/rubyc/rubyc-$(PLATFORM)-x64.gz | gunzip > rubyc && chmod +x rubyc

build: rubyc
	./bin/build.sh

build/yq:
	curl -L https://github.com/mikefarah/yq/releases/download/3.3.0/yq_$(PLATFORM)_amd64 --output build/yq && chmod +x build/yq

test: build/yq build/metanorma 
	./bin/test.sh