@ECHO OFF
SETLOCAL EnableDelayedExpansion

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

IF [%1]==[] (
	ECHO:
	ECHO No input file.
	ECHO:
	PAUSE
	EXIT
)

SET "_INPUT_PDF=%~nx1"

SET "_OUTPUT_PDF=flattened.pdf"
SET "_OUTPUT_PDF_PS=flattened_postscript.pdf"
SET "_OUTPUT_PDF_IMAGES=flattened_lowres.pdf"

SET "_PLACEHOLDER_PS=flattened.ps"

SET "_DPI=63"
SET "_DPI=120"
SET "_DPI=150"
SET "_DPI=200"
::SET "_DPI=300"

:: https://ss64.com/nt/syntax-args.html
:: %~n1 Expand %1 to a file Name without file extension or path - MyFile or if only a path is present, with no trailing backslash, the last folder in that path.
:: %~x1 Expand %1 to a file eXtension only - .txt

REM -------------------------------------------------------------------------------

IF EXIST "%_OUTPUT_PDF%" (
	DEL "%_OUTPUT_PDF%"
)

IF EXIST "%_OUTPUT_PDF_PS%" (
	DEL "%_OUTPUT_PDF_PS%"
)

IF EXIST "%_OUTPUT_PDF_IMAGES%" (
	DEL "%_OUTPUT_PDF_IMAGES%"
)

IF EXIST "%_PLACEHOLDER_PS%" (
	DEL "%_PLACEHOLDER_PS%"
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ECHO:
ECHO Running Ghostscript . . .
ECHO:
ECHO ===============================================================================
ECHO:

:: Method thanks to:
:: https://security.stackexchange.com/questions/103323/effectiveness-of-flattening-a-pdf-to-remove-malware

:: Ghostscript Help
::gswin64c -h
::https://www.ghostscript.com/Documentation.html
::https://www.ghostscript.com/doc/9.23/Install.htm

ECHO PDF-to-PDF conversion . . .
ECHO:

::gswin64c -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=flattened.pdf %~nx1

gswin64c -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=%_OUTPUT_PDF% %_INPUT_PDF%

ECHO:
ECHO -------------------------------------------------------------------------------
ECHO:
ECHO PDF-to-PostScript2-to-PDF . . .
ECHO:

:: Ghostscript Devices:
::https://ghostscript.com/doc/current/Devices.htm
::gswin64c -dNOPAUSE -dBATCH -sDEVICE=ps2write -sOutputFile=flattened.ps %_INPUT_PDF%
gswin64c -dNOPAUSE -dBATCH -sDEVICE=ps2write -sOutputFile=%_PLACEHOLDER_PS% %_INPUT_PDF%
::gswin64c -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=%_PLACEHOLDER_PS% %_INPUT_PDF%

ECHO:

::https://www.ghostscript.com/doc/9.23/Use.htm#PDF
gswin64c -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=%_OUTPUT_PDF_PS% %_PLACEHOLDER_PS%

ECHO:
ECHO -------------------------------------------------------------------------------
ECHO:
ECHO PDF-to-PDF ^(image resolution downsize to %_DPI% DPI^) . . .
ECHO:

::gswin64c -dNOPAUSE -dBATCH -r%_DPI% -sDEVICE=pdfwrite -sOutputFile=%_OUTPUT_PDF_IMAGES% %_INPUT_PDF%

::-dDownsampleColorImages -dColorImageDownsampleType=/Bicubic -dColorImageResolution=%_DPI% -dDownsampleGrayImages -dGrayImageDownsampleType=/Bicubic -dGrayImageResolution=%_DPI% -dDownsampleMonoImages -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution=%_DPI%

::https://www.ghostscript.com/doc/9.23/VectorDevices.htm#PDFWRITE
gswin64c -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dDownsampleColorImages -dColorImageDownsampleType=/Bicubic -dColorImageResolution=%_DPI% -dDownsampleGrayImages -dGrayImageDownsampleType=/Bicubic -dGrayImageResolution=%_DPI% -dDownsampleMonoImages -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution=%_DPI% -sOutputFile=%_OUTPUT_PDF_IMAGES% %_INPUT_PDF%

:: Test for failure condition.
::SET "_OUTPUT_PDF=%_INPUT_PDF%"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SET "_INPUT_SIZE=%~z1"
FOR /F "usebackq" %%G IN ('%_OUTPUT_PDF%') DO SET "_OUTPUT_SIZE=%%~zG"
::https://ss64.com/nt/set.html
SET /A "_SIZE_DIFF=%_INPUT_SIZE%-%_OUTPUT_SIZE%"
SET /A "_SIZE_DIFF/=1024"
::ECHO Size difference = %_SIZE_DIFF% KB

ECHO:
IF %_SIZE_DIFF% GTR 0 (
	ECHO Success^^!
	ECHO "%_OUTPUT_PDF%" is %_SIZE_DIFF% KB smaller than "%_INPUT_PDF%"
) ELSE (
	ECHO ===============================================================================
	ECHO:
	ECHO Failure^^!
	ECHO Output PDF is either same size ^(or larger^!^) than Input PDF.
	ECHO:
	ECHO  Input = %_INPUT_SIZE% B
	ECHO Output = %_OUTPUT_SIZE% B
	ECHO:
	ECHO  Input = "%_INPUT_PDF%"
	ECHO Output = "%_OUTPUT_PDF%"
	ECHO:
	ECHO Size difference = %_SIZE_DIFF% KB
	ECHO:
	ECHO -------------------------------------------------------------------------------
)
ECHO:
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FOR /F "usebackq" %%G IN ('%_OUTPUT_PDF_PS%') DO SET "_OUTPUT_PS_SIZE=%%~zG"
ECHO PostScript2 conversion:
IF %_OUTPUT_PS_SIZE% LSS %_INPUT_SIZE% (
	SET /A "_SIZE_DIFF=%_INPUT_SIZE%-%_OUTPUT_PS_SIZE%"
	SET /A "_SIZE_DIFF/=1024"
	ECHO "%_OUTPUT_PDF_PS%" is !_SIZE_DIFF! KB smaller than "%_INPUT_PDF%"
) ELSE (
	SET /A "_SIZE_DIFF=%_OUTPUT_PS_SIZE%-%_INPUT_SIZE%"
	SET /A "_SIZE_DIFF/=1024"
	ECHO "%_OUTPUT_PDF_PS%" is !_SIZE_DIFF! KB larger than "%_INPUT_PDF%"
)
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IF %_OUTPUT_PS_SIZE% LSS %_OUTPUT_SIZE% (
	SET /A "_SIZE_DIFF=%_OUTPUT_SIZE%-%_OUTPUT_PS_SIZE%"
	SET /A "_SIZE_DIFF/=1024"
	ECHO "%_OUTPUT_PDF_PS%" is !_SIZE_DIFF! KB smaller than "%_OUTPUT_PDF%"
) ELSE (
	SET /A "_SIZE_DIFF=%_OUTPUT_PS_SIZE%-%_OUTPUT_SIZE%"
	SET /A "_SIZE_DIFF/=1024"
	ECHO "%_OUTPUT_PDF_PS%" is !_SIZE_DIFF! KB larger than "%_OUTPUT_PDF%"
)
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FOR /F "usebackq" %%G IN ('%_OUTPUT_PDF_IMAGES%') DO SET "_OUTPUT_LOWRES_SIZE=%%~zG"
SET /A "_SIZE_DIFF=%_INPUT_SIZE%-%_OUTPUT_LOWRES_SIZE%
SET /A "_SIZE_DIFF/=1024"
ECHO:
ECHO Image resolution downsize:
IF %_SIZE_DIFF% GTR 0 (
	ECHO Success^^!
	ECHO "%_OUTPUT_PDF_IMAGES%" is %_SIZE_DIFF% KB smaller than "%_INPUT_PDF%"
) ELSE (
	ECHO ===============================================================================
	ECHO:
	ECHO Failure^^!
	ECHO Output PDF is either same size ^(or larger^!^) than Input PDF.
	ECHO:
	ECHO  Input = %_INPUT_SIZE% B
	ECHO Output = %_OUTPUT_LOWRES_SIZE% B
	ECHO:
	ECHO  Input = "%_INPUT_PDF%"
	ECHO Output = "%_OUTPUT_PDF_IMAGES%"
	ECHO:
	ECHO Size difference = %_SIZE_DIFF% KB
	ECHO:
	ECHO -------------------------------------------------------------------------------
)
ECHO:
ECHO End %~nx0.
ECHO:
PAUSE

IF EXIST "%_PLACEHOLDER_PS%" (
	DEL "%_PLACEHOLDER_PS%"
)

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ENDLOCAL
EXIT
