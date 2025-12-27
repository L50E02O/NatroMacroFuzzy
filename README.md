# 🐝 Natro Macro

<div align="center">

**Un macro de código abierto para Bee Swarm Simulator escrito en AutoHotkey**

[![Versión](https://img.shields.io/badge/versión-1.0.1-orange)](https://github.com/NatroTeam/NatroMacro/releases)
[![Licencia](https://img.shields.io/badge/licencia-GPL%20v3.0-blue)](LICENSE.md)
[![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0-green)](https://www.autohotkey.com/)

</div>

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características Principales](#-características-principales)
- [Instalación](#-instalación)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Uso](#-uso)
- [Configuración](#-configuración)
- [Requisitos del Sistema](#-requisitos-del-sistema)
- [Troubleshooting](#-troubleshooting)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)

---

## 🎯 Descripción

**Natro Macro** es un macro automatizado de código abierto diseñado para el juego **Bee Swarm Simulator** de Roblox. El macro permite automatizar diversas tareas del juego, incluyendo recolección de polen, gestión de plantadores, completado de misiones, y mucho más, permitiendo a los jugadores optimizar su progreso mientras el macro trabaja en segundo plano.

### ⚠️ Advertencia Importante

Este macro está diseñado para uso personal y educativo. Asegúrate de cumplir con los términos de servicio de Roblox al utilizarlo.

---

## ✨ Características Principales

### 🎮 Automatización de Juego

- **Recolección Automática de Polen**: Recolecta polen automáticamente en diferentes campos usando patrones de movimiento personalizables
- **Gestión de Plantadores**: Sistema inteligente para plantar, cosechar y gestionar plantadores en diferentes campos
- **Sistema de Misiones**: Automatización de misiones diarias y rotación de quests
- **Detección de Día/Noche**: Detecta automáticamente el ciclo día/noche del juego y ajusta el comportamiento
- **Sistema de Boosts**: Gestión automática de boosts y mejoras temporales

### 🤖 Eventos y Máquinas

- **Máquinas Automatizadas**:
  - Blender (con rotación automática)
  - Wealth Clock
  - Ant Pass
  - Robo Pass
  - Sticker Printer
  - Wind Shrine
  - Y más...

- **Dispensadores**:
  - Honey Dispenser
  - Treat Dispenser
  - Blueberry/Strawberry/Coconut Dispensers
  - Glue Dispenser
  - Royal Jelly Dispenser

- **Eventos Especiales**:
  - Detección de Guiding Star
  - Detección de Pop Star
  - Eventos de Beesmas (Stockings, Feast, Gingerbread House, etc.)
  - Memory Match (Normal, Mega, Extreme, Winter)
  - Honeystorm y Honey LB

### 🎯 Funcionalidades Avanzadas

- **Sistema de Prioridades**: Configuración personalizable de prioridades de tareas
- **Detección de Muerte**: Sistema que detecta cuando el jugador muere y reinicia automáticamente
- **Reconexión Automática**: Sistema de reconexión programada para mantener la sesión activa
- **Monitoreo de Mochila**: Seguimiento en tiempo real del porcentaje de llenado de la mochila
- **Integración con Discord**: Notificaciones y reportes a través de webhooks de Discord
- **Capturas de Pantalla**: Sistema de capturas automáticas para eventos importantes

### 🗺️ Patrones y Rutas

- **Patrones de Movimiento**: Múltiples patrones personalizables para recolección (Snake, Lines, Diamonds, etc.)
- **Rutas de Campos**: Rutas optimizadas para todos los campos del juego
- **Rutas de Misiones**: Rutas específicas para diferentes tipos de misiones (GTB, GTC, GTF, GTP, GTQ, WF)

---

## 🛠️ Instalación

### Requisitos Previos

- Windows 10 o superior
- Roblox instalado y actualizado
- Escala de pantalla configurada al **100%** (requisito crítico)

### Pasos de Instalación

1. **Descargar el Macro**:
   - Descarga el archivo `Natro_Macro_v#.#.#.zip` desde los [releases oficiales](https://github.com/NatroTeam/NatroMacro/releases/latest)
   - O desde el servidor de Discord oficial

2. **Extraer el Archivo**:
   - Extrae el contenido del archivo ZIP en una carpeta de tu elección
   - **Importante**: Evita carpetas protegidas del sistema (como Program Files)

3. **Configurar la Escala de Pantalla**:
   - Haz clic derecho en el escritorio → "Configuración de pantalla"
   - En "Escala y diseño", asegúrate de que la escala esté al **100%**
   - Reinicia Roblox después de cambiar la escala

4. **Ejecutar el Macro**:
   - Haz doble clic en `START.bat`
   - Espera a que el macro se cargue completamente

### ⚠️ Notas Importantes

- El macro requiere permisos de administrador en algunas carpetas
- Si tu antivirus detecta el macro, agrega una excepción (tanto Natro Macro como AutoHotkey son seguros)
- Microsoft Defender funciona correctamente sin excepciones

---

## 📁 Estructura del Proyecto

```
NatroMacroFuzzy/
│
├── lib/                          # Librerías y utilidades
│   ├── data/                     # Datos y configuraciones
│   ├── enum/                     # Enumeraciones
│   ├── Gdip_All.ahk            # Librería GDI+ para procesamiento de imágenes
│   ├── Gdip_ImageSearch.ahk     # Búsqueda de imágenes
│   ├── JSON.ahk                 # Manejo de JSON
│   ├── Roblox.ahk               # Funciones específicas de Roblox
│   ├── Walk.ahk                 # Sistema de movimiento
│   └── ...
│
├── submacros/                    # Scripts principales
│   ├── natro_macro.ahk         # Script principal del macro
│   ├── background.ahk          # Procesos en segundo plano
│   ├── Status.ahk              # Manejo de estado y Discord
│   ├── StatMonitor.ahk         # Monitor de estadísticas
│   ├── PlanterTimers.ahk       # Temporizadores de plantadores
│   ├── Heartbeat.ahk           # Sistema de latido
│   ├── AutoHotkey32.exe        # Ejecutable AutoHotkey 32-bit
│   └── AutoHotkey64.exe        # Ejecutable AutoHotkey 64-bit
│
├── paths/                        # Rutas de movimiento
│   ├── gtb-*.ahk               # Rutas para misiones "Go to Blue"
│   ├── gtc-*.ahk               # Rutas para misiones "Go to Collect"
│   ├── gtf-*.ahk               # Rutas para misiones "Go to Field"
│   ├── gtp-*.ahk               # Rutas para misiones "Go to Plant"
│   ├── gtq-*.ahk               # Rutas para misiones "Go to Quest"
│   └── wf-*.ahk                # Rutas para "Walk to Field"
│
├── patterns/                     # Patrones de movimiento
│   ├── Snake.ahk               # Patrón serpiente
│   ├── Lines.ahk               # Patrón líneas
│   ├── Diamonds.ahk            # Patrón diamantes
│   ├── Stationary.ahk         # Patrón estacionario
│   └── ...
│
├── nm_image_assets/             # Recursos de imágenes
│   ├── *.png                   # Imágenes para reconocimiento
│   └── offset/                 # Imágenes con offset
│
├── settings/                    # Configuraciones (generado automáticamente)
│   ├── nm_config.ini          # Configuración principal
│   └── mutations.ini          # Configuración de mutaciones
│
├── START.bat                    # Script de inicio
├── LICENSE.md                   # Licencia GPL v3.0
└── README.md                    # Este archivo
```

---

## 🚀 Uso

### Inicio Rápido

1. **Abre Roblox** y entra a Bee Swarm Simulator
2. **Ejecuta `START.bat`**
3. **Configura las opciones** en la interfaz gráfica del macro
4. **Presiona el botón de inicio** o la tecla configurada para comenzar

### Controles Principales

- **Iniciar/Pausar**: Botón en la interfaz o tecla configurada
- **Detener**: Tecla de parada configurada (por defecto puede variar)
- **Interfaz**: La GUI principal muestra el estado actual y permite configurar opciones

### Configuración Básica

1. **Campo de Recolección**: Selecciona el campo donde quieres recolectar polen
2. **Patrón de Movimiento**: Elige un patrón (Snake, Lines, etc.)
3. **Gestión de Plantadores**: Configura si quieres que el macro gestione plantadores
4. **Misiones**: Activa/desactiva la automatización de misiones
5. **Boosts**: Configura cuándo usar boosts automáticamente

---

## ⚙️ Configuración

### Archivos de Configuración

El macro guarda su configuración en archivos INI dentro de la carpeta `settings/`:

- **`nm_config.ini`**: Configuración principal del macro
  - Secciones: `Boost`, `Collect`, `Gather`, `Planters`, `Quests`, `Settings`, `Status`, `Blender`, `Shrine`
  
- **`mutations.ini`**: Configuración de mutaciones y abejas
  - Configuración de qué mutaciones usar
  - Configuración de qué abejas seleccionar

### Configuración de Discord

Para habilitar notificaciones de Discord:

1. Crea un webhook en tu servidor de Discord
2. Ingresa la URL del webhook en la configuración
3. Configura qué eventos quieres recibir notificaciones

### Configuración de Prioridades

El sistema de prioridades determina el orden en que el macro ejecuta las tareas:

- **Prioridades por defecto**: Night → Mondo → Planter → Bugrun → Collect → QuestRotate → Boost → GoGather
- Puedes personalizar el orden en la configuración avanzada

---

## 💻 Requisitos del Sistema

### Mínimos

- **Sistema Operativo**: Windows 10 (64-bit recomendado)
- **RAM**: 4 GB
- **Espacio en Disco**: 500 MB libres
- **Resolución**: 1280x720 mínimo
- **Escala de Pantalla**: **100%** (obligatorio)

### Recomendados

- **Sistema Operativo**: Windows 11
- **RAM**: 8 GB o más
- **Procesador**: Múltiples núcleos para mejor rendimiento
- **Resolución**: 1920x1080 o superior

### Requisitos Específicos

- **Roblox**: Versión actualizada
- **AutoHotkey**: Incluido en el proyecto (32-bit y 64-bit)
- **Escala de Pantalla**: Debe estar al 100% o el macro no funcionará correctamente

---

## 🔧 Troubleshooting

### Problemas Comunes

#### El macro no inicia

- **Verifica la escala de pantalla**: Debe estar al 100%
- **Ejecuta como administrador**: Algunas carpetas requieren permisos
- **Verifica que AutoHotkey32.exe existe**: Puede haber sido eliminado por el antivirus

#### El macro no detecta el juego

- **Asegúrate de que Roblox esté abierto** y en primer plano
- **Verifica que la ventana de Roblox esté visible** (no minimizada)
- **Reinicia el macro** después de abrir Roblox

#### El macro se detiene inesperadamente

- **Revisa los logs** en la interfaz del macro
- **Verifica la conexión a internet** (necesaria para Roblox)
- **Comprueba si hay actualizaciones** del macro disponibles

#### Problemas con plantadores

- **Verifica que tengas plantadores** en tu inventario
- **Revisa la configuración de plantadores** en el macro
- **Asegúrate de tener suficientes semillas** para plantar

#### El antivirus bloquea el macro

- **Agrega una excepción** para la carpeta del macro
- **Microsoft Defender funciona sin problemas**, otros antivirus pueden requerir excepciones
- **AutoHotkey es seguro**, es un software legítimo y ampliamente usado

### Obtener Ayuda

- **Discord**: Únete al [servidor oficial de Discord](https://discord.gg/natromacro)
- **GitHub Issues**: Reporta bugs o sugiere features en el [repositorio](https://github.com/NatroTeam/NatroMacro/issues)
- **Documentación**: Revisa la documentación en el servidor de Discord

---

## 🤝 Contribuir

Natro Macro es un proyecto de código abierto y agradece todas las contribuciones.

### Cómo Contribuir

1. **Reportar Bugs**: 
   - Crea un [issue de bug](https://github.com/NatroTeam/NatroMacro/issues/new?template=bug.yml)
   - Incluye información detallada sobre el problema

2. **Sugerir Features**:
   - Crea un [issue de sugerencia](https://github.com/NatroTeam/NatroMacro/issues/new?template=suggestion.yml)
   - Describe la funcionalidad que te gustaría ver

3. **Contribuir Código**:
   - Fork el repositorio
   - Crea una rama para tu feature
   - Realiza tus cambios
   - Envía un Pull Request

4. **Compartir Patrones/Rutas**:
   - Comparte tus patrones personalizados en Discord
   - Ayuda a otros usuarios con rutas optimizadas

### Guías de Contribución

Lee las [Guías de Contribución](https://github.com/NatroTeam/.github/blob/main/CONTRIBUTING.md) antes de contribuir.

---

## 📝 Licencia

Este proyecto está licenciado bajo la **GNU General Public License v3.0**.

Ver el archivo [LICENSE.md](LICENSE.md) para más detalles.

### Resumen de la Licencia

- ✅ Puedes usar, modificar y distribuir el código
- ✅ Debes mantener la licencia GPL v3.0
- ✅ Debes incluir el código fuente al distribuir
- ❌ No puedes usar el código en software propietario sin cumplir con GPL

---

## 🙏 Créditos

Natro Macro no sería posible sin la ayuda e inspiración de muchas personas extraordinarias.

Ver la [lista completa de créditos](https://github.com/NatroTeam/.github/blob/main/CREDITS.md) para más información.

---

## ⚠️ Disclaimer

Este macro es una herramienta de automatización para uso personal. Los usuarios son responsables de cumplir con los términos de servicio de Roblox. El uso de macros puede violar los términos de servicio de algunos juegos. Úsalo bajo tu propio riesgo.

---

## 📞 Enlaces Útiles

- **GitHub**: [NatroTeam/NatroMacro](https://github.com/NatroTeam/NatroMacro)
- **Discord**: [discord.gg/natromacro](https://discord.gg/natromacro)
- **Roblox Group**: [Natro Macro](https://www.roblox.com/groups/16490149/Natro-Macro)
- **Releases**: [Latest Release](https://github.com/NatroTeam/NatroMacro/releases/latest)

---

<div align="center">

**⭐ Si este proyecto te ha ayudado, considera darle una estrella en GitHub! ⭐**

Hecho con ❤️ por el Natro Team

</div>
