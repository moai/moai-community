@echo off
 


if "%MOAI_SDK_HOME%"=="" set "MOAI_SDK_HOME=%~dp0%..\sdk\moai"



if not exist %MOAI_SDK_HOME% (
  echo "Could not find moai sdk, please set MOAI_SDK_HOME to the location of your SDK"
  echo "Looked in: %MOAI_SDK_HOME%"
  exit /b 1
)


where moai >nul 2>&1
if ERRORLEVEL 1 (

   if NOT EXIST %~dp0\moai.exe (
     echo "Could not find a moai binary in %~dp0 or on the path"
     pause "attempting to build one (ctrl+c to cancel)"
     pushd "%~dp0..\"
     setlocal
     call scripts\env-win.bat
     call scripts\build-windows.bat
     endlocal
     popd
   )
)

where pito.bat >nul 2>&1
if ERRORLEVEL 1 (
    rem Add to the path to help the user out
    set "PATH=%~dp0;%PATH%"
)

setlocal

set "SCRIPT_DIR=%~dp0..\util"
set "PITO_HOME=%SCRIPT_DIR%..\"
set "INVOKE_DIR=%CD%"
set MOAI_CMD=%1


set args=%INVOKE_DIR% %MOAI_SDK_HOME% %MOAI_CMD%

shift

:parse
if "%~1" neq "" (
   set args=%args% %1
   shift 
   goto :parse
)
pushd "%SCRIPT_DIR%"
%~dp0\moai pito.lua %args%
popd 

endlocal
