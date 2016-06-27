#!/bin/bash


  export MOAI_SDK_HOME=${MOAI_SDK_HOME-$(cd $(dirname "${BASH_SOURCE[0]}")/../; pwd)/sdk/moai}
  #--User config
  if [ -e "$(dirname ${BASH_SOURCE[0]})/env-local.sh" ]; then
     source $(dirname "${BASH_SOURCE[0]}")/env-local.sh
  fi




#--check for reqs
error=false

which cmake || (echo "could not detect cmake. apt-get install cmake" && error = true)


#--install
if [ "$error" == "false" ]; then

echo "MOAI_SDK_HOME = $MOAI_SDK_HOME"

if [ ! -z "$NDK_PATH" ]; then
   echo "Setting NDK path..."
   export ANDROID_NDK=$NDK_PATH
 else
   echo "No NDK_PATH specified, Android will not be buildable"
fi

if [ ! -z "$EMSDK_PATH" ]; then
  echo "Setting Emscripten path..."
  pushd $EMSDK_PATH > /dev/null
  ls
  source ./emsdk_env.sh
  popd > /dev/null
else
  echo "No EMSDK_PATH specified, JS libs will not be buildable"
fi

echo "Environment setup complete"
fi
