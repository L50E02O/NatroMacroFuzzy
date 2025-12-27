/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

Script para Alt Account - Escucha comandos del macro principal y los ejecuta
Usa el sistema abstracto de comunicacion para recibir comandos
*/

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#MaxThreads 255

#Include "%A_ScriptDir%\..\lib"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"
#Include "Roblox.ahk"
#Include "DurationFromSeconds.ahk"
#Include "nowUnix.ahk"
#Include "Walk.ahk"
#Include "MacroCommunication.ahk"

OnError (e, mode) => (mode = "Return") ? -1 : 0
SetWorkingDir A_ScriptDir "\.."
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SendMode "Event"

; Variables globales
AltState := "idle"
CurrentField := ""
CurrentAction := ""
AltCommunication := ""
CommandCheckInterval := 1000

; Inicializacion
; Parametros: <tipo_comunicacion> <config_json_o_ruta>
; Ejemplo: fileshare \\192.168.1.100\NatroMacro
; O: fileshare {"sharePath": "\\192.168.1.100\NatroMacro", "commandFile": "alt_command.txt", "statusFile": "alt_status.txt"}
if (A_Args.Length < 1) {
    MsgBox "Uso: AltAccount.ahk <tipo_comunicacion> [configuracion]`n`nEjemplos:`n  AltAccount.ahk fileshare \\192.168.1.100\NatroMacro`n  AltAccount.ahk fileshare `"{\`"sharePath\`": \`"\\\\192.168.1.100\\NatroMacro\`"}`"", "Error", 0x40010
    ExitApp
}

commType := A_Args[1]
config := Map()

; Parsear configuracion
if (A_Args.Length >= 2) {
    configStr := A_Args[2]
    
    ; Si es una ruta simple (legacy), convertir a config
    if (InStr(configStr, "\\") = 1 || InStr(configStr, "/") = 1) {
        ; Es una ruta de archivo compartido
        config["sharePath"] := configStr
        config["commandFile"] := (A_Args.Length >= 3) ? A_Args[3] : "alt_command.txt"
        config["statusFile"] := (A_Args.Length >= 4) ? A_Args[4] : "alt_status.txt"
    } else {
        ; Intentar parsear como JSON
        try {
            #Include "JSON.ahk"
            configObj := JSON.Load(configStr)
            for key, value in configObj.OwnProps()
                config[key] := value
        } catch {
            ; Si falla, tratar como ruta simple
            config["sharePath"] := configStr
            config["commandFile"] := "alt_command.txt"
            config["statusFile"] := "alt_status.txt"
        }
    }
} else {
    ; Configuracion por defecto
    config := CommunicationFactory.GetDefaultConfig(commType)
}

; Inicializar comunicacion
AltCommunication := MacroCommunication()
if (!AltCommunication.Init(commType, config)) {
    MsgBox "Error al inicializar comunicacion. Tipo: " commType, "Error", 0x40010
    ExitApp
}

; Inicializar GDI+
pToken := Gdip_Startup()
bitmaps := Map()
bitmaps.CaseSense := 0
#Include "%A_ScriptDir%\..\nm_image_assets\offset\bitmaps.ahk"

; Importar paths
nm_importPaths()

; Variables de movimiento
FwdKey := "sc011"
LeftKey := "sc01e"
BackKey := "sc01f"
RightKey := "sc020"
RotLeft := "sc033"
RotRight := "sc034"
RotUp := "sc149"
RotDown := "sc151"
SC_E := "sc012"
SC_Space := "sc039"

; Variables de campo
FieldName := ""
FieldPattern := "Snake"
FieldPatternSize := "M"
FieldPatternReps := 1
MoveSpeedNum := 20
NewWalk := true
currentWalk := {pid: "", name: ""}

; Declarar ruta del ejecutable (necesario para nm_createWalk)
exe_path64 := (A_Is64bitOS && FileExist("submacros\AutoHotkey64.exe")) ? (A_WorkingDir "\submacros\AutoHotkey64.exe") : A_AhkPath

; Importar patrones
nm_importPatterns()

; Funcion para actualizar el estado
UpdateStatus(status, field := "", action := "") {
    global AltState, CurrentField, CurrentAction, AltCommunication
    
    AltState := status
    CurrentField := field
    CurrentAction := action
    
    statusMap := Map(
        "status", status,
        "field", field,
        "action", action,
        "time", nowUnix()
    )
    
    AltCommunication.WriteStatus(statusMap)
}

; Funcion para procesar comandos
ProcessCommand(command) {
    if (command = "")
        return
    
    command := Trim(command)
    
    if (command = "STOP") {
        nm_AltReturnToHive()
        UpdateStatus("stopped", "", "")
        return
    }
    
    if (command = "RETURN_HIVE") {
        nm_AltReturnToHive()
        return
    }
    
    if (InStr(command, "GATHER ") = 1) {
        ; Formato: GATHER <FieldName> [Pattern]
        parts := StrSplit(SubStr(command, 8), " ", , 2)
        fieldName := parts[1]
        pattern := (parts.Length > 1) ? parts[2] : "Snake"
        
        nm_AltGather(fieldName, pattern)
        return
    }
    
    ; Comando desconocido
    UpdateStatus("error", "", "Unknown command: " command)
}

; Funcion para ir a un campo usando los paths existentes
nm_gotoField(location) {
    global paths, HiveConfirmed := 0
    
    path := paths["gtf"][StrReplace(location, " ")]
    if (!path) {
        UpdateStatus("error", "", "Path no encontrado para: " location)
        return 0
    }
    
    nm_setShiftLock(0)
    nm_createPath(path)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T120 L"
    nm_endWalk()
    return 1
}

; Funcion para recolectar en un campo
nm_AltGather(fieldName, pattern := "Snake") {
    global FieldPattern, FieldPatternSize, FieldPatternReps, patterns, CurrentField
    
    UpdateStatus("traveling", fieldName, "Going to field")
    
    ; Ir al campo
    if (!nm_gotoField(fieldName)) {
        UpdateStatus("error", fieldName, "Failed to reach field")
        return 0
    }
    
    CurrentField := fieldName
    UpdateStatus("gathering", fieldName, "Collecting pollen")
    
    ; Verificar que el patron existe
    if (!patterns.Has(pattern))
        pattern := "Snake"
    
    FieldPattern := pattern
    
    ; Iniciar recoleccion
    nm_gather(pattern, 1, FieldPatternSize, FieldPatternReps, 0)
    
    ; Mantener la recoleccion activa
    Loop {
        ; Verificar si hay un nuevo comando
        command := AltCommunication.ReceiveCommand()
        if (command != "") {
            if (InStr(command, "STOP") || InStr(command, "RETURN_HIVE"))
                break
        }
        
        ; Continuar el patron de recoleccion
        if (KeyWait("F14", "D T0.1 L") = 0) {
            ; El patron termino, iniciar uno nuevo
            nm_gather(pattern, 1, FieldPatternSize, FieldPatternReps, 0)
        }
        
        Sleep 100
    }
    
    UpdateStatus("idle", "", "")
    return 1
}

; Funcion para regresar al hive
nm_AltReturnToHive() {
    global CurrentField, paths
    
    if (CurrentField = "")
        return 1
    
    UpdateStatus("traveling", "", "Returning to hive")
    
    path := paths["wf"][StrReplace(CurrentField, " ")]
    if (path) {
        nm_setShiftLock(0)
        nm_createPath(path)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T120 L"
        nm_endWalk()
    }
    
    CurrentField := ""
    UpdateStatus("idle", "", "")
    return 1
}

; Funciones auxiliares necesarias (simplificadas)
nm_setShiftLock(state) {
    return
}

nm_createPath(path) {
    global MoveSpeedNum, NewWalk, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, SC_E, SC_Space
    nm_createWalk(path, , nm_PathVars())
}

nm_PathVars() {
    return nm_KeyVars()
}

nm_KeyVars() {
    global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, RotUp, RotDown, SC_E, SC_Space
    return
    (
    '
    FwdKey:="' FwdKey '"
    LeftKey:="' LeftKey '"
    BackKey:="' BackKey '"
    RightKey:="' RightKey '"
    RotLeft:="' RotLeft '"
    RotRight:="' RotRight '"
    RotUp:="' RotUp '"
    RotDown:="' RotDown '"
    SC_E:="' SC_E '"
    SC_Space:="' SC_Space '"
    '
    )
}

nm_createWalk(movement, name := "", vars := "") {
    global exe_path64, MoveSpeedNum, NewWalk, currentWalk
    
    ; Reutilizar la implementacion del macro principal
    script :=
    (
    '
    #SingleInstance Off
    #NoTrayIcon
    ProcessSetPriority("AboveNormal")
    KeyHistory 0
    ListLines 0
    OnExit(ExitFunc)

    #Include "%A_ScriptDir%\lib"
    #Include "Gdip_All.ahk"
    #Include "Gdip_ImageSearch.ahk"
    #Include "HyperSleep.ahk"
    #Include "Roblox.ahk"
    '
    )
    
    . (NewWalk ?
    (
    '
    global base_movespeed, hasty_guard, gifted_hasty
    base_movespeed := 0
    hasty_guard := 0
    gifted_hasty := 0
    
    #Include "Walk.ahk"
    
    movespeed := ' MoveSpeedNum '
    both            := (Mod(movespeed*1000, 1265) = 0) || (Mod(Round((movespeed+0.005)*1000), 1265) = 0)
    hasty_guard     := (both || Mod(movespeed*1000, 1100) < 0.00001)
    gifted_hasty    := (both || Mod(movespeed*1000, 1150) < 0.00001)
    base_movespeed  := round(movespeed / (both ? 1.265 : (hasty_guard ? 1.1 : (gifted_hasty ? 1.15 : 1))), 0)
    '
    ) :
    (
    '
    (bitmaps := Map()).CaseSense := 0
    pToken := Gdip_Startup()
    Walk(param, *) => HyperSleep(4000/' MoveSpeedNum '*param)
    '
    ))
    
    . (
    (
    '
    hwnd := GetRobloxHWND()
    offsetY := GetYOffset(hwnd)
    ' nm_KeyVars() '
    ' vars '

    start()
    return

    nm_Walk(tiles, MoveKey1, MoveKey2:=0)
    {
        Send "{" MoveKey1 " down}" (MoveKey2 ? "{" MoveKey2 " down}" : "")
        ' (NewWalk ? 'Walk(tiles)' : ('HyperSleep(4000/' MoveSpeedNum '*tiles)')) '
        Send "{" MoveKey1 " up}" (MoveKey2 ? "{" MoveKey2 " up}" : "")
    }

    F13::
        start(hk?)
        {
            Send "{F14 down}"
            ' movement '
            Send "{F14 up}"
        }

    ExitFunc(*)
    {
        Send "{' LeftKey ' up}{' RightKey ' up}{' FwdKey ' up}{' BackKey ' up}{' SC_Space ' up}{F14 up}{' SC_E ' up}"
        try Gdip_Shutdown(pToken)
    }
    '
    ))
    
    shell := ComObject("WScript.Shell")
    exec := shell.Exec('"' exe_path64 '" /script /force *')
    exec.StdIn.Write(script), exec.StdIn.Close()
    
    if WinWait("ahk_class AutoHotkey ahk_pid " exec.ProcessID, , 2) {
        DetectHiddenWindows 0
        currentWalk.pid := exec.ProcessID
        currentWalk.name := name
        return 1
    }
    return 0
}

nm_endWalk() {
    global currentWalk
    if (currentWalk.pid != "") {
        try {
            ProcessClose(currentWalk.pid)
        } catch {
        }
        currentWalk.pid := ""
        currentWalk.name := ""
    }
}

nm_gather(pattern, index, patternsize := "M", reps := 1, facingcorner := 0) {
    global patterns, FieldName, FieldPattern, FieldPatternSize, FieldPatternReps
    global FieldUntilMins, FieldUntilPack, FieldReturnType, currentWalk
    
    if (!patterns.Has(pattern)) {
        pattern := "Snake"
    }
    
    size := (patternsize = "XS") ? 0.25
        : (patternsize = "S") ? 0.5
        : (patternsize = "L") ? 1.5
        : (patternsize = "XL") ? 2
        : 1
    
    DetectHiddenWindows 1
    if ((index = 1) || !WinExist("ahk_class AutoHotkey ahk_pid " currentWalk.pid)) {
        nm_createWalk(patterns[pattern], "pattern",
        (
        '
        size:=' size '
        reps:=' reps '
        facingcorner:=' facingcorner '
        FieldName:="' FieldName '"
        FieldPattern:="' FieldPattern '"
        '
        ))
    } else {
        Send "{F13}"
    }
    DetectHiddenWindows 0
    
    if (KeyWait("F14", "D T5 L") = 0)
        nm_endWalk()
}

; Importar paths (funcion simplificada)
nm_importPaths() {
    global paths := Map()
    paths.CaseSense := 0
    
    path_names := Map(
        "gtf", ["bamboo", "blueflower", "cactus", "clover", "coconut", "dandelion", "mountaintop", "mushroom", "pepper", "pinetree", "pineapple", "pumpkin", "rose", "spider", "strawberry", "stump", "sunflower"],
        "wf", ["bamboo", "blueflower", "cactus", "clover", "coconut", "dandelion", "mountaintop", "mushroom", "pepper", "pinetree", "pineapple", "pumpkin", "rose", "spider", "strawberry", "stump", "sunflower"]
    )
    
    for k, list in path_names {
        (paths[k] := Map()).CaseSense := 0
        for v in list {
            try {
                file := FileOpen(A_WorkingDir "\paths\" k "-" v ".ahk", "r")
                paths[k][v] := file.Read()
                file.Close()
            } catch {
            }
        }
    }
}

; Importar patrones (funcion simplificada)
nm_importPatterns() {
    global patterns := Map()
    patterns.CaseSense := 0
    
    Loop Files A_WorkingDir "\patterns\*.ahk" {
        file := FileOpen(A_LoopFilePath, "r")
        pattern := file.Read()
        file.Close()
        pattern_name := StrReplace(A_LoopFileName, "." A_LoopFileExt)
        patterns[pattern_name] := pattern
    }
}

; Inicializar estado
UpdateStatus("idle", "", "")

; Loop principal
Loop {
    ; Verificar comandos
    command := AltCommunication.ReceiveCommand()
    if (command != "") {
        ProcessCommand(command)
    }
    
    ; Actualizar estado periodicamente
    if (Mod(A_Index, 10) = 0) {
        UpdateStatus(AltState, CurrentField, CurrentAction)
    }
    
    Sleep CommandCheckInterval
}

; Cleanup al salir
OnExit((*) => (
    UpdateStatus("offline", "", ""),
    AltCommunication.Close(),
    Gdip_Shutdown(pToken)
))
