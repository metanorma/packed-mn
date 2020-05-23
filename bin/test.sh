#!/bin/bash
#set -eu

CLONE_DIR=$(pwd)/build
PROCESSORS=( iso cc gb iec itu ogc un iho nist )

ERRORS=( )

for s in "${PROCESSORS[@]}"; do \
	[[ -d ${CLONE_DIR}/${s} ]] || git clone --recurse-submodules https://${GITHUB_CREDENTIALS}@github.com/metanorma/mn-samples-${s} ${CLONE_DIR}/${s}
	pushd ${CLONE_DIR}/${s}
		env PATH="${CLONE_DIR}:${PATH}" make all &> ${CLONE_DIR}/test_${s}.log &
		[ $? -ne 0 ] && ERRORS+=("${s}"); \
	popd
done; \
wait
if [ ${#ERRORS[@]} -ne 0 ]; then
	for s in "${ERRORS[@]}"; do \
		echo "--------------- tail -50 test_${s}.log ------------------"
		tail -50 ${CLONE_DIR}/test_${s}.log
	done
	echo "------------------------------------------------------------"
	echo "Failed processors (${ERRORS[@]}) check details above"
	exit 1
fi
