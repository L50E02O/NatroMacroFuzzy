/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

Funciones GUI para el control de Alt Account - Simplificado como Revolution Macro
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
        }
    }
    
    ; Crear nueva GUI
    AltControlGui := Gui("+OwnDialogs", "Alt Account Control")
    AltControlGui.OnEvent("Close", nm_AltControlGUIClose)
    
    ; Configuracion simple (como Revolution Macro)
    AltControlGui.Add("GroupBox", "x10 y10 w480 h105", "Conexion")
    AltControlGui.Add("Text", "x20 y30 w120 +BackgroundTrans", "Nombre de Ventana:")
    AltControlGui.Add("Edit", "x140 y28 w250 h20 vAltWindowEdit", "AltAccount.ahk ahk_class AutoHotkey")
    AltControlGui.Add("Button", "x400 y28 w80 h20 vAltConnectButton", "Conectar").OnEvent("Click", nm_AltConnect)
    AltControlGui.Add("Text", "x20 y55 w120 +BackgroundTrans", "Numero de Hive:")
    AltControlGui.Add("Edit", "x140 y53 w50 h20 vAltHiveSlotEdit", "1")
    AltControlGui.Add("Text", "x195 y55 w285 +BackgroundTrans", "(1-6, necesario para paths correctos)")
    AltControlGui.Add("Text", "x20 y80 w460 +BackgroundTrans vAltStatusText", "Estado: No conectado")
    
    ; Control de campos
    AltControlGui.Add("GroupBox", "x10 y125 w480 h150", "Asignar Campo")
    AltControlGui.Add("Text", "x20 y145 w100 +BackgroundTrans", "Campo:")
    AltControlGui.Add("DropDownList", "x120 y143 w150 h200 vAltFieldSelect", AltControlFields)
    AltControlGui.Add("Text", "x20 y170 w100 +BackgroundTrans", "Patron:")
    AltControlGui.Add("DropDownList", "x120 y168 w150 h200 vAltPatternSelect", AltControlPatterns)
    AltControlGui.Add("Button", "x280 y143 w100 h30 vAltSendGatherButton", "Enviar a Recolectar").OnEvent("Click", nm_AltSendGather)
    AltControlGui.Add("Button", "x280 y178 w100 h30 vAltStopButton", "Detener").OnEvent("Click", nm_AltStopGUI)
    AltControlGui.Add("Button", "x390 y143 w90 h30 vAltReturnButton", "Regresar al Hive").OnEvent("Click", nm_AltReturnToHiveGUI)
    
    ; Estado de la Alt
    AltControlGui.Add("GroupBox", "x10 y285 w480 h80", "Estado de Alt Account")
    AltControlGui.Add("Text", "x20 y305 w460 h60 +BackgroundTrans -Wrap vAltStateText", "Esperando conexion...")
    
    ; Timer para actualizar estado
    SetTimer nm_AltUpdateStatus, 1000
    
    ; Intentar conectar automaticamente si ya hay configuracion
    nm_AltLoadConfig()
    if (AltControlGui["AltWindowEdit"].Value != "") {
        nm_AltConnect()
    }
    
    AltControlGui.Show("w500 h375")
    nm_AltUpdateStatus()
}

; Cierra la GUI
nm_AltControlGUIClose(*) {
    global AltControlGui
    SetTimer nm_AltUpdateStatus, 0
    AltControlGui.Destroy()
    AltControlGui := ""
}

; Conecta con la alt account
nm_AltConnect(*) {
    global AltControlGui, AltController
    
    AltControlGui.Submit(false)
    windowTitle := AltControlGui["AltWindowEdit"].Value
    
    if (windowTitle = "") {
        MsgBox "Por favor ingresa el nombre de la ventana de la alt account", "Error", 0x40010
        return
    }
    
    ; Inicializar controlador
    if (!IsSet(AltController))
        AltController := AltControl()
    
    if (nm_InitAltControl(windowTitle)) {
        AltControlGui["AltStatusText"].Text := "Estado: Conectado"
        nm_AltSaveConfig()
    } else {
        AltControlGui["AltStatusText"].Text := "Estado: No se pudo conectar. Verifica que la alt account este ejecutandose."
        MsgBox "No se pudo conectar. Asegurate de que:`n- La alt account este ejecutandose`n- El nombre de la ventana sea correcto", "Error", 0x40010
    }
}

; Envia comando de recoleccion
nm_AltSendGather(*) {
    global AltControlGui, AltController
    
    if (!IsSet(AltController) || !AltController.IsEnabled) {
        MsgBox "Primero debes conectar con la alt account", "Error", 0x40010
        return
    }
    
    AltControlGui.Submit(false)
    fieldName := AltControlGui["AltFieldSelect"].Text
    pattern := AltControlGui["AltPatternSelect"].Text
    hiveSlot := AltControlGui["AltHiveSlotEdit"].Value
    
    if (fieldName = "") {
        MsgBox "Por favor selecciona un campo", "Error", 0x40010
        return
    }
    
    ; Validar hive slot
    if (!IsInteger(hiveSlot) || hiveSlot < 1 || hiveSlot > 6) {
        MsgBox "El numero de hive debe ser entre 1 y 6", "Error", 0x40010
        return
    }
    
    if (nm_AltGather(fieldName, pattern, hiveSlot)) {
        AltControlGui["AltStateText"].Text := "Comando enviado: Recolectar en " fieldName " (Hive " hiveSlot ")"
        nm_setStatus("Sent", "Alt: Gather " fieldName " Hive " hiveSlot)
    } else {
        MsgBox "Error al enviar comando. Verifica la conexion.", "Error", 0x40010
    }
}

; Detiene la alt
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
        MsgBox "Error al enviar comando.", "Error", 0x40010
    }
}

; Regresa al hive
nm_AltReturnToHiveGUI(*) {
    global AltControlGui, AltController
    
    if (!IsSet(AltController) || !AltController.IsEnabled) {
        MsgBox "Primero debes conectar con la alt account", "Error", 0x40010
        return
    }
    
    if (nm_AltReturnToHive()) {
        AltControlGui["AltStateText"].Text := "Comando enviado: Regresar al Hive"
        nm_setStatus("Sent", "Alt: Return to Hive")
    } else {
        MsgBox "Error al enviar comando.", "Error", 0x40010
    }
}

; Actualiza el estado
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
    if (status.Has("hiveSlot") && status["hiveSlot"] != "")
        statusText .= "Hive: " status["hiveSlot"] "`n"
    if (status["field"] != "")
        statusText .= "Campo: " status["field"] "`n"
    if (status["action"] != "")
        statusText .= "Accion: " status["action"]
    
    AltControlGui["AltStateText"].Text := statusText
}

; Guarda la configuracion
nm_AltSaveConfig() {
    global AltControlGui
    
    if (!IsSet(AltControlGui) || !AltControlGui)
        return
    
    AltControlGui.Submit(false)
    windowTitle := AltControlGui["AltWindowEdit"].Value
    hiveSlot := AltControlGui["AltHiveSlotEdit"].Value
    
    try {
        IniWrite windowTitle, "settings\nm_config.ini", "AltControl", "AltWindowTitle"
        IniWrite hiveSlot, "settings\nm_config.ini", "AltControl", "AltHiveSlot"
    } catch {
    }
}

; Carga la configuracion
nm_AltLoadConfig() {
    global AltControlGui
    
    if (!IsSet(AltControlGui) || !AltControlGui)
        return
    
    try {
        windowTitle := IniRead("settings\nm_config.ini", "AltControl", "AltWindowTitle", "AltAccount.ahk ahk_class AutoHotkey")
        hiveSlot := IniRead("settings\nm_config.ini", "AltControl", "AltHiveSlot", "1")
        AltControlGui["AltWindowEdit"].Value := windowTitle
        AltControlGui["AltHiveSlotEdit"].Value := hiveSlot
    } catch {
    }
}
