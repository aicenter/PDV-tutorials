#!/bin/bash

ROOT=$(pwd)
RELATIVE=$GIT_PREFIX
PARAMS=$@

# Convert the .ipe figures to .pdf
function build_ipe {
	for fig in "$ROOT"/"$1"/figs/*.ipe
	do
	  ipetoipe -pdf "$fig"
	done
}

function build_latex {
	(cd $ROOT/$1 && TEXINPUTS=.//:$ROOT/support/beamer_template:$TEXINPUTS lualatex -shell-escape main.tex)
}

function build_cmake {
	(cd $ROOT/$1 && cmake CMakeLists.txt && make $PARAMS)
}

while [ ! $RELATIVE == "." ]; do
	if [ -f $ROOT/$RELATIVE/main.tex ]; then
		build_ipe $RELATIVE
		build_latex $RELATIVE
		exit 0
	elif [ -f $ROOT/$RELATIVE/CMakeLists.txt ]; then
		build_cmake $RELATIVE
		exit 0
	fi
	RELATIVE=$(dirname $RELATIVE)
done

echo "==================================================="
echo "  ERROR: Build target not found!                   "
echo "==================================================="
