#!/bin/bash
set -e

echo "PREPARE SDK - OSX"
SCRIPT_DIR=$(cd `dirname $0` && pwd)
pushd $(dirname "${0}")/../../ > /dev/null

MOAI_SDK_ROOT=$(pwd)
echo $MOAI_SDK_ROOT

cd $MOAI_SDK_ROOT
source ./scripts/env-osx.sh

./scripts/build-all-osx.sh


 
pushd $SCRIPT_DIR/moai-debugger > /dev/null

echo y| pito host create android 
pito host build android 

APK_DIR=../../../lib/android/apk

if ! [ -d  $APK_DIR ]; then
	mkdir -p $APK_DIR
fi

if [ -e $APK_DIR/moai-debug.apk ]; then 
  rm $APK_DIR/moai-debug.apk
fi
cp ./hosts/android/moai/build/outputs/apk/moai-debug.apk $APK_DIR/moai-debug.apk
rm -rf hosts/android

popd

popd > /dev/null
