@ECHO OFF

:: RUNAS /noprofile /user:[DOMAIN]\[USERNAME] CMD.EXE

:: RUNAS /noprofile /user:[DOMAIN]\[USERNAME] "CMD.EXE /C ".\Get-Chocolatey.bat""

:: Source:
::https://github.com/Kerbalnut/Batch-Tools-SysAdmin
::https://github.com/Kerbalnut/Batch-Tools-SysAdmin/blob/master/Tools/Install-Chocolatey.bat

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

:: https://chocolatey.org/packages/win2003-mklink
ECHO If you install Chocolatey on Windows 2003, you should choose another location over the default install (in this case, preferably one without spaces in the path). 
ECHO.
:: https://chocolatey.org/install#alternative-installation-options
ECHO Don't use "C:\Chocolatey" unless necessary.
ECHO.
ECHO Type in alternate install path: (Will be created if does not exist)
SET /P AltInstallPath=

IF EXIST %AltInstallPath% (
    ECHO Install folder found.
    ECHO %AltInstallPath%
 ) ELSE ( 
    ECHO Install folder does not exist. (yet)
	MKDIR %AltInstallPath%
 )

:: Creates machine level environment variable named ChocolateyInstall
SETX ChocolateyInstall "%AltInstallPath%" /m 
:: Machine variables are stored on the machine and will not follow a users roaming profile. To set a machine variable (/m) requires Administrator rights. 

ECHO.
ECHO Because SETX writes variables to the master environment in the registry, edits will only take effect when a new command window is opened - they do not affect the current CMD or PowerShell session. 
ECHO.
ECHO Chocolatey only locks down the permissions to Admins when installed to the default location. If you are installing to another location, you will need to handle this yourself. This is due to alternative locations could have a range of permissions that should not be changed - see https://github.com/chocolatey/choco/issues/398 for more details.
ECHO. 

::@powershell -NoProfile -ExecutionPolicy Unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%SYSTEMDRIVE%\chocolatey\bin;%ALLUSERSPROFILE%\chocolatey\bin

::@powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH="%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

@powershell -NoProfile -ExecutionPolicy Unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%SYSTEMDRIVE%\chocolatey\bin;%ALLUSERSPROFILE%\chocolatey\bin
:: @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

ECHO:
ECHO ===============================================================================
ECHO: 
ECHO End %~nx0
ECHO: 
PAUSE
::GOTO :EOF
EXIT /B & REM If you call this program from the command line and want it to return to CMD instead of closing Command Prompt, need to use EXIT /B or no EXIT command at all.
