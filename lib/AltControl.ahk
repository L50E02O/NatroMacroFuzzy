/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

Sistema de control de Alt Account usando comunicacion abstracta entre macros
*/

#Include "MacroCommunication.ahk"

; Clase principal para controlar una alt account
class AltControl {
    Communication := ""
    IsEnabled := false
    ConnectionType := "fileshare"
    
    ; Inicializa el sistema de control de alt
    ; type: Tipo de comunicacion ("fileshare", "tcp", etc.)
    ; config: Map con la configuracion de la comunicacion
    ;   Para fileshare: {"sharePath": "\\192.168.1.100\NatroMacro", "commandFile": "alt_command.txt", "statusFile": "alt_status.txt"}
    ;   Para tcp: {"host": "192.168.1.100", "port": 8888, "isServer": false}
    ; Devuelve: 1 si se inicializo correctamente, 0 si hubo error
    Init(type := "fileshare", config := Map()) {
        this.ConnectionType := type
        this.Communication := MacroCommunication()
        
        if (!this.Communication.Init(type, config))
            return 0
        
        this.IsEnabled := true
        return 1
    }
    
    ; Inicializa usando archivos compartidos (metodo legacy para compatibilidad)
    ; altIP: IP de la computadora donde corre la alt account (no se usa, solo para compatibilidad)
    ; sharePath: Ruta compartida en red
    ; Devuelve: 1 si se inicializo correctamente, 0 si hubo error
    InitFileShare(altIP := "", sharePath := "") {
        config := Map(
            "sharePath", sharePath,
            "commandFile", "alt_command.txt",
            "statusFile", "alt_status.txt"
        )
        return this.Init("fileshare", config)
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
    ; pattern: Patron de recoleccion (opcional, usa el default si no se especifica)
    ; Devuelve: 1 si se envio correctamente, 0 si hubo error
    SendGatherCommand(fieldName, pattern := "") {
        command := "GATHER " fieldName
        if (pattern != "")
            command .= " " pattern
        return this.SendCommand(command)
    }
    
    ; Envia comando avanzado de recoleccion (inspirado en Revolution Macro)
    ; fieldName: Nombre del campo
    ; pattern: Patron de recoleccion
    ; gatherTime: Tiempo de recoleccion en minutos (0 = infinito)
    ; rotateFields: Si debe rotar entre campos
    ; Devuelve: 1 si se envio correctamente, 0 si hubo error
    SendGatherCommandAdvanced(fieldName, pattern := "", gatherTime := 0, rotateFields := false) {
        command := "GATHER " fieldName
        if (pattern != "")
            command .= " " pattern
        if (gatherTime > 0)
            command .= " TIME:" gatherTime
        if (rotateFields)
            command .= " ROTATE:1"
        return this.SendCommand(command)
    }
    
    ; Envia comando para cambiar de campo (prioridad alta, interrumpe gathering actual)
    ; fieldName: Nuevo campo al que cambiar
    ; pattern: Patron de recoleccion (opcional)
    ; Devuelve: 1 si se envio correctamente, 0 si hubo error
    SendChangeFieldCommand(fieldName, pattern := "") {
        command := "CHANGE_FIELD " fieldName
        if (pattern != "")
            command .= " " pattern
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

; Funcion global para inicializar el control de alt (compatibilidad legacy)
; altIP: IP de la computadora de la alt (no se usa realmente, solo para compatibilidad)
; sharePath: Ruta compartida en red
; Devuelve: 1 si se inicializo correctamente, 0 si hubo error
nm_InitAltControl(altIP := "", sharePath := "") {
    global AltController
    if (!IsSet(AltController))
        AltController := AltControl()
    
    if (sharePath = "") {
        ; Intentar leer de configuracion
        try {
            sharePath := IniRead("settings\nm_config.ini", "AltControl", "AltSharePath", "")
            if (sharePath = "")
                return 0
        } catch {
            return 0
        }
    }
    
    result := AltController.InitFileShare(altIP, sharePath)
    if (result)
        return AltController.TestConnection()
    return 0
}

; Funcion global para inicializar el control de alt con configuracion avanzada
; type: Tipo de comunicacion ("fileshare", "tcp", etc.)
; config: Map con la configuracion
; Devuelve: 1 si se inicializo correctamente, 0 si hubo error
nm_InitAltControlAdvanced(type, config) {
    global AltController
    if (!IsSet(AltController))
        AltController := AltControl()
    return AltController.Init(type, config)
}

; Funcion global para enviar comando de recoleccion a la alt
nm_AltGather(fieldName, pattern := "") {
    global AltController
    if (!IsSet(AltController) || !AltController.IsEnabled)
        return 0
    return AltController.SendGatherCommand(fieldName, pattern)
}

; Funcion global para enviar comando avanzado de recoleccion (inspirado en Revolution Macro)
nm_AltGatherAdvanced(fieldName, pattern := "", gatherTime := 0, rotateFields := false) {
    global AltController
    if (!IsSet(AltController) || !AltController.IsEnabled)
        return 0
    return AltController.SendGatherCommandAdvanced(fieldName, pattern, gatherTime, rotateFields)
}

; Funcion global para cambiar de campo dinamicamente (interrumpe gathering actual)
nm_AltChangeField(fieldName, pattern := "") {
    global AltController
    if (!IsSet(AltController) || !AltController.IsEnabled)
        return 0
    return AltController.SendChangeFieldCommand(fieldName, pattern)
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
