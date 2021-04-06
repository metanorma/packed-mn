#!/bin/bash
# Set strict mode
set -eu

BUILD_DIR=${1:-build}

set -a
# shellcheck disable=SC1090
. "bin/$(uname -s).env"
set +a

TEMP_DIR=$(${MKTEMP_CMD[@]})

cp Gemfile* "$TEMP_DIR"
cp bin/metanorma "${TEMP_DIR}"
cp -R vendor "$TEMP_DIR"

./rubyc -r "${TEMP_DIR}" -o ${BUILD_DIR}/metanorma "${TEMP_DIR}/metanorma" --clean-tmpdir 
strip ${BUILD_DIR}/metanorma