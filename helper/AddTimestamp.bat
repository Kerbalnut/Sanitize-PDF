@ECHO OFF
::Last updated: 2022-10-23

REM ECHO DEBUGGING: Begin %~nx0 script.

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

SET "_INPUT_FILE=%~1"

REM -------------------------------------------------------------------------------

SET "_TEMP_FILE=%TEMP%\DELETE_ME_posh_date.txt"
powershell -Command "& {Get-Date -Format "FileDate"}" > "%_TEMP_FILE%"
SET /P _DATE1=<"%_TEMP_FILE%"
ECHO DEBUGGING: Date1 = "%_DATE1%"
powershell -Command "& {Get-Date -Format "yyyy-MM-dd"}" > "%_TEMP_FILE%"
SET /P _DATE2=<"%_TEMP_FILE%"
ECHO DEBUGGING: Date2 = "%_DATE2%"
DEL "%_TEMP_FILE%"

SET "_TEMP_FILE=%TEMP%\DELETE_ME_posh_time.txt"
powershell ^
	$a = Get-Date -Format HH:mm; ^
	$a -replace \":\", \"-\" > "%_TEMP_FILE%"
SET /P _TIME1=<"%_TEMP_FILE%"
ECHO DEBUGGING: Time1 = "%_TIME1%"
powershell ^
	$a = Get-Date -UFormat \"%H-%M-%S\"; ^
	$a > "%_TEMP_FILE%"
SET /P _TIME2=<"%_TEMP_FILE%"
ECHO DEBUGGING: Timn2 = "%_TIME2%"
powershell ^
	Get-Date -UFormat \"%H-%M-%S\" > "%_TEMP_FILE%"
SET /P _TIME2=<"%_TEMP_FILE%"
ECHO DEBUGGING: Timn2 = "%_TIME2%"
powershell ^
	Get-Date -UFormat \"%H-%M-%S\"""" > "%_TEMP_FILE%"
SET /P _TIME2=<"%_TEMP_FILE%"
ECHO DEBUGGING: Timn2 = "%_TIME2%"
powershell -Command "& {Get-Date -UFormat """"%H-%M-%S""""}" > "%_TEMP_FILE%"
SET /P _TIME2=<"%_TEMP_FILE%"
ECHO DEBUGGING: Time2 = "%_TIME2%"
powershell -Command "& {Get-Date -UFormat """""%H-%M-%S"""""}" > "%_TEMP_FILE%"
SET /P _TIME2=<"%_TEMP_FILE%"
ECHO DEBUGGING: Time2 = "%_TIME2%"
powershell -Command "& {Get-Date -UFormat """"%H-%M-%S""""}"""" > "%_TEMP_FILE%"
SET /P _TIME2=<"%_TEMP_FILE%"
ECHO DEBUGGING: Time2 = "%_TIME2%"
SET "_TIME2=hellow owrld"
ECHO DEBUGGING: Timn2 = "%_TIME2%"
powershell -Command "& {Get-Date -UFormat %H-%M-%S}" > "%_TEMP_FILE%"
SET /P _TIME2=<"%_TEMP_FILE%"
ECHO DEBUGGING: Time2 = "%_TIME2%"
DEL "%_TEMP_FILE%"

SET "_TEMP_FILE=%TEMP%\DELETE_ME_posh_datetime.txt"
powershell -Command "& {Get-Date -Format "FileDateTime"}" > "%_TEMP_FILE%"
SET /P _DATETIME1=<"%_TEMP_FILE%"
ECHO DEBUGGING: DateTime1 = "%_DATETIME1%"
DEL "%_TEMP_FILE%"




SET "_FILE_NAME=%~n1"

SET "_DATE_TIME_STRING=%_DATE1%"
SET "_DATE_TIME_STRING=%_DATE2%"
SET "_DATE_TIME_STRING=%_TIME1%"
SET "_DATE_TIME_STRING=%_TIME2%"
SET "_DATE_TIME_STRING=%_DATETIME1%"

::SET "_RENAME_TO=%~n1%~x1"
::ECHO DEBUGGING: _RENAME_TO = "%_RENAME_TO%"
SET "_RENAME_TO=%_FILE_NAME%_%_DATE_TIME_STRING%%~x1"
ECHO DEBUGGING: _RENAME_TO = "%_RENAME_TO%"

pause
exit


REM -------------------------------------------------------------------------------


:: https://ss64.com/nt/syntax-args.html
:: %~f1 Expand %1 to a Fully qualified path name - C:\utils\MyFile.txt
:: %~d1 Expand %1 to a Drive letter only - C:
:: %~p1 Expand %1 to a Path only e.g. \utils\ this includes a trailing \ which will be interpreted as an escape character by some commands.
SET "_HOME_PATH=%~dp0"

SET "_FULL_PATH=%_HOME_PATH%%_RENAME_TO%"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Get _INPUT_FILE Name & eXtention, Drive letter & Path, siZe
FOR %%G IN ("%_INPUT_FILE%") DO SET "_INPUT_FILE_NAME=%%~nxG"
FOR %%G IN ("%_INPUT_FILE%") DO SET "_INPUT_FILE_PATH=%%~dpG"
FOR %%G IN ("%_INPUT_FILE%") DO SET "_INPUT_FILE_SIZE=%%~zG"
SET /A "_INPUT_FILE_SIZE_KB=%_INPUT_FILE_SIZE%/1024"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: %~n1 Expand %1 to a file Name without file extension or path - MyFile or if only a path is present, with no trailing backslash, the last folder in that path.
:: %~x1 Expand %1 to a file eXtension only - .txt
ECHO:
ECHO Rename 
ECHO:
ECHO %~nx1 
ECHO: 
ECHO to 
ECHO:
ECHO %_RENAME_TO%?
ECHO:
PAUSE
ECHO:

COPY /B /Y %1 "%_FULL_PATH%" && SET "_COMMAND_EXIT=SUCCESS" || SET "_COMMAND_EXIT=FAILURE"
REM ECHO DEBUGGING: %%_COMMAND_EXIT%% = %_COMMAND_EXIT%

::XCOPY %1 "%_FULL_PATH%" /Y && SET "_COMMAND_EXIT=SUCCESS" || SET "_COMMAND_EXIT=FAILURE"
REM ECHO DEBUGGING: %%_COMMAND_EXIT%% = %_COMMAND_EXIT%

::robocopy "%_INPUT_FILE%" "%_HOME_PATH%" "%_RENAME_TO%" /XX && SET "_COMMAND_EXIT=SUCCESS" || SET "_COMMAND_EXIT=FAILURE"
ECHO DEBUGGING: %%_COMMAND_EXIT%% = %_COMMAND_EXIT%

ECHO:
IF /I "%_COMMAND_EXIT%"=="FAILURE" PAUSE


REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
