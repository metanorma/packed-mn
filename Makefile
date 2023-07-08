#!make
SHELL := bash

.PHONY: build test clean

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
    PLATFORM := darwin
else
	PLATFORM := $(shell echo $$OSTYPE)
endif

ARCH := $(shell uname -m)

TEST_FLAVOR ?= iso
TEST_PROCESSORS ?= iso cc iec un m3aawg jcgm csa bipm iho ogc itu ietf ieee

ifdef RUBY_VER
RUBY_VERSION := $(RUBY_VER)
else
RUBY_VERSION := '3.0.6'
endif

BUILD_DIR := build

all: $(BUILD_DIR)/bin/metanorma-$(PLATFORM)-$(ARCH)

test:
	parallel -j+0 --joblog parallel.log --eta make test-flavor TEST_FLAVOR={} "&>" test_{}.log ::: $(TEST_PROCESSORS); \
	parallel -j+0 --joblog parallel.log --resume-failed 'echo ---- {} ----; tail -15 test_{}.log; echo ---- --- ----; exit 1' ::: $(TEST_PROCESSORS)

test-flavor:
	[ -d $(BUILD_DIR)/$(TEST_FLAVOR) ] || git clone --recurse-submodules https://${GITHUB_CREDENTIALS}@github.com/metanorma/mn-samples-$(TEST_FLAVOR) $(BUILD_DIR)/$(TEST_FLAVOR); \
	$(BUILD_DIR)/bin/metanorma-$(PLATFORM)-$(ARCH) \
	  site generate $(BUILD_DIR)/$(TEST_FLAVOR) \
		-c $(BUILD_DIR)/$(TEST_FLAVOR)/metanorma.yml \
		-o site/$(TEST_FLAVOR) \
		--agree-to-terms

$(BUILD_DIR)/package/Gemfile:
	mkdir -p $(dir $@);
	cp Gemfile $@

$(BUILD_DIR)/package/metanorma:
	mkdir -p $(dir $@);
	cp bin/metanorma $@

$(BUILD_DIR)/package/vendor:
	mkdir -p $(dir $@);
	cp -R vendor $@

$(BUILD_DIR)/.package-ready: $(BUILD_DIR)/package/metanorma $(BUILD_DIR)/package/Gemfile $(BUILD_DIR)/package/vendor
	touch $@

$(BUILD_DIR)/bin/metanorma-$(PLATFORM)-$(ARCH): $(BUILD_DIR)/.package-ready
	mkdir -p $(dir $@);
	tebako press -r "$(BUILD_DIR)/package" -e "metanorma" -o "$@" -p ".archive/tebako" -R $(RUBY_VERSION);
ifneq ($(PLATFORM),darwin)
	strip $@;
endif

clean:
	rm -rf $(BUILD_DIR)

distclean: clean
	rm -rf .archive
