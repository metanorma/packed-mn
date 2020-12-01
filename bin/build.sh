#!/bin/bash
# Set strict mode
set -eu

[ -d build ] || mkdir build; rm -rf build/* || true

gem install bundler -v 1.15.3
bundle _1.15.3_ install
echo "-- Gemfile.lock --"
cat Gemfile.lock
echo "-- ------------ --"

case "$(uname -s)" in
    Linux*)
		TEMP_DIR="$(mktemp -d --tmpdir="$HOME" .rubyc-build.XXXXXX)"
		cp Gemfile* "$TEMP_DIR" && cp bin/metanorma "$TEMP_DIR" && cp -R vendor "$TEMP_DIR"
		./rubyc --make-args=-j2 --clean-tmpdir -r "$TEMP_DIR" -o ./build/metanorma "$TEMP_DIR/metanorma"
		strip ./build/metanorma
		;;
    Darwin*)
		TEMP_DIR="$(mktemp -d)"
		cp Gemfile* "$TEMP_DIR" && cp bin/metanorma "$TEMP_DIR" && cp -R vendor "$TEMP_DIR"
		env CC="xcrun clang -mmacosx-version-min=10.10" ./rubyc --clean-tmpdir -r "$TEMP_DIR" -o ./build/metanorma "$TEMP_DIR/metanorma"
		;;
esac
