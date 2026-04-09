# Tareas: macOS-style GNOME Dock Customization

## Fase 1: Implementación de la Función setup_gnome_ui()

- [x] 1.1 Crear la función `setup_gnome_ui()` en `post_install.sh` después de la función `setup_dotfiles()` (línea ~351)
- [x] 1.2 Agregar verificación de instalación de Dash to Dock antes de aplicar configuraciones
- [x] 1.3 Agregar configuración de posición del Dock: `dock-position 'BOTTOM'`
- [x] 1.4 Agregar configuración de centrado del Dock: `extend-height false`
- [x] 1.5 Agregar configuración de botón de aplicaciones: `show-apps-at-top true`
- [x] 1.6 Incluir mensajes de logging usando `_log()` y `_success()` existentes

## Fase 2: Integración en main()

- [x] 2.1 Agregar invocación de `setup_gnome_ui()` en la función `main()` antes de "Limpieza final"
- [x] 2.2 La invocación debe ser independiente de los perfiles (sin condición if)
- [x] 2.3 Agregar comentario descriptivo: "# Configuración de GNOME UI (para todos los perfiles)"

## Fase 3: Verificación

- [x] 3.1 Validar sintaxis Bash: ejecutar `bash -n post_install.sh`
- [x] 3.2 Verificar que la estructura de la función sea correcta: verificar que todos los comandos usen el patrón `sudo -u "$SUDO_USER" dbus-launch gsettings set ...`
- [x] 3.3 Verificar que la invocación en main() no esté dentro de ninguna condición de perfil

## Fase 4: Documentación (Opcional)

- [x] 4.1 Agregar comentario en la función indicando prerequisitos (Dash to Dock debe estar instalado)
- [x] 4.2 Verificar que los mensajes de output sean consistentes con el estilo del resto del script