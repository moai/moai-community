@echo off

pushd %~dp0%\moai-debugger


rem create moai-debugger apk
echo y| call pito host create android || goto :error
call pito host build android || goto :error

mkdir ..\..\..\lib\android\apk
erase /q ..\..\..\lib\android\apk\moai-debug.apk
copy hosts\android\moai\build\outputs\apk\moai-debug.apk ..\..\..\lib\android\apk\moai-debug.apk || goto :error
rmdir /s/q hosts\android
popd 
goto :end

:error
popd
endlocal
echo "error during build"
exit /b 1

:end
endlocal