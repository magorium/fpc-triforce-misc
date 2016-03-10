@ECHO OFF

REM ##################################################################
REM #                                                                #
REM #               FPC trunk checkout/update script                 #
REM #                                                                #
REM ##################################################################
REM #   Author : Magorium                                            #
REM #     Date : 06-02-2014                                          #
REM #  Version : v0.69                                               #
REM # Platform : Windows                                             #
REM ##################################################################
REM #                                                                #
REM #                          Disclaimer                            #
REM #                                                                #
REM #                   Provided for convenience                     #
REM #                                                                #
REM #               USE THIS SCRIPT AT YOUR OWN RISK                 #
REM #                                                                #
REM #       Only guaranteed to work for my own personal setup        #
REM #                                                                #
REM ##################################################################

ECHO FPC trunk checkout/update script v0.69
ECHO.

SET CURRENT_DIR=%CD%
SET FPCSVNDIR=%CURRENT_DIR%\fpc
SET TRUNKPATH=trunk
SET TRUNKDIR=%FPCSVNDIR%\%TRUNKPATH%
SET TRUNKURL=http://svn.freepascal.org/svn/fpc/trunk
SET LOGDIR=%CURRENT_DIR%

GOTO :MAIN


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUB_SHOWINITMENU
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
ECHO The script detected that the following directory:
ECHO.
ECHO      %TRUNKDIR%
ECHO.
ECHO does not exist and wants to create this directory
ECHO and additionally perform an svn checkout on the url:
ECHO.
ECHO      %TRUNKURL%
ECHO.
ECHO Is this OK ? (negative answer will kill script)
CHOICE /C:YN "Choose option:"

SET NEXTACTION=QUIT
IF ErrorLevel 1 SET NEXTACTION=MAKEDIR
IF ErrorLevel 2 SET NEXTACTION=QUIT
GOTO :EOF



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUB_CONSTRUCTLOGFILENAME
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM ### construct filename to use for log (based on revision)
IF %_FPCTRUNK_REV%==0 (
@SET LOGFILE=%LOGDIR%/checkout_svn_%_FPCTRUNK_REV%-%_FPCTRUNK_URLREV%.log
) ELSE (
@SET LOGFILE=%LOGDIR%/update_svn_%_FPCTRUNK_REV%-%_FPCTRUNK_URLREV%.log
)
GOTO :EOF



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUB_GETREMOTESVNVERSION
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM ### get svn version of online tree + store it to file
@CALL svn info %TRUNKURL% | FindStr "Revision" | pString Extractword N=2 >"%TEMP%\revision.txt"

REM ### store revision.txt into variable
SET /P _FPCTRUNK_URLREV= < "%TEMP%\revision.txt"

REM ### remove used temp file
DEL %TEMP%\revision.txt

GOTO :EOF



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUB_GETLOCALSVNVERSION
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM ### svnversion on local tree + store it to file
ECHO Retrieving current FPC trunk revision... (may take a moment)
@CALL svnversion %TRUNKDIR% >"%TEMP%\revision.txt"

REM ### store revision.txt into variable
SET /P _FPCTRUNK_REV= < "%TEMP%\revision.txt"

REM ### remove temp used file
DEL %TEMP%\revision.txt

REM ### check whether it was a valid version
SET CHECK=%_FPCTRUNK_REV:~0,11%
IF [%CHECK%]==[Unversioned] SET _FPCTRUNK_REV=0
ECHO Determined FPC trunk revision
GOTO :EOF



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUB_CREATEDIR
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM ### create trunk directory

ECHO Creating directory
MKDIR %TRUNKDIR%
GOTO :EOF


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUB_SVNARCHIVE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM ### zip up current local svn tree

ECHO Archiving latest revision
IF EXIST fpc-trunk-%_FPCTRUNK_REV%.zip (
ECHO Archive already exists
) ELSE (
ECHO Zipping...
@CALL 7za a -r -tzip -xr!?svn\ fpc-trunk-%_FPCTRUNK_REV%.zip fpc\trunk
)
GOTO :EOF


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUB_SVNUPDATE
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
ECHO Updating FPC trunk ...
CD %TRUNKDIR%
@CALL svn update >%LOGFILE%
CD %CURRENT_DIR%
ECHO Trunk updated
GOTO :EOF



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUB_SVNBOTH
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
ECHO Updating to latest revision and archive
CALL :SUB_SVNUPDATE
CALL :SUB_GETLOCALSVNVERSION
CALL :SUB_SVNARCHIVE
GOTO :EOF



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SUB_SVNMENU
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
ECHO           current settings
ECHO '------------------------------------------'
ECHO   fpc   svn directory : %FPCSVNDIR%
ECHO   fpc trunk directory : %TRUNKDIR%
ECHO.
ECHO local  trunk revision : %_FPCTRUNK_REV%
ECHO online trunk revision : %_FPCTRUNK_URLREV%
IF [%_FPCTRUNK_REV%]==[%_FPCTRUNK_URLREV%] @ECHO Trunk is up to date
ECHO '------------------------------------------'
ECHO.
ECHO #################################
ECHO #          options              #
ECHO #################################
ECHO =  1 - update fpc trunk         =
ECHO =  2 - archive latest revision  =
ECHO =  3 - do 1 then 2              =
ECHO =================================
ECHO.
CHOICE /C:123 "Choose option:"

IF ErrorLevel 3 CALL :SUB_SVNBOTH
IF ErrorLevel 2 CALL :SUB_SVNARCHIVE
IF ErrorLevel 1 CALL :SUB_SVNUPDATE
GOTO :EOF


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MAIN
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
IF NOT EXIST "%TRUNKDIR%\" (
CALL :SUB_SHOWINITMENU
IF [%NEXTACTION%]==[QUIT] GOTO :END
IF [%NEXTACTION%]==[MAKEDIR] CALL :SUB_CREATEDIR
)
CALL :SUB_GETLOCALSVNVERSION
CALL :SUB_GETREMOTESVNVERSION
CALL :SUB_CONSTRUCTLOGFILENAME
ECHO.

IF %_FPCTRUNK_REV%==0 (
REM ### make sure to be in correct dir before checkout
CD %FPCSVNDIR%
REM ###  check out svn
@CALL svn checkout %TRUNKURL% %TRUNKPATH% >%LOGFILE%
) ELSE (
CD %FPCSVNDIR%
CALL :SUB_SVNMENU
)

:END
CD %CURRENT_DIR%
