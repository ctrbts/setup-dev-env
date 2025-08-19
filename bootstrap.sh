#!/bin/bash
echo "Clonando el repositorio de configuración de la workstation..."
git clone https://GHSAT0AAAAAADJNP3STUEWUYLMMZ43RY5WE2FEVJPA@github.com/ctrbts/setup-dev-env.git ~/setup-dev-env
cd ~/setup-dev-env
bash post_install.sh --all