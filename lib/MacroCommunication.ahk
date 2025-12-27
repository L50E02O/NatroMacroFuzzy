/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

Sistema abstracto de comunicacion entre macros en la misma red
Implementa el patron Strategy para permitir diferentes metodos de comunicacion
*/

; Interfaz base para estrategias de comunicacion
class ICommunicationStrategy {
    ; Inicializa la estrategia de comunicacion
    ; config: Map con la configuracion especifica de la estrategia
    ; Devuelve: 1 si se inicializo correctamente, 0 si hubo error
    Init(config) {
        throw Error("Init() debe ser implementado por la clase derivada")
    }
    
    ; Envia un mensaje/comando
    ; message: Mensaje a enviar (String)
    ; Devuelve: 1 si se envio correctamente, 0 si hubo error
    Send(message) {
        throw Error("Send() debe ser implementado por la clase derivada")
    }
    
    ; Recibe un mensaje/comando
    ; Devuelve: String con el mensaje recibido, o "" si no hay mensajes
    Receive() {
        throw Error("Receive() debe ser implementado por la clase derivada")
    }
    
    ; Escribe un estado
    ; status: Map con el estado a escribir
    ; Devuelve: 1 si se escribio correctamente, 0 si hubo error
    WriteStatus(status) {
        throw Error("WriteStatus() debe ser implementado por la clase derivada")
    }
    
    ; Lee el estado actual
    ; Devuelve: Map con el estado, o 0 si hay error
    ReadStatus() {
        throw Error("ReadStatus() debe ser implementado por la clase derivada")
    }
    
    ; Verifica si la conexion esta disponible
    ; Devuelve: 1 si esta disponible, 0 si no
    TestConnection() {
        throw Error("TestConnection() debe ser implementado por la clase derivada")
    }
    
    ; Limpia recursos y cierra la conexion
    Close() {
        ; Implementacion opcional por defecto
    }
}

; Estrategia de comunicacion mediante archivos compartidos en red
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
        
        ; Verificar que el directorio compartido existe
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
            
            ; Solo leer si el archivo fue modificado recientemente
            FileGetTime fileTime, this.CommandFile
            if (fileTime <= this.LastCommandTime)
                return ""
            
            file := FileOpen(this.CommandFile, "r")
            if (!file)
                return ""
            
            message := Trim(file.Read())
            file.Close()
            
            ; Limpiar el archivo despues de leerlo
            try {
                FileDelete this.CommandFile
            } catch {
                ; Ignorar error si no se puede borrar
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
            ; Convertir Map a string en formato: key=value|key=value
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
            
            ; Parsear el contenido
            statusMap := Map()
            Loop Parse content, "|" {
                if (InStr(A_LoopField, "=")) {
                    parts := StrSplit(A_LoopField, "=", , 2)
                    if (parts.Length = 2)
                        statusMap[Trim(parts[1])] := Trim(parts[2])
                }
            }
            
            ; Valores por defecto
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

; Estrategia de comunicacion mediante TCP/IP (para futura implementacion)
class TCPStrategy extends ICommunicationStrategy {
    Host := ""
    Port := 0
    Socket := ""
    IsServer := false
    
    Init(config) {
        if (!config.Has("host") || !config.Has("port"))
            return 0
        
        this.Host := config["host"]
        this.Port := config["port"]
        this.IsServer := config.Has("isServer") ? config["isServer"] : false
        
        ; TODO: Implementar conexion TCP real
        ; Por ahora retornamos 0 para indicar que no esta implementado
        return 0
    }
    
    Send(message) {
        ; TODO: Implementar envio TCP
        return 0
    }
    
    Receive() {
        ; TODO: Implementar recepcion TCP
        return ""
    }
    
    WriteStatus(status) {
        ; TODO: Implementar escritura de estado via TCP
        return 0
    }
    
    ReadStatus() {
        ; TODO: Implementar lectura de estado via TCP
        return 0
    }
    
    TestConnection() {
        ; TODO: Implementar test de conexion TCP
        return 0
    }
}

; Factory para crear estrategias de comunicacion
class CommunicationFactory {
    ; Crea una estrategia de comunicacion basada en el tipo
    ; type: Tipo de estrategia ("fileshare", "tcp", etc.)
    ; config: Map con la configuracion necesaria
    ; Devuelve: Instancia de la estrategia o 0 si hay error
    static Create(type, config) {
        strategy := ""
        
        switch StrLower(type) {
            case "fileshare", "file", "share":
                strategy := FileShareStrategy()
            case "tcp", "socket":
                strategy := TCPStrategy()
            default:
                return 0
        }
        
        if (strategy.Init(config))
            return strategy
        else
            return 0
    }
    
    ; Obtiene la configuracion por defecto para un tipo de estrategia
    ; type: Tipo de estrategia
    ; Devuelve: Map con configuracion por defecto
    static GetDefaultConfig(type) {
        switch StrLower(type) {
            case "fileshare", "file", "share":
                return Map(
                    "sharePath", "",
                    "commandFile", "alt_command.txt",
                    "statusFile", "alt_status.txt"
                )
            case "tcp", "socket":
                return Map(
                    "host", "127.0.0.1",
                    "port", 8888,
                    "isServer", false
                )
            default:
                return Map()
        }
    }
}

; Clase principal para manejar la comunicacion entre macros
class MacroCommunication {
    Strategy := ""
    IsEnabled := false
    Config := Map()
    
    ; Inicializa el sistema de comunicacion
    ; type: Tipo de estrategia ("fileshare", "tcp", etc.)
    ; config: Map con la configuracion necesaria
    ; Devuelve: 1 si se inicializo correctamente, 0 si hubo error
    Init(type, config) {
        this.Strategy := CommunicationFactory.Create(type, config)
        if (this.Strategy = 0)
            return 0
        
        this.Config := config.Clone()
        this.IsEnabled := true
        return 1
    }
    
    ; Envia un comando
    ; command: Comando a enviar
    ; Devuelve: 1 si se envio correctamente, 0 si hubo error
    SendCommand(command) {
        if (!this.IsEnabled || !this.Strategy)
            return 0
        return this.Strategy.Send(command)
    }
    
    ; Recibe un comando
    ; Devuelve: String con el comando recibido, o "" si no hay comandos
    ReceiveCommand() {
        if (!this.IsEnabled || !this.Strategy)
            return ""
        return this.Strategy.Receive()
    }
    
    ; Escribe el estado
    ; status: Map con el estado
    ; Devuelve: 1 si se escribio correctamente, 0 si hubo error
    WriteStatus(status) {
        if (!this.IsEnabled || !this.Strategy)
            return 0
        return this.Strategy.WriteStatus(status)
    }
    
    ; Lee el estado
    ; Devuelve: Map con el estado, o 0 si hay error
    ReadStatus() {
        if (!this.IsEnabled || !this.Strategy)
            return 0
        return this.Strategy.ReadStatus()
    }
    
    ; Verifica si la conexion esta disponible
    ; Devuelve: 1 si esta disponible, 0 si no
    TestConnection() {
        if (!this.Strategy)
            return 0
        return this.Strategy.TestConnection()
    }
    
    ; Verifica si esta conectado y respondiendo
    ; Devuelve: 1 si esta conectado, 0 si no
    IsConnected() {
        status := this.ReadStatus()
        if (status = 0)
            return 0
        return (status["status"] != "offline" && status["status"] != "unknown")
    }
    
    ; Cierra la conexion y limpia recursos
    Close() {
        if (this.Strategy) {
            this.Strategy.Close()
            this.Strategy := ""
        }
        this.IsEnabled := false
    }
}

