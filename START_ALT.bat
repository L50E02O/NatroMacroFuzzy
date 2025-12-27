@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul
cd %~dp0

if not exist "submacros\AltAccount.ahk" (
    echo.
    echo [ERROR] No se encontro AltAccount.ahk
    echo Asegurate de que el archivo existe en la carpeta submacros
    echo.
    pause
    exit
)

if not exist "submacros\AutoHotkey32.exe" (
    echo.
    echo [ERROR] No se encontro AutoHotkey32.exe
    echo Asegurate de que el archivo existe en la carpeta submacros
    echo.
    pause
    exit
)

echo.
echo ========================================
echo   Natro Macro - Alt Account
echo ========================================
echo.

if [%1]==[] (
    echo Para usar la Alt Account necesitas la ruta de la carpeta compartida.
    echo.
    echo Ejemplo: \\192.168.1.100\NatroMacro
    echo.
    set /p sharePath="Ingresa la ruta compartida: "
    
    if "!sharePath!"=="" (
        echo.
        echo [ERROR] Debes proporcionar la ruta compartida
        echo.
        pause
        exit
    )
) else (
    set sharePath=%1
)

echo.
echo Iniciando Alt Account...
echo Ruta compartida: !sharePath!
echo.
echo La Alt Account comenzara a escuchar comandos del macro principal.
echo Puedes cerrar esta ventana despues de iniciar.
echo.

start "" "%~dp0submacros\AutoHotkey32.exe" "%~dp0submacros\AltAccount.ahk" "fileshare" "!sharePath!"

timeout /t 2 >nul
echo.
echo Alt Account iniciada correctamente!
echo.
pause
