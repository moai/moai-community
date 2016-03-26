: "${MOAI_SDK_HOME:?Please set MOAI_SDK_HOME variable to point to your MOAI Sdk }"

pushd $MOAI_SDK_HOME/util/build/
./build-ios.sh
popd


