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
    ca-certificates 
    git 
    curl 
    wget 
    zsh
    htop
    gnupg 
    ncdu 
    file-roller 
    unzip 
    p7zip-full 
    rar 
    gnome-sushi 
    flatpak 
    gnome-software-plugin-flatpak 
    gnome-shell-extensions 
    gnome-shell-pomodoro 
    gnome-browser-connector 
    libssl-dev 
    zlib1g-dev 
    libbz2-dev 
    libreadline-dev 
    libsqlite3-dev 
    llvm 
    libncurses5-dev 
    libncursesw5-dev 
    xz-utils 
    tk-dev 
    libxml2-dev 
    libxmlsec1-dev 
    libffi-dev 
    liblzma-dev
)

APT_APPS=(
    google-chrome-stable 
    gnome-boxes 
    gnome-tweaks 
    sqlitebrowser 
    dbeaver-ce 
    code
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
    org.videolan.VLC 
    org.gimp.GIMP 
    org.inkscape.Inkscape
    org.blender.Blender
    org.onlyoffice.desktopeditors
)

ASDF_PLUGINS=(
    python 
    php 
    nodejs
    java
)

# --- Funciones de Utilidad ---
_log() { echo -e "\n${BLUE}==> $1${NC}"; }
_success() { echo -e "${GREEN}✅ $1${NC}"; }
_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }

# --- Funciones de Lógica Principal ---

# 01. Limpia configuraciones de repositorios previas para evitar conflictos.
cleanup_previous_configs() {
    _log "Limpiando configuraciones de repositorios previas"
    
    # Eliminar archivos de lista de repositorios
    sudo rm -f /etc/apt/sources.list.d/vscode.list \
               /etc/apt/sources.list.d/vscode.sources \
               /etc/apt/sources.list.d/serge-rider-ubuntu-dbeaver-ce-plucky.list \
               /etc/apt/sources.list.d/google-chrome.list \
               /etc/apt/sources.list.d/mozilla.list \
               /etc/apt/sources.list.d/docker.list

    # Eliminar llaves GPG antiguas
    sudo rm -f /usr/share/keyrings/microsoft.gpg

    # Eliminar líneas conflictivas del archivo principal de sources.list
    if [ -f /etc/apt/sources.list ]; then
        sudo sed -i -E '/.*packages\.microsoft\.com\/repos\/code.*/d' /etc/apt/sources.list
        sudo sed -i -E '/.*dl\.google\.com\/linux\/chrome\/deb.*/d' /etc/apt/sources.list
        sudo sed -i -E '/.*download\.docker\.com\/linux\/ubuntu.*/d' /etc/apt/sources.list
    fi
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
    # Intenta eliminar todos los snaps en cada pasada. Los que fallen por
    # dependencias se eliminarán en pasadas posteriores.
    while [ -n "$(snap list | awk '!/^Name/{print $1}')" ]; do
        for snap in $(snap list | awk '!/^Name/{print $1}'); do
            sudo snap remove "$snap" 2>/dev/null || true
        done
    done

    sudo apt purge snapd -y
    sudo rm -rf "$USER_HOME/snap" /snap /var/snap /var/lib/snapd
    
    cat <<EOF | sudo tee /etc/apt/preferences.d/no-snap.pref
Package: snapd
Pin: release *
Pin-Priority: -1
EOF
    _success "Snapd eliminado y bloqueado."
}

# 03. Configura repositorios de terceros (Chrome, VSCode, Docker, DBeaver).
setup_apt_repos() {
    _log "Configurando repositorios APT de terceros"
    sudo install -m 0755 -d /etc/apt/keyrings

    # Firefox Developer Edition (opcional)
    # sudo add-apt-repository -y ppa:mozillateam/ppa
    # sudo install -d -m 0755 /etc/apt/keyrings
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
    echo 'Package: *
        Pin: origin packages.mozilla.org
        Pin-Priority: 1000
        ' | sudo tee /etc/apt/preferences.d/mozilla

    # Visual Studio Code
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --yes --dearmor -o /usr/share/keyrings/microsoft.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

    # Antigravity Google
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null

    # Google Chrome
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --yes --dearmor -o /etc/apt/keyrings/google-chrome.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

    # DBeaver Community Edition (URL y formato corregidos)
    curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/dbeaver.gpg
    echo "deb [signed-by=/etc/apt/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list

    # Docker (con fallback a LTS)
    local ubuntu_codename
    ubuntu_codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
    
    if ! curl -fsSL "https://download.docker.com/linux/ubuntu/dists/$ubuntu_codename/" | grep -q "stable"; then
        _warning "No se encontró un repositorio de Docker para '$ubuntu_codename'. Usando fallback a 'noble' (LTS)."
        ubuntu_codename="noble"
    fi

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $ubuntu_codename stable" | sudo tee /etc/apt/sources.list.d/docker.list

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
        sudo -u "$SUDO_USER" sed -i 's/^plugins=(git)$/plugins=(git common-aliases extract colored-man-pages zsh-autosuggestions zsh-syntax-highlighting asdf)/' "$zshrc_file"
    fi
    _success "Zsh y plugins configurados."
}

