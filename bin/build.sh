#!/bin/bash
# Set strict mode
set -eu

[ -d build ] || mkdir build; rm -rf build/* || true

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     export TEMP_DIR="$(mktemp -d --tmpdir=$HOME .rubyc-build.XXXXXX)";;
    Darwin*)    export TEMP_DIR="$(mktemp -d)";;
esac

echo TEMP_DIR=$TEMP_DIR GITHUB_REF=${GITHUB_REF:-}

[[ "${GITHUB_REF:-}" = refs/tags/v* ]] && {
	gem install bundler -v 1.15.3
	bundle _1.15.3_ update
	bundle _1.15.3_ install
}

cp Gemfile* $TEMP_DIR && cp bin/metanorma $TEMP_DIR && cp -R vendor $TEMP_DIR
./rubyc --clean-tmpdir -r $TEMP_DIR -o ./build/metanorma $TEMP_DIR/metanorma
