#!/bin/bash
# Salir inmediatamente si un comando falla.
set -e

# Variables globales
CURRENT_USER=$(whoami)
DEV_BASE_DIR="$HOME/workspace/github.com/$CURRENT_USER"

# --- Variables ---
# Acceso por SSH
REPO_URL="git@github.com:tu_usuario/setup-dev-env.git"
#Descomentar si el repositorio es público
#REPO_URL="https://github.com/tu_usuario/setup-dev-env.git"
TARGET_DIR="$DEV_BASE_DIR/setup-dev-env"

echo "==> Asegurando que 'git' esté instalado..."
# Instalar git si no está presente.
sudo apt-get update -y
sudo apt-get install -y curl git

echo "==> Clonando el repositorio de configuración..."
# Clonar el repositorio.
rm -rf "$REPO_URL" "$TARGET_DIR"
git clone "$REPO_URL" "$TARGET_DIR"

# Cambiar al directorio del repositorio.
cd "$TARGET_DIR"

echo "==> Asignando permisos de ejecución al script principal..."
# Asegurarse de que el script principal sea ejecutable.
chmod +x post_install.sh

echo "==> Ejecutando el script de post-instalación..."
# Ejecuta post_install.sh pasando todos los argumentos recibidos por bootstrap.sh.
# Si no se pasa ningún argumento, usa "--all" como valor predeterminado.
sudo ./post_install.sh "${@:---all}"
