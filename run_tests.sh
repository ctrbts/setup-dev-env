#!/bin/bash

# run_tests.sh - Ejecutor de pruebas automatizadas

# Colores para el output
BLUE='\033[0;34m'
NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'

echo -e "${BLUE}=== Iniciando Suite de Pruebas ===${NC}\n"

TOTAL_FAILED=0

# Encontrar y ejecutar todos los archivos de prueba
for test_file in tests/test_*.sh; do
    if [ -f "$test_file" ] && [ "$test_file" != "tests/test_helper.sh" ]; then
        echo -e "${BLUE}Ejecutando: $test_file${NC}"
        bash "$test_file"
        if [ $? -ne 0 ]; then
            TOTAL_FAILED=$((TOTAL_FAILED + 1))
        fi
    fi
done

echo -e "${BLUE}=== Suite de Pruebas Finalizada ===${NC}"

if [ $TOTAL_FAILED -eq 0 ]; then
    echo -e "${GREEN}Todas las pruebas pasaron correctamente.${NC}"
    exit 0
else
    echo -e "${RED}Hubo fallos en $TOTAL_FAILED archivo(s) de prueba.${NC}"
    exit 1
fi
