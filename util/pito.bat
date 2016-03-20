@echo off
 


if "%MOAI_SDK_HOME%"=="" set "MOAI_SDK_HOME=%~dp0%..\sdk\moai"



if not exist %MOAI_SDK_HOME% (
  echo "Could not find moai sdk, please set MOAI_SDK_HOME to the location of your SDK"
  echo "Looked in: $MOAI_SDK_HOME%"
  exit /b 1
)


where moai >nul 2>&1
if ERRORLEVEL 1 (
   echo "Could not find a moai binary in %~dp0 or on the path"
   pause "attempting to build one (ctrl+c to cancel)"
   pushd %~dp0%..\
   echo "launching env"
   bin\env-win.bat
   bin\build-windows.bat
   popd
)

setlocal

set SCRIPT_DIR=%~dp0%
set "PITO_HOME=%SCRIPT_DIR%..\"
set INVOKE_DIR=%CD%
set MOAI_CMD=%1

rem pito scripts assume pito is on the path
set PATH=%PATH%;%SCRIPT_DIR%


set args=%INVOKE_DIR% %MOAI_SDK_HOME% %MOAI_CMD%

shift

:parse
if "%~1" neq "" (
   set args=%args% %1
   shift 
   goto :parse
)
pushd %SCRIPT_DIR% 
moai pito.lua %args%
popd 

endlocal
