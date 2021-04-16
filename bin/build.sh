#!/bin/bash
# Set strict mode
set -eu

BUILD_DIR=${1:-./build}

set -a
# shellcheck disable=SC1090
. "${BASH_SOURCE[0]%/*}/$(uname -s).env"
set +a

TEMP_DIR=$(${MKTEMP_CMD[@]})

cp Gemfile* "$TEMP_DIR"
cp bin/metanorma "${TEMP_DIR}"
cp -R vendor "$TEMP_DIR"

[ -d "${BUILD_DIR}" ] || mkdir -p "${BUILD_DIR}"; rm -rf ${BUILD_DIR}/* || true

if [[ "$OSTYPE" == "darwin"* ]]; then
	export CC="xcrun clang -mmacosx-version-min=10.10 -Wno-implicit-function-declaration"
fi

./rubyc --clean-tmpdir -r "${TEMP_DIR}" -o ${BUILD_DIR}/metanorma "${TEMP_DIR}/metanorma"
