#!/bin/bash

# ==============================================================================
# Post-Install Script for Ubuntu Developer Workstation
#
# Uso:
#   chmod +x post_install.sh
#   ./post_install.sh [OPCIÓN]
# ==============================================================================

# --- Configuración de Seguridad y Robustez ---
set -e
set -o pipefail

# --- Variables Globales y de Color ---
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
# Asume que el script se ejecuta desde la raíz del repositorio clonado
REPO_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# --- Listas de Paquetes (Fácil de modificar) ---
APT_ESSENTIALS=(
    build-essential 
    zsh
    ncdu 
    7zip 
    rar 
    gnome-sushi 
    flatpak 
    gnome-software-plugin-flatpak 
    gnome-shell-extensions 
    gnome-browser-connector 
    libssl-dev 
    zlib1g-dev 
    libsqlite3-dev 
    libffi-dev 
)

APT_APPS=(
    google-chrome-stable 
    gnome-boxes 
    gnome-tweaks 
    sqlitebrowser 
    dbeaver-ce 
    code
    gh
    antigravity 
    docker-ce 
    docker-ce-cli 
    containerd.io 
    docker-buildx-plugin 
    docker-compose-plugin
    firefox-devedition
    firefox-devedition-l10n-es-ar
)

FLATPAK_APPS=(
    org.gimp.GIMP 
    org.inkscape.Inkscape
    org.blender.Blender
    org.onlyoffice.desktopeditors
)

# --- Funciones de Utilidad ---
_log() { echo -e "\n${BLUE}==> $1${NC}"; }
_success() { echo -e "${GREEN}✅ $1${NC}"; }
_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }

# --- Funciones de Lógica Principal ---

# 01. Limpia configuraciones de repositorios previas para evitar conflictos.
cleanup_previous_configs() {
    _log "Limpiando configuraciones de repositorios previas"
    
    # Eliminar archivos de lista de repositorios (.list y .sources)
    sudo rm -f /etc/apt/sources.list.d/vscode.list /etc/apt/sources.list.d/vscode.sources \
               /etc/apt/sources.list.d/antigravity.list /etc/apt/sources.list.d/antigravity.sources \
               /etc/apt/sources.list.d/dbeaver.list /etc/apt/sources.list.d/dbeaver.sources \
               /etc/apt/sources.list.d/google-chrome.list /etc/apt/sources.list.d/google-chrome.sources \
               /etc/apt/sources.list.d/mozilla.list /etc/apt/sources.list.d/mozilla.sources \
               /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.sources \
               /etc/apt/sources.list.d/github-cli.list /etc/apt/sources.list.d/github-cli.sources

    # Eliminar llaves GPG antiguas
    sudo rm -f /usr/share/keyrings/microsoft.gpg

    _success "Limpieza de configuraciones previas completada."
}

# 02. Erradicación completa de Snap.
remove_snap() {
    _log "Erradicando SnapD del sistema"
    if ! command -v snap &> /dev/null; then
        _success "Snapd no está instalado. Omitiendo."
        return
    fi

    # Bucle que se ejecuta mientras queden snaps instalados.
    while [ -n "$(snap list | awk '!/^Name/{print $1}')" ]; do
        for snap in $(snap list | awk '!/^Name/{print $1}'); do
            sudo snap remove "$snap" 2>/dev/null || true
        done
    done

    sudo apt purge snapd -y
    sudo rm -rf "$USER_HOME/snap" /snap /var/snap /var/lib/snapd
    
    cat <<EOF | sudo tee /etc/apt/preferences.d/no-snap.pref > /dev/null
Package: snapd
Pin: release *
Pin-Priority: -1
EOF
    _success "Snapd eliminado y bloqueado."
}

# 03. Configura repositorios de terceros (Chrome, VSCode, Docker, DBeaver) en formato DEB822.
setup_apt_repos() {
    _log "Configurando repositorios APT de terceros (Formato DEB822)"
    sudo install -m 0755 -d /etc/apt/keyrings

    # Firefox Developer Edition (Mozilla)
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    cat <<EOF | sudo tee /etc/apt/sources.list.d/mozilla.sources > /dev/null
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF

    echo 'Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null

    # Visual Studio Code
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --yes --dearmor -o /usr/share/keyrings/microsoft.gpg
    cat <<EOF | sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

    # GitHub CLI
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    cat <<EOF | sudo tee /etc/apt/sources.list.d/github-cli.sources > /dev/null
Types: deb
URIs: https://cli.github.com/packages
Suites: stable
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/githubcli-archive-keyring.gpg
EOF

    # Antigravity Google
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
    cat <<EOF | sudo tee /etc/apt/sources.list.d/antigravity.sources > /dev/null
Types: deb
URIs: https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/
Suites: antigravity-debian
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/antigravity-repo-key.gpg
EOF

    # Google Chrome
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --yes --dearmor -o /etc/apt/keyrings/google-chrome.gpg
    cat <<EOF | sudo tee /etc/apt/sources.list.d/google-chrome.sources > /dev/null
Types: deb
URIs: http://dl.google.com/linux/chrome/deb/
Suites: stable
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/google-chrome.gpg
EOF

    # DBeaver Community Edition (Repositorio plano)
    curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/dbeaver.gpg
    cat <<EOF | sudo tee /etc/apt/sources.list.d/dbeaver.sources > /dev/null
Types: deb
URIs: https://dbeaver.io/debs/dbeaver-ce
Suites: /
Signed-By: /etc/apt/keyrings/dbeaver.gpg
EOF

    # Docker
    local ubuntu_codename
    #ubuntu_codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
    ubuntu_codename="noble"
    
    # Validar si existe el repo para la versión actual. 
    # Fallback temporal a la LTS actual (noble - 24.04) si Docker aún no da soporte al snapshot.
    if ! curl -fsSL "https://download.docker.com/linux/ubuntu/dists/$ubuntu_codename/" | grep -q "stable"; then
        _warning "No se encontró un repositorio de Docker para '$ubuntu_codename'. Usando fallback a 'noble' (LTS 24.04)."
        ubuntu_codename="noble"
    fi

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
    cat <<EOF | sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $ubuntu_codename
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.gpg
EOF

    _success "Repositorios de terceros configurados."
}

# 04. Instala todos los paquetes desde APT.
install_apt_packages() {
    _log "Instalando paquetes esenciales y software desde APT"
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y "${APT_ESSENTIALS[@]}"
    sudo DEBIAN_FRONTEND=noninteractive apt install -y "${APT_APPS[@]}"
    _success "Todos los paquetes APT instalados."
}

# 05. Configura Zsh, Oh My Zsh y los plugins.
setup_zsh() {
    _log "Configurando Zsh y Oh My Zsh"
    
    # Cambiar shell por defecto
    sudo chsh -s "$(which zsh)" "$SUDO_USER"
    
    # Instalar Oh My Zsh
    local oh_my_zsh_dir="$USER_HOME/.oh-my-zsh"
    if [ ! -d "$oh_my_zsh_dir" ]; then
        sudo -u "$SUDO_USER" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
    fi

    # Instalar plugins
    local custom_plugins_dir="$oh_my_zsh_dir/custom/plugins"
    sudo -u "$SUDO_USER" git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "$custom_plugins_dir/zsh-autosuggestions" || true
    sudo -u "$SUDO_USER" git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_plugins_dir/zsh-syntax-highlighting" || true

    # Activar plugins en .zshrc
    local zshrc_file="$USER_HOME/.zshrc"
    if [ -f "$zshrc_file" ]; then
        sudo -u "$SUDO_USER" sed -i 's/^plugins=(git)$/plugins=(git common-aliases extract colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)/' "$zshrc_file"
    fi
    _success "Zsh y plugins configurados."
}

# 06. Instala y configura Docker y herramientas de desarrollo.
install_uv() {
    _log "Instalando uv (Python)..."
    if ! sudo -u "$SUDO_USER" env HOME="$USER_HOME" sh -c "command -v uv" &> /dev/null; then
        sudo -u "$SUDO_USER" env HOME="$USER_HOME" sh -c "curl -LsSf https://astral.sh/uv/install.sh | sh"
        _success "uv instalado."
    else
        _warning "uv ya está instalado. Omitiendo."
    fi
}

install_fnm() {
    _log "Instalando fnm (Node.js)..."
    if ! sudo -u "$SUDO_USER" env HOME="$USER_HOME" sh -c "command -v fnm" &> /dev/null; then
        # Instalamos en .local/bin para asegurar que esté en el PATH
        sudo -u "$SUDO_USER" env HOME="$USER_HOME" sh -c "curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir \"$USER_HOME/.local/bin\" --skip-shell"
        _success "fnm instalado."
    else
        _warning "fnm ya está instalado. Omitiendo."
    fi
}

install_sdkman() {
    _log "Instalando SDKMAN! (Java)..."
    local sdkman_dir="$USER_HOME/.sdkman"
    if [ ! -d "$sdkman_dir" ]; then
        sudo -u "$SUDO_USER" env HOME="$USER_HOME" sh -c "curl -s \"https://get.sdkman.io\" | bash"
        _success "SDKMAN! instalado."
    else
        _warning "SDKMAN! ya está instalado. Omitiendo."
    fi
}

setup_runtimes() {
    _log "Configurando entorno de desarrollo (Runtimes)"
    
    # Docker Post-install (siempre se ejecuta si está instalado)
    if command -v docker &> /dev/null; then
        sudo usermod -aG docker "$SUDO_USER"
        sudo systemctl enable --now docker.service
        _success "Docker configurado."
    fi

    echo ""
    echo "--- Selección de Herramientas de Desarrollo ---"

    # UV
    read -p "¿Deseas instalar uv (Gestor de paquetes/proyectos Python ultra rápido)? [s/N]: " install_uv_opt
    if [[ "$install_uv_opt" =~ ^[sS]$ ]]; then
        install_uv
    fi

    # FNM
    read -p "¿Deseas instalar fnm (Fast Node Manager)? [s/N]: " install_fnm_opt
    if [[ "$install_fnm_opt" =~ ^[sS]$ ]]; then
        install_fnm
    fi

    # SDKMAN
    read -p "¿Deseas instalar SDKMAN! (Gestor para Java, Gradle, Maven, etc.)? [s/N]: " install_sdk_opt
    if [[ "$install_sdk_opt" =~ ^[sS]$ ]]; then
        install_sdkman
    fi
}

# 10. Copia y configura los dotfiles personalizados.
setup_dotfiles() {
    _log "Configurando dotfiles personalizados"

    # Agregar aqui archivos de configuración a copiar desde el repositorio
    sudo -u "$SUDO_USER" cp "$REPO_DIR/configs/functions.sh" "$USER_HOME/.functions.sh" 2>/dev/null || true
    
    # Reemplazar el .zshrc del usuario con nuestra versión personalizada
    sudo -u "$SUDO_USER" cp "$REPO_DIR/configs/zshrc" "$USER_HOME/.zshrc" 2>/dev/null || true

    _success "Dotfiles copiados y .zshrc configurado."
}

# 20. Instala aplicaciones GUI vía Flatpak.
install_flatpaks() {
    _log "Instalando aplicaciones GUI desde Flatpak"
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install -y --noninteractive flathub "${FLATPAK_APPS[@]}"
    _success "Aplicaciones Flatpak instaladas."
}

# --- Función Principal que orquesta la ejecución ---
main() {
    if [ "$EUID" -ne 0 ]; then
        _warning "Este script debe ser ejecutado con sudo."
        exit 1
    fi

    _log "Actualizando paquetes del sistema"
    sudo apt update && sudo apt upgrade -y

    # Inicializar variables para los flags
    MODE="all"
    REMOVE_SNAP=false

    # Parsear los argumentos de línea de comandos
    for arg in "$@"; do
        case $arg in
            --dev-only)
            MODE="dev"
            shift # Quitar --dev-only de la lista de argumentos
            ;;
            --remove-snap)
            REMOVE_SNAP=true
            shift # Quitar --remove-snap de la lista de argumentos
            ;;
            *)
            # Argumento desconocido, se puede ignorar o manejar como error
            ;;
        esac
    done
    
    _log "Iniciando configuración de la workstation en modo: $MODE"
    if [ "$REMOVE_SNAP" = true ]; then
        _warning "La opción --remove-snap está activa. Se procederá a eliminar Snapd."
    fi

    # Fases de instalación
    cleanup_previous_configs

    # Ejecutar la eliminación de Snap solo si el flag está presente
    if [ "$REMOVE_SNAP" = true ]; then
        remove_snap
    else
        _log "Omitiendo la eliminación de Snapd. Para eliminarlo, ejecuta el script con el flag --remove-snap."
    fi

    setup_apt_repos
    install_apt_packages
    setup_zsh
    setup_runtimes
    setup_dotfiles

    if [[ "$MODE" == "all" ]]; then
        install_flatpaks
    fi

    # Limpieza final
    _log "Limpiando la instalación"
    sudo apt autoremove -y && sudo apt autoclean

    # Mensajes finales
    echo -e "\n\n${GREEN}✅ ¡Configuración de la Workstation completada! ✅${NC}"
    echo -e "\n${YELLOW}--- Pasos Finales MUY IMPORTANTES ---${NC}"
    echo "1. Para que todos los cambios se apliquen correctamente,"
    echo -e "   necesitas ${GREEN}CERRAR SESIÓN Y VOLVER A INICIARLA${NC}."
    echo "2. Las herramientas uv, fnm y sdkman están listas para usar si las seleccionaste."
}

# --- Punto de Entrada del Script ---
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
