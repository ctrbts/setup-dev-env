#!/bin/bash
# Salir inmediatamente si un comando falla.
set -e

# --- Variables ---
REPO_URL="https://github.com/ctrbts/setup-dev-env.git"
TARGET_DIR="$HOME/dev/github.com/ctrbts/setup-dev-env"

echo "==> Asegurando que 'git' esté instalado..."
# Instalar git si no está presente.
sudo apt-get update -y
sudo apt-get install -y curl git

echo "==> Clonando el repositorio de configuración..."
# Clonar el repositorio.
git clone "$REPO_URL" "$TARGET_DIR"

# Cambiar al directorio del repositorio.
cd "$TARGET_DIR"

echo "==> Asignando permisos de ejecución al script principal..."
# Asegurarse de que el script principal sea ejecutable.
chmod +x post_install.sh

echo "==> Ejecutando el script de post-instalación..."
# Ejecutar el script principal con sudo.
sudo ./post_install.sh --all
