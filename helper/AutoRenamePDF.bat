@ECHO OFF
::Last updated: 2020-01-25

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

::SET "_RENAME_TO=First-Last-Resume-CV-Portfolio%~x1"
:: or
SET "_RENAME_TO=%~n0%~x1"

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
