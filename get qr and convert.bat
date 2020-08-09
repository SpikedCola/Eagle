@echo off

rem strip "s
set arg1=%1
set arg1=%arg1:"=%
set arg2=%2
set arg2=%arg2:"=%

REM empty arg check
if "%arg1%" == "" goto blank
if "%arg2%" == "" goto blank

set url=%arg1%
set outputpath=%arg2%

set pngfile=%outputpath%/qr.png
set bmpfile=%outputpath%/qr.bmp

rem -s silent
rem -k ignore ssl
curl -s -k -o "%pngfile%" "https://api.qrserver.com/v1/create-qr-code/?size=100x100&margin=6&format=png&data=%url%"

convert "%pngfile%" -depth 2 "%bmpfile%"

del "%pngfile%"

exit /b

:blank
	echo.
	echo Pass url and directory to save Qr in as arguments
	echo Exiting...
	echo.
	pause
	exit /b -2