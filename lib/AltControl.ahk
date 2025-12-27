/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

Este archivo es parte de Natro Macro. Nuestro código fuente siempre será abierto y disponible.

Natro Macro es software libre: puedes redistribuirlo y/o modificarlo bajo los términos de la GNU General Public License.
*/

; Sistema de control de Alt Account
; Utiliza archivos compartidos en red para comunicacion entre el macro principal y la alt account

class AltControl {
    static CommandFile := ""
    static StatusFile := ""
    static AltIP := ""
    static AltSharePath := ""
    static IsEnabled := false
    
    ; Inicializa el sistema de control de alt
    ; altIP: IP de la computadora donde corre la alt account
    ; sharePath: Ruta compartida en red (ej: \\192.168.1.100\NatroMacro)
    Init(altIP, sharePath) {
        this.AltIP := altIP
        this.AltSharePath := sharePath
        this.CommandFile := sharePath "\alt_command.txt"
        this.StatusFile := sharePath "\alt_status.txt"
        this.IsEnabled := true
    }
    
    ; Envia un comando a la alt account
    ; command: Comando a ejecutar (ej: "GATHER Sunflower", "STOP", "STATUS")
    ; Devuelve: 1 si se envio correctamente, 0 si hubo error
    SendCommand(command) {
        if (!this.IsEnabled || this.CommandFile = "")
            return 0
        
        try {
            file := FileOpen(this.CommandFile, "w")
            if (!file) {
                ; Intentar crear el archivo si no existe
                file := FileOpen(this.CommandFile, "w-d")
                if (!file)
                    return 0
            }
            file.Write(command)
            file.Close()
            return 1
        } catch {
            return 0
        }
    }
    
    ; Lee el estado actual de la alt account
    ; Devuelve: Map con el estado o 0 si hay error
    GetStatus() {
        if (!this.IsEnabled || this.StatusFile = "")
            return 0
        
        try {
            if (!FileExist(this.StatusFile))
                return Map("status", "offline", "field", "", "action", "")
            
            file := FileOpen(this.StatusFile, "r")
            if (!file)
                return 0
            
            content := file.Read()
            file.Close()
            
            ; Parsear el contenido del estado
            ; Formato esperado: status=value|field=value|action=value
            statusMap := Map()
            Loop Parse content, "|" {
                if (InStr(A_LoopField, "=")) {
                    parts := StrSplit(A_LoopField, "=", , 2)
                    if (parts.Length = 2)
                        statusMap[Trim(parts[1])] := Trim(parts[2])
                }
            }
            
            ; Valores por defecto si faltan
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
        status := this.GetStatus()
        if (status = 0)
            return 0
        return (status["status"] != "offline" && status["status"] != "unknown")
    }
    
    ; Verifica si la conexion a la red compartida esta disponible
    ; Devuelve: 1 si esta disponible, 0 si no
    TestConnection() {
        if (this.AltSharePath = "")
            return 0
        
        try {
            ; Intentar acceder al directorio compartido
            if (DirExist(this.AltSharePath))
                return 1
            return 0
        } catch {
            return 0
        }
    }
}

; Funcion global para inicializar el control de alt
; altIP: IP de la computadora de la alt
; sharePath: Ruta compartida en red
nm_InitAltControl(altIP, sharePath) {
    global AltController
    if (!IsSet(AltController))
        AltController := AltControl()
    AltController.Init(altIP, sharePath)
    return AltController.TestConnection()
}

; Funcion global para enviar comando de recoleccion a la alt
nm_AltGather(fieldName, pattern := "") {
    global AltController
    if (!IsSet(AltController) || !AltController.IsEnabled)
        return 0
    return AltController.SendGatherCommand(fieldName, pattern)
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

