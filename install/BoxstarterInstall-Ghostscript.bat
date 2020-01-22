@ECHO OFF
::SETLOCAL
SETLOCAL EnableDelayedExpansion

::Index: 
:: 1. :RunAsAdministrator
:: 2. :Header
:: 3. :Parameters
:: 4. :ExternalFunctions
:: 5. :Main
:: 6. :DefineFunctions
:: 7. :Footer

:RunAsAdministrator
:: BatchGotAdmin International-Fix Code
:: https://sites.google.com/site/eneerge/home/BatchGotAdmin
:-------------------------------------------------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
IF '%ERRORLEVEL%' NEQ '0' (
    ECHO Requesting administrative privileges... ^(waiting 2 seconds^)
	PING -n 3 127.0.0.1>nul
    GOTO UACPrompt
) ELSE ( GOTO gotAdmin )

:UACPrompt
    ECHO Set UAC = CreateObject^("Shell.Application"^) > "%Temp%\getadmin.vbs"
    ECHO UAC.ShellExecute "%~s0", "", "", "RUNAS", 1 >> "%Temp%\getadmin.vbs"

    "%Temp%\getadmin.vbs"
    EXIT /B

:gotAdmin
    IF EXIST "%Temp%\getadmin.vbs" ( DEL "%Temp%\getadmin.vbs" )
    PUSHD "%CD%"
    CD /D "%~dp0"
	ECHO BatchGotAdmin Permissions set.
:-------------------------------------------------------------------------------
:: End Run-As-Administrator function

:Header
::GOTO SkipHeader & REM Un-comment this line to skip Header
CLS
ECHO Boxstarter Template ^( %~nx0 ^) & REM This script's file name and extension. https://ss64.com/nt/syntax-args.html
ECHO Working directory: %~dp0 & REM The drive letter and path of this script's location.
REM Debugging: cannot use :: for comments within IF statement, instead use REM
:SkipHeader

:: End Header

REM -------------------------------------------------------------------------------

:Parameters

REM -------------------------------------------------------------------------------

:: Param1 = 

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Boxstarter launcher

:: Compose the Boxstarter script in *.txt file on Gist. Other than Boxstarter commands, the syntax is already familiar with Chocolatey
:: After saving the Gist, click the "View Raw" link
:: Copy the raw URL and replace %_GistRawAddr% with it:
::START /D "%ProgramFiles%\Internet Explorer" iexplore.exe http://boxstarter.org/package/url?%_GistRawAddr%

:: Github Gist scripts
:: http://boxstarter.org/Learn/WebLauncher

:: 1
SET "_GistRawAddr=https://gist.githubusercontent.com/Kerbalnut/19f9225e7470e58c70fa9f06fbce7e33/raw/af9805556bc73bcc9499c484dfb8283b33b800ee/Install-WindowsUpdates.txt"

:: "NR" stands for "No Reboot" so the computer will not restart during Boxstarter process
:: http://boxstarter.org/package/nr/url?%_GistRawAddr%

:: Otherwise if you do not include the "NR" Boxstarter will manage reboots and automatically log user back in so you do not have to attend the machine throughout
:: http://boxstarter.org/package/url?%_GistRawAddr%

:: Additionally, if the script is saved locally to a single text file, the path can be added to the Boxstarter URL, again separated by a '?'.
:: START http://boxstarter.org/package/nr/url?c:\temp\myscript.txt
:: http://boxstarter.org/package/nr/url?%_LocalFolderPath%boxstarter-CleanupTools.txt
:: http://boxstarter.org/package/nr/url?%_LocalFolderPath%%_LocalFileName%

:: 2
:: https://ss64.com/nt/syntax-args.html
SET "_LocalScriptPckg=%~dpn0.txt" & REM %~dpn0.txt = This script's [D]rive letter, folder [P]ath, & [N]ame with a .txt extension. https://ss64.com/nt/syntax-args.html

:: E.g.
:: if you name your your new project script "BoxstarterInstall-MyNewProject.bat" then %~dpn0.txt will point to "BoxstarterInstall-MyNewProject.txt" stored in the same folder.

:: Installing several packages
:: While often install scripts may be complex and the information on this page will show you how to capture such scripts in a gist, if you simply want to install a list of chocolatey packages, you can use this URL:

:: http://boxstarter.org/package/sysinternals,kdiff3,fiddler4,itunes
:: http://boxstarter.org/package/nr/sysinternals,kdiff3,fiddler4,itunes

:: You can also install any package on the public Chocolatey.org feed as well as the Boxstarter community feed on MyGet.org. To install these packages, use the package name instead of URL. So if you wanted to install FireFox, you would use http://boxstarter.org/package/nr/firefox.

:: Separate multiple packages with a single comma e.g. http://boxstarter.org/package/nr/firefox,googlechrome,wincdemu

:: 3
SET "_ChocolateyPackages=Ghostscript"

:: Choose which Boxstarter source mode to use: 
SET "_BoxstarterSource=3" & REM : 1 = Gist address, 2 = Local file, 3 = Package list

REM -------------------------------------------------------------------------------

:: Param2 = Instructions / Description

SET "_INSTRUCTIONS_FILE=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.txt"

:: create file with contents = > 
:: append to file = >>
REM >-------------------------------------------------------------------------------
REM >  INSTRUCTIONS: 
REM >
REM >-------------------------------------------------------------------------------
ECHO   This script will invoke Boxstarter, an automatic software installation > "%_INSTRUCTIONS_FILE%"
ECHO   utility, which is essentially a wrapper for Chocolatey, a software packaging>> "%_INSTRUCTIONS_FILE%"
ECHO   manager. This script you're about to run,>> "%_INSTRUCTIONS_FILE%"
ECHO:>> "%_INSTRUCTIONS_FILE%"
ECHO   %~nx0>> "%_INSTRUCTIONS_FILE%"
ECHO:>> "%_INSTRUCTIONS_FILE%"
ECHO   is essentially a wrapper for Boxstarter. It will automatically generate a URL>> "%_INSTRUCTIONS_FILE%"
ECHO   based on our Ghostscript package, pointing to a Boxstarter on-demand script,>> "%_INSTRUCTIONS_FILE%"
ECHO   calling from the only browser that supports it: Internet Explorer.>> "%_INSTRUCTIONS_FILE%"
ECHO:>> "%_INSTRUCTIONS_FILE%"
ECHO   #########>> "%_INSTRUCTIONS_FILE%"
ECHO   ## TL;DR:  If successful, many screens will flash, and Ghostscript will >> "%_INSTRUCTIONS_FILE%"
ECHO   ##         automatically be installed. >> "%_INSTRUCTIONS_FILE%"
ECHO   #########>> "%_INSTRUCTIONS_FILE%"
REM >-------------------------------------------------------------------------------
REM >-------------------------------------------------------------------------------
REM >  INSTRUCTIONS: 
REM >
::ECHO   Write a basic explanation of what will be installed here, so users or forget-> "%_INSTRUCTIONS_FILE%"
::ECHO   ful admins can be sure of what this package does before they run it.>> "%_INSTRUCTIONS_FILE%"
::ECHO:>> "%_INSTRUCTIONS_FILE%"
::ECHO   The quick brown fox jumps over the lazy dog. The quick brown fox jumps over>> "%_INSTRUCTIONS_FILE%"
::ECHO   the lazy dog.>> "%_INSTRUCTIONS_FILE%"
REM >-------------------------------------------------------------------------------

REM -------------------------------------------------------------------------------

:: End Parameters

REM -------------------------------------------------------------------------------

REM ECHO DEBUGGING: Begin ExternalFunctions block.

:ExternalFunctions
:: Load External functions and programs:

::Index of external functions: 
:: 1. choco.exe "%_CHOCO_INSTALLED%"

