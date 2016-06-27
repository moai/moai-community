#!/bin/bash

#
# Build script for Mac OSX
# Usage: Run from Moai SDK's root directory:
#
# build-osx.sh

: "${MOAI_SDK_HOME:?Please set MOAI_SDK_HOME variable to point to your MOAI Sdk }"

$MOAI_SDK_HOME/util/build/build-osx.sh

PITO_ROOT=$(cd `dirname $0`/.. && pwd)

if [ ! -e "$PITO_ROOT/bin/moai" ]; then
   cp $MOAI_SDK_HOME/bin/osx/moai $PITO_ROOT/bin/moai
fi

