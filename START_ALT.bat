@echo off
chcp 65001 > nul
cd %~dp0

if not exist "submacros\AltAccount.ahk" (
    echo Error: No se encontro AltAccount.ahk
    echo Asegurate de que el archivo existe en la carpeta submacros
    pause
    exit
)

if exist "submacros\AutoHotkey32.exe" (
    echo.
    echo ========================================
    echo   Natro Macro - Alt Account
    echo ========================================
    echo.
    echo Iniciando Alt Account...
    echo.
    start "" "%~dp0submacros\AutoHotkey32.exe" "%~dp0submacros\AltAccount.ahk"
    echo Alt Account iniciada. Puedes cerrar esta ventana.
    timeout /t 3 >nul
    exit
)

if exist "submacros\AutoHotkey64.exe" (
    echo.
    echo ========================================
    echo   Natro Macro - Alt Account
    echo ========================================
    echo.
    echo Iniciando Alt Account (64-bit)...
    echo.
    start "" "%~dp0submacros\AutoHotkey64.exe" "%~dp0submacros\AltAccount.ahk"
    echo Alt Account iniciada. Puedes cerrar esta ventana.
    timeout /t 3 >nul
    exit
)

echo Error: No se encontro AutoHotkey32.exe ni AutoHotkey64.exe
echo Asegurate de que el archivo existe en la carpeta submacros
echo.
echo Si el problema persiste:
echo 1. Desactiva cualquier antivirus de terceros
echo 2. Re-extrae el macro y verifica que AutoHotkey32.exe existe en la carpeta 'submacros'
echo 3. Ejecuta START.bat primero para asegurar que todo esta correcto
echo.
pause

