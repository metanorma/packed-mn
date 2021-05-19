#!make
SHELL := /bin/bash

.PHONY: build test png2ico

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
TEST_PROCESSORS ?= iso cc iec un nist m3aawg mpfa jcgm csa ribose bipm iho
# ietf - wait for release of https://github.com/metanorma/metanorma-ietf/commit/ca75ea3
# itu  - https://github.com/relaton/relaton-bib/issues/44
# ogc  - https://github.com/metanorma/mn-samples-ogc/issues/119

BUILD_DIR := build

rubyc:
	curl -L https://github.com/metanorma/ruby-packer/releases/download/v0.4.5/rubyc-$(PLATFORM)-x64 > ./rubyc && chmod +x rubyc

$(BUILD_DIR)/metanorma: rubyc
ifeq (,$(wildcard $(BUILD_DIR)/metanorma))
	./bin/build.sh $(BUILD_DIR)
endif
ifeq ($(UNAME_S),Linux)
	strip $(BUILD_DIR)/metanorma
endif

test: $(BUILD_DIR)/metanorma
	parallel -j+0 --joblog parallel.log --eta make test-flavor TEST_FLAVOR={} "&>" test_{}.log ::: $(TEST_PROCESSORS); \
	parallel -j+0 --joblog parallel.log --resume-failed 'echo ---- {} ----; tail -15 test_{}.log; echo ---- --- ----; exit 1' ::: $(TEST_PROCESSORS)

test-flavor: build/metanorma
	[ -d $(BUILD_DIR)/$(TEST_FLAVOR) ] || git clone --recurse-submodules https://${GITHUB_CREDENTIALS}@github.com/metanorma/mn-samples-$(TEST_FLAVOR) $(BUILD_DIR)/$(TEST_FLAVOR); \
	$(BUILD_DIR)/metanorma site generate $(BUILD_DIR)/$(TEST_FLAVOR) -c $(BUILD_DIR)/$(TEST_FLAVOR)/metanorma.yml -o site/$(TEST_FLAVOR) --agree-to-terms

clean:
	[ -d $(BUILD_DIR) ] || mkdir $(BUILD_DIR); rm -rf $(BUILD_DIR)/* || true

png2ico:
	convert ocra/icon.png -define icon:auto-resize="256,128,96,64,48,32,16" ocra/metanorma.ico