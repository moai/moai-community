@echo on
setlocal enableextensions

set "PITO_HOME=%~dp0..\"

if "%MOAI_SDK_HOME%"=="" echo "You need to set MOAI_SDK_HOME to your moai sdk folder" && exit /b 1

set "OUTPUT=%1"
if "%OUTPUT%"=="" set OUTPUT=dist

rem ----- Build community sdk -----
mkdir "%OUTPUT%"
pushd %OUTPUT%
set "OUTPUT=%CD%"
popd



pushd "%PITO_HOME%"

for %%G in (bin,cmake,host-templates,util,scripts) DO (
  robocopy %%G "%OUTPUT%\%%G" /mir /NDL /NJH /NJS
)
copy /y util\package-cmake-sdk\README.md "%OUTPUT%\README.md"

mkdir "%OUTPUT%\sdk\moai"

popd
pushd "%MOAI_SDK_HOME%"

for %%G in (3rdparty-android,3rdparty,ant,docs,samples,src,util) DO (
  robocopy %%G "%OUTPUT%\sdk\moai\%%G" /mir /NDL /NJH /NJS
)

popd

pushd "%OUTPUT%\sdk\moai\3rdparty"

rem unwanted 3rdparty libs
for %%G in (facebook-ios-sdk-4.5.1,libUAirship-3.0.1,civetweb,chartboost-4.2,flurry-ios-5.0.0,adcolony-2.2.4,vungle-2.0.1,TapjoySDK_iOS_v10.0.2,crittercism-4.3.3,playhaven-ios-1.13.1,kontagent_ios_v1.5.6,MobileAppTracking-ios-2.6,MobileAppTracking-ios,sdl2-2.0.0\test) DO (
  RMDIR /S/Q %%G
)



erase /Q "%OUTPUT%\bin\env-local.bat"
popd