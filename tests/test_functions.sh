#!/bin/bash

# tests/test_functions.sh - Pruebas para configs/functions.sh

# Cargar el helper de pruebas
source "$(dirname "$0")/test_helper.sh"

# Mock de variables que usa functions.sh
BLUE='\033[0;34m'
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'

# Sourcing del script a probar
source "configs/functions.sh" > /dev/null

echo "Pruebas de funciones de utilidad en configs/functions.sh:"

# Test log_info
output=$(log_info "Info")
expected=$(echo -e "${BLUE}[INFO] Info${NC}")
assert_equals "$expected" "$output" "log_info produce el formato correcto"

echo -e "\nPruebas de lógica en clone_repo:"

# Mock de comandos para probar clone_repo
mkdir() { return 0; }
git() { return 0; }
cd() { return 0; }
# Mock de log_info para capturar el target_dir
log_info() { echo "$1"; }

# Test clone_repo con HTTPS
output=$(clone_repo "https://github.com/user/repo.git")
expected_dir="$HOME/workspace/github.com/user/repo"
assert_equals "Clonando en: $expected_dir" "$(echo "$output" | grep "Clonando en:")" "clone_repo parsea correctamente URL HTTPS"

# Test clone_repo con SSH (simulado)
output=$(clone_repo "https://github.com/user/repo.git" "true")
assert_equals "Clonando en: $expected_dir" "$(echo "$output" | grep "Clonando en:")" "clone_repo parsea correctamente URL para SSH"

test_summary
