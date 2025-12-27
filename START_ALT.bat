@echo off
chcp 65001 > nul
cd %~dp0

if not exist "submacros\AltAccount.ahk" (
    echo Error: No se encontro AltAccount.ahk
    echo Asegurate de que el archivo existe en la carpeta submacros
    pause
    exit
)

if not exist "submacros\AutoHotkey32.exe" (
    echo Error: No se encontro AutoHotkey32.exe
    echo Asegurate de que el archivo existe en la carpeta submacros
    pause
    exit
)

if [%1]==[] (
    echo.
    echo ========================================
    echo   Natro Macro - Alt Account Launcher
    echo ========================================
    echo.
    echo Uso: START_ALT.bat ^<IP_Principal^> ^<Ruta_Compartida^>
    echo.
    echo Ejemplo:
    echo   START_ALT.bat 192.168.1.100 \\192.168.1.100\NatroMacro
    echo.
    echo O ejecuta con parametros:
    echo   START_ALT.bat ^<IP^> ^<Ruta^>
    echo.
    set /p altIP="IP de la computadora principal: "
    set /p sharePath="Ruta compartida (ej: \\192.168.1.100\NatroMacro): "
) else (
    set altIP=%1
    set sharePath=%2
)

if [%altIP%]==[] (
    echo Error: Debes proporcionar la IP de la computadora principal
    pause
    exit
)

if [%sharePath%]==[] (
    echo Error: Debes proporcionar la ruta compartida
    pause
    exit
)

echo.
echo Iniciando Alt Account...
echo IP Principal: %altIP%
echo Ruta Compartida: %sharePath%
echo.

start "" "%~dp0submacros\AutoHotkey32.exe" "%~dp0submacros\AltAccount.ahk" "%sharePath%" "alt_command.txt" "alt_status.txt"

echo Alt Account iniciada. Puedes cerrar esta ventana.
timeout /t 3 >nul

