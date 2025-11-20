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

echo "--------------------------------------------------"
echo "🎉 ¡Configuración del servidor completada!"
echo "--------------------------------------------------"
