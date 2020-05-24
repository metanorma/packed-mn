.PHONY: build test test-flavor

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
	curl -L http://enclose.io/rubyc/rubyc-$(PLATFORM)-x64.gz | gunzip > rubyc && chmod +x rubyc

build: rubyc
	./bin/build.sh

build/yq:
	curl -L https://github.com/mikefarah/yq/releases/download/3.3.0/yq_$(PLATFORM)_amd64 --output build/yq && chmod +x build/yq

test: build/yq build/metanorma 
	PROCESSORS="iso cc gb iec itu ogc un iho nist"; \
	parallel -j+0 --joblog parallel.log --eta make test-flavor TEST_FLAVOR={} "&>" test_{}.log ::: $${PROCESSORS}; \
	parallel -j+0 --joblog parallel.log --resume-failed 'echo ---- {} ----; cat test_{}.log; echo ---- --- ----' ::: $${PROCESSORS}

test-flavor:
	CLONE_DIR=$(pwd)/build; \
	[[ -d mn-samples-$(TEST_FLAVOR) ]] || git clone --recurse-submodules https://${GITHUB_CREDENTIALS}@github.com/metanorma/mn-samples-${TEST_FLAVOR}; \
	cd $${CLONE_DIR}/$(TEST_FLAVOR); env PATH="$${CLONE_DIR}:$${PATH}" make all
