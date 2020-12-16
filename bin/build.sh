#!/bin/bash
# Set strict mode
set -eu

[ -d build ] || mkdir build; rm -rf build/* || true

gem install bundler
bundle install

echo "-- Gemfile.lock --"
cat Gemfile.lock
echo "-- ------------ --"

OPENSSL_DIR=$(openssl version -d | cut -d \" -f2)
NEW_CERT_URL=https://raw.githubusercontent.com/rubygems/rubygems/master/lib/rubygems/ssl_certs/rubygems.org/GlobalSignRootCA_R3.pem
BUNDLER_GEM_PATH="${TMPDIR:-/tmp}/rubyc/rubyc_work_dir/__enclose_io_memfs__/lib/ruby/gems/2.4.0/gems/bundler-1.15.3/lib/bundler"

case "$(uname -s)" in
    Linux*)
		TEMP_DIR="$(mktemp -d --tmpdir="$HOME" .rubyc-build.XXXXXX)"
		cp Gemfile* "$TEMP_DIR" && cp bin/metanorma "$TEMP_DIR" && cp -R vendor "$TEMP_DIR"
		./rubyc --make-args=-j2 --clean-tmpdir -r "$TEMP_DIR" -o ./build/metanorma "$TEMP_DIR/metanorma" || true
		wget "$NEW_CERT_URL" -O "${BUNDLER_GEM_PATH}/ssl_certs/rubygems.org/GlobalSignRootCA_R3.pem"
		./rubyc --make-args=-j2 --keep-tmpdir -r "$TEMP_DIR" -o ./build/metanorma "$TEMP_DIR/metanorma"
		strip ./build/metanorma
		;;
    Darwin*)
		TEMP_DIR="$(mktemp -d)"
		cp Gemfile* "$TEMP_DIR" && cp bin/metanorma "$TEMP_DIR" && cp -R vendor "$TEMP_DIR"
		env CC="xcrun clang -mmacosx-version-min=10.10" ./rubyc --clean-tmpdir -r "$TEMP_DIR" -o ./build/metanorma "$TEMP_DIR/metanorma" || true
		wget "$NEW_CERT_URL" -O "${BUNDLER_GEM_PATH}/ssl_certs/rubygems.org/GlobalSignRootCA_R3.pem"
		env CC="xcrun clang -mmacosx-version-min=10.10" ./rubyc --keep-tmpdir -r "$TEMP_DIR" -o ./build/metanorma "$TEMP_DIR/metanorma"
		;;
esac
