/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

Sistema de control de Alt Account - Adaptado de Revolution Macro
Usa WM_COPYDATA para comunicacion directa (mas rapido y simple)
*/

#Include "MacroCommunication.ahk"

; Clase principal para controlar una alt account
class AltControl {
    Communication := ""
    IsEnabled := false
    ConnectionType := "wmcopydata"
    
    ; Inicializa el sistema de control de alt
    ; windowTitle: Titulo de la ventana de la alt account (ej: "AltAccount.ahk ahk_class AutoHotkey")
    ; Devuelve: 1 si se inicializo correctamente, 0 si hubo error
    Init(windowTitle := "AltAccount.ahk ahk_class AutoHotkey") {
        this.ConnectionType := "wmcopydata"
        this.Communication := MacroCommunication()
        
        config := Map("targetWindowTitle", windowTitle)
        if (!this.Communication.Init("wmcopydata", config))
            return 0
        
        this.IsEnabled := true
        return 1
    }
    
    ; Inicializa usando archivos compartidos (fallback para red)
    ; sharePath: Ruta compartida en red
    ; Devuelve: 1 si se inicializo correctamente, 0 si hubo error
    InitFileShare(sharePath := "") {
        config := Map(
            "sharePath", sharePath,
            "commandFile", "alt_command.txt",
            "statusFile", "alt_status.txt"
        )
        this.ConnectionType := "fileshare"
        this.Communication := MacroCommunication()
        
        if (!this.Communication.Init("fileshare", config))
            return 0
        
        this.IsEnabled := true
        return 1
    }
    
    ; Envia un comando a la alt account
    ; command: Comando a ejecutar (ej: "GATHER Sunflower", "STOP", "STATUS")
    ; Devuelve: 1 si se envio correctamente, 0 si hubo error
    SendCommand(command) {
        if (!this.IsEnabled)
            return 0
        return this.Communication.SendCommand(command)
    }
    
    ; Lee el estado actual de la alt account
    ; Devuelve: Map con el estado o 0 si hay error
    GetStatus() {
        if (!this.IsEnabled)
            return 0
        return this.Communication.ReadStatus()
    }
    
    ; Envia comando para que la alt vaya a un campo y recolecte
    ; fieldName: Nombre del campo (ej: "Sunflower", "Pine Tree")
    ; pattern: Patron de recoleccion (opcional)
    ; hiveSlot: Numero de hive (1-6, opcional)
    ; Devuelve: 1 si se envio correctamente, 0 si hubo error
    SendGatherCommand(fieldName, pattern := "", hiveSlot := "") {
        command := "GATHER " fieldName
        if (pattern != "")
            command .= " " pattern
        if (hiveSlot != "")
            command .= " HIVE:" hiveSlot
        return this.SendCommand(command)
    }
    
    ; Envia comando para detener la alt account
    ; Devuelve: 1 si se envio correctamente, 0 si hubo error
    SendStopCommand() {
        return this.SendCommand("STOP")
    }
    
    ; Envia comando para que la alt regrese al hive
    ; Devuelve: 1 si se envio correctamente, 0 si hubo error
    SendReturnToHiveCommand() {
        return this.SendCommand("RETURN_HIVE")
    }
    
    ; Verifica si la alt account esta conectada y respondiendo
    ; Devuelve: 1 si esta conectada, 0 si no
    IsConnected() {
        if (!this.IsEnabled)
            return 0
        return this.Communication.IsConnected()
    }
    
    ; Verifica si la conexion esta disponible
    ; Devuelve: 1 si esta disponible, 0 si no
    TestConnection() {
        if (!this.Communication)
            return 0
        return this.Communication.TestConnection()
    }
    
    ; Cierra la conexion y limpia recursos
    Close() {
        if (this.Communication) {
            this.Communication.Close()
            this.Communication := ""
        }
        this.IsEnabled := false
    }
}

; Funcion global para inicializar el control de alt (simple, como Revolution Macro)
; windowTitle: Titulo de la ventana de la alt (por defecto busca "AltAccount.ahk")
; Devuelve: 1 si se inicializo correctamente, 0 si hubo error
nm_InitAltControl(windowTitle := "AltAccount.ahk ahk_class AutoHotkey") {
    global AltController
    if (!IsSet(AltController))
        AltController := AltControl()
    
    result := AltController.Init(windowTitle)
    if (result)
        return AltController.TestConnection()
    return 0
}

; Funcion global para inicializar usando archivos compartidos (para red)
nm_InitAltControlFileShare(sharePath := "") {
    global AltController
    if (!IsSet(AltController))
        AltController := AltControl()
    
    if (sharePath = "") {
        try {
            sharePath := IniRead("settings\nm_config.ini", "AltControl", "AltSharePath", "")
            if (sharePath = "")
                return 0
        } catch {
            return 0
        }
    }
    
    result := AltController.InitFileShare(sharePath)
    if (result)
        return AltController.TestConnection()
    return 0
}

; Funcion global para enviar comando de recoleccion a la alt
nm_AltGather(fieldName, pattern := "", hiveSlot := "") {
    global AltController
    if (!IsSet(AltController) || !AltController.IsEnabled)
        return 0
    return AltController.SendGatherCommand(fieldName, pattern, hiveSlot)
}

; Funcion global para detener la alt
nm_AltStop() {
    global AltController
    if (!IsSet(AltController) || !AltController.IsEnabled)
        return 0
    return AltController.SendStopCommand()
}

; Funcion global para que la alt regrese al hive
nm_AltReturnToHive() {
    global AltController
    if (!IsSet(AltController) || !AltController.IsEnabled)
        return 0
    return AltController.SendReturnToHiveCommand()
}

; Funcion global para obtener el estado de la alt
nm_AltGetStatus() {
    global AltController
    if (!IsSet(AltController) || !AltController.IsEnabled)
        return 0
    return AltController.GetStatus()
}

; Funcion global para verificar si la alt esta conectada
nm_AltIsConnected() {
    global AltController
    if (!IsSet(AltController) || !AltController.IsEnabled)
        return 0
    return AltController.IsConnected()
}
