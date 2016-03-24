cd %~dp0%..

setlocal

call env-win.bat

echo "Building windows libs"

call bin\build-windows.bat vs2015 || goto :error

echo "windows lib complete"

echo "Building android libs"

call bin\build-android.bat || goto :error

echo "Android lib complete"

echo "Building JS libs"

call bin\build-html.bat || goto :error

echo "JS libs complete


:error
endlocal
echo "error during build"
exit /b 1

:end
endlocal
