#!/bin/bash

ROOT=$(pwd)
RELATIVE=$GIT_PREFIX

function package {
	cd $ROOT/$RELATIVE
	TUTORIAL=$(basename $(dirname $RELATIVE))
	zip ../tutorial_$TUTORIAL.zip *.cpp *.h CMakeLists.txt *.dat *.txt
}

while [ ! $RELATIVE == "." ]; do
	if [ -f $ROOT/$RELATIVE/CMakeLists.txt ]; then
		package
		exit 0
	fi
	RELATIVE=$(dirname $RELATIVE)
done

echo "==================================================="
echo "  ERROR: Build target not found!                   "
echo "==================================================="