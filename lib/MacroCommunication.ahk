/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

Sistema de comunicacion entre macros - Adaptado de Revolution Macro
Usa WM_COPYDATA para comunicacion directa entre procesos
*/

; Interfaz base para estrategias de comunicacion
class ICommunicationStrategy {
    Init(config) {
        throw Error("Init() debe ser implementado por la clase derivada")
    }
    Send(message) {
        throw Error("Send() debe ser implementado por la clase derivada")
    }
    Receive() {
        throw Error("Receive() debe ser implementado por la clase derivada")
    }
    WriteStatus(status) {
        throw Error("WriteStatus() debe ser implementado por la clase derivada")
    }
    ReadStatus() {
        throw Error("ReadStatus() debe ser implementado por la clase derivada")
    }
    TestConnection() {
        throw Error("TestConnection() debe ser implementado por la clase derivada")
    }
    Close() {
    }
}

; Estrategia de comunicacion mediante WM_COPYDATA (como Revolution Macro)
; Funciona en la misma maquina usando el nombre de la ventana
class WM_COPYDATAStrategy extends ICommunicationStrategy {
    TargetWindowTitle := ""
    StatusBuffer := Map()
    LastStatusUpdate := 0
    
    Init(config) {
        if (!config.Has("targetWindowTitle"))
            return 0
        
        this.TargetWindowTitle := config["targetWindowTitle"]
        return 1
    }
    
    Send(message) {
        if (this.TargetWindowTitle = "")
            return 0
        
        DetectHiddenWindows 1
        if (!WinExist(this.TargetWindowTitle))
            return 0
        
        try {
            result := Send_WM_COPYDATA("CMD:" message, this.TargetWindowTitle, 1)
            return (result >= 0) ? 1 : 0
        } catch {
            return 0
        }
    }
    
    Receive() {
        ; Los comandos se reciben directamente via OnMessage en AltAccount.ahk
        ; Esta funcion no se usa en esta estrategia
        return ""
    }
    
    WriteStatus(status) {
        ; El estado se actualiza en memoria
        this.StatusBuffer := status.Clone()
        this.LastStatusUpdate := A_TickCount
        return 1
    }
    
    ReadStatus() {
        ; Retornar el estado actual del buffer
        if (this.StatusBuffer.Count > 0) {
            ; Verificar si el estado es reciente (menos de 5 segundos)
            if ((A_TickCount - this.LastStatusUpdate) < 5000) {
                return this.StatusBuffer.Clone()
            } else {
                ; Estado muy viejo, considerar offline
                return Map("status", "offline", "field", "", "action", "")
            }
        }
        return Map("status", "unknown", "field", "", "action", "")
    }
    
    TestConnection() {
        if (this.TargetWindowTitle = "")
            return 0
        
        DetectHiddenWindows 1
        return WinExist(this.TargetWindowTitle) ? 1 : 0
    }
    
    ; Actualizar estado desde mensaje recibido (llamado desde nm_WM_COPYDATA)
    UpdateStatusFromMessage(statusStr) {
        statusMap := Map()
        Loop Parse statusStr, "|" {
            if (InStr(A_LoopField, "=")) {
                parts := StrSplit(A_LoopField, "=", , 2)
                if (parts.Length = 2)
                    statusMap[Trim(parts[1])] := Trim(parts[2])
            }
        }
        this.StatusBuffer := statusMap
        this.LastStatusUpdate := A_TickCount
    }
}

; Estrategia de comunicacion mediante archivos compartidos (fallback)
class FileShareStrategy extends ICommunicationStrategy {
    CommandFile := ""
    StatusFile := ""
    SharePath := ""
    LastCommandTime := 0
    
    Init(config) {
        if (!config.Has("sharePath"))
            return 0
        
        this.SharePath := config["sharePath"]
        commandFileName := config.Has("commandFile") ? config["commandFile"] : "alt_command.txt"
        statusFileName := config.Has("statusFile") ? config["statusFile"] : "alt_status.txt"
        
        this.CommandFile := this.SharePath "\" commandFileName
        this.StatusFile := this.SharePath "\" statusFileName
        
        try {
            if (!DirExist(this.SharePath))
                return 0
        } catch {
            return 0
        }
        
        return 1
    }
    
    Send(message) {
        if (this.CommandFile = "")
            return 0
        
        try {
            file := FileOpen(this.CommandFile, "w-d")
            if (!file)
                return 0
            file.Write(message)
            file.Close()
            return 1
        } catch {
            return 0
        }
    }
    
