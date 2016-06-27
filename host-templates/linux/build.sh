#!/bin/bash

pushd .
cd `dirname $0`
THIS_PATH=$(pwd)
if [ x$1 == x ]; then
  libprefix=`dirname $0`/lib
else
  libprefix=$1
fi
libprefix=$(cd $libprefix; pwd)

cmakedir=`dirname $0`/cmake
cmakedir=$(cd $cmakedir; pwd)


mkdir -p build/release
cd build/release
cmake -DLIB_PATH=$libprefix \
      -DCMAKE_BUILD_TYPE=Release \
      $cmakedir

cmake --build . --target moai --config Release

cd ..
mkdir debug
cd debug
cmake -DBUILD_LINUX=TRUE \
      -DMOAI_SDL=true \
      -DLIB_PATH=$libprefix \
      -DCMAKE_BUILD_TYPE=Debug \
      $cmakedir

cmake --build . --target moai --config Debug


#now build app bundle
pushd $THIS_PATH
LUAPATH=$THIS_PATH/../../src
mkdir bundle
cd bundle
cp -a $LUAPATH/. .
cp ../build/debug/moai .
popd

popd
