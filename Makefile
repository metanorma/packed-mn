#!make
SHELL := /bin/bash

.PHONY: build test clean

ifeq ($(OS),Windows_NT)
  PLATFORM := windows
else
  UNAME_S := $(shell uname -s)
	ARCH := $(shell uname -m)
  ifeq ($(UNAME_S),Linux)
    PLATFORM := linux
  endif
  ifeq ($(UNAME_S),Darwin)
    PLATFORM := darwin
  endif
endif

TEST_FLAVOR ?= iso
TEST_PROCESSORS ?= iso cc iec un m3aawg jcgm csa bipm iho ogc itu ietf

BUILD_DIR := build
TEBAKO_TAG := v0.3.3

all: $(BUILD_DIR)/bin/metanorma-$(PLATFORM)-$(ARCH)

ocra/metanorma.ico:
	convert ocra/icon.png -define icon:auto-resize="256,128,96,64,48,32,16" $@

vendor/cacert.pem.mozilla:
	curl -L https://curl.se/ca/cacert.pem -o $@

test:
	parallel -j+0 --joblog parallel.log --eta make test-flavor TEST_FLAVOR={} "&>" test_{}.log ::: $(TEST_PROCESSORS); \
	parallel -j+0 --joblog parallel.log --resume-failed 'echo ---- {} ----; tail -15 test_{}.log; echo ---- --- ----; exit 1' ::: $(TEST_PROCESSORS)

test-flavor:
	[ -d $(BUILD_DIR)/$(TEST_FLAVOR) ] || git clone --recurse-submodules https://${GITHUB_CREDENTIALS}@github.com/metanorma/mn-samples-$(TEST_FLAVOR) $(BUILD_DIR)/$(TEST_FLAVOR); \
	$(BUILD_DIR)/bin/metanorma-$(PLATFORM)-x86_64 \
	  site generate $(BUILD_DIR)/$(TEST_FLAVOR) \
		-c $(BUILD_DIR)/$(TEST_FLAVOR)/metanorma.yml \
		-o site/$(TEST_FLAVOR) \
		--agree-to-terms

.archive/rubyc:
	mkdir -p $(dir $@);
	curl -L https://github.com/metanorma/ruby-packer/releases/download/v0.6.1/rubyc-$(PLATFORM)-x64 \
		-o $@ && \
	chmod +x $@

.archive/tebako/.git:
	mkdir -p .archive;
	git clone -b "$(TEBAKO_TAG)" https://github.com/tamatebako/tebako $(dir $@)

.archive/tebako/bin/tebako: .archive/tebako/.git

.archive/tebako/deps/bin/mkdwarfs: .archive/tebako/bin/tebako
	mkdir -p -v $(dir $(dir $@))
	$< setup

Gemfile.lock:
	bundle

$(BUILD_DIR)/package/Gemfile:
	mkdir -p $(dir $@);
	cp Gemfile $@

$(BUILD_DIR)/package/Gemfile.lock: Gemfile.lock
	mkdir -p $(dir $@);
	cp Gemfile.lock $@

$(BUILD_DIR)/package/metanorma:
	mkdir -p $(dir $@);
	cp bin/metanorma $@

$(BUILD_DIR)/package/cacert.pem.mozilla:
	mkdir -p $(dir $@);
	cp vendor/cacert.pem.mozilla $@

$(BUILD_DIR)/package/vendor:
	mkdir -p $(dir $@);
	cp -R vendor $@

$(BUILD_DIR)/.package-ready: $(BUILD_DIR)/package/metanorma $(BUILD_DIR)/package/cacert.pem.mozilla $(BUILD_DIR)/package/vendor
	touch $@

$(BUILD_DIR)/bin/metanorma-darwin-x86_64: .archive/tebako/bin/tebako $(BUILD_DIR)/.package-ready
	mkdir -p $(dir $@);
	$< press -r "$(BUILD_DIR)/package" -e "metanorma" -o "$@";
	chmod +x $@

$(BUILD_DIR)/bin/metanorma-darwin-arm64: .archive/rubyc $(BUILD_DIR)/.package-ready
	mkdir -p $(dir $@);
	export CC="xcrun clang -mmacosx-version-min=10.10 -Wno-implicit-function-declaration";
	arch -arm64 $< --clean-tmpdir -o $@ -r "$(BUILD_DIR)/package" "$(BUILD_DIR)/package/metanorma"
	chmod a+x $@

$(BUILD_DIR)/bin/metanorma-linux-x86_64: .archive/tebako/bin/tebako $(BUILD_DIR)/.package-ready
	mkdir -p $(dir $@);
	$< press -r "$(BUILD_DIR)/package" -e "metanorma" -o "$@";
	strip $@;
	chmod +x $@

$(BUILD_DIR)/bin/metanorma-linux-aarch64: .archive/tebako/bin/tebako $(BUILD_DIR)/.package-ready
	mkdir -p $(dir $@);
	$< press -r "$(BUILD_DIR)/package" -e "metanorma" -o "$@";
	strip $@;
	chmod +x $@

clean:
	rm -rf $(BUILD_DIR)

distclean: clean
	rm -rf .archive
