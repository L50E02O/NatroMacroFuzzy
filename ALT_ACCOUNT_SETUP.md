# Guia de Configuracion - Control de Alt Account

Esta guia explica como configurar y usar la funcionalidad de control de Alt Account en Natro Macro.

## Descripcion

La funcionalidad de Alt Account permite controlar una cuenta alternativa de Bee Swarm Simulator desde el macro principal. Puedes asignar campos especificos para que la alt account recolecte polen usando los paths y patrones existentes.

## Requisitos

1. Dos computadoras en la misma red local
2. Una carpeta compartida en red accesible desde ambas computadoras
3. Natro Macro instalado en ambas computadoras
4. Roblox y Bee Swarm Simulator abiertos en ambas computadoras

## Configuracion Paso a Paso

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
3. Cuando se te pida:
   - Ingresa la IP de la computadora principal
   - Ingresa la ruta compartida (la misma que configuraste en el paso 2)
4. El script de alt account comenzara a escuchar comandos

## Uso

### Asignar Campo a la Alt Account

1. En el macro principal, abre "Alt Account Control" (pestaña Misc)
2. Selecciona un campo del menu desplegable
3. (Opcional) Selecciona un patron de recoleccion
4. Click en "Enviar a Recolectar"

La alt account recibira el comando y comenzara a:
- Ir al campo seleccionado usando los paths existentes
- Recolectar polen usando el patron seleccionado

### Detener la Alt Account

Click en el boton "Detener Alt" para que la alt account deje de recolectar.

### Regresar al Hive

Click en el boton "Regresar al Hive" para que la alt account regrese al hive usando los paths existentes.

### Ver Estado

El estado de la alt account se actualiza automaticamente cada 2 segundos en la ventana de control. Puedes ver:
- Estado actual (idle, gathering, traveling, etc.)
- Campo actual
- Accion que esta realizando

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

1. La comunicacion se realiza mediante archivos compartidos en red. Asegurate de que la carpeta compartida tenga permisos de lectura y escritura.

2. Los paths y patrones utilizados son los mismos que usa el macro principal, por lo que deben existir en ambas instalaciones de Natro Macro.

3. La alt account funciona de forma independiente del macro principal. Puedes tener ambos ejecutandose simultaneamente.

4. El estado se actualiza cada 2 segundos. Si no ves cambios inmediatos, espera unos segundos.

5. Asegurate de que ambas computadoras tengan la misma version de Natro Macro para evitar incompatibilidades.

## Limitaciones

- La alt account solo puede recolectar en un campo a la vez
- No se pueden enviar comandos multiples simultaneos
- La comunicacion requiere que ambas computadoras esten en la misma red local
- Los paths deben existir en ambas instalaciones

## Soporte

Si encuentras problemas o tienes preguntas:
1. Revisa esta guia completa
2. Verifica los logs del macro principal
3. Consulta el servidor de Discord oficial de Natro Macro