    Receive() {
        if (this.CommandFile = "")
            return ""
        
        try {
            if (!FileExist(this.CommandFile))
                return ""
            
            FileGetTime fileTime, this.CommandFile
            if (fileTime <= this.LastCommandTime)
                return ""
            
            file := FileOpen(this.CommandFile, "r")
            if (!file)
                return ""
            
            message := Trim(file.Read())
            file.Close()
            
            try {
                FileDelete this.CommandFile
            } catch {
            }
            
            this.LastCommandTime := fileTime
            return message
        } catch {
            return ""
        }
    }
    
    WriteStatus(status) {
        if (this.StatusFile = "")
            return 0
        
        try {
            statusStr := ""
            for key, value in status {
                if (statusStr != "")
                    statusStr .= "|"
                statusStr .= key "=" value
            }
            
            file := FileOpen(this.StatusFile, "w-d")
            if (!file)
                return 0
            file.Write(statusStr)
            file.Close()
            return 1
        } catch {
            return 0
        }
    }
    
    ReadStatus() {
        if (this.StatusFile = "")
            return 0
        
        try {
            if (!FileExist(this.StatusFile))
                return Map("status", "offline", "field", "", "action", "")
            
            file := FileOpen(this.StatusFile, "r")
            if (!file)
                return 0
            
            content := file.Read()
            file.Close()
            
            statusMap := Map()
            Loop Parse content, "|" {
                if (InStr(A_LoopField, "=")) {
                    parts := StrSplit(A_LoopField, "=", , 2)
                    if (parts.Length = 2)
                        statusMap[Trim(parts[1])] := Trim(parts[2])
                }
            }
            
            if (!statusMap.Has("status"))
                statusMap["status"] := "unknown"
            if (!statusMap.Has("field"))
                statusMap["field"] := ""
            if (!statusMap.Has("action"))
                statusMap["action"] := ""
            
            return statusMap
        } catch {
            return 0
        }
    }
    
    TestConnection() {
        if (this.SharePath = "")
            return 0
        
        try {
            return DirExist(this.SharePath) ? 1 : 0
        } catch {
            return 0
        }
    }
}

; Factory para crear estrategias
class CommunicationFactory {
    static Create(type, config) {
        strategy := ""
        
        switch StrLower(type) {
            case "wmcopydata", "wm", "message":
                strategy := WM_COPYDATAStrategy()
            case "fileshare", "file", "share":
                strategy := FileShareStrategy()
            default:
                return 0
        }
        
        if (strategy.Init(config))
            return strategy
        else
            return 0
    }
    
    static GetDefaultConfig(type) {
        switch StrLower(type) {
            case "wmcopydata", "wm", "message":
                return Map("targetWindowTitle", "AltAccount.ahk ahk_class AutoHotkey")
            case "fileshare", "file", "share":
                return Map(
                    "sharePath", "",
                    "commandFile", "alt_command.txt",
                    "statusFile", "alt_status.txt"
                )
            default:
                return Map()
        }
    }
}

; Clase principal para manejar la comunicacion
class MacroCommunication {
    Strategy := ""
    IsEnabled := false
    Config := Map()
    
    Init(type, config) {
        this.Strategy := CommunicationFactory.Create(type, config)
        if (this.Strategy = 0)
            return 0
        
        this.Config := config.Clone()
        this.IsEnabled := true
        return 1
    }
    
    SendCommand(command) {
        if (!this.IsEnabled || !this.Strategy)
            return 0
        return this.Strategy.Send(command)
    }
    
    ReceiveCommand() {
        if (!this.IsEnabled || !this.Strategy)
            return ""
        return this.Strategy.Receive()
    }
    
    WriteStatus(status) {
        if (!this.IsEnabled || !this.Strategy)
            return 0
        return this.Strategy.WriteStatus(status)
    }
    
    ReadStatus() {
        if (!this.IsEnabled || !this.Strategy)
            return 0
        return this.Strategy.ReadStatus()
    }
    
    TestConnection() {
        if (!this.Strategy)
            return 0
        return this.Strategy.TestConnection()
    }
    
    IsConnected() {
        status := this.ReadStatus()
        if (status = 0)
            return 0
        return (status["status"] != "offline" && status["status"] != "unknown")
    }
    
    Close() {
        if (this.Strategy) {
            this.Strategy.Close()
            this.Strategy := ""
        }
        this.IsEnabled := false
    }
}

; Funcion helper para enviar WM_COPYDATA
Send_WM_COPYDATA(StringToSend, TargetScriptTitle, wParam := 0) {
    CopyDataStruct := Buffer(3 * A_PtrSize)
    SizeInBytes := (StrLen(StringToSend) + 1) * 2
    NumPut("Ptr", SizeInBytes
        , "Ptr", StrPtr(StringToSend)
        , CopyDataStruct, A_PtrSize)
    
    try {
        s := SendMessage(0x004A, wParam, CopyDataStruct,, TargetScriptTitle)
    } catch {
        return -1
    } else {
        return s
    }
}
