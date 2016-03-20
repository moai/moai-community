@echo off

rem ----- defaults ----


where cmake
if ERRORLEVEL 1 (
  if EXIST "%ProgramFiles(x86)%\CMake\bin" set "CMAKE_PATH=%ProgramFiles(x86)%\CMake\bin"
)

rem visual studio
where lib.exe
set VS_TOOLS=
if not ERRORLEVEL 1 goto :envlocal

set "VS_TOOLS=%VS140COMNTOOLS%"
if NOT EXIST "%VS_TOOLS%\vsdevcmd.bat"  set "VS_TOOLS=%VS120COMNTOOLS%"
if NOT EXIST "%VS_TOOLS%\vsdevcmd.bat" set "VS_TOOLS="
  
:envlocal
if exist "%~dp0%\env-local.bat" (
  call "%~dp0%\env-local.bat"
)


rem ---- cmake ------


if "%CMAKE_PATH%"=="" goto :vstudio
echo "Setting CMAKE bin path..."
set PATH=%PATH%;%CMAKE_PATH%



rem ---- visual studio ----
:vstudio

if "%VS_TOOLS%"=="" echo Visual Studio not found..SKIPPED && goto :ndk 
echo "Setting Visual Studio path..."

pushd .
call "%VS_TOOLS%\Vsvars32.bat"
popd



rem ---- android NDK -------
:ndk
if "%NDK_PATH%"=="" goto :mingw
echo "Setting Android NDK path..."

set ANDROID_NDK=%NDK_PATH%



rem ----- mingw ----------
:mingw
if "%MINGW_PATH%"=="" goto :emsdk
echo "Setting MingW Gcc path..."

set PATH=%PATH%;%MINGW_PATH%

set OLD_JAVA_HOME=%JAVA_HOME%

rem ---- emscripten SDK -------
:emsdk
if "%EMSDK_PATH%"=="" goto :util
echo "Setting Emscripten path..."

pushd .
cd %EMSDK_PATH%
call emsdk_env.bat
popd                         

if NOT "%OLD_JAVA_HOME%"=="" set JAVA_HOME=%OLD_JAVA_HOME%



rem ---- moai util path -----
:util
echo "Setting Moai Util path..."

pushd .
cd %~dp0%/..
set UTIL_PATH=%cd%/util
popd

set PATH=%PATH%;%UTIL_PATH%

rem ---- Doxygen -----
if "%DOXYGEN_PATH%"=="" goto :end
echo "Setting DOXYGEN path..."
set PATH=%PATH%;%DOXYGEN_PATH%;%DOT_PATH%

:end
echo "Path setup complete"