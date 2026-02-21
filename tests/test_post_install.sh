#!/bin/bash

# tests/test_post_install.sh - Pruebas para post_install.sh

# Cargar el helper de pruebas
source "$(dirname "$0")/test_helper.sh"

# Mock de variables que usa post_install.sh
BLUE='\033[0;34m'
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

# Sourcing del script a probar
source "post_install.sh"

echo "Pruebas de funciones de utilidad en post_install.sh:"

# Test _log
# Nota: _log usa echo -e "\n...", lo que genera un salto de línea real
output=$(_log "Mensaje de prueba")
expected=$(echo -e "\n${BLUE}==> Mensaje de prueba${NC}")
assert_equals "$expected" "$output" "_log produce el formato correcto"

# Test _success
output=$(_success "Éxito")
expected=$(echo -e "${GREEN}✅ Éxito${NC}")
assert_equals "$expected" "$output" "_success produce el formato correcto"

# Test _warning
output=$(_warning "Advertencia")
expected=$(echo -e "${YELLOW}⚠️ Advertencia${NC}")
assert_equals "$expected" "$output" "_warning produce el formato correcto"

test_summary
