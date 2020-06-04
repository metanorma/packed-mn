#!/bin/bash
# Set strict mode
set -eu

[ -d build ] || mkdir build; rm -rf build/* || true

[[ "${GITHUB_REF:-}" = refs/tags/v* ]] && {
	gem install bundler -v 1.15.3
	bundle _1.15.3_ install
	echo "----"
	cat Gemfile.lock
	echo "----"
}

case "$(uname -s)" in
    Linux*)
		TEMP_DIR="$(mktemp -d --tmpdir="$HOME" .rubyc-build.XXXXXX)"
		cp Gemfile* "$TEMP_DIR" && cp bin/metanorma "$TEMP_DIR" && cp -R vendor "$TEMP_DIR"
		./rubyc --clean-tmpdir -r "$TEMP_DIR" -o ./build/metanorma "$TEMP_DIR/metanorma"
		;;
    Darwin*)
		TEMP_DIR="$(mktemp -d)"
		cp Gemfile* "$TEMP_DIR" && cp bin/metanorma "$TEMP_DIR" && cp -R vendor "$TEMP_DIR"
		env CC="clang -mmacosx-version-min=10.3" ./rubyc --clean-tmpdir -r "$TEMP_DIR" -o ./build/metanorma "$TEMP_DIR/metanorma"
		;;
esac