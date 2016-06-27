#!/bin/bash

set -e


cd `dirname $0`
MOAIROOT=$(pwd)/..

cd $MOAIROOT



echo "Building osx libs"

./scripts/build-osx.sh || exit 1

echo "OSX Libs complete"

echo "Building ios libs"

./scripts/build-ios.sh || exit 1

echo "iOS libs complete"

echo "Building android libs"

./scripts/build-android.sh || exit 1

echo "Android libs complete"

echo "Building html lib"

./scripts/build-html.sh || exit 1

echo "Creating html lib complete"


echo "All OSX compatible libs have been built"