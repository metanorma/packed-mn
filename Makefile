#!make
SHELL := bash

.PHONY: build test clean

PLATFORM := $(shell echo $$OSTYPE)
ARCH := $(shell uname -m)

TEST_FLAVOR ?= iso
TEST_PROCESSORS ?= iso cc iec un m3aawg jcgm csa bipm iho ogc itu ietf

BUILD_DIR := build
TEBAKO_TAG := v0.3.7

all: $(BUILD_DIR)/bin/metanorma-$(PLATFORM)-$(ARCH)

gogo: 
	echo "$$OSTYPE"
	echo $(UNAME_S)
	echo $(BUILD_DIR)
	echo $(PLATFORM)
	echo $(ARCH)

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

.archive/tebako/.git:
	mkdir -p .archive
	git clone --recurse-submodules -b "$(TEBAKO_TAG)" https://github.com/tamatebako/tebako $(dir $@)

.archive/tebako/bin/tebako: .archive/tebako/.git

.archive/tebako/deps/bin/mkdwarfs: .archive/tebako/bin/tebako
	mkdir -p -v $(dir $(dir $@))
	$< setup

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

$(BUILD_DIR)/bin/metanorma-$(PLATFORM)-$(ARCH): .archive/tebako/bin/tebako $(BUILD_DIR)/.package-ready
	mkdir -p $(dir $@);
	$< press -r "$(BUILD_DIR)/package" -e "metanorma" -o "$@";
	strip $@;
	chmod +x $@

clean:
	rm -rf $(BUILD_DIR)

distclean: clean
	rm -rf .archive
