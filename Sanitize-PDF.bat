@ECHO OFF
SETLOCAL

::Index: 
:: 1. :Parameters
:: 2. :ExternalFunctions
:: 3. :Main
:: 4. :DefineFunctions
:: 5. :Footer

REM Bugfix: Use "REM ECHO DEBUG*ING: " instead of "::ECHO DEBUG*ING: " to comment-out debugging lines, in case any are within IF statements.
REM ECHO DEBUGGING: Begin Parameters block.

REM -------------------------------------------------------------------------------

:Parameters

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param1 = PDF file to sanitize

SET "_INPUT_PDF="

::SET "_INPUT_PDF=%~nx1"

:: https://ss64.com/nt/syntax-args.html
:: %~n1 Expand %1 to a file Name without file extension or path - MyFile or if only a path is present, with no trailing backslash, the last folder in that path.
:: %~x1 Expand %1 to a file eXtension only - .txt

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Params2 = Output PDF and placeholder file names

SET "_OUTPUT_PDF=flattened.pdf"
SET "_OUTPUT_PDF_PS=flattened_postscript.pdf"
SET "_OUTPUT_PDF_IMAGES=flattened_lowres.pdf"

SET "_PLACEHOLDER_PS=flattened.ps"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param3 = DPI settings to use for image down-sizing (helps remove image metadata)

SET "_DPI=63"
SET "_DPI=120"
SET "_DPI=150"
SET "_DPI=200"
::SET "_DPI=300"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: End Parameters

REM -------------------------------------------------------------------------------

REM ECHO DEBUGGING: Begin ExternalFunctions block.

:ExternalFunctions
:: Load External functions and programs:

::Index of external functions: 
:: 1. choco.exe "%_CHOCO_INSTALLED%"
:: 2. gswin64c.exe (Ghostscript) "%_GSWIN64C_INSTALLED%"

