# Tareas: Refactor Workstation Scripts for Modular Profiles

## Fase 1: Reestructuración de Arrays de Paquetes

- [x] 1.1 Crear array `APT_BASE` en `post_install.sh` (línea ~22) con: build-essential, ncdu, 7zip, rar, gnome-sushi, flatpak, gnome-software-plugin-flatpak, gnome-shell-extensions, gnome-browser-connector, libssl-dev, zlib1g-dev, libsqlite3-dev, libffi-dev, gnome-tweaks, gnome-boxes
- [x] 1.2 Crear array `APT_DEV` con: zsh, google-chrome-stable, dbeaver-ce, code, gh, docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin, firefox-devedition, firefox-devedition-l10n-es-ar, curl, git
- [x] 1.3 Crear array `APT_OFFICE` con: onlyoffice-desktopeditors (Flatpak) o paquetes APT de OnlyOffice
- [x] 1.4 Eliminar arrays `APT_ESSENTIALS` y `APT_APPS` existentes

## Fase 2: Refactorización del Parseo de Argumentos

- [x] 2.1 Reescribir inicialización de variables en `main()`: agregar `INSTALL_DEV=false`, `INSTALL_OFFICE=false`, `REMOVE_SNAP=false`
- [x] 2.2 Reemplazar el loop `for arg in "$@"` existente para parsear:
  - Si arg es `--dev` → `INSTALL_DEV=true`
  - Si arg es `--office` → `INSTALL_OFFICE=true`
  - Si arg es `--remove-snap` → `REMOVE_SNAP=true`
  - Si arg es `--all` → `INSTALL_DEV=true` y `INSTALL_OFFICE=true`
  - Si no hay argumentos → `INSTALL_DEV=true` y `INSTALL_OFFICE=true`
- [x] 2.3 Actualizar mensaje de log en línea 366: mostrar perfiles activos

## Fase 3: Condicionales para Funciones de Perfil

- [x] 3.1 Envolver llamada a `setup_zsh` en `if [ "$INSTALL_DEV" = true ]; then`
- [x] 3.2 Envolver llamada a `setup_runtimes` en `if [ "$INSTALL_DEV" = true ]; then`
- [x] 3.3 Envolver llamada a `setup_dotfiles` en `if [ "$INSTALL_DEV" = true ]; then`
- [x] 3.4 Modificar `install_apt_packages()` para instalar arrays basados en perfiles activos

## Fase 4: Zero-Touch para Office

- [x] 4.1 Agregar guard al inicio de `setup_runtimes()`: `if [ "$INSTALL_DEV" != true ]; then return; fi`
- [x] 4.2 Eliminar o condicionalizar las pausas `read -p` para uv, fnm, sdkman dentro de `setup_runtimes`

## Fase 5: Instalación de Flatpaks por Perfil

- [x] 5.1 Envolver llamada a `install_flatpaks()` en `if [ "$INSTALL_OFFICE" = true ]; then`
- [x] 5.2 Verificar que solo se instalen flatpaks de Office cuando corresponda

## Fase 6: Verificación Manual

- [x] 6.1 Verificar parseo de argumentos con: `./post_install.sh --help` o modo debug
- [x] 6.2 Verificar que sin argumentos active ambos perfiles
- [x] 6.3 Verificar que `--office` solo instale paquetes de Office (sin Zsh, runtimes)
- [x] 6.4 Verificar que `--dev` instale todo excepto Office apps (opcional)