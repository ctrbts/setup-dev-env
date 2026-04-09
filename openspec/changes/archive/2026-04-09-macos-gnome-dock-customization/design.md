# Diseño: macOS-style GNOME Dock Customization

## Enfoque Técnico

Agregar una nueva función `setup_gnome_ui()` en `post_install.sh` que ejecute comandos `gsettings` para configurar la extensión Dash to Dock. La función será invocada desde `main()` para todos los perfiles (--dev y --office), ya que define la experiencia base del sistema operativo.

## Decisiones de Arquitectura

### Decisión: Uso de dbus-launch para ejecutar gsettings como root

**Elección**: Ejecutar gsettings mediante `sudo -u "$SUDO_USER" dbus-launch gsettings set ...`

**Alternativas consideradas**:
- Ejecutar `sudo -u "$SUDO_USER" gsettings set ...` sin dbus-launch
- Ejecutar directamente como root modificando la base de datos del sistema

**Justificación**: Cuando el script se ejecuta con `sudo`, el usuario real (`$SUDO_USER`) tiene su propia sesión de escritorio con su propia base de datos dconf. Sin `dbus-launch`, los comandos gsettings fallan con "Cannot autolaunch D-Bus without X11 $DISPLAY" porque D-Bus requiere un contexto de sesión. La combinación de `sudo -u` + `dbus-launch` garantiza que los comandos se ejecuten en el contexto del usuario de escritorio, no de root.

### Decisión: Invocación en main() para todos los perfiles

**Elección**: Llamar `setup_gnome_ui()` independientemente de si está activo --dev o --office

**Alternativas consideradas**:
- Invocar solo para perfil --dev
- Invocar solo para perfil --office
- Hacer la invocación opcional mediante un flag

**Justificación**: La personalización del Dock es una configuración de experiencia base del sistema operativo que aplica a todos los usuarios, independientemente del perfil de uso (desarrollo u oficina). No hay razón técnica ni de negocio para limitarla a un perfil específico.

### Decisión: Logging con funciones existentes

**Elección**: Usar `_log` y `_success` existentes en el script para los mensajes de la nueva función

**Alternativas consideradas**:
- Crear funciones de logging propias para esta función
- No incluir mensajes de logging

**Justificación**: El script ya tiene funciones de logging (`_log`, `_success`, `_warning`) que siguen un patrón consistente con emojis y colores. Mantener este patrón asegura consistencia visual en la salida del script.

## Flujo de Datos

```
main()
   │
   ├── cleanup_previous_configs()
   ├── remove_snap() [condicional]
   ├── setup_apt_repos()
   ├── install_apt_packages()
   ├── setup_zsh() [si --dev]
   ├── setup_runtimes() [si --dev]
   ├── install_flatpaks_dev() [si --dev]
   ├── install_flatpaks_office() [si --office]
   ├── setup_dotfiles() [si --dev]
   │
   └── setup_gnome_ui() ← NUEVA FUNCIÓN (siempre se ejecuta)
        │
        └── sudo -u "$SUDO_USER" dbus-launch gsettings set ...
              │
              └── org.gnome.shell.extensions.dash-to-dock
                   ├── dock-position 'BOTTOM'
                   ├── extend-height false
                   └── show-apps-at-top true
```

## Cambios de Archivos

| Archivo            | Acción    | Descripción                                              |
|--------------------|-----------|----------------------------------------------------------|
| `post_install.sh` | Modificar | Agregar función `setup_gnome_ui()` y llamada en `main()` |

## Interfaces / Contratos

### Nueva Función: setup_gnome_ui()

```bash
# 07. Configura la personalización del GNOME Dock (estilo macOS).
setup_gnome_ui() {
    _log "Configurando GNOME Dock (estilo macOS)"
    
    # Verificar que la extensión Dash to Dock esté instalada
    local extension_check=$(sudo -u "$SUDO_USER" dbus-launch gsettings get org.gnome.shell.extensions.dash-to-dock dock-position 2>/dev/null || echo "not-installed")
    
    if [ "$extension_check" = "not-installed" ]; then
        _warning "Dash to Dock no está instalado. Omitiendo configuración del Dock."
        return
    fi
    
    # Configurar posición inferior
    sudo -u "$SUDO_USER" dbus-launch gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    
    # Configurar centrado (sin expansión a bordes)
    sudo -u "$SUDO_USER" dbus-launch gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    
    # Configurar botón de aplicaciones a la izquierda
    sudo -u "$SUDO_USER" dbus-launch gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
    
    _success "GNOME Dock configurado estilo macOS."
}
```

### Llamada en main()

Agregar antes de "Limpieza final":

```bash
# Configuración de GNOME UI (para todos los perfiles)
setup_gnome_ui
```

## Estrategia de Testing

| Capa        | Qué Testear                              | Enfoque                              |
|-------------|------------------------------------------|--------------------------------------|
| Sintaxis    | Validar sintaxis Bash del script         | `bash -n post_install.sh`            |
| Manual      | Verificar cambios en dconf del usuario  | Ejecutar script y verificar con dconf Editor |
| Manual      | Verificar cambios visuales en el Dock   | Comprobación visual tras reiniciar sesión |

## Migración / Despliegue

No se requiere migración. Los cambios de dconf se aplican directamente a la configuración del usuario y no requieren migración de datos existente.

## Preguntas Abiertas

- [ ] Ninguna. Los requisitos están claros y el diseño es directo.