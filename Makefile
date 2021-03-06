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
	curl -L https://github.com/metanorma/ruby-packer/releases/download/v0.4.1/rubyc-$(PLATFORM)-x64 > ./rubyc && chmod +x rubyc

build: build/metanorma

build/metanorma: rubyc
ifeq (,$(wildcard build/metanorma))
	./bin/build.sh
endif

test: build/metanorma 
	# ietf itu ogc iho - broken at the moment
	MAKE_BASED_PROCESSORS="iso cc iec un nist m3aawg mpfa jcgm csa ribose bipm"; \
	parallel -j+0 --joblog parallel.log --eta make test-flavor TEST_FLAVOR={} "&>" test_{}.log ::: $${PROCESSORS}; \
	parallel -j+0 --joblog parallel.log --resume-failed 'echo ---- {} ----; tail -15 test_{}.log; echo ---- --- ----; exit 1' ::: $${PROCESSORS}

test-flavor: build/metanorma
	CLONE_DIR=$(shell pwd)/build; \
	[[ -d $${CLONE_DIR}/$(TEST_FLAVOR) ]] || git clone --recurse-submodules https://${GITHUB_CREDENTIALS}@github.com/metanorma/mn-samples-$(TEST_FLAVOR) $${CLONE_DIR}/$(TEST_FLAVOR); \
	$${CLONE_DIR}/metanorma site generate $${CLONE_DIR}/$(TEST_FLAVOR) -c $${CLONE_DIR}/$(TEST_FLAVOR)/metanorma.yml --agree-to-terms

clean:
	[ -d build ] || mkdir build; rm -rf build/* || true
