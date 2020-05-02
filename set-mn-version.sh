#!/usr/bin/env bash

MN_CLI_GEM_VERSION=${1:-1.2.11}

REPLACE_MARKER_BEGIN="# > mn-cli-dependency #"
REPLACE_MARKER_END="# < mn-cli-dependency #"

case "$OSTYPE" in
	linux-gnu) SED=sed ;;
	darwin*) SED=gsed ;;
esac

${SED} -i "/${REPLACE_MARKER_BEGIN}/,/${REPLACE_MARKER_END}/c\\${REPLACE_MARKER_BEGIN}\ngem 'metanorma-cli', '${MN_CLI_GEM_VERSION}'\n${REPLACE_MARKER_END}" Gemfile
