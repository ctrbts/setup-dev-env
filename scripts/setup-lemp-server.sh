#!/bin/bash

# ---
# Script de Provisionamiento de Servidor de Aplicación Nginx + PHP
#
# OBJETIVO:
# 1. Actualizar el sistema.
# 2. Securizar SSH (deshabilitar login root y por password).
# 3. Instalar y configurar UFW (Firewall) para tráfico web.
# 4. Instalar Nginx (versión de repositorio).
# 5. Instalar PHP-FPM y extensiones (versión de repositorio, conector MySQL/MariaDB).
# 6. Configurar Nginx para que funcione con PHP-FPM (usando /public como web root).
# 7. Crear un directorio de aplicación y un archivo info.php de prueba.
# 8. Configurar Zsh y Oh My Zsh para el usuario 'sudo' que ejecuta el script.
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
# 9. Lo ejecutamos: sudo ./setup.sh
# ---

# --- Configuración de Seguridad ---
set -eou pipefail

# --- 1. Verificación de Usuario 'sudo' ---
echo "[+] Verificando permisos de ejecución..."
if [ -z "${SUDO_USER-}" ] || [ "$SUDO_USER" = "root" ]; then
    echo "ERROR: Este script debe ser ejecutado por un usuario no-root con 'sudo'."
    echo "       Ejemplo: sudo $0"
    exit 1
fi

# Determinar el HOME del usuario que invocó 'sudo'
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
if [ ! -d "$USER_HOME" ]; then
    echo "ERROR: No se pudo determinar el directorio HOME para $SUDO_USER."
    exit 1
fi

echo "[i] Script ejecutado por el usuario '$SUDO_USER' (HOME=$USER_HOME)."
echo "[i] El usuario '$SUDO_USER' debe tener sus claves SSH ya configuradas."


# --- Variables ---
APP_DIR="/var/www/app"      # Directorio raíz para la aplicación
WEB_ROOT="$APP_DIR/public"  # Directorio 'public' (Laravel/Symfony style)

echo "--- Iniciando provisionamiento de Nginx/PHP Server ---"
echo "  Directorio de App (Base): $APP_DIR"
echo "  Directorio de App (Web Root): $WEB_ROOT"
echo "  Usando Nginx/PHP de los repositorios de Ubuntu..."
echo "-----------------------------------------------------"
sleep 3

# --- 2. Actualización del Sistema ---
echo "[+] Actualizando paquetes del sistema..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y

# --- 3. Instalación de Dependencias ---
echo "[+] Instalando UFW, Nginx, PHP-FPM y extensiones..."
# Se instala el conector php-mysql para MariaDB/MySQL
# Se añaden git y zsh para la configuración de Oh My Zsh
apt-get install -y \
    ufw \
    curl \
    nginx \
    git \
    zsh \
    php-fpm \
    php-mysql \
    php-mbstring \
    php-xml \
    php-curl \
    php-zip

# --- 4. Detección de Versión de PHP ---
# Detectar la versión de PHP instalada para configurar las rutas correctamente
PHP_VERSION_DETECTED=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
if [ -z "$PHP_VERSION_DETECTED" ]; then
    echo "ERROR: No se pudo detectar la versión de PHP instalada."
    exit 1
fi
echo "[i] Versión de PHP detectada: $PHP_VERSION_DETECTED"

# --- 5. Securización de SSH ---
echo "[+] Securizando configuración de SSHD..."
# Asume que el usuario $SUDO_USER ya tiene acceso SSH por clave.
sed -i 's/PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# --- 6. Configuración del Firewall (UFW) ---
echo "[+] Configurando Firewall (UFW)..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh # Permitir SSH para nuestro acceso de admin
ufw allow 'Nginx Full' # Permitir HTTP (80) y HTTPS (443)

echo "y" | ufw enable
ufw status verbose

# --- 7. Creación del Directorio de la Aplicación ---
echo "[+] Creando directorio raíz de la aplicación en $WEB_ROOT..."
# Crear el directorio base y el directorio 'public'
mkdir -p "$WEB_ROOT"
# Asignar propiedad al usuario que corre Nginx/PHP
# Damos propiedad a todo el directorio de la app
chown -R www-data:www-data "$APP_DIR"
chmod -R 755 "$APP_DIR"

# --- 8. Configuración de Nginx ---
echo "[+] Configurando Nginx..."
# Eliminar el sitio 'default'
rm -f /etc/nginx/sites-enabled/default

