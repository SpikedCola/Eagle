@echo off

REM TODO: check if we have a variant set, if so set to none.
REM       if variant is set, this all fails

REM empty arg check
if %1 == "" goto blank

REM set file name, board name, size file, etc..
REM sizefile (size.txt) is referenced in eagle ULP - if changed, it must be changed in both places
REM gerbfolder ("gerbers") also specified in "make board images.bat"
FOR %%i IN (%1) DO (
	set filepath=%~dp1
	set filename=%%~ni
)
set boardfile=%1
set boardfile=%boardfile:"=%
set gerbfolder=%filepath%gerbers
set sizefile=%filepath%size.txt

REM echo Removing lock files...
REM remove lock files if necessary to prevent eagle prompting (I would have thought -N took care of this?)
REM whoops it was supposed to be "-N-" argument that suppresses lock file prompt 
REM (actually nope, it doesnt... sometimes it does and sometimes it doesnt, not sure why... just delete them manually)
set lockfilesch=%filepath%.%filename%.sch.lck
set lockfilebrd=%filepath%.%filename%.brd.lck
if exist "%lockfilesch%" del "%lockfilesch%"
if exist "%lockfilebrd%" del "%lockfilebrd%"

echo Generating gerbers...

REM generate gerbers (dirtypcbs format)
if not exist "%gerbfolder%" mkdir "%gerbfolder%"
C:\EAGLE-7.6.0\bin\eagle.exe -N -X -d EXCELLON -o "%gerbfolder%\%%N.TXT" "%boardfile%" 20 44 45
C:\EAGLE-7.6.0\bin\eagle.exe -N -X -d GERBER_RS274X -o "%gerbfolder%\%%N.GML" "%boardfile%" 20 46
C:\EAGLE-7.6.0\bin\eagle.exe -N -X -d GERBER_RS274X -o "%gerbfolder%\%%N.GBP" "%boardfile%" 20 32
C:\EAGLE-7.6.0\bin\eagle.exe -N -X -d GERBER_RS274X -o "%gerbfolder%\%%N.GBS" "%boardfile%" 20 30
C:\EAGLE-7.6.0\bin\eagle.exe -N -X -d GERBER_RS274X -o "%gerbfolder%\%%N.GBO" "%boardfile%" 20 22 26
C:\EAGLE-7.6.0\bin\eagle.exe -N -X -d GERBER_RS274X -o "%gerbfolder%\%%N.GBL" "%boardfile%" 16 17 18 20
C:\EAGLE-7.6.0\bin\eagle.exe -N -X -d GERBER_RS274X -o "%gerbfolder%\%%N.GTP" "%boardfile%" 20 31
C:\EAGLE-7.6.0\bin\eagle.exe -N -X -d GERBER_RS274X -o "%gerbfolder%\%%N.GTS" "%boardfile%" 20 29
C:\EAGLE-7.6.0\bin\eagle.exe -N -X -d GERBER_RS274X -o "%gerbfolder%\%%N.GTO" "%boardfile%" 20 21 25
C:\EAGLE-7.6.0\bin\eagle.exe -N -X -d GERBER_RS274X -o "%gerbfolder%\%%N.GTL" "%boardfile%" 1 17 18 20

echo Determining board size...

if exist "%lockfilesch%" del "%lockfilesch%"
if exist "%lockfilebrd%" del "%lockfilebrd%"

REM generate size.txt
C:\EAGLE-7.6.0\bin\eagle.exe -N- -C "run generate-size-file.ulp; quit;" "%boardfile%"
if not exist "%sizefile%" goto SizeFail

REM parse size file - x on first line, y on second line
set /p boardX=<"%sizefile%"
REM type is a workaround for spaces in sizefile
for /f "skip=1" %%G IN ('type "%sizefile%"') DO ( set "boardY=%%G" )

REM call "make board images" batch file 
echo Generating board images...
REM %~dp0 = C:\EAGLE-7.6.0\
call "%~dp0Make Board Images.bat" "%boardfile%"

echo Packaging gerbers...

REM make zip file
set zipfile=%filepath%%filename% Gerbers (%boardY%cm x %boardX%cm).zip
if exist "%zipfile%" del "%zipfile%"
"c:\Program Files\WinRAR\winrar.exe" a -ep -afzip "%zipfile%" "%gerbfolder%"
IF %ERRORLEVEL% NEQ 0 GOTO ArchiveFail

REM purchase requests
echo Making purchase requests...
call 

REM Win!
echo Cleaning up...
REM %~dp0 = C:\EAGLE-7.6.0\
REM php "%~dp0Make Purchase Requests.php" "%boardfile%"

REM cleanup
rmdir /s /q "%gerbfolder%"
del "%sizefile%"

REM open explorer to zip file (reuse current explorer window)
OpenAndSelect.exe "%filepath%%filename% Top.png"

REM also open explorer to purchase requests folder
REM explorer "Z:\Purchase Requests\"

echo Done!

exit /b

:SizeFail
	echo.
	echo Failed to create size file.
	echo Exiting...
	echo.
	pause
	exit /b -4

:ArchiveFail
	echo.
	echo Failed to create zip archive.
	echo Exiting...
	echo.
	pause
	exit /b -3

:blank
	echo.
	echo Pass board file as argument. 
	echo Exiting...
	echo.
	pause
	exit /b -2
	