@echo off
setlocal
title virus.bat
color 0A

set "DEST=%USERPROFILE%\STOLEN_FILES"
set "SRC=%USERPROFILE%"

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
echo   Target      : %SRC%
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
for %%F in (Desktop Documents Downloads Pictures Videos Music) do (
    if exist "%SRC%\%%F" (
        robocopy "%SRC%\%%F" "%DEST%\%%F" /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP >nul
    )
)
break on
echo done>"%TEMP%\virus_done.flag"
exit /b