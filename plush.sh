#!/bin/sh

# Stop at the first error
set -e

PKG_FILE=`mktemp`

if [ "$#" -ne 1 ]; then
    SRC_FILE=`mktemp`
    cat $* > ${SRC_FILE}
else
    SRC_FILE=$1
fi

# Compile the input
./cplush ${SRC_FILE} > ${PKG_FILE}

# Run the compiled output
./zeta ${PKG_FILE}
