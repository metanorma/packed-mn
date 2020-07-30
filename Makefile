#!make
SHELL := /bin/bash

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

TEST_FLAVOR ?= iso

rubyc:
	curl -L https://github.com/metanorma/ruby-packer/releases/download/v0.4.0/rubyc-$(PLATFORM)-x64 > ./rubyc && chmod +x rubyc

build: build/metanorma

build/metanorma: rubyc
ifeq (,$(wildcard build/metanorma))
	./bin/build.sh
endif

build/yq:
	curl -L https://github.com/mikefarah/yq/releases/download/3.3.0/yq_$(PLATFORM)_amd64 --output build/yq && chmod +x build/yq

test: build/yq build/metanorma 
	gem install relaton-cli
	PROCESSORS="iso cc gb iec itu ogc un nist"; \
	parallel -j+0 --joblog parallel.log --eta make test-flavor TEST_FLAVOR={} "&>" test_{}.log ::: $${PROCESSORS}; \
	parallel -j+0 --joblog parallel.log --resume-failed 'echo ---- {} ----; tail -15 test_{}.log; echo ---- --- ----; exit 1' ::: $${PROCESSORS}

test-flavor: build/yq build/metanorma
	CLONE_DIR=$(shell pwd)/build; \
	[[ -d $${CLONE_DIR}/$(TEST_FLAVOR) ]] || git clone --recurse-submodules https://${GITHUB_CREDENTIALS}@github.com/metanorma/mn-samples-$(TEST_FLAVOR) $${CLONE_DIR}/$(TEST_FLAVOR); \
	env PATH="$${CLONE_DIR}:$${PATH}" env SKIP_BUNDLE=true make all publish -C $${CLONE_DIR}/$(TEST_FLAVOR)

clean:
	[ -d build ] || mkdir build; rm -rf build/* || true