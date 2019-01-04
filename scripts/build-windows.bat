@echo off
rem :: Determine target directory and cmake generator
setlocal enableextensions
call "%~dp0%\env-win.bat"

if "%MOAI_SDK_HOME%"=="" (
	echo Could not determine location of MOAI SDK, please set MOAI_SDK_HOME
	exit /b 1
)


where msbuild || echo "Could not find msbuild.exe (are you in your VS developer tools prompt?)" && exit /b 1


cd "%~dp0.."
set "rootpath=%cd%"
set "libprefix=%rootpath%\lib\windows\vs2015"
set "projpath=%MOAI_SDK_HOME%\vs2015"


echo Creating Release Libs
msbuild %projpath%\moai.sln /verbosity:minimal /t:Moai\moai /p:Configuration=Release || echo "Error during build" && exit /b 1

robocopy "%projpath%\bin\win32\Release" "%libprefix%\Release" /MIR 

echo Creating Debug Libs
msbuild %projpath%\moai.sln /verbosity:minimal /t:Moai\moai /p:Configuration=Debug || echo "Error during build" && exit /b 1

robocopy "%projpath%\bin\win32\Debug" "%libprefix%\Debug" /MIR 

if not exist "%rootpath%\bin\moai.exe" copy "%projpath%\bin\win32\debug\moai.exe" "%rootpath%\bin\moai.exe"

echo "Build complete"
exit /b 0