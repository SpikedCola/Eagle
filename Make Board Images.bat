@echo off

REM empty arg check
if %1 == "" goto blank

set GERBV="C:\gerbv-2.6a\gerbv.exe"
set BORDER=0
set DPI=1200

REM set file name, path, gerber folder, etc..
FOR %%i IN (%1) DO (
	set filepath=%~dp1
	set filename=%%~ni
)
set gerbfolder=%filepath%gerbers

set TOPGVP=%gerbfolder%/top.gvp
set BOTTOMGVP=%gerbfolder%/bottom.gvp

REM output top side project file
echo (gerbv-file-version! "2.0A") > "%TOPGVP%"
echo (define-layer! 5 (cons 'filename "%filename%.GBL") >> "%TOPGVP%"
echo 	(cons 'visible #t) >> "%TOPGVP%"
echo 	(cons 'color #(20560 41120 20560)) >> "%TOPGVP%"
echo 	(cons 'alpha #(65535)) >> "%TOPGVP%"
echo ) >> "%TOPGVP%"
echo (define-layer! 4 (cons 'filename "%filename%.GTL") >> "%TOPGVP%"
echo 	(cons 'visible #t) >> "%TOPGVP%"
echo 	(cons 'color #(59110 51400 0)) >> "%TOPGVP%"
echo 	(cons 'alpha #(65535)) >> "%TOPGVP%"
echo ) >> "%TOPGVP%"
echo (define-layer! 3 (cons 'filename "%filename%.GTS") >> "%TOPGVP%"
echo 	(cons 'inverted #t) >> "%TOPGVP%"
echo 	(cons 'visible #t) >> "%TOPGVP%"
echo 	(cons 'color #(0 23130 0)) >> "%TOPGVP%"
echo ) >> "%TOPGVP%"
echo (define-layer! 2 (cons 'filename "%filename%.GTO") >> "%TOPGVP%"
echo 	(cons 'visible #t) >> "%TOPGVP%"
echo 	(cons 'color #(65535 65535 65535)) >> "%TOPGVP%"
echo 	(cons 'alpha #(65535)) >> "%TOPGVP%"
echo ) >> "%TOPGVP%"
echo (define-layer! 1 (cons 'filename "%filename%.GML") >> "%TOPGVP%"
echo 	(cons 'visible #t) >> "%TOPGVP%"
echo 	(cons 'color #(0 0 0)) >> "%TOPGVP%"
echo 	(cons 'alpha #(65535)) >> "%TOPGVP%"
echo ) >> "%TOPGVP%"
echo (define-layer! 0 (cons 'filename "%filename%.TXT") >> "%TOPGVP%"
echo 	(cons 'visible #t) >> "%TOPGVP%"
echo 	(cons 'color #(0 0 0)) >> "%TOPGVP%"
echo 	(cons 'alpha #(65535)) >> "%TOPGVP%"
echo 	(cons 'attribs (list >> "%TOPGVP%"
echo 		(list 'autodetect 'Boolean 0) >> "%TOPGVP%"
echo 		(list 'zero_suppression 'Enum 1) >> "%TOPGVP%"
echo 		(list 'units 'Enum 0) >> "%TOPGVP%"
echo 		(list 'digits 'Integer 5) >> "%TOPGVP%"
echo 	)) >> "%TOPGVP%"
echo ) >> "%TOPGVP%"
echo (define-layer! -1 (cons 'filename "%gerbfolder%") >> "%TOPGVP%"
echo 	(cons 'color #(24672 32896 24672)) >> "%TOPGVP%"
echo ) >> "%TOPGVP%"
echo (set-render-type! 3) >> "%TOPGVP%"

echo  Generating top image...

%GERBV% --dpi=%DPI% --border=%BORDER% --export=png --output="%filepath%%filename% Top.png" --project="%TOPGVP%"

REM outpuut bottom side project file

echo (gerbv-file-version! "2.0A") > "%BOTTOMGVP%"
echo (define-layer! 5 (cons 'filename "%filename%.GTL") >> "%BOTTOMGVP%"
echo 	(cons 'visible #t) >> "%BOTTOMGVP%"
echo 	(cons 'color #(20560 41120 20560)) >> "%BOTTOMGVP%"
echo 	(cons 'alpha #(65535)) >> "%BOTTOMGVP%"
echo 	(cons 'mirror #(#f #t)) >> "%BOTTOMGVP%"
echo ) >> "%BOTTOMGVP%"
echo (define-layer! 4 (cons 'filename "%filename%.GBL") >> "%BOTTOMGVP%"
echo 	(cons 'visible #t) >> "%BOTTOMGVP%"
echo 	(cons 'color #(59110 51400 0)) >> "%BOTTOMGVP%"
echo 	(cons 'alpha #(65535)) >> "%BOTTOMGVP%"
echo 	(cons 'mirror #(#f #t)) >> "%BOTTOMGVP%"
echo ) >> "%BOTTOMGVP%"
echo (define-layer! 3 (cons 'filename "%filename%.GBS") >> "%BOTTOMGVP%"
echo 	(cons 'inverted #t) >> "%BOTTOMGVP%"
echo 	(cons 'visible #t) >> "%BOTTOMGVP%"
echo 	(cons 'color #(0 23130 0)) >> "%BOTTOMGVP%"
echo 	(cons 'mirror #(#f #t)) >> "%BOTTOMGVP%"
echo ) >> "%BOTTOMGVP%"
echo (define-layer! 2 (cons 'filename "%filename%.GBO") >> "%BOTTOMGVP%"
echo 	(cons 'visible #t) >> "%BOTTOMGVP%"
echo 	(cons 'color #(65535 65535 65535)) >> "%BOTTOMGVP%"
echo 	(cons 'alpha #(65535)) >> "%BOTTOMGVP%"
echo 	(cons 'mirror #(#f #t)) >> "%BOTTOMGVP%"
echo ) >> "%BOTTOMGVP%"
echo (define-layer! 1 (cons 'filename "%filename%.GML") >> "%BOTTOMGVP%"
echo 	(cons 'visible #t) >> "%BOTTOMGVP%"
echo 	(cons 'color #(0 0 0)) >> "%BOTTOMGVP%"
echo 	(cons 'alpha #(65535)) >> "%BOTTOMGVP%"
echo 	(cons 'mirror #(#f #t)) >> "%BOTTOMGVP%"
echo ) >> "%BOTTOMGVP%"
echo (define-layer! 0 (cons 'filename "%filename%.TXT") >> "%BOTTOMGVP%"
echo 	(cons 'visible #t) >> "%BOTTOMGVP%"
echo 	(cons 'color #(0 0 0)) >> "%BOTTOMGVP%"
echo 	(cons 'alpha #(65535)) >> "%BOTTOMGVP%"
echo 	(cons 'mirror #(#f #t)) >> "%BOTTOMGVP%"
echo 	(cons 'attribs (list >> "%BOTTOMGVP%"
echo 		(list 'autodetect 'Boolean 0) >> "%BOTTOMGVP%"
echo 		(list 'zero_suppression 'Enum 1) >> "%BOTTOMGVP%"
echo 		(list 'units 'Enum 0) >> "%BOTTOMGVP%"
echo 		(list 'digits 'Integer 5) >> "%BOTTOMGVP%"
echo 	)) >> "%BOTTOMGVP%"
echo ) >> "%BOTTOMGVP%"
echo (define-layer! -1 (cons 'filename "%gerbfolder%") >> "%BOTTOMGVP%"
echo 	(cons 'color #(24672 32896 24672)) >> "%BOTTOMGVP%"
echo ) >> "%BOTTOMGVP%"
echo (set-render-type! 3) >> "%BOTTOMGVP%"

echo  Generating bottom image...

%GERBV% --dpi=%DPI% --border=%BORDER% --export=png --output="%filepath%%filename% Bottom.png" --project="%BOTTOMGVP%"