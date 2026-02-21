#!/bin/bash

# ---
# Script de Provisionamiento de Servidor de Aplicación Nginx + PHP + SSL (Let's Encrypt)
#
# OBJETIVO:
# 1. Actualizar el sistema.
# 2. Securizar SSH.
# 3. Instalar Firewall, Nginx, PHP, Certbot.
# 4. Configurar Nginx con dominio real.
# 5. Obtener certificado SSL y forzar HTTPS automáticamente.
#
# USO:
# 1. Crear tu usuario (ej. 'soporte'): adduser soporte
# 2. Darle permisos 'sudo': usermod -aG sudo soporte
# 3. (Opcional pero recomendado) Configurar tu clave SSH: mkdir -p /home/soporte/.ssh
# 4. Copiamos la clave SSH: mv /root/.ssh/authorized_keys /home/soporte/.ssh/
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

USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
if [ ! -d "$USER_HOME" ]; then
    echo "ERROR: No se pudo determinar el directorio HOME para $SUDO_USER."
    exit 1
fi

echo "[i] Script ejecutado por el usuario '$SUDO_USER'."

# --- Configuración Interactiva ---
printf "Ingrese el nombre de dominio (ej. mi-sitio.com): "
read DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: El nombre de dominio es requerido."
    exit 1
fi

printf "Ingrese el email para notificaciones SSL: "
read CERT_EMAIL
if [ -z "$CERT_EMAIL" ]; then
    echo "Error: El email es requerido."
    exit 1
fi

# --- Variables ---
APP_DIR="/var/www/app"
WEB_ROOT="$APP_DIR/public"

echo "--- Iniciando provisionamiento de Nginx/PHP/SSL ---"
echo "  Dominio: $DOMAIN_NAME"
echo "  Email SSL: $CERT_EMAIL"
echo "  Web Root: $WEB_ROOT"
echo "-----------------------------------------------------"

# --- 2. Actualización del Sistema ---
echo "[+] Actualizando paquetes del sistema..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y

# --- 3. Instalación de Dependencias ---
echo "[+] Instalando Nginx, PHP, Certbot y extensiones..."
apt-get install -y \
    ufw \
    curl \
    nginx \
    git \
    zsh \
    mc \
    certbot \
    python3-certbot-nginx \
    php-fpm \
    php-mysql \
    php-mbstring \
    php-xml \
    php-curl \
    php-zip

# --- 4. Detección de Versión de PHP ---
PHP_VERSION_DETECTED=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
echo "[i] Versión de PHP detectada: $PHP_VERSION_DETECTED"

# --- 5. Securización de SSH ---
echo "[+] Securizando configuración de SSHD..."
sed -i 's/PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# --- 6. Configuración del Firewall (UFW) ---
echo "[+] Configurando Firewall (UFW)..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 'Nginx Full' # Abre puerto 80 (HTTP) y 443 (HTTPS)

echo "y" | ufw enable
ufw status verbose

# --- 7. Creación del Directorio de la Aplicación y Permisos ---
echo "[+] Configurando directorio de aplicación..."
mkdir -p "$WEB_ROOT"
usermod -aG www-data "$SUDO_USER"
chown -R www-data:www-data "$APP_DIR"
chmod -R 775 "$APP_DIR"
find "$APP_DIR" -type d -exec chmod g+s {} +

# --- 8. Configuración de Nginx (HTTP Inicial) ---
echo "[+] Configurando Nginx (Bloque HTTP)..."
rm -f /etc/nginx/sites-enabled/default

NGINX_CONF="/etc/nginx/sites-available/app.conf"
PHP_FPM_SOCK="/run/php/php$PHP_VERSION_DETECTED-fpm.sock"

# Creamos la configuración HTTP estándar.
# Certbot modificará este archivo automáticamente para añadir SSL.
cat << EOF > "$NGINX_CONF"
server {
    listen 80;
    server_name $DOMAIN_NAME; # Importante: Debe coincidir con el dominio real
    
    root $WEB_ROOT;
    client_max_body_size 64M;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$PHP_FPM_SOCK;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -s -f "$NGINX_CONF" "/etc/nginx/sites-enabled/"
nginx -t
systemctl restart nginx

# --- 9. Configuración de PHP-FPM ---
echo "[+] Ajustando PHP-FPM..."
PHP_INI_FILE="/etc/php/$PHP_VERSION_DETECTED/fpm/php.ini"
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" "$PHP_INI_FILE"
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 64M/" "$PHP_INI_FILE"
sed -i "s/post_max_size = .*/post_max_size = 64M/" "$PHP_INI_FILE"
systemctl restart "php$PHP_VERSION_DETECTED-fpm"

# --- 10. Archivo de Prueba ---
echo "<?php phpinfo(); ?>" > "$WEB_ROOT/info.php"
chown www-data:www-data "$WEB_ROOT/info.php"

# --- 11. Zsh y Oh My Zsh ---
echo "[+] Configurando Zsh para $SUDO_USER..."
OH_MY_ZSH_DIR="$USER_HOME/.oh-my-zsh"

if ! command -v zsh &> /dev/null; then
    echo "zsh no instalado."
else
    chsh -s "$(which zsh)" "$SUDO_USER"
    if [ ! -d "$OH_MY_ZSH_DIR" ]; then
        sudo -u "$SUDO_USER" HOME="$USER_HOME" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
    fi
    # Plugins (Simplificado para evitar errores si ya existen)
    CUSTOM_PLUGINS="$OH_MY_ZSH_DIR/custom/plugins"
    [ ! -d "$CUSTOM_PLUGINS/zsh-autosuggestions" ] && sudo -u "$SUDO_USER" HOME="$USER_HOME" git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "$CUSTOM_PLUGINS/zsh-autosuggestions"
    [ ! -d "$CUSTOM_PLUGINS/zsh-syntax-highlighting" ] && sudo -u "$SUDO_USER" HOME="$USER_HOME" git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM_PLUGINS/zsh-syntax-highlighting"
    
    if [ -f "$USER_HOME/.zshrc" ]; then
        sudo -u "$SUDO_USER" sed -i 's/^plugins=(git)$/plugins=(git common-aliases extract colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)/' "$USER_HOME/.zshrc"
    fi
fi

# --- 12. Obtención de Certificado SSL (Certbot) ---
echo "-----------------------------------------------------"
echo "[+] Solicitando certificado SSL para $DOMAIN_NAME..."
echo "-----------------------------------------------------"

# Ejecutamos certbot con el plugin de nginx.
# --non-interactive: No hace preguntas.
# --agree-tos: Acepta términos.
# --redirect: Modifica el Nginx conf para redirigir HTTP -> HTTPS automáticamente.
if certbot --nginx -d "$DOMAIN_NAME" --non-interactive --agree-tos -m "$CERT_EMAIL" --redirect; then
    echo "[SUCCESS] Certificado SSL instalado y redirección HTTPS activada."
else
    echo "[WARNING] Certbot falló. Posibles causas:"
    echo "  1. El dominio $DOMAIN_NAME no apunta a la IP de este servidor."
    echo "  2. El firewall bloqueó la conexión (puerto 80 debe estar abierto)."
    echo "  Puedes intentar correrlo manualmente luego: sudo certbot --nginx"
fi

# --- Finalización ---
echo "---"
echo "[+] ¡PROVISIONAMIENTO COMPLETADO!"
echo "  URL: https://$DOMAIN_NAME/info.php"
echo "---"