# Crear un nuevo archivo de configuración para nuestra app
NGINX_CONF="/etc/nginx/sites-available/app.conf"
PHP_FPM_SOCK="/run/php/php$PHP_VERSION_DETECTED-fpm.sock"

cat << EOF > "$NGINX_CONF"
server {
    listen 80;
    server_name _; # Escucha en cualquier IP/dominio
    
    # ¡CAMBIO IMPORTANTE! El root es el directorio 'public'
    root $WEB_ROOT;

    # Permitir uploads de hasta 64M (igualando a PHP)
    client_max_body_size 64M;

    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    # Pasar scripts PHP al socket de FastCGI
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$PHP_FPM_SOCK;
    }

    # Denegar acceso a archivos .ht (común en Apache, buena práctica en Nginx)
    location ~ /\.ht {
        deny all;
    }
}
EOF

# Activar el nuevo sitio
ln -s -f "$NGINX_CONF" "/etc/nginx/sites-enabled/"

echo "[+] Probando configuración de Nginx..."
nginx -t

# --- 9. Configuración de PHP-FPM ---
echo "[+] Securizando PHP-FPM (cgi.fix_pathinfo)..."
PHP_INI_FILE="/etc/php/$PHP_VERSION_DETECTED/fpm/php.ini"

sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" "$PHP_INI_FILE"

echo "[+] Ajustando límites de subida de PHP-FPM..."
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 64M/" "$PHP_INI_FILE"
sed -i "s/post_max_size = .*/post_max_size = 64M/" "$PHP_INI_FILE"

# --- 10. Creación de Archivo de Prueba ---
echo "[+] Creando $WEB_ROOT/info.php para pruebas..."
# ¡CAMBIO IMPORTANTE! El archivo de prueba ahora va dentro de 'public'
echo "<?php phpinfo(); ?>" > "$WEB_ROOT/info.php"
chown www-data:www-data "$WEB_ROOT/info.php"

# --- 11. Configuración de Zsh y Oh My Zsh ---
# Esta sección ahora se ejecuta para el usuario $SUDO_USER
echo "[+] Configurando Zsh y Oh My Zsh para $SUDO_USER..."
OH_MY_ZSH_DIR="$USER_HOME/.oh-my-zsh"

if ! command -v zsh &> /dev/null; then
    echo "zsh no está instalado. Saliendo."
    exit 1
fi

# Cambiar el shell por defecto para $SUDO_USER
chsh -s "$(which zsh)" "$SUDO_USER"

# Instalar Oh My Zsh
if [ ! -d "$OH_MY_ZSH_DIR" ]; then
    echo "[i] Instalando Oh My Zsh para $SUDO_USER..."
    # Ejecutar como el usuario no-root, pasando explícitamente su variable HOME
    # Esto soluciona el error 'cd: can't cd to /root'
    sudo -u "$SUDO_USER" HOME="$USER_HOME" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
else
    echo "[i] Oh My Zsh ya está instalado en $OH_MY_ZSH_DIR."
fi

# Instalar plugins
CUSTOM_PLUGINS_DIR="$OH_MY_ZSH_DIR/custom/plugins"
if [ ! -d "$CUSTOM_PLUGINS_DIR/zsh-autosuggestions" ]; then
    sudo -u "$SUDO_USER" HOME="$USER_HOME" git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "$CUSTOM_PLUGINS_DIR/zsh-autosuggestions"
fi
if [ ! -d "$CUSTOM_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    sudo -u "$SUDO_USER" HOME="$USER_HOME" git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM_PLUGINS_DIR/zsh-syntax-highlighting"
fi

# Activar plugins
ZSHRC_FILE="$USER_HOME/.zshrc"
if [ -f "$ZSHRC_FILE" ]; then
    sudo -u "$SUDO_USER" sed -i 's/^plugins=(git)$/plugins=(git common-aliases extract colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC_FILE"
fi

# --- 12. Reinicio y Limpieza ---
echo "[+] Reiniciando servicios Nginx y PHP-FPM..."
systemctl restart "php$PHP_VERSION_DETECTED-fpm"
systemctl restart nginx

echo "[+] Limpiando paquetes..."
apt-get autoremove -y
apt-get clean

echo "---"
echo "[+] ¡PROVISIONAMIENTO COMPLETADO!"
echo "  Tu servidor Nginx/PHP está listo."
echo "  Directorio de la app: $APP_DIR"
echo "  Directorio Web (Root): $WEB_ROOT"
echo "  Prueba accediendo a http://<IP_DEL_CT>/info.php"
echo "  Recuerda conectarte como '$SUDO_USER' por SSH."
echo "---"