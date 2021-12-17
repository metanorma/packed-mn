#!make
SHELL := /bin/bash

.PHONY: build test clean

ifeq ($(OS),Windows_NT)
  PLATFORM := windows
else
  UNAME_S = $(shell uname -s)
  ifeq ($(UNAME_S),Linux)
    PLATFORM := linux
  endif
  ifeq ($(UNAME_S),Darwin)
    PLATFORM := darwin
		CC := xcrun clang -mmacosx-version-min=10.10 -Wno-implicit-function-declaration
  endif
endif

TEST_FLAVOR ?= iso
TEST_PROCESSORS ?= iso cc iec un m3aawg jcgm csa bipm iho ogc itu ietf

BUILD_DIR := build

all: $(BUILD_DIR)/bin/metanorma-$(PLATFORM)-x86_64

ocra/metanorma.ico:
	convert ocra/icon.png -define icon:auto-resize="256,128,96,64,48,32,16" $@

vendor/cacert.pem.mozilla:
	curl -L https://curl.se/ca/cacert.pem -o $@

test: $(BUILD_DIR)/bin/metanorma-$(PLATFORM)-x86_64
	parallel -j+0 --joblog parallel.log --eta make test-flavor TEST_FLAVOR={} "&>" test_{}.log ::: $(TEST_PROCESSORS); \
	parallel -j+0 --joblog parallel.log --resume-failed 'echo ---- {} ----; tail -15 test_{}.log; echo ---- --- ----; exit 1' ::: $(TEST_PROCESSORS)

test-flavor: $(BUILD_DIR)/bin/metanorma-$(PLATFORM)-x86_64
	[ -d $(BUILD_DIR)/$(TEST_FLAVOR) ] || git clone --recurse-submodules https://${GITHUB_CREDENTIALS}@github.com/metanorma/mn-samples-$(TEST_FLAVOR) $(BUILD_DIR)/$(TEST_FLAVOR); \
	$< site generate $(BUILD_DIR)/$(TEST_FLAVOR) -c $(BUILD_DIR)/$(TEST_FLAVOR)/metanorma.yml -o site/$(TEST_FLAVOR) --agree-to-terms

rubyc:
	curl -L https://github.com/metanorma/ruby-packer/releases/download/v0.6.1/rubyc-$(PLATFORM)-x64 \
		-o $@ && \
	chmod +x $@

tebako/.git:
	git clone https://github.com/tamatebako/tebako

tebako/bin/tebako: tebako/.git

tebako/deps/bin/mkdwarfs: tebako/bin/tebako
	mkdir -p -v tebako/deps
	$< setup

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/package:
	mkdir -p $@

$(BUILD_DIR)/package/Gemfile: | $(BUILD_DIR)/package
	cp Gemfile $@

$(BUILD_DIR)/package/metanorma: | $(BUILD_DIR)/package
	cp bin/metanorma $@

$(BUILD_DIR)/package/cacert.pem.mozilla: | $(BUILD_DIR)/package
	cp vendor/cacert.pem.mozilla $@

$(BUILD_DIR)/bin:
	mkdir -p $@

$(BUILD_DIR)/bin/metanorma-darwin-x86_64: rubyc $(BUILD_DIR)/package/Gemfile $(BUILD_DIR)/package/metanorma $(BUILD_DIR)/package/cacert.pem.mozilla | $(BUILD_DIR)/bin
	arch -x86_64 ./rubyc --clean-tmpdir -r "$(BUILD_DIR)/package" -o $@ "$(BUILD_DIR)/package/metanorma"
	strip $@
	chmod a+x $@

$(BUILD_DIR)/bin/metanorma-darwin-arm64: rubyc $(BUILD_DIR)/package/Gemfile $(BUILD_DIR)/package/metanorma $(BUILD_DIR)/package/cacert.pem.mozilla | $(BUILD_DIR)/bin
	arch -arm64 ./rubyc --clean-tmpdir -r "$(BUILD_DIR)/package" -o $@ "$(BUILD_DIR)/package/metanorma"
	strip $@
	chmod a+x $@

$(BUILD_DIR)/bin/metanorma-linux-x86_64: tebako/bin/tebako $(BUILD_DIR)/package/Gemfile $(BUILD_DIR)/package/metanorma $(BUILD_DIR)/package/cacert.pem.mozilla | $(BUILD_DIR)/bin
	$< press -r "$(BUILD_DIR)/package" -e "metanorma" -o "$@"
	strip $@
	chmod +x $@

clean:
	[ -d $(BUILD_DIR) ] || mkdir $(BUILD_DIR); rm -rf $(BUILD_DIR)/package $(BUILD_DIR)/bin || true
