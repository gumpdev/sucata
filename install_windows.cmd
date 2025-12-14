@echo off
setlocal ENABLEDELAYEDEXPANSION

echo ===========================
echo  Sucata Installer (Windows)
echo ===========================
echo.

echo Building sucata.exe...

odin build . -out:sucata.exe

set "INSTALL_DIR=%LocalAppData%\Sucata"

echo Installing to: "%INSTALL_DIR%"
echo.

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
)

echo Copying files...
copy /Y "sucata.exe" "%INSTALL_DIR%" >nul
copy /Y "lua54.dll" "%INSTALL_DIR%" >nul

if errorlevel 1 (
    echo ERROR copying sucata.exe or lua54.dll. Make sure they are in the same folder as install-windows.cmd.
    pause
    exit /b 1
)

echo Updating user PATH...

set "OLDPATH="

for /f "tokens=2,* skip=2" %%A in ('reg query HKCU\Environment /v PATH 2^>nul') do (
    set "OLDPATH=%%B"
)

if not defined OLDPATH (
    set "NEWPATH=%INSTALL_DIR%"
) else (
    echo !OLDPATH! | find /I "%INSTALL_DIR%" >nul
    if errorlevel 1 (
        set "NEWPATH=!OLDPATH!;%INSTALL_DIR%"
    ) else (
        set "NEWPATH=!OLDPATH!"
    )
)

reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d "%NEWPATH%" /f >nul

echo.
echo Installation complete!
echo Folder: %INSTALL_DIR%
echo.

echo NOTE: Open a new terminal (cmd/powershell) for the PATH to update.
echo After that, you can run: sucata
echo.
pause