::choco.exe
:-------------------------------------------------------------------------------
::IF /I "%_CHOCO_INSTALLED%"=="YES" choco upgrade javaruntime jre8 -y
::-------------------------------------------------------------------------------
:: Parameters
::SET "_CHOCO_INSTALLED=YES"
SET "_CHOCO_INSTALLED=NO"
::SET "_QUIET_ERRORS=NO"
SET "_QUIET_ERRORS=YES"
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Test: check if fake "choc" command fails. Redirect all text & error output to NULL (supress all output)
::choc /? >nul 2>&1 && ECHO "Choc" command exists?^!?^!
::choc /? >nul 2>&1 || ECHO "Choc" command does NOT exist^! ^(TEST SUCCESS^)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if the choco help command succeeds. Redirect text output to NULL but redirect error output to temp file.
SET "_ERROR_OUTPUT_FILE=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.txt"
choco /? >nul 2>&1 && SET "_CHOCO_INSTALLED=YES" & REM ECHO choco.exe help command succeeded. & REM choco help command returned success.
choco /? >nul 2>"%_ERROR_OUTPUT_FILE%" || (
	REM SET "_CHOCO_INSTALLED=NO"
	IF /I NOT "%_QUIET_ERRORS%"=="YES" (
		ECHO choco.exe help command failed. & REM choco help command failed.
		ECHO Error output text:
		ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		TYPE "%_ERROR_OUTPUT_FILE%"
		ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		ECHO:
	)
)
IF EXIST "%_ERROR_OUTPUT_FILE%" DEL /Q "%_ERROR_OUTPUT_FILE%" & REM Clean-up temp file ASAP.
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if %ChocolateyInstall% directory exists ($env:ChocolateyInstall for PowerShell)
IF EXIST "%ChocolateyInstall%" (
	SET "_CHOCO_INSTALLED=YES"
	REM ECHO "ChocolateyInstall" directory exists. 
	REM ECHO e.g. %%ChocolateyInstall%% or $env:ChocolateyInstall
) ELSE (
	REM SET "_CHOCO_INSTALLED=NO"
	IF /I NOT "%_QUIET_ERRORS%"=="YES" (
		ECHO "ChocolateyInstall" directory does NOT exist. 
	)
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:-------------------------------------------------------------------------------

::gswin64c.exe (Ghostscript)
:-------------------------------------------------------------------------------
::IF /I "%_GSWIN64C_INSTALLED%"=="YES" gswin64c
::-------------------------------------------------------------------------------
::GOTO GSWIN64C_SKIP
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Parameters
SET "_GSWIN64C_INSTALLED=NO"
SET "_QUIET_ERRORS=NO"
::SET "_QUIET_ERRORS=YES"
SET "_CHOCO_PKG=Ghostscript"
SET "_AFTER_ADMIN_ELEVATION=%Temp%\temp-gswin64c-function.txt"
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
REM Bugfix: Check if we have admin rights right now (even tho we may not need them), so that later functions can check the result without requiring EnableDelayedExpansion to be enabled.
REM ECHO DEBUGGING: _GOT_ADMIN = '%_GOT_ADMIN%'
::https://stackoverflow.com/questions/4051883/batch-script-how-to-check-for-admin-rights
NET SESSION >nul 2>&1 && SET "_GOT_ADMIN=YES"
NET SESSION >nul 2>&1 || SET "_GOT_ADMIN=NO"
REM ECHO DEBUGGING: _GOT_ADMIN = '%_GOT_ADMIN%'
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if we just got commands ready from a previous run.
IF EXIST "%_AFTER_ADMIN_ELEVATION%" (
	FOR /F "tokens=*" %%G IN (%_AFTER_ADMIN_ELEVATION%) DO (
		SET "_CHOICES_BEFORE_ELEVATION=%%~G"
	)
)
IF EXIST "%_AFTER_ADMIN_ELEVATION%" DEL /F /Q "%_AFTER_ADMIN_ELEVATION%" & REM Delete this file-var as soon as it's retrieved 
REM ECHO DEBUGGING: _CHOICES_BEFORE_ELEVATION = '%_CHOICES_BEFORE_ELEVATION%'
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if a Chocolatey Install was requested.
IF /I "%_CHOICES_BEFORE_ELEVATION%"=="ChocoInstallGhostscript" (
	REM Check if we have admin rights
	IF "%_GOT_ADMIN%"=="YES" (
		GOTO gswin64c_install
	) ELSE (
		ECHO:
		ECHO ERROR:
		ECHO -------------------------------------------------------------------------------
		ECHO Administrator rights elevation failed. Software install may fail.
		ECHO:
		ECHO Continue anyway?
		ECHO:
		PAUSE
		GOTO gswin64c_install
	)
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::Chocolatey install function
GOTO gswin64c_install_skip
:gswin64c_install
SET "_CHOCO_CMD_RESULT=FAILURE"
REM ECHO DEBUGGING: _CHOCO_CMD_RESULT = "%_CHOCO_CMD_RESULT%"
REM ECHO DEBUGGING: Installing %_CHOCO_PKG% via chocolatey...
REM PAUSE
choco install %_CHOCO_PKG% -y && SET "_CHOCO_CMD_RESULT=SUCCESS" && ECHO Chocolatey software installation succeeded.
REM ECHO DEBUGGING: _CHOCO_CMD_RESULT = "%_CHOCO_CMD_RESULT%"
IF /I NOT "%_CHOCO_CMD_RESULT%"=="SUCCESS" ( 
	REM Software install failed.
	ECHO %_CHOCO_PKG% install failed.
	ECHO:
	PAUSE
	GOTO END
) ELSE (
	REM Software install succeeded.
	ECHO:
	ECHO %_CHOCO_PKG% install complete, refreshing environment variables...
	PAUSE
	refreshenv
	ECHO Refresh complete^!
	REM ECHO DEBUGGING: Continue on with rest of script from here...
	PAUSE
	REM GOTO GSWIN64C_SKIP
	REM Bug: After reboot and _CHOICES_BEFORE_ELEVATION evaluation, returns to command line and does not continue. Must manuallly re-run script.
)
REM ECHO DEBUGGING: End of :gswin64c_install function.
REM Bug: Script will not make it this far to this message.
:gswin64c_install_skip
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Test if our External Function exists.
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if the gswin64c help command succeeds. Redirect text output to NULL but redirect error output to temp file.
SET "_ERROR_OUTPUT_FILE=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.txt"
gswin64c -h >nul 2>&1 && SET "_GSWIN64C_INSTALLED=YES" && SET "_GSWIN64C_EXE=gswin64c" & REM && ECHO gswin64c.exe help command succeeded.
gswin64c -h >nul 2>"%_ERROR_OUTPUT_FILE%" || (
	REM SET "_GSWIN64C_INSTALLED=NO"
	IF /I NOT "%_QUIET_ERRORS%"=="YES" (
		ECHO gswin64c.exe help command failed.
		ECHO Error output text:
		ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		TYPE "%_ERROR_OUTPUT_FILE%"
		IF EXIST "%_ERROR_OUTPUT_FILE%" DEL /Q "%_ERROR_OUTPUT_FILE%" & REM Clean-up temp file ASAP.
		ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		REM ECHO:
		REM PAUSE
	)
	IF EXIST "%_ERROR_OUTPUT_FILE%" DEL /Q "%_ERROR_OUTPUT_FILE%" & REM Clean-up temp file ASAP.
)
IF EXIST "%_ERROR_OUTPUT_FILE%" DEL /Q "%_ERROR_OUTPUT_FILE%" & REM Clean-up temp file ASAP.
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if the gswin64c.exe exists in Program Files directory
REM ECHO DEBUGGING: Looking for gswin64c.exe in Program Files "%ProgramFiles%"
IF NOT EXIST "%_GSWIN64C_EXE%" SET "_GSWIN64C_EXE="
SET "_FOLDER="
::https://stackoverflow.com/questions/53761805/use-multiple-wildcards-in-a-path-in-batch-file
REM ECHO DEBUGGING: "%ProgramFiles%\gs\gs*.**\bin\gswin64c.exe"
FOR /D %%G IN ("%ProgramFiles%\gs\gs*") DO (
	FOR /D %%H IN ("%%~G\bin") DO (
		SET "_FOLDER=%%~H"
	)
)
REM ECHO DEBUGGING: _FOLDER = %_FOLDER%
IF NOT EXIST "%_GSWIN64C_EXE%" SET "_GSWIN64C_EXE=%_FOLDER%\gswin64c.exe"
IF /I NOT "%_GSWIN64C_INSTALLED%"=="YES" (
	IF EXIST "%_GSWIN64C_EXE%" (
		REM ECHO DEBUGGING: Found "%_GSWIN64C_EXE%" 
		SET "_GSWIN64C_INSTALLED=YES"
		IF /I "%_GOT_ADMIN%"=="YES" (
			IF EXIST "%ChocolateyInstall%\tools\shimgen.exe" (
				REM ECHO DEBUGGING: Shimming gswin64c . . .
				REM "%ChocolateyInstall%\tools\shimgen.exe" --output="gswin64c" --path="C:\Program Files\gs\gs9.27\bin\gswin64c.exe"
				"%ChocolateyInstall%\tools\shimgen.exe" --output="gswin64c" --path="%_GSWIN64C_EXE%"
			) ELSE (
				REM ECHO DEBUGGING: Adding gswin64c to PATH . . .
				SETX PATH "%PATH%;%_FOLDER%"
			)
		) ELSE (
			REM ECHO DEBUGGING: Adding gswin64c to PATH . . .
			SETX PATH "%PATH%;%_FOLDER%"
		)
		IF /I "%_CHOCO_INSTALLED%"=="YES" (
			ECHO Refreshing environment variables...
			PAUSE
			refreshenv
			ECHO Refresh complete^!
			REM ECHO DEBUGGING: Continue on with rest of script from here...
			PAUSE
			REM GOTO GSWIN64C_SKIP
		) ELSE (
			ECHO Please restart the script to update environment variables.
			ECHO:
			PAUSE
			GOTO END
		)
	)
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if the gswin64c.exe exists in Program Files (x86) directory
REM ECHO DEBUGGING: Looking for gswin64c.exe in Program Files "%ProgramFiles(x86)%"
IF NOT EXIST "%_GSWIN64C_EXE%" SET "_GSWIN64C_EXE="
SET "_FOLDER="
REM ECHO DEBUGGING: "%ProgramFiles(x86)%\gs\gs*.**\bin\gswin64c.exe"
FOR /D %%G IN ("%ProgramFiles(x86)%\gs\gs*") DO (
	FOR /D %%H IN ("%%~G\bin") DO (
		SET "_FOLDER=%%~H"
	)
)
REM ECHO DEBUGGING: _FOLDER = %_FOLDER%
IF NOT EXIST "%_GSWIN64C_EXE%" SET "_GSWIN64C_EXE=%_FOLDER%\gswin64c.exe"
IF /I NOT "%_GSWIN64C_INSTALLED%"=="YES" (
	IF EXIST "%_GSWIN64C_EXE%" (
		REM ECHO DEBUGGING: Found "%_GSWIN64C_EXE%" 
		SET "_GSWIN64C_INSTALLED=YES"
		IF /I "%_GOT_ADMIN%"=="YES" (
			IF EXIST "%ChocolateyInstall%\tools\shimgen.exe" (
				REM ECHO DEBUGGING: Shimming gswin64c . . .
				REM "%ChocolateyInstall%\tools\shimgen.exe" --output="gswin64c" --path="C:\Program Files\gs\gs9.27\bin\gswin64c.exe"
				"%ChocolateyInstall%\tools\shimgen.exe" --output="gswin64c" --path="%_GSWIN64C_EXE%"
			) ELSE (
				REM ECHO DEBUGGING: Adding gswin64c to PATH . . .
				SETX PATH "%PATH%;%_FOLDER%"
			)
		) ELSE (
			REM ECHO DEBUGGING: Adding gswin64c to PATH . . .
			SETX PATH "%PATH%;%_FOLDER%"
		)
		IF /I "%_CHOCO_INSTALLED%"=="YES" (
			ECHO Refreshing environment variables...
			PAUSE
			refreshenv
			ECHO Refresh complete^!
			REM ECHO DEBUGGING: Continue on with rest of script from here...
			PAUSE
			REM GOTO GSWIN64C_SKIP
		) ELSE (
			ECHO Please restart the script to update environment variables.
			ECHO:
			PAUSE
			GOTO END
		)
	)
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Cast errors if our External Function is still not found. Attempt to install it automatically if Chocolatey or Boxstarter functions are found.
REM ECHO DEBUGGING: Call errors and installers if script is still not found . . .
IF /I "%_GSWIN64C_INSTALLED%"=="NO" (
	ECHO:
	ECHO EXTERNAL FUNCTION NOT FOUND
	ECHO -------------------------------------------------------------------------------
	ECHO ERROR: Cannot find gswin64c.exe
	ECHO:
	IF /I "%_CHOCO_INSTALLED%"=="YES" (
		ECHO This software can be installed via chocolatey ^(Run As Administrator^):
		ECHO:
		ECHO https://chocolatey.org/packages/%_CHOCO_PKG%
		ECHO ^> choco install %_CHOCO_PKG% -y
		ECHO:
		REM https://ss64.com/nt/choice.html
		CHOICE /M "Would you like to install it now?"
		IF ERRORLEVEL 2 ECHO Please install %_CHOCO_PKG% before running script again. & ECHO: & PAUSE & GOTO END
		IF ERRORLEVEL 1 REM Yes.
		REM Check if we have admin rights
		IF /I "%_GOT_ADMIN%"=="YES" (
			ECHO Elevated Permissions: YES
			ECHO:
			GOTO gswin64c_install
		) ELSE ( 
			ECHO Elevated Permissions: NO
			REM -------------------------------------------------------------------------------
			REM Bugfix: cannot use :: for comments within IF statement, instead use REM
			REM Bugfix: cannot use ECHO( for newlines within IF statement, instead use ECHO. or ECHO: 
			REM ECHO -------------------------------------------------------------------------------
			ECHO:
			ECHO ChocoInstallGhostscript> "%_AFTER_ADMIN_ELEVATION%"
			REM PAUSE
			GOTO ElevateMe
		)
	) ELSE (
		REM Chocolatey is not installed.
		ECHO Is Ghostscript installed? ^(contains gswin64c^)
		ECHO:
		ECHO This software can be installed via chocolatey:
		ECHO:
		ECHO https://chocolatey.org/packages/%_CHOCO_PKG%
		ECHO:
		ECHO ^> choco install %_CHOCO_PKG% -y
		ECHO:
		ECHO Or manually via:
		ECHO:
		ECHO http://ghostscript.com/
		ECHO -------------------------------------------------------------------------------
		ECHO:
		PAUSE
		GOTO END
	)
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
REM ECHO DEBUGGING: End of gswin64c.exe External Function.
:GSWIN64C_SKIP
:-------------------------------------------------------------------------------

::End ExternalFunctions

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:Main

REM ECHO DEBUGGING: Beginning Main execution block.

::Index of Main:

::===============================================================================
:: Phase 1: Evaluate input parameters
:: Phase 2: Test :GetIfPathIsDriveRoot
:: Phase 3: Test :GetWindowsVersion
:: Phase 4: Test Banner.cmd (external function)
:: Phase 5: Test :GetTerminalWidth
:: Phase 6: Test :CheckLink
:: Phase 7: Test :GetDate, :ConvertTimeToSeconds, and :ConvertSecondsToTime
:: Phase 8: Test :InitLog and :InitLogOriginal
:: Phase 9: Test :CreateShortcut, :CreateSymbolicLink, and :CreateSymbolicDirLink
::===============================================================================

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 1: Evaluate input parameters
::===============================================================================


:: Always prefer parameters passed via command line over hard-coded vars.
SET "_CALLED_FROM_SCRIPT=DISABLED"
IF NOT "%~1"=="" (
	SET "_CALLED_FROM_SCRIPT=ACTIVE"
	SET "_INPUT_PDF=%~1"
)

IF "%_INPUT_PDF%"=="" (
	ECHO:
	ECHO No input file.
	ECHO:
	PAUSE
	GOTO END
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
	ECHO Success^!
	ECHO "%_OUTPUT_PDF%" is %_SIZE_DIFF% KB smaller than "%_INPUT_PDF%"
) ELSE (
	ECHO ===============================================================================
	ECHO:
	ECHO Failure^!
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
	ECHO Success^!
	ECHO "%_OUTPUT_PDF_IMAGES%" is %_SIZE_DIFF% KB smaller than "%_INPUT_PDF%"
) ELSE (
	ECHO ===============================================================================
	ECHO:
	ECHO Failure^!
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

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: End Main

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
REM ===============================================================================
REM -------------------------------------------------------------------------------

:: <-- Footer could also go here -->

:: End Footer

REM -------------------------------------------------------------------------------

REM ECHO DEBUGGING: Begin DefineFunctions block.

:DefineFunctions
:: Declare Functions

::Index of functions: 
:: 1. :SampleFunction
:: 2. :DisplayHelp
:: 3. :Wait
:: 4. :ElevateMe
:: 5. :GetAdmin
:: 6. :AddToPATH
:: 7. :RemoveFromPATH

GOTO SkipFunctions
:-------------------------------------------------------------------------------
:SampleFunction RequiredParam [OptionalParam]
:: Dependences: other functions this one is dependent on.
:: Description for SampleFunction's purpose & ability.
:: Description of RequiredParam and OptionalParam.
:: Outputs:
:: "%_SAMPLE_OUTPUT_1%"
:: "%_SAMPLE_OUTPUT_2%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@ECHO OFF
::SETLOCAL
SETLOCAL EnableDelayedExpansion
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SET "_required_param=%1"
SET "_optional_param=%2"
:: Also works: IF [%1]==[] (
IF [!_required_param!]==[] (
	ECHO ERROR in SampleFunction^! No Required Parameter.
	ECHO:
	PAUSE
	ENDLOCAL
	EXIT /B
)
:: Also works: IF [%2]==[] (
IF [!_optional_param!]==[] (
	REM https://ss64.com/nt/syntax-args.html
	SET "_use_optional=NOPE."
) ELSE (
	SET "_use_optional=YUP."
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Do things here.

SET "_result=%_required_param%"

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL & SET "_SAMPLE_OUTPUT_1=%_result%" & SET "_SAMPLE_OUTPUT_2=%_use_optional%"
EXIT /B
:-------------------------------------------------------------------------------
:ElevateMe
::GOTO :ElevateMe
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: wait 2 seconds, in case this user is not in Administrators group. (To prevent an infinite loop of UAC admin requests on a restricted user account.)
ECHO Requesting administrative privileges... ^(waiting 2 seconds^)
PING -n 3 127.0.0.1 > nul
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::Create and run a temporary VBScript to elevate this batch file
:: https://ss64.com/nt/syntax-args.html
SET _batchFile=%~s0
::SET _batchFile=%~f0
SET "_Args=%*"
IF NOT [%_Args%]==[] (
	REM double up any quotes
	REM https://ss64.com/nt/syntax-replace.html
	SET "_Args=%_Args:"=""%"
	REM Debugging: cannot use :: for comments within IF statement, instead use REM
)
:: https://ss64.com/nt/if.html
IF ["%_Args%"] EQU [""] ( 
	SET "_CMD_RUN=%_batchFile%"
) ELSE ( 
	SET "_CMD_RUN=""%_batchFile%"" %_Args%"
)
:: https://ss64.com/vb/shellexecute.html
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%Temp%\~ElevateMe.vbs"
::ECHO UAC.ShellExecute "CMD", "/C ""%_CMD_RUN%""", "", "RUNAS", 1 >> "%Temp%\~ElevateMe.vbs"
ECHO UAC.ShellExecute "CMD", "/K ""%_CMD_RUN%""", "", "RUNAS", 1 >> "%Temp%\~ElevateMe.vbs"
::ECHO UAC.ShellExecute "CMD", "/K ""%_batchFile% %_Args%""", "", "RUNAS", 1 >> "%temp%\~ElevateMe.vbs"

cscript "%Temp%\~ElevateMe.vbs" 
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
EXIT /B
:-------------------------------------------------------------------------------
:GetAdmin
::CALL :GetAdmin
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: wait 2 seconds, in case this user is not in Administrators group. (To prevent an infinite loop of UAC admin requests on a restricted user account.)
ECHO Requesting administrative privileges... ^(waiting 2 seconds^)
PING -n 3 127.0.0.1 > nul
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%Temp%\getadmin.vbs"
ECHO UAC.ShellExecute "%~s0", "", "", "RUNAS", 1 >> "%Temp%\getadmin.vbs"

"%Temp%\getadmin.vbs"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
EXIT /B
:-------------------------------------------------------------------------------
:AddToPATH "PathToAdd"
::CALL :AddToPATH "C:/Path/to/Add"
:: Add string to PATH variable, if it doesn't already exist there.
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SETLOCAL
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SET "_PATH_TO_ADD=%~1"
IF "%_PATH_TO_ADD%"=="" (
	ECHO ERROR in AddToPATH^! No path to add supplied.
	ECHO:
	PAUSE
	ENDLOCAL
	EXIT /B
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if PATH var already contains the path we're trying to add.
SET "_CONTAINS=NO"
FOR /F "tokens=* delims=;" %%G IN ("%PATH%") DO (
	IF "%%~G"=="%_PATH_TO_ADD%" (
		SET "_CONTAINS=YES"
	)
)
REM ECHO DEBUGGING: Does PATH conatin "%_PATH_TO_ADD%"? = %_CONTAINS%
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Add to PATH
IF /I "%_CONTAINS%"=="NO" SETX PATH "%PATH%;%_PATH_TO_ADD%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL
EXIT /B
:-------------------------------------------------------------------------------
:RemoveFromPATH "PathToRemove"
::CALL :RemoveFromPATH "C:/Path/to/Remove"
:: Remove string from PATH variable.
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SETLOCAL
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SET "_PATH_TO_REMOVE=%~1"
IF "%_PATH_TO_REMOVE%"=="" (
	ECHO ERROR in RemoveFromPATH^! No path to remove supplied.
	ECHO:
	PAUSE
	ENDLOCAL
	EXIT /B
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Remove from PATH
::https://stackoverflow.com/questions/21289762/remove-unwanted-path-name-from-path-variable-via-batch#39141462
SETX /M PATH "%PATH:;%_PATH_TO_REMOVE%=%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL
EXIT /B
:-------------------------------------------------------------------------------
:: End functions
:SkipFunctions

:Footer
:END
ENDLOCAL
EXIT /B
