# Setup a NodeJS/NGinx environment

Configuración de un entorno de Node.js listo para producción en un servidor Ubuntu 24.04. Este servidor ejecutará una aplicaciónes de Node.js administradas por PM2 y brindará a los usuarios acceso seguro a la aplicación mediante un proxy inverso de Nginx. El servidor Nginx brindará HTTPS usando un certificado gratuito proporcionado por Let’s Encrypt.

- [Script para configurar un servidor Ubuntu](../scripts/setup-ubuntu-server.sh)
- [Instalar Nginx](setup-nginx-server.md)
- [Proteger Nginx con Let’s Encrypt](setup-ssl-encrypt.md)
