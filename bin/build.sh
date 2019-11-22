#!/bin/sh

[ -d build ] || mkdir build; rm -rf build/* || true

# TODO: wrong test for linux
if [[ "$OSTYPE" == "darwin"* ]]; then
  export TEMP_DIR="$(mktemp -d)"
else
  export TEMP_DIR="$(mktemp -d --tmpdir=$HOME .rubyc-build.XXXXXX)"
fi

echo $TEMP_DIR
cp Gemfile* $TEMP_DIR && cp bin/metanorma $TEMP_DIR && cp -R vendor $TEMP_DIR

echo $TEMP_DIR
./rubyc --clean-tmpdir -r $TEMP_DIR -o ./build/metanorma $TEMP_DIR/metanorma