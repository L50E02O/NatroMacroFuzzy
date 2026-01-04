# Guia de Configuracion - Control de Alt Account

Esta guia explica como configurar y usar la funcionalidad de control de Alt Account en Natro Macro.

## Descripcion

La funcionalidad de Alt Account permite controlar una cuenta alternativa de Bee Swarm Simulator desde el macro principal. Puedes asignar campos especificos para que la alt account recolecte polen usando los paths y patrones existentes.

### Nuevas Caracteristicas (v2.0)

- **Sistema de Relay con ACK**: Comunicacion confiable con confirmacion de recepcion de comandos
- **Cambio Dinamico de Campos**: Cambia de campo mientras la alt esta recolectando sin necesidad de detenerla manualmente
- **Comunicacion Mejorada**: Verificacion cada 500ms para respuesta mas rapida
- **Reintentos Automaticos**: El sistema reintenta automaticamente si un comando no es confirmado

## Requisitos

1. Dos computadoras en la misma red local
2. Una carpeta compartida en red accesible desde ambas computadoras
3. Natro Macro instalado en ambas computadoras
4. Roblox y Bee Swarm Simulator abiertos en ambas computadoras

## Inicio Rapido

### Paso 1: Preparar la Carpeta Compartida

En la computadora principal:
1. Crea una carpeta llamada `NatroMacro` (puede estar en cualquier ubicacion)
2. Click derecho en la carpeta > Propiedades > Pestaña "Compartir"
3. Click en "Compartir" y agrega "Todos" con permisos de lectura/escritura
4. Anota la ruta de red (ej: `\\NOMBRE-PC\NatroMacro` o `\\192.168.1.100\NatroMacro`)

### Paso 2: Iniciar la Alt Account

En la computadora donde corre la alt account:
1. Abre Roblox y Bee Swarm Simulator
2. Ejecuta `START_ALT.bat` desde la carpeta de Natro Macro
3. Ingresa la ruta compartida cuando se te pida:
   ```
   \\192.168.1.100\NatroMacro
   ```
4. La ventana mostrara "Alt Account iniciada correctamente!"
5. Puedes cerrar la ventana, el script seguira ejecutandose

### Paso 3: Conectar desde el Macro Principal

En la computadora principal:
1. Abre Natro Macro
2. Ve a la pestaña **"Misc"**
3. Click en el boton **"Alt Account Control"**
4. En la ventana que se abre:
   - Ingresa la IP de la computadora de la alt (opcional, solo informativo)
   - Ingresa la ruta compartida (la misma del Paso 1)
   - Click en **"Probar Conexion"** para verificar
   - Click en **"Conectar"** para establecer la conexion
5. Veras "Estado: Conectado" cuando este listo

### Paso 4: Enviar Comandos

Una vez conectado:
1. Selecciona un campo del menu desplegable
2. Selecciona un patron de recoleccion (opcional, default: Snake)
3. Click en **"Iniciar Recoleccion"**
4. La alt account comenzara a recolectar en el campo seleccionado

**Para cambiar de campo mientras recolecta:**
- Selecciona el nuevo campo
- Click en **"Cambiar Campo"** (interrumpe el gathering actual y cambia)

## Configuracion Paso a Paso (Detallada)

### Paso 1: Configurar la Carpeta Compartida

En la computadora principal (donde corre el macro principal):

1. Crea una carpeta llamada `NatroMacro` en una ubicacion accesible
2. Comparte la carpeta en la red:
   - Click derecho en la carpeta > Propiedades
   - Ve a la pestaña "Compartir"
   - Click en "Compartir" y agrega "Todos" con permisos de lectura/escritura
   - Anota la ruta de red (ej: `\\NOMBRE-PC\NatroMacro`)

### Paso 2: Configurar el Macro Principal

1. Abre Natro Macro en la computadora principal
2. Ve a la pestaña "Misc"
3. Click en el boton "Alt Account Control"
4. En la ventana que se abre:
   - Ingresa la IP de la computadora donde corre la alt account
   - Ingresa la ruta compartida (ej: `\\192.168.1.100\NatroMacro`)
   - Click en "Probar Conexion" para verificar que funciona
   - Click en "Conectar" para establecer la conexion

### Paso 3: Configurar la Alt Account

En la computadora donde corre la alt account:

1. Asegurate de que Roblox y Bee Swarm Simulator esten abiertos
2. Ejecuta `START_ALT.bat` desde la carpeta de Natro Macro
3. Cuando se te pida, ingresa la ruta compartida (la misma que configuraste en el paso 2)
   - Ejemplo: `\\192.168.1.100\NatroMacro`
4. El script de alt account comenzara a escuchar comandos automaticamente

## Uso

### Inicio Rapido

1. **En la computadora de la Alt Account:**
   - Abre Roblox y Bee Swarm Simulator
   - Ejecuta `START_ALT.bat`
   - Ingresa la ruta compartida cuando se te pida (ej: `\\192.168.1.100\NatroMacro`)

2. **En la computadora Principal:**
   - Abre Natro Macro
   - Ve a la pestaña "Misc"
   - Click en "Alt Account Control"
   - Ingresa la IP y ruta compartida
   - Click en "Conectar"

### Asignar Campo a la Alt Account

1. En el macro principal, abre "Alt Account Control" (pestaña Misc)
2. Selecciona un campo del menu desplegable
3. (Opcional) Selecciona un patron de recoleccion
4. Click en **"Iniciar Recoleccion"**

La alt account recibira el comando (con confirmacion ACK) y comenzara a:
- Ir al campo seleccionado usando los paths existentes
- Recolectar polen usando el patron seleccionado

### Cambiar Campo Dinamicamente (NUEVA FUNCIONALIDAD)

**Esta es la caracteristica principal mejorada - inspirada en Revolution Macro:**

Mientras la alt account esta recolectando en un campo, puedes cambiar a otro campo sin detenerla manualmente:

1. En la ventana "Alt Account Control", selecciona el nuevo campo
2. (Opcional) Selecciona un patron diferente
3. Click en **"Cambiar Campo"**

La alt account:
- Interrumpira automaticamente el gathering actual
- Viajara al nuevo campo
- Comenzara a recolectar en el nuevo campo

**Ventajas:**
- No necesitas detener manualmente antes de cambiar
- Transicion fluida entre campos
- Ideal para optimizar recoleccion segun boosts o eventos

### Detener la Alt Account

Click en el boton **"Detener Alt"** para que la alt account deje de recolectar y regrese al hive.

### Regresar al Hive

Click en el boton **"Regresar al Hive"** para que la alt account regrese al hive usando los paths existentes.

### Ver Estado

El estado de la alt account se actualiza automaticamente cada 2 segundos en la ventana de control. Puedes ver:
- Estado actual (idle, gathering, traveling, etc.)
- Campo actual
- Accion que esta realizando

**Nota:** El sistema de relay con ACK asegura que todos los comandos sean confirmados. Si un comando no es confirmado, el sistema lo reintentara automaticamente hasta 3 veces.

## Campos Disponibles

Los siguientes campos estan disponibles para asignar a la alt account:
- Sunflower
- Dandelion
- Clover
- Mushroom
- Blue Flower
- Spider
- Strawberry
- Bamboo
- Pine Tree
- Pineapple
- Cactus
- Pumpkin
- Rose
- Pepper
- Stump
- Coconut
- Mountain Top

## Patrones Disponibles

Los siguientes patrones de recoleccion estan disponibles:
- Snake
- Lines
- Diamonds
- Stationary
- XSnake
- CornerXSnake
- Fork
- Squares
- Slimline
- SuperCat
- Auryn
- e_lol

## Solucion de Problemas

### Error: "No se puede acceder a la ruta compartida"

- Verifica que la carpeta este compartida correctamente
- Verifica que el firewall permita el acceso a archivos compartidos
- Asegurate de que ambas computadoras esten en la misma red
- Prueba acceder a la ruta compartida manualmente desde el Explorador de Windows

### Error: "Error al enviar comando"

- Verifica que la alt account este ejecutandose (revisa que START_ALT.bat este corriendo)
- Verifica que la ruta compartida sea correcta
- Asegurate de que los archivos de comando se puedan crear en la carpeta compartida

### La alt account no responde

- Verifica que Roblox este abierto en la computadora de la alt
- Verifica que el script AltAccount.ahk este ejecutandose
- Revisa que no haya errores en la ventana de la alt account
- Intenta reiniciar el script de alt account

### La alt account no va al campo correcto

- Verifica que el path para ese campo exista en la carpeta `paths/`
- Asegurate de que el nombre del campo coincida exactamente con los nombres disponibles
- Revisa los logs del macro para ver si hay errores

## Notas Importantes

1. **Sistema de Relay con ACK**: La comunicacion ahora usa un sistema de confirmacion (ACK) que asegura que cada comando sea recibido. Si un comando no es confirmado en 2 segundos, se reintenta automaticamente hasta 3 veces.

2. **Cambio Dinamico de Campos**: Puedes cambiar de campo en cualquier momento usando el boton "Cambiar Campo". La alt account interrumpira automaticamente el gathering actual y cambiara al nuevo campo.

3. **Comunicacion Mejorada**: El sistema verifica comandos cada 500ms (en lugar de cada segundo) para una respuesta mas rapida.

4. La comunicacion se realiza mediante archivos compartidos en red. Asegurate de que la carpeta compartida tenga permisos de lectura y escritura.

5. Los paths y patrones utilizados son los mismos que usa el macro principal, por lo que deben existir en ambas instalaciones de Natro Macro.

6. La alt account funciona de forma independiente del macro principal. Puedes tener ambos ejecutandose simultaneamente.

7. El estado se actualiza cada 2 segundos. Si no ves cambios inmediatos, espera unos segundos.

8. Asegurate de que ambas computadoras tengan la misma version de Natro Macro para evitar incompatibilidades.

## Limitaciones

- La alt account solo puede recolectar en un campo a la vez (pero puedes cambiar dinamicamente)
- No se pueden enviar comandos multiples simultaneos (el sistema procesa uno a la vez)
- La comunicacion requiere que ambas computadoras esten en la misma red local
- Los paths deben existir en ambas instalaciones

## Mejoras Tecnicas (v2.0)

### Sistema de Relay con ACK

El sistema ahora incluye:
- **IDs de Comando**: Cada comando tiene un ID unico para tracking
- **Confirmacion ACK**: La alt account confirma la recepcion de cada comando
- **Reintentos Automaticos**: Si no hay ACK en 2 segundos, se reintenta hasta 3 veces
- **Cola de Comandos**: Los comandos pendientes se mantienen hasta confirmacion

### Formato de Comandos

Los comandos ahora usan el formato: `ID:TIMESTAMP:COMMAND`

Ejemplos:
- `1:1234567890:GATHER Sunflower Snake`
- `2:1234567891:CHANGE_FIELD Pine Tree`
- `3:1234567892:STOP`

### Archivos de Comunicacion

El sistema usa tres archivos en la carpeta compartida:
- `alt_command.txt`: Comandos enviados del main a la alt
- `alt_status.txt`: Estado actual de la alt account
- `alt_ack.txt`: Confirmaciones de recepcion (ACK)

## Soporte

Si encuentras problemas o tienes preguntas:
1. Revisa esta guia completa
2. Verifica los logs del macro principal
3. Consulta el servidor de Discord oficial de Natro Macro

