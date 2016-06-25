
pushd 
cd %~dp0%..\..\
setlocal

call scripts\env-win.bat || goto :error
call scripts\build-all-windows.bat || goto :error

call %~dp0%\build-android-apk.bat || goto :error

cd sdk\moai\vs2015 || goto :error
git clean -d -f -x 

popd 
goto :end

:error
endlocal
echo "error during build"
exit /b 1

:end
endlocal