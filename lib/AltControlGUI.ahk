/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

Funciones GUI para el control de Alt Account
*/

; Variables globales para la GUI de Alt Control
AltControlGui := ""
AltControlFields := ["Sunflower", "Dandelion", "Clover", "Mushroom", "Blue Flower", "Spider", "Strawberry", "Bamboo", "Pine Tree", "Pineapple", "Cactus", "Pumpkin", "Rose", "Pepper", "Stump", "Coconut", "Mountain Top"]
AltControlPatterns := ["Snake", "Lines", "Diamonds", "Stationary", "XSnake", "CornerXSnake", "Fork", "Squares", "Slimline", "SuperCat", "Auryn", "e_lol"]

; Crea y muestra la GUI de control de Alt Account
nm_AltControlGUI(*) {
    global AltControlGui, AltControlFields, AltControlPatterns, AltController
    
    ; Si la GUI ya existe, mostrarla
    if (IsSet(AltControlGui) && AltControlGui) {
        try {
            AltControlGui.Show()
            AltControlGui.Focus()
            return
        } catch {
            ; GUI fue destruida, crear una nueva
        }
    }
    
    ; Crear nueva GUI
    AltControlGui := Gui("+Resize +OwnDialogs", "Alt Account Control")
    AltControlGui.OnEvent("Close", nm_AltControlGUIClose)
    AltControlGui.OnEvent("Size", nm_AltControlGUISize)
    
    ; Configuracion de conexion
    AltControlGui.Add("GroupBox", "x10 y10 w480 h100", "Configuracion de Conexion")
    AltControlGui.Add("Text", "x20 y30 w100 +BackgroundTrans", "IP de Alt Account:")
    AltControlGui.Add("Edit", "x120 y28 w200 h20 vAltIPEdit", "")
    AltControlGui.Add("Text", "x20 y55 w100 +BackgroundTrans", "Ruta Compartida:")
    AltControlGui.Add("Edit", "x120 y53 w300 h20 vAltShareEdit", "")
    AltControlGui.Add("Button", "x330 y28 w80 h20 vAltTestButton", "Probar Conexion").OnEvent("Click", nm_AltTestConnection)
    AltControlGui.Add("Button", "x420 y28 w60 h20 vAltConnectButton", "Conectar").OnEvent("Click", nm_AltConnect)
    AltControlGui.Add("Text", "x20 y80 w460 +BackgroundTrans vAltStatusText", "Estado: No conectado")
    
    ; Control de campos
    AltControlGui.Add("GroupBox", "x10 y120 w480 h200", "Asignar Campo a Alt")
    AltControlGui.Add("Text", "x20 y140 w100 +BackgroundTrans", "Campo:")
    AltControlGui.Add("DropDownList", "x120 y138 w150 h200 vAltFieldSelect", AltControlFields)
    AltControlGui.Add("Text", "x20 y165 w100 +BackgroundTrans", "Patron:")
    AltControlGui.Add("DropDownList", "x120 y163 w150 h200 vAltPatternSelect", AltControlPatterns)
    AltControlGui.Add("Button", "x280 y138 w100 h30 vAltSendGatherButton", "Enviar a Recolectar").OnEvent("Click", nm_AltSendGather)
    AltControlGui.Add("Button", "x280 y173 w100 h30 vAltStopButton", "Detener Alt").OnEvent("Click", nm_AltStopGUI)
    AltControlGui.Add("Button", "x280 y208 w100 h30 vAltReturnButton", "Regresar al Hive").OnEvent("Click", nm_AltReturnToHive)
    
    ; Estado de la Alt
    AltControlGui.Add("GroupBox", "x10 y330 w480 h100", "Estado de Alt Account")
    AltControlGui.Add("Text", "x20 y350 w460 h80 +BackgroundTrans -Wrap vAltStateText", "Esperando conexion...")
    
    ; Timer para actualizar estado
    SetTimer nm_AltUpdateStatus, 2000
    
    ; Cargar configuracion guardada
    nm_AltLoadConfig()
    
    AltControlGui.Show("w500 h440")
    nm_AltUpdateStatus()
}

; Cierra la GUI de Alt Control
nm_AltControlGUIClose(*) {
    global AltControlGui
    SetTimer nm_AltUpdateStatus, 0
    AltControlGui.Destroy()
    AltControlGui := ""
}

; Maneja el redimensionamiento de la GUI
nm_AltControlGUISize(GuiObj, MinMax, Width, Height) {
    ; Mantener tamaño minimo
    if (Width < 500)
        GuiObj[""].Move(, , 500)
    if (Height < 440)
        GuiObj[""].Move(, , , 440)
}

; Prueba la conexion con la alt account
nm_AltTestConnection(*) {
    global AltControlGui, AltController
    
    AltControlGui.Submit(false)
    altIP := AltControlGui["AltIPEdit"].Value
    sharePath := AltControlGui["AltShareEdit"].Value
    
    if (altIP = "" || sharePath = "") {
        MsgBox "Por favor ingresa la IP y la ruta compartida", "Error", 0x40010
        return
    }
    
    ; Inicializar controlador
    if (!IsSet(AltController))
        AltController := AltControl()
    
    AltController.Init(altIP, sharePath)
    
    if (AltController.TestConnection()) {
        MsgBox "Conexion exitosa!", "Exito", 0x40040
        AltControlGui["AltStatusText"].Text := "Estado: Conexion disponible"
    } else {
        MsgBox "No se pudo conectar. Verifica que:`n- La IP sea correcta`n- La ruta compartida exista`n- El firewall permita el acceso", "Error de Conexion", 0x40010
        AltControlGui["AltStatusText"].Text := "Estado: Error de conexion"
    }
}

; Conecta con la alt account
nm_AltConnect(*) {
    global AltControlGui, AltController
    
    AltControlGui.Submit(false)
    altIP := AltControlGui["AltIPEdit"].Value
    sharePath := AltControlGui["AltShareEdit"].Value
    
    if (altIP = "" || sharePath = "") {
        MsgBox "Por favor ingresa la IP y la ruta compartida", "Error", 0x40010
        return
    }
    
    ; Inicializar controlador
    if (!IsSet(AltController))
        AltController := AltControl()
    
    if (nm_InitAltControl(altIP, sharePath)) {
        AltControlGui["AltStatusText"].Text := "Estado: Conectado"
        nm_AltSaveConfig()
        MsgBox "Conectado exitosamente a la alt account!", "Exito", 0x40040
    } else {
        AltControlGui["AltStatusText"].Text := "Estado: Error de conexion"
        MsgBox "No se pudo conectar. Verifica la configuracion.", "Error", 0x40010
    }
}

; Envia comando de recoleccion a la alt
nm_AltSendGather(*) {
    global AltControlGui, AltController
    
    if (!IsSet(AltController) || !AltController.IsEnabled) {
        MsgBox "Primero debes conectar con la alt account", "Error", 0x40010
        return
    }
    
    AltControlGui.Submit(false)
    fieldName := AltControlGui["AltFieldSelect"].Text
    pattern := AltControlGui["AltPatternSelect"].Text
    
    if (fieldName = "") {
        MsgBox "Por favor selecciona un campo", "Error", 0x40010
        return
    }
    
    if (nm_AltGather(fieldName, pattern)) {
        AltControlGui["AltStateText"].Text := "Comando enviado: Recolectar en " fieldName " con patron " pattern
        nm_setStatus("Sent", "Alt: Gather " fieldName)
    } else {
        MsgBox "Error al enviar comando. Verifica la conexion.", "Error", 0x40010
    }
}

; Detiene la alt account
nm_AltStopGUI(*) {
    global AltControlGui, AltController
    
    if (!IsSet(AltController) || !AltController.IsEnabled) {
        MsgBox "Primero debes conectar con la alt account", "Error", 0x40010
        return
    }
    
    if (nm_AltStop()) {
        AltControlGui["AltStateText"].Text := "Comando enviado: Detener"
        nm_setStatus("Sent", "Alt: Stop")
    } else {
        MsgBox "Error al enviar comando. Verifica la conexion.", "Error", 0x40010
    }
}

; Envia comando para que la alt regrese al hive
nm_AltReturnToHive(*) {
    global AltControlGui, AltController
    
    if (!IsSet(AltController) || !AltController.IsEnabled) {
        MsgBox "Primero debes conectar con la alt account", "Error", 0x40010
        return
    }
    
    if (nm_AltReturnToHive()) {
        AltControlGui["AltStateText"].Text := "Comando enviado: Regresar al Hive"
        nm_setStatus("Sent", "Alt: Return to Hive")
    } else {
        MsgBox "Error al enviar comando. Verifica la conexion.", "Error", 0x40010
    }
}

; Actualiza el estado de la alt account
nm_AltUpdateStatus(*) {
    global AltControlGui, AltController
    
    if (!IsSet(AltControlGui) || !AltControlGui)
        return
    
    if (!IsSet(AltController) || !AltController.IsEnabled) {
        AltControlGui["AltStateText"].Text := "No conectado"
        return
    }
    
    status := nm_AltGetStatus()
    if (status = 0) {
        AltControlGui["AltStateText"].Text := "Error al leer estado"
        return
    }
    
    statusText := "Estado: " status["status"] "`n"
    if (status["field"] != "")
        statusText .= "Campo: " status["field"] "`n"
    if (status["action"] != "")
        statusText .= "Accion: " status["action"]
    
    AltControlGui["AltStateText"].Text := statusText
}

; Guarda la configuracion de alt
nm_AltSaveConfig() {
    global AltControlGui
    
    if (!IsSet(AltControlGui) || !AltControlGui)
        return
    
    AltControlGui.Submit(false)
    altIP := AltControlGui["AltIPEdit"].Value
    sharePath := AltControlGui["AltShareEdit"].Value
    
    try {
        IniWrite altIP, "settings\nm_config.ini", "AltControl", "AltIP"
        IniWrite sharePath, "settings\nm_config.ini", "AltControl", "AltSharePath"
    } catch {
        ; Ignorar error
    }
}

; Carga la configuracion de alt
nm_AltLoadConfig() {
    global AltControlGui
    
    if (!IsSet(AltControlGui) || !AltControlGui)
        return
    
    try {
        altIP := IniRead("settings\nm_config.ini", "AltControl", "AltIP", "")
        sharePath := IniRead("settings\nm_config.ini", "AltControl", "AltSharePath", "")
        
        if (altIP != "")
            AltControlGui["AltIPEdit"].Value := altIP
        if (sharePath != "")
            AltControlGui["AltShareEdit"].Value := sharePath
    } catch {
        ; Ignorar error si no existe la configuracion
    }
}

