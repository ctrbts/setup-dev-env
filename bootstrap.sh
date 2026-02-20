#!/bin/bash
# Salir inmediatamente si un comando falla.
set -e

# Variables globales
CURRENT_USER=$(whoami)

# --- Configuración Interactiva ---
# Permite que el script sea "one-shot" de forma ininterrumpida si GITHUB_USER se pasa como variable de entorno
if [ -z "$GITHUB_USER" ]; then
    printf "Ingrese el usuario de GitHub para clonar el repositorio [ctrbts]: "
    read INPUT_USER
    GITHUB_USER="${INPUT_USER:-ctrbts}"
fi

DEV_BASE_DIR="$HOME/workspace/github.com/$GITHUB_USER"

# --- Variables ---
# Usamos HTTPS para el clonado inicial ya que la máquina aún no tiene llaves SSH configuradas.
REPO_URL="https://github.com/${GITHUB_USER}/setup-dev-env.git"
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
