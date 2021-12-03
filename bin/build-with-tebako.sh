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

pushd tebako
bin/tebako press -r "${TEMP_DIR}" -e "${TEMP_DIR}/metanorma" -o "${BUILD_DIR}/metanorma"

strip "${BUILD_DIR}/metanorma"
ls -l "${BUILD_DIR}/metanorma"

popd