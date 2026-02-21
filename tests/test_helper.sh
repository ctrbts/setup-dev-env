#!/bin/bash

# tests/test_helper.sh - Utilidades para pruebas unitarias en Bash

# Colores para el output de las pruebas
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Contadores de pruebas
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Función para reportar éxito
assert_success() {
    local status=$?
    local message=$1
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ $status -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} $message (Se esperaba éxito, pero falló con estado $status)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Función para reportar falla
assert_failure() {
    local status=$?
    local message=$1
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ $status -ne 0 ]; then
        echo -e "  ${GREEN}✓${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} $message (Se esperaba falla, pero tuvo éxito)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Función para comparar valores
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$expected" == "$actual" ]; then
        echo -e "  ${GREEN}✓${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}✗${NC} $message"
        echo "      Esperado: '$expected'"
        echo "      Obtenido: '$actual'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Función para resumir resultados de un archivo de prueba
test_summary() {
    echo -e "\nResultados: ${GREEN}$TESTS_PASSED pasadas${NC}, ${RED}$TESTS_FAILED fallidas${NC}, de $TESTS_RUN totales.\n"
    if [ $TESTS_FAILED -gt 0 ]; then
        return 1
    fi
    return 0
}
