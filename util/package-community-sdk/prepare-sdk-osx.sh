#!/bin/bash
set -e

echo "PREPARE SDK - OSX"
pushd $(dirname "${0}")/../../ > /dev/null

MOAI_SDK_ROOT=$(pwd)
echo $MOAI_SDK_ROOT

cd $MOAI_SDK_ROOT
source ./scripts/env-osx.sh

bash ./scripts/build-all-osx.sh


popd > /dev/null
