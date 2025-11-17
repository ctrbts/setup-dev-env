#!/bin/bash

# ---
# Script de Provisionamiento de Servidor MariaDB en Ubuntu
#
# OBJETIVO:
# 1. Actualizar el sistema.
# 2. Securizar SSH (deshabilitar login root y por password).
# 3. Instalar y configurar UFW (Firewall).
# 4. Instalar MariaDB Server.
# 5. Crear una base de datos, usuario y contraseña (pasados como argumentos).
# 6. Configurar MariaDB para aceptar conexiones remotas *solo* desde la IP del servidor de aplicación.
#
# USO:
# 1. Crear tu usuario (ej. 'soporte' o 'sysadmin'): adduser soporte
# 2. Darle permisos 'sudo': usermod -aG sudo soporte
# 3. (Opcional pero recomendado) Configurar tu clave SSH: mkdir -p /home/soporte/.ssh
# 4. Copiamos la clave SSH: cp /root/.ssh/authorized_keys /home/soporte/.ssh/
# 5. Le cambiamos el porpietario: chown -R soporte:soporte /home/soporte/.ssh
# 6. Salir de 'root': # exit
# 7. Creamos un nevo archivo: nano setup.sh
# 8. Le damos permiso de ejecución: sudo chmod +x setup.sh
# 9. Lo ejecutamos: sudo ./setup.sh <db_name> <db_user> <db_password> <app_server_ip>
#
# EJEMPLO:
# sudo ./setup.sh "mi_app_db" "mi_app_user" "P4ssw0rdS3gur0!" "192.168.50.10"
# ---

# --- Configuración de Seguridad ---
set -eou pipefail

# --- 1. Verificación de Usuario 'sudo' ---
echo "[+] Verificando permisos de ejecución..."
if [ -z "${SUDO_USER-}" ] || [ "$SUDO_USER" = "root" ]; then
    echo "ERROR: Este script debe ser ejecutado por un usuario no-root con 'sudo'."
    echo "       Ejemplo: sudo $0 <db_name> <db_user> <db_password> <app_server_ip>"
    exit 1
fi
echo "[i] Script ejecutado por el usuario '$SUDO_USER'."
echo "[i] El usuario '$SUDO_USER' debe tener sus claves SSH ya configuradas."

# --- Variables (Capturadas de los argumentos) ---
if [ "$#" -ne 4 ]; then
    echo "ERROR: Argumentos insuficientes."
    echo "Uso: sudo $0 <db_name> <db_user> <db_password> <app_server_ip>"
    exit 1
fi

DB_NAME=$1
DB_USER=$2
DB_PASS=$3
APP_SERVER_IP=$4 # La IP del servidor de aplicación que se conectará

echo "--- Iniciando provisionamiento de MariaDB Server ---"
echo "  Base de Datos: $DB_NAME"
echo "  Usuario de BD: $DB_USER"
echo "  IP de App (Permitida): $APP_SERVER_IP"
echo "-----------------------------------------------------"
sleep 3

# --- 2. Actualización del Sistema ---
echo "[+] Actualizando paquetes del sistema..."
export DEBIAN_FRONTEND=noninteractive
apt update
apt upgrade -y

# --- 3. Instalación de Dependencias ---
echo "[+] Instalando utilidades básicas y MariaDB Server..."
apt install -y ufw curl mariadb-server

# --- 4. Securización de SSH ---
echo "[+] Securizando configuración de SSHD..."
# Asume que el usuario $SUDO_USER ya tiene acceso SSH por clave.
sed -i 's/PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# --- 5. Configuración del Firewall (UFW) ---
echo "[+] Configurando Firewall (UFW)..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh # Permitir SSH para nuestro acceso de admin

# ¡REGLA CRÍTICA!
# Permitir conexiones al puerto de MariaDB (3306) *solo* desde la IP de nuestro servidor de aplicación.
echo "[+] Creando regla de firewall para MariaDB (3306) desde $APP_SERVER_IP..."
ufw allow from "$APP_SERVER_IP" to any port 3306 proto tcp

echo "y" | ufw enable
ufw status verbose

# --- 6. Configuración de Acceso Remoto de MariaDB ---
echo "[+] Configurando MariaDB para acceso de red..."
# Por defecto, MariaDB se bindea a 127.0.0.1.
# Lo cambiamos a 0.0.0.0 (escuchar en todas las IPs) - UFW ya nos protege.
CONF_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"

if ! grep -q "bind-address = 0.0.0.0" "$CONF_FILE"; then
    if grep -q "^\s*bind-address" "$CONF_FILE"; then
        echo "[i] Modificando bind-address existente..."
        sed -i "s/^\s*bind-address\s*=\s*.*$/bind-address = 0.0.0.0/" "$CONF_FILE"
    else
        echo "[i] Añadiendo bind-address..."
        sed -i "/\[mysqld\]/a bind-address = 0.0.0.0" "$CONF_FILE"
    fi
fi

# --- 7. Creación de Base de Datos y Usuario ---
echo "[+] Creando Base de Datos y Usuario en MariaDB..."
# Usamos un Here-Document (heredoc) para pasar los comandos SQL de forma segura
# NOTA: Creamos el usuario con '@'$APP_SERVER_IP'.
# Esto es una capa de seguridad crucial: el usuario *solo* puede loguearse desde esa IP.
sudo mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
CREATE USER IF NOT EXISTS \`$DB_USER\`@'$APP_SERVER_IP' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO \`$DB_USER\`@'$APP_SERVER_IP';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "[+] Base de datos '$DB_NAME' y usuario '$DB_USER' creados."

# --- 8. Reinicio y Limpieza ---
echo "[+] Reiniciando MariaDB para aplicar cambios..."
systemctl restart mariadb

echo "[+] Limpiando paquetes..."
apt autoremove -y
apt clean

echo "---"
echo "[+] ¡PROVISIONAMIENTO COMPLETADO!"
echo "  Tu servidor MariaDB está listo en esta IP."
echo "  Acceso (puerto 3306) permitido solo desde: $APP_SERVER_IP"
echo "  Recuerda conectarte como '$SUDO_USER' por SSH."
echo "---"