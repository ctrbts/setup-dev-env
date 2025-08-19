#!/bin/bash
echo "Clonando el repositorio de configuración de la workstation..."
git clone https://github.com/ctrbts/setup-dev-env.git
echo "Cambiando al directorio para ejecutar la instalación..."
cd ~/setup-dev-env
bash post_install.sh --all
