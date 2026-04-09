# Propuesta: macOS-style GNOME Dock Customization

## Intención

Modificar el script `post_install.sh` para incluir una capa de personalización de la interfaz de usuario (UI) de GNOME. El objetivo es configurar el Ubuntu Dock para que simule la ergonomía de macOS: ubicado en la parte inferior, centrado (sin expandirse a los bordes) y con el botón de "Mostrar Aplicaciones" en el extremo izquierdo.

## Alcance

### Dentro del Alcance

- Nueva función dedicada `setup_gnome_ui()` en `post_install.sh`
- Configuración de extensión Dash to Dock mediante gsettings:
  - Posición inferior (`dock-position 'BOTTOM'`)
  - Centrado sin expansión a bordes (`extend-height false`)
  - Botón de aplicaciones a la izquierda (`show-apps-at-top true`)
- Invocación de `setup_gnome_ui()` en función `main()` para TODOS los perfiles (--dev y --office)
- Manejo correcto del contexto D-Bus para ejecución como root

### Fuera del Alcance

- Instalación de la extensión Dash to Dock (se asume preinstalada)
- Configuraciones adicionales de GNOME (temas, iconos, etc.)
- Validación de que la extensión esté activa

## Enfoque

Ejecutar los comandos gsettings envolviéndolos para el usuario real mediante `sudo -u "$SUDO_USER" dbus-launch gsettings set ...`. Esto asegura que las configuraciones impacten la base de datos dconf del usuario de escritorio y no generen errores de "dconf-CRITICAL" o "Cannot autolaunch D-Bus without X11 $DISPLAY".

## Áreas Afectadas

| Área                   | Impacto    | Descripción                                    |
|------------------------|------------|-----------------------------------------------|
| `post_install.sh`      | Modificado | Nueva función setup_gnome_ui() y llamada en main() |

## Riesgos

| Riesgo                                     | Probabilidad | Mitigación                                      |
|--------------------------------------------|--------------|-------------------------------------------------|
| Error al ejecutar gsettings como root      | Alta         | Usar `sudo -u "$SUDO_USER" dbus-launch gsettings` |
| D-Bus no disponible en entorno sin X11    | Baja         | Verificar que DISPLAY esté configurado         |
| Extensión Dash to Dock no instalada       | Media        | Documentar prerequisito en output del script  |

## Plan de Rollback

1. Eliminar la función `setup_gnome_ui()` de `post_install.sh`
2. Eliminar la llamada a `setup_gnome_ui()` en `main()`
3. Las configuraciones de dconf del usuario permanecerán aplicadas; el usuario puede revertirlas manualmente desde Gnome Tweaks o dconf Editor

## Dependencias

- Extensión GNOME "Dash to Dock" instalada y activa
- Paquete `gnome-tweaks` instalado (incluido en APT_BASE)

## Criterios de Éxito

- [ ] La función `setup_gnome_ui()` está definida en `post_install.sh`
- [ ] La función es invocada en `main()` independientemente del perfil activo
- [ ] Los comandos gsettings usan el patrón `sudo -u "$SUDO_USER" dbus-launch gsettings`
- [ ] La sintaxis de Bash es válida (`bash -n post_install.sh`)