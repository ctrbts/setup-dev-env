#!/bin/bash
# Script para configurar un servidor Ubuntu 24.04 LTS con Docker y herramientas esenciales.
# Diseñado para ser copiado y pegado en una sesión SSH.

# Salir inmediatamente si un comando falla
set -e

echo "🚀 Iniciando la configuración del servidor para Ubuntu 24.04 LTS..."

# 1. ACTUALIZACIÓN DEL SISTEMA
echo "🔄 Actualizando y mejorando los paquetes del sistema..."
sudo apt-get update
sudo apt-get upgrade -y

# 2. INSTALACIÓN DE HERRAMIENTAS ESENCIALES
echo "🛠️ Instalando herramientas esenciales (curl, git, ufw, fail2ban, htop)..."
sudo apt-get install -y curl git ufw fail2ban htop

# 3. CONFIGURACIÓN DE SEGURIDAD BÁSICA
echo "🔒 Configurando el firewall (UFW)..."
sudo ufw allow OpenSSH # Permitir conexiones SSH para no perder el acceso
# Si planeas correr servicios web, descomenta las siguientes líneas:
# echo "🌐 Permitiendo tráfico HTTP y HTTPS..."
# sudo ufw allow http
# sudo ufw allow https
sudo ufw --force enable # Habilitar el firewall sin prompt interactivo

echo "🛡️ Iniciando y habilitando Fail2Ban..."
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

echo "✅ Seguridad básica configurada. Estado del firewall:"
sudo ufw status

# 4. INSTALACIÓN DE DOCKER Y DOCKER COMPOSE (MÉTODO OFICIAL)
echo "🐳 Instalando Docker y Docker Compose..."

# Añadir la clave GPG oficial de Docker
sudo apt-get update
sudo apt-get install -y ca-certificates gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Añadir el repositorio de Docker a las fuentes de APT
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Instalar los paquetes de Docker
echo "📦 Instalando Docker Engine, CLI, Containerd y Docker Compose..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. AJUSTES DE USABILIDAD
echo "👤 Añadiendo el usuario actual al grupo 'docker' para ejecutar comandos sin sudo..."
sudo usermod -aG docker $USER

echo "--------------------------------------------------"
echo "🎉 ¡Configuración del servidor completada!"
echo "--------------------------------------------------"
echo "🔴 IMPORTANTE:"
echo "Para poder usar Docker sin 'sudo', necesitas CERRAR SESIÓN y VOLVER A INICIAR SESIÓN."
echo ""
echo "Después de volver a iniciar sesión, puedes verificar la instalación de Docker con:"
echo "docker run hello-world"

echo "Estado del firewall:"
sudo ufw status
echo "--------------------------------------------------"
