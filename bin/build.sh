#!/bin/sh
# Set strict mode
set -eu

[ -d build ] || mkdir build; rm -rf build/* || true

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     export TEMP_DIR="$(mktemp -d --tmpdir=$HOME .rubyc-build.XXXXXX)";;
    Darwin*)    export TEMP_DIR="$(mktemp -d)";;
esac

echo TEMP_DIR=$TEMP_DIR GITHUB_REF=$GITHUB_REF

[[ ${GITHUB_REF:-} == refs/tags/v* ]] && {
	sudo gem install bundler -v 1.17.3
	bundle install --jobs 4 --retry 3
}

cp Gemfile* $TEMP_DIR && cp bin/metanorma $TEMP_DIR && cp -R vendor $TEMP_DIR
./rubyc --clean-tmpdir -r $TEMP_DIR -o ./build/metanorma $TEMP_DIR/metanorma