# 06. Configura el entorno de desarrollo (Docker, asdf).
setup_dev_environment() {
    _log "Configurando entorno de desarrollo (Docker, asdf)"

    # Docker Post-install
    sudo usermod -aG docker "$SUDO_USER"
    sudo systemctl enable --now docker.service

    # asdf (versión Go con binario)
    local asdf_data_dir="$USER_HOME/.asdf"
    if ! command -v asdf &> /dev/null; then
        _log "Instalando asdf (versión Go)..."
        local asdf_version
        asdf_version=$(curl -s "https://api.github.com/repos/asdf-vm/asdf/releases/latest" | grep -oP '"tag_name": "\K(v[0-9\.]+)')
        local asdf_tarball="asdf-${asdf_version}-linux-amd64.tar.gz"

        # https://github.com/asdf-vm/asdf/releases/download/v0.18.0/asdf-v0.18.0-linux-amd64.tar.gz
        wget -qO "/tmp/$asdf_tarball" "https://github.com/asdf-vm/asdf/releases/download/$asdf_version/$asdf_tarball"
        
        sudo -u "$SUDO_USER" mkdir -p "$asdf_data_dir/bin"
        sudo -u "$SUDO_USER" tar -xzf "/tmp/$asdf_tarball" -C "$asdf_data_dir/bin"
        rm "/tmp/$asdf_tarball"
        # sudo chown -R $USER .asdf
        
        # Configurar asdf en .zshrc
        local zshrc_file="$USER_HOME/.zshrc"
        if [ -f "$zshrc_file" ] && ! grep -q "ASDF_DATA_DIR" "$zshrc_file"; then
            # Eliminar la configuración antigua si existe
            sudo -u "$SUDO_USER" sed -i '/\. "$HOME\/\.asdf\/asdf\.sh"/d' "$zshrc_file"
            # Añadir la nueva configuración
            sudo -u "$SUDO_USER" tee -a "$zshrc_file" > /dev/null <<EOF

# --- ASDF (Go Version) ---
export ASDF_DATA_DIR=$asdf_data_dir
export PATH="\$ASDF_DATA_DIR/shims:\$ASDF_DATA_DIR/bin:\$PATH"
EOF
        fi
        _success "asdf instalado."
    else
        _warning "asdf ya está instalado. Omitiendo."
    fi
    
    # Cargar asdf en la sesión actual para instalar plugins
    export ASDF_DATA_DIR=$asdf_data_dir
    export PATH="$ASDF_DATA_DIR/shims:$ASDF_DATA_DIR/bin:$PATH"

    # Instalar plugins
    for plugin in "${ASDF_PLUGINS[@]}"; do
        if ! asdf plugin list | grep -q "$plugin"; then
            asdf plugin add "$plugin"
        fi
    done
    _success "Docker y plugins de asdf configurados."
}

# 10. Copia y configura los dotfiles personalizados.
setup_dotfiles() {
    _log "Configurando dotfiles personalizados"

    # Agregar aqui archivos de configuración a copiar desde el repositorio
    sudo -u "$SUDO_USER" cp "$REPO_DIR/configs/functions.sh" "$USER_HOME/.functions.sh"
    
    # Reemplazar el .zshrc del usuario con nuestra versión personalizada
    sudo -u "$SUDO_USER" cp "$REPO_DIR/configs/zshrc" "$USER_HOME/.zshrc"

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
    setup_dev_environment
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
    echo "2. Una vez en la nueva sesión, puedes instalar las versiones de tus herramientas, por ejemplo:"
    echo -e "   ${GREEN}asdf install python latest${NC}"
    echo -e "   ${GREEN}asdf global python latest${NC}"
}

# --- Punto de Entrada del Script ---
main "$@"
