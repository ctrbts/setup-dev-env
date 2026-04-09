# Especificación de GNOME UI - Dash to Dock

## Propósito

Esta especificación define los requisitos para la personalización de la interfaz de usuario de GNOME (UI) en el script `post_install.sh`. Específicamente, configura la extensión Dash to Dock para simular la ergonomía de macOS.

## Requisitos

### Requisito: Nueva función setup_gnome_ui()

El script `post_install.sh` DEBE incluir una función dedicada llamada `setup_gnome_ui()` que configure las opciones del GNOME Dock.

#### Escenario: Función definida correctamente

- GIVEN El script `post_install.sh` existe y es ejecutable
- WHEN Se ejecuta la función `setup_gnome_ui()` sin argumentos
- THEN La función DEBE ejecutar comandos gsettings para configurar Dash to Dock

#### Escenario: Función invocada en main()

- GIVEN La función `main()` está definida en `post_install.sh`
- WHEN El script se ejecuta con cualquier perfil (`--dev`, `--office`, o sin argumentos)
- THEN La función `setup_gnome_ui()` DEBE ser invocada desde `main()`

### Requisito: Configuración de posición del Dock

El sistema DEBE configurar la posición del Dock en la parte inferior de la pantalla.

- GIVEN La extensión Dash to Dock está instalada y activa
- WHEN Se ejecuta la configuración de posición
- THEN El comando gsettings DEBE establecer `dock-position` a `'BOTTOM'`

#### Escenario: Posición inferior aplicada

- GIVEN El usuario ha ejecutado `post_install.sh` con cualquier perfil
- WHEN Se verifica el valor de `org.gnome.shell.extensions.dash-to-dock dock-position`
- THEN El valor DEBE ser `'BOTTOM'`

### Requisito: Configuración de centrado del Dock

El sistema DEBE desactivar la expansión del Dock a los bordes de la pantalla para mantenerlo centrado.

- GIVEN La extensión Dash to Dock está instalada y activa
- WHEN Se ejecuta la configuración de extensión de altura
- THEN El comando gsettings DEBE establecer `extend-height` a `false`

#### Escenario: Centrado aplicado

- GIVEN El usuario ha ejecutado `post_install.sh` con cualquier perfil
- WHEN Se verifica el valor de `org.gnome.shell.extensions.dash-to-dock extend-height`
- THEN El valor DEBE ser `false`

### Requisito: Botón de aplicaciones a la izquierda

El sistema DEBE mover el botón de "Mostrar Aplicaciones" al extremo izquierdo del Dock.

- GIVEN La extensión Dash to Dock está instalada y activa
- WHEN Se ejecuta la configuración de posición del botón de aplicaciones
- THEN El comando gsettings DEBE establecer `show-apps-at-top` a `true`

#### Escenario: Botón de aplicaciones a la izquierda

- GIVEN El usuario ha ejecutado `post_install.sh` con cualquier perfil
- WHEN Se verifica el valor de `org.gnome.shell.extensions.dash-to-dock show-apps-at-top`
- THEN El valor DEBE ser `true`

### Requisito: Ejecución como root con contexto D-Bus correcto

El sistema DEBE ejecutar los comandos gsettings en el contexto del usuario de escritorio, no como root.

- GIVEN El script `post_install.sh` se ejecuta con privilegios de root (`sudo ./post_install.sh`)
- WHEN Se ejecutan los comandos de configuración de gsettings
- THEN Los comandos DEBEN usar el patrón `sudo -u "$SUDO_USER" dbus-launch gsettings` para evitar errores de "dconf-CRITICAL" y "Cannot autolaunch D-Bus without X11 $DISPLAY"

#### Escenario: Ejecución sin errores de D-Bus

- GIVEN El script se ejecuta como root con `SUDO_USER` definido
- WHEN Se ejecuta `setup_gnome_ui()`
- THEN Los comandos DEBEN completar sin mensajes de error relacionados con D-Bus o dconf

### Requisito: Mensaje de prerequisitos

El sistema DEBE informar al usuario sobre el prerequisito de tener Dash to Dock instalado.

- GIVEN La función `setup_gnome_ui()` se ejecuta
- WHEN La función muestra su mensaje de log
- THEN El mensaje DEBE informar que se requiere la extensión Dash to Dock

#### Escenario: Mensaje informativo mostrado

- GIVEN El script se ejecuta con cualquier perfil
- WHEN Se alcanza la función `setup_gnome_ui()`
- THEN La salida DEBE incluir un mensaje indicando que se está configurando la personalización del Dock de GNOME