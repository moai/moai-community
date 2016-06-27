cd %~dp0%..

setlocal

call scripts\env-win.bat

rem Do we have a chance of success?

if "%ANDROID_NDK%"=="" echo "You need to set ANDROID_NDK to your ndk path in your env-local.bat" && exit /b 1
if "%ANDROID_NDK%"=="" echo "You need to set ANDROID_NDK to your ndk path" && exit /b 1
if "%EMSCRIPTEN%"=="" echo "EMSCRIPTEN is not defined. Please set to the location of your emscripten install (path)" && exit /b 1
where mingw32-make || echo "mingw32-make is required. Install TCC Mingw from http://tdm-gcc.tdragon.net/ and add to the path" && exit /b 1
where cmake || echo "Cmake 2.8.11+ is required, download from cmake.org" && exit /b 1

echo "Building windows libs"

call scripts\build-windows.bat vs2015 || goto :error

echo "windows lib complete"

echo "Building android libs"

call scripts\build-android.bat --clean || goto :error

echo "Android lib complete"

echo "Building JS libs"

call scripts\build-html.bat || goto :error

echo "JS libs complete

goto :end

:error
endlocal
echo "error during build"
exit /b 1

:end
endlocal