::choco.exe
:-------------------------------------------------------------------------------
::IF /I "%_CHOCO_INSTALLED%"=="YES" choco upgrade javaruntime -y
::-------------------------------------------------------------------------------
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
choco /? >nul 2>%_ERROR_OUTPUT_FILE% || (
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

::End ExternalFunctions

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:Main

::===============================================================================
:: Phase 1: Evaluate Parameters
:: Phase 2: Check system compatibility & internet connection
:: Phase 3: Prompt user to review install package & choose reboot options
:: Phase 4: Run Boxstarter with provided parameters
::===============================================================================

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 1: Evaluate Parameters
::===============================================================================

:: Activate help function
IF NOT "%~1"=="" (
	REM Debugging: cannot use :: for comments within IF statement, instead use REM
	IF /I "%~1"=="help" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
	IF /I "%~1"=="-h" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
	IF /I "%~1"=="-help" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
	IF /I "%~1"=="--help" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
	IF /I "%~1"=="/?" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
	IF /I "%~1"=="/h" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
	IF /I "%~1"=="/help" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
)

REM ECHO DEBUGGING: Finished help evaluation.

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Always prefer parameters passed via command line over hard-coded vars.
SET "_CALLED_FROM_SCRIPT=DISABLED"
IF NOT "%~1"=="" (
	SET "_CALLED_FROM_SCRIPT=ACTIVE"
)

::IF /I NOT "%_CALLED_FROM_SCRIPT%"=="ACTIVE" CLS

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 2: Check system compatibility & internet connection
::===============================================================================

ECHO(
ECHO Detecting Windows OS version compatibility . . . 
ECHO(

CALL :GetWindowsVersion

IF %_WindowsVersion% LSS 6 (
	ECHO. 
	ECHO WARNING:
	ECHO. 
	ECHO This program is only designed to work with Windows Vista and above.
	ECHO. 
	ECHO Proceed at your own risk.
	ECHO.
	PAUSE
)

ECHO(
ECHO Checking internet connection . . . 
ECHO(

CALL :CheckLink 8.8.8.8
::CALL :CheckLink 8.8.4.4

IF "%_LinkState%"=="down" (
	ECHO.
	ECHO Could not establish internet connection.
	ECHO.
	ECHO Please troubleshoot network connectivity.
	ECHO.
	PAUSE
	GOTO END
)

ECHO(
ECHO Testing Domain Name resolution . . . 
ECHO(

::CALL :CheckLink google.com
::CALL :CheckLink bing.com
CALL :CheckLink yahoo.com

IF "%_LinkState%"=="down" (
	ECHO.
	ECHO Could not confirm DNS resolution. 
	ECHO.
	ECHO Please troubleshoot name resolution service.
	ECHO.
	PAUSE
	REM EXIT
	REM Debugging: cannot use :: for comments within IF statement, instead use REM
)

::===============================================================================
:: Phase 3: Prompt user to review install package & choose reboot options
::===============================================================================

REM -------------------------------------------------------------------------------

:: If Chocolatey Packages list mode is enabled, stretch it out into a multi-line list

:: Method #1: FOR Loop
SET "_CHOCO_PKG_LIST_FILE=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.txt"
IF %_BoxstarterSource% EQU 3 (
	FOR %%G IN (%_ChocolateyPackages%) DO (
		REM ECHO   - %%G
		ECHO   - %%G>> "%_CHOCO_PKG_LIST_FILE%"
	)
	REM ECHO Type file:
	REM TYPE "%_CHOCO_PKG_LIST_FILE%"
	REM DEL /Q "%_CHOCO_PKG_LIST_FILE%" & REM Clean-up temp file ASAP.
)

:: Method #2: Replace character with newline character
IF %_BoxstarterSource% EQU 3 (
	REM Thanks to:
	REM https://stackoverflow.com/questions/24877969/replace-string-with-a-new-line-in-batch
	SET "_ChocolateyPackages_InitialSpaces=  - %_ChocolateyPackages%"
	SET "_ChocolateyPackages_Spaces=!_ChocolateyPackages_InitialSpaces:,=,  - !"
SET _ChocolateyPackages_List=!_ChocolateyPackages_Spaces:,=^

!
	REM ECHO !_ChocolateyPackages_List!
)

REM -------------------------------------------------------------------------------

:: Get _LocalScriptPckg Name & eXtention, Drive letter & folder Path
FOR %%G IN ("%_LocalScriptPckg%") DO SET "_LocalFileName=%%~nxG"
FOR %%G IN ("%_LocalScriptPckg%") DO SET "_LocalFolderPath=%%~dpG"

REM -------------------------------------------------------------------------------

CLS
ECHO Run program: ^( %~nx0 ^)
ECHO:
ECHO -------------------------------------------------------------------------------
ECHO:
ECHO   INSTRUCTIONS: 
ECHO:
TYPE "%_INSTRUCTIONS_FILE%"
DEL /Q "%_INSTRUCTIONS_FILE%" & REM Clean-up temp file ASAP.
ECHO:
IF %_BoxstarterSource% EQU 3 (
ECHO   The following Chocolatey packages will be installed:
ECHO:
REM ECHO   %_ChocolateyPackages%
REM ECHO !_ChocolateyPackages_List!
TYPE "%_CHOCO_PKG_LIST_FILE%"
DEL /Q "%_CHOCO_PKG_LIST_FILE%" & REM Clean-up temp file ASAP.
) ELSE IF %_BoxstarterSource% EQU 2 (
ECHO   Boxstarter source: Text File
ECHO   "%_LocalFileName%"
) ELSE IF %_BoxstarterSource% EQU 1 (
ECHO   Boxstarter source: Gist Address
ECHO   %_GistRawAddr%
)
ECHO:
ECHO -------------------------------------------------------------------------------
PAUSE
:: Open the text file holding the boxstarter script about to be called, so that it can be reviewed before running.
IF %_BoxstarterSource% EQU 2 (
	ECHO:
	ECHO CLOSE NOTEPAD WHEN READY:
	%_LocalFolderPath%%_LocalFileName%
)
IF %_BoxstarterSource% EQU 1 (
	IF EXIST "%ProgramFiles%\Internet Explorer\iexplore.exe" (
		ECHO:
		ECHO CLOSE BROWSER WHEN READY:
		START /D "%ProgramFiles%\Internet Explorer" iexplore.exe "%_GistRawAddr%"
	) ELSE IF EXIST "%ProgramFiles(x86)%\Internet Explorer\iexplore.exe" (
		ECHO:
		ECHO CLOSE BROWSER WHEN READY:
		START /D "%ProgramFiles(x86)%\Internet Explorer" iexplore.exe "%_GistRawAddr%"
	)
)
:: Get reboot option
ECHO(
IF "%_WindowsVersion%"=="10" (
	REM ECHO -------------------------------------------------------------------------------
	ECHO Not Recommended for Windows 10. 
	ECHO The computer may reboot immediately if a pending reboot is detected, before 
	ECHO installing any software.
	REM >-------------------------------------------------------------------------------
	ECHO Windows 10 Updates are triggered to install when a reboot happens, and can take
	ECHO hours.
) ELSE ( 
	ECHO RECOMMENED:
)
ECHO(
ECHO Do you want the computer to reboot itself automatically (as necessary)?
::ECHO Will you allow the computer to automatically restart (if necessary)?
ECHO(
ECHO This will require you to type in your password again, so it can be entered 
CHOICE /M "automatically after reboot."
::CHOICE /M "Will you allow the computer to automatically restart (if necessary)?"
IF ERRORLEVEL 2 SET "_BoxstarterLauncher=http://boxstarter.org/package/nr/" & ECHO NO. & GOTO NRchoice
IF ERRORLEVEL 1 SET "_BoxstarterLauncher=http://boxstarter.org/package/" & ECHO YES. & GOTO NRchoice
ECHO(
ECHO ERROR: Invalid choice / Choice not recognized.
ECHO(
ECHO Defaulting to No Reboots Allowed.
SET "_BoxstarterLauncher=http://boxstarter.org/package/nr/"
ECHO(
PAUSE
:NRchoice
ECHO(

::===============================================================================
:: Phase 4: Run Boxstarter with provided parameters
::===============================================================================

:: Boxstarter Source
IF %_BoxstarterSource% EQU 1 (
	REM Gist file web address
	SET "_BoxstarterURL=%_BoxstarterLauncher%url?%_GistRawAddr%
	ECHO Gist source selected:
	ECHO %_GistRawAddr%
	ECHO:
) ELSE IF %_BoxstarterSource% EQU 2 (
	REM Local file saved alongside script
	SET "_BoxstarterURL=%_BoxstarterLauncher%url?%_LocalFolderPath%%_LocalFileName%"
	ECHO Local file selected: %_LocalFileName%
	ECHO:
) ELSE IF %_BoxstarterSource% EQU 3 (
	REM Chocolatey package list
	SET "_BoxstarterURL=%_BoxstarterLauncher%%_ChocolateyPackages%"
	ECHO Chocolatey packages selected: %_ChocolateyPackages%
	ECHO:
) ELSE (
	REM Error interpreting choice
	CLS
	ECHO -------------------------------------------------------------------------------
	ECHO:
	ECHO   ERROR: Invalid script parameter
	ECHO:
	ECHO -------------------------------------------------------------------------------
	ECHO.
	ECHO "_BoxstarterSource" is set to "%_BoxstarterSource%"
	ECHO.
	ECHO Valid values to indicate choice of Boxstarter source are:
	ECHO.
	ECHO   1 = Gist address
	ECHO   2 = Local file
	ECHO   3 = Chocolatey package list
	ECHO.
	ECHO Please edit the "_BoxstarterSource" value to be one of the three options.
	ECHO.
	ECHO %~dpnx0
	ECHO.
	PAUSE
	START "" notepad.exe %0 & REM After notepad opens, cmd.exe stops and waits for it to close anyway, so it's like it has PAUSE already
	GOTO END
	REM -------------------------------------------------------------------------------
	REM Debugging: cannot use :: for comments within IF statement, instead use REM
	REM Debugging: cannot use ECHO( for newlines within IF statement, instead use ECHO. or ECHO: 
)

ECHO Launch URL: 
ECHO(
ECHO %_BoxstarterURL%
ECHO(
ECHO  Boxstarter is about to begin.
ECHO(
::PAUSE
ECHO(

:: Launch this from IE and the Boxstarter launcher should install and run. Note that this will not work on Chrome or Firefox unless you have a "Click-Once" extension.

IF EXIST "%ProgramFiles%\Internet Explorer\iexplore.exe" (
	START /D "%ProgramFiles%\Internet Explorer" iexplore.exe %_BoxstarterURL%
) ELSE (
	IF EXIST "%ProgramFiles(x86)%\Internet Explorer\iexplore.exe" (
		START /D "%ProgramFiles(x86)%\Internet Explorer" iexplore.exe %_BoxstarterURL%
	) ELSE (
		CLS
		ECHO -------------------------------------------------------------------------------
		ECHO:
		ECHO   ERROR: Internet Explorer not found.
		ECHO:
		ECHO -------------------------------------------------------------------------------
		ECHO.
		ECHO Could not automatically locate path to Internet Explorer ^(IE^):
		ECHO.
		ECHO "%ProgramFiles%\Internet Explorer\iexplore.exe"
		ECHO "%ProgramFiles(x86)%\Internet Explorer\iexplore.exe"
		ECHO.
		ECHO Please ensure Internet Explorer is installed correctly.
		ECHO.
		ECHO Or, copy-and-paste this Launch URL into IE yourself ^(other browsers will not
		ECHO work properly without modification^):
		ECHO.
		ECHO -------------------------------------------------------------------------------
		ECHO.
		ECHO %_BoxstarterURL%
		ECHO.
		ECHO -------------------------------------------------------------------------------
		ECHO. 
		PAUSE
	)
)

ECHO -------------------------------------------------------------------------------

:: End Main

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
REM ===============================================================================
REM -------------------------------------------------------------------------------

:: <-- Footer could also go here -->

:: End Footer

REM -------------------------------------------------------------------------------

REM ECHO DEBUGGING: Begin DefineFunctions block.

::Index of functions: 
:: 1. :DisplayHelp
:: 2. :CheckLink
:: 3. :GetWindowsVersion

GOTO SkipFunctions
:: Declare Functions
:DefineFunctions
:-------------------------------------------------------------------------------
:DisplayHelp
::CALL :DisplayHelp
:: Display help splash text.
@ECHO OFF
SETLOCAL
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::C:\Users\[Username]>ipconfig /?
::
::USAGE:
::    ipconfig [/allcompartments] [/? | /all |
::                                 /renew [adapter] | /release [adapter] |
::                                 /renew6 [adapter] | /release6 [adapter] |
::                                 /flushdns | /displaydns | /registerdns |
::                                 /showclassid adapter |
::                                 /setclassid adapter [classid] |
::                                 /showclassid6 adapter |
::                                 /setclassid6 adapter [classid] ]
::
::where
::    adapter             Connection name
::                       (wildcard characters * and ? allowed, see examples)
::
::    Options:
::       /?               Display this help message
::       /all             Display full configuration information.
::       /release         Release the IPv4 address for the specified adapter.
::       /release6        Release the IPv6 address for the specified adapter.
::       /renew           Renew the IPv4 address for the specified adapter.
::       /renew6          Renew the IPv6 address for the specified adapter.
::       /flushdns        Purges the DNS Resolver cache.
::       /registerdns     Refreshes all DHCP leases and re-registers DNS names
::       /displaydns      Display the contents of the DNS Resolver Cache.
::       /showclassid     Displays all the dhcp class IDs allowed for adapter.
::       /setclassid      Modifies the dhcp class id.
::       /showclassid6    Displays all the IPv6 DHCP class IDs allowed for adapter.
::       /setclassid6     Modifies the IPv6 DHCP class id.
::
::
::The default is to display only the IP address, subnet mask and
::default gateway for each adapter bound to TCP/IP.
::
::For Release and Renew, if no adapter name is specified, then the IP address
::leases for all adapters bound to TCP/IP will be released or renewed.
::
::For Setclassid and Setclassid6, if no ClassId is specified, then the ClassId is removed.
::
::Examples:
::    > ipconfig                       ... Show information
::    > ipconfig /all                  ... Show detailed information
::    > ipconfig /renew                ... renew all adapters
::    > ipconfig /renew EL*            ... renew any connection that has its
::                                         name starting with EL
::    > ipconfig /release *Con*        ... release all matching connections,
::                                         eg. "Wired Ethernet Connection 1" or
::                                             "Wired Ethernet Connection 2"
::    > ipconfig /allcompartments      ... Show information about all
::                                         compartments
::    > ipconfig /allcompartments /all ... Show detailed information about all
::                                         compartments
::
::C:\Users\[Username]>_
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::C:\Users\[Username]>tracert /?
::
::Usage: tracert [-d] [-h maximum_hops] [-j host-list] [-w timeout]
::               [-R] [-S srcaddr] [-4] [-6] target_name
::
::Options:
::    -d                 Do not resolve addresses to hostnames.
::    -h maximum_hops    Maximum number of hops to search for target.
::    -j host-list       Loose source route along host-list (IPv4-only).
::    -w timeout         Wait timeout milliseconds for each reply.
::    -R                 Trace round-trip path (IPv6-only).
::    -S srcaddr         Source address to use (IPv6-only).
::    -4                 Force using IPv4.
::    -6                 Force using IPv6.
::
::C:\Users\[Username]>_
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO:
ECHO ===============================================================================
::ECHO:
ECHO Called from: "%~dp0"
ECHO:
ECHO %~n0 command-line help.
::ECHO:
ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO:
ECHO USAGE: .\%~nx0 "path_to_file_a" "path_to_file_b" [banner]
ECHO:
::ECHO EXAMPLE:
::ECHO .\%~nx0 "path_to_file_a" "path_to_file_b" [BANNER]
::ECHO:
::ECHO where
::ECHO     banner      =       QUIET - for minimal output
::ECHO                         SIMPLE - for a small banner during start.
::ECHO                         FANCY - for a custom banner during start ^& end.
::ECHO                         (If no option is selected, the default is FANCY.)
::ECHO:
::ECHO OPTIONS:
ECHO PARAMETERS:
ECHO    "path_to_file_a"   - Full file path pointing to the first file.
ECHO    "path_to_file_b"   - Full file path pointing to the second file.
ECHO    banner             - If no option is selected, the default is FANCY.
ECHO                           + QUIET - for minimal output
ECHO                           + SIMPLE - for a small banner during start.
ECHO                           + FANCY - for a custom banner during start ^& end.
ECHO:
ECHO DESCRIPTION:
ECHO Uses kdiff3 to merge changes between two different files or folders.
ECHO:
ECHO "File_A" will always be updated first from "File_B", then "File_B" will be
ECHO will be updated from "File_A".
ECHO:
ECHO Any file that gets updated will have a backup saved called "File_A.orig"
ECHO                                                         or "File_B.orig"
ECHO:
ECHO Paramters can be passed via command line, or hard-coded into this script.
ECHO If no parameters are provided, default is to use the hard-coded variables.
ECHO:
ECHO You can also drag-and-drop files on this script one at a time to merge them.
ECHO:
ECHO EXAMPLE:
ECHO     ^> .\%~nx0 "^%USERPROFILE^%\Documents\file_1.txt" "^%USERPROFILE^%\Dropbox\file_1.txt"
ECHO:
ECHO EXAMPLE:
ECHO     ^> .\%~nx0 "^%USERPROFILE^%\Documents\Folder1" "\\^%server_name^%\packages\Folder1" fancy
ECHO:
ECHO EXAMPLE:
ECHO     ^> .\%~nx0 "^%USERPROFILE^%\Desktop\file_2.json" "G:\Data\file_2.json" quiet
ECHO:
::ECHO     > ipconfig                       ... Show information
::ECHO     > ipconfig /all                  ... Show detailed information
::ECHO     > ipconfig /renew                ... renew all adapters
::ECHO     > ipconfig /renew EL*            ... renew any connection that has its
::ECHO                                          name starting with EL
::ECHO     > ipconfig /release *Con*        ... release all matching connections,
::ECHO                                          eg. "Wired Ethernet Connection 1" or
::ECHO                                              "Wired Ethernet Connection 2"
::ECHO     > ipconfig /allcompartments      ... Show information about all
::ECHO                                          compartments
::ECHO     > ipconfig /allcompartments /all ... Show detailed information about all
::ECHO                                          compartments
::ECHO 
::ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO -------------------------------------------------------------------------------
::ECHO:
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL
EXIT /B
:-------------------------------------------------------------------------------
:CheckLink IPorDNSaddress
:: Check address for ICMP ping response packets
:: http://stackoverflow.com/questions/3050898/how-to-check-if-ping-responded-or-not-in-a-batch-file
:: thanks to paxdiablo for checklink.cmd
@SETLOCAL EnableExtensions EnableDelayedExpansion
@ECHO OFF
SET "ipaddr=%1"
ECHO Testing address: %ipaddr%
SET "_loopcount=0"
:loop
SET "state=down"
FOR /F "tokens=5,7" %%a IN ('PING -n 1 !ipaddr!') DO (
    IF "x%%a"=="xReceived" IF "x%%b"=="x1," SET "state=up"
)
ECHO Link is !state!
REM --> test networking hardware capability
PING -n 6 127.0.0.1 >nul: 2>nul:
IF "!state!"=="down" (
	IF !_loopcount! LSS 3 (
		SET /A "_loopcount+=1"
		GOTO :loop
	) ELSE (
		ENDLOCAL & SET "_LinkState=%state%" & EXIT /B
	)	
) ELSE (
	IF "!state!"=="up" (
		ENDLOCAL & SET "_LinkState=%state%" & EXIT /B
	)
)
ENDLOCAL & SET "_LinkState=%state%"
EXIT /B
:-------------------------------------------------------------------------------
:GetWindowsVersion
@ECHO OFF
SETLOCAL
FOR /F "tokens=4-7 delims=[.] " %%i IN ('ver') DO (
	IF %%i == Version SET "_winversion=%%j.%%k"
	IF %%i neq Version SET "_winversion=%%i.%%j"
)	
IF "%_winversion%" == "10.0" (
	SET "_winversion=10"
	SET "_winvername=10"
	SET "_easyname=Windows 10"
	ECHO Windows 10
) ELSE (
	IF "%_winversion%" == "6.3" (
		SET "_winvername=8.1"
		SET "_easyname=Windows 8.1"
		ECHO Windows 8.1
	) ELSE (
		IF "%_winversion%" == "6.2" (
			SET "_winvername=8"
			SET "_easyname=Windows 8"
			ECHO Windows 8
		) ELSE (
			IF "%_winversion%" == "6.1" (
				SET "_winvername=7"
				SET "_easyname=Windows 7"
				ECHO Windows 7
			) ELSE (
				IF "%_winversion%" == "6.0" (
					SET "_winvername=Vista"
					SET "_easyname=Windows Vista"
					ECHO Windows Vista
				) ELSE (
					IF "%_winversion%" == "5.2" (
						SET "_winvername=Server 2003 / R2 / XP 64-bit"
						SET "_easyname=Windows Server 2003 / R2 / Windows XP 64-bit Edition"
						ECHO Windows Server 2003 / R2 / Windows XP 64-bit Edition
					) ELSE (
						IF "%_winversion%" == "5.1" (
							SET "_winvername=XP"
							SET "_easyname=Windows XP"
							ECHO Windows XP
						) ELSE (
							IF "%_winversion%" == "5.0" (
								SET "_winvername=2000"
								SET "_easyname=Windows 2000"
								ECHO Windows 2000
							) ELSE (
								REM SET "_winversion=0.0"
								SET "_winvername=Unknown"
								SET "_easyname=Unable to determine OS version automatically: %_winversion%"
								ECHO %_easyname%
							)
						)
					)
				)
			)
		)
	)
)
ENDLOCAL & SET "_WindowsVersion=%_winversion%" & SET "_WindowsName=%_winvername%" & SET "_WindowsEasyName=%_easyname%"
EXIT /B
:-------------------------------------------------------------------------------
:: End functions
:SkipFunctions

:Footer
:END
ENDLOCAL
ECHO: 
ECHO End %~nx0
ECHO: 
PAUSE
::GOTO :EOF
EXIT /B & REM If you call this program from the command line and want it to return to CMD instead of closing Command Prompt, need to use EXIT /B or no EXIT command at all.
