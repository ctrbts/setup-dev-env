# Delta para Documentación README

## Propósito

Documentar los cambios en la documentación del proyecto para reflejar la nueva arquitectura de perfiles modulares.

## Requisitos AGREGADOS

### Requisito: Documentación de Flags Combinables

El documento DEBE documentar las nuevas banderas combinables disponibles: `--dev`, `--office`, `--all`, `--remove-snap`.

#### Escenario: Flags documentados

- GIVEN el usuario lee el README.md
- WHEN busca la sección de uso avanzado
- THEN las banderas `--dev`, `--office`, `--all`, `--remove-snap` DEBEN estar documentadas

#### Escenario: Descripción de --dev

- GIVEN el usuario lee la documentación de --dev
- WHEN entiende qué se instala
- THEN DEBE indicar: Zsh, Docker, VSCode, DBeaver, runtimes interactivos

#### Escenario: Descripción de --office

- GIVEN el usuario lee la documentación de --office
- WHEN entiende qué se instala
- THEN DEBE indicar: OnlyOffice, Zoom, Spotify, modo zero-touch, Bash estándar

#### Escenario: Descripción de --all

- GIVEN el usuario lee la documentación de --all
- WHEN entiende qué hace
- THEN DEBE indicar que es equivalente a `--dev --office` y es el comportamiento por defecto

### Requisito: Ejemplos de Código

El documento DEBE incluir bloques de código (`bash`) listos para copiar y pegar.

#### Escenario: Ejemplo Office

- GIVEN el usuario copia el ejemplo de instalación office
- WHEN lo ejecuta
- THEN DEBE usar el formato `GITHUB_USER="ctrbts" bash -c "$(curl -fsSL ...)" _ --office`

#### Escenario: Ejemplo Dev con Snap eliminado

- GIVEN el usuario copia el ejemplo de instalación dev sin Snap
- WHEN lo ejecuta
- THEN DEBE usar el formato `GITHUB_USER="ctrbts" bash -c "$(curl -fsSL ...)" _ --dev --remove-snap`

## Requisitos MODIFICADOS

### Requisito: Eliminación de --dev-only

El documento NO DEBE mencionar el flag `--dev-only`.

(Anteriormente: El documento mencionaba `--dev-only` como option)

#### Escenario: Sin mención a --dev-only

- GIVEN el usuario busca --dev-only en el README
- WHEN lo busca en el documento
- THEN NO DEBE encontrar ninguna mención a `--dev-only`

### Requisito: Actualización de ejemplos

Los ejemplos de código DEBEN usar los nuevos flags.

(Anteriormente: Los ejemplos usaban `--all` y `--dev-only`)

#### Escenario: Ejemplo con --remove-snap

- GIVEN el ejemplo muestra eliminación de Snap
- WHEN el usuario lo ejecuta
- THEN DEBE usar `--remove-snap` (manteniendo la advertencia)

## Requisitos ELIMINADOS

### Requisito: Documentación de --dev-only

El documento DEBE haber eliminado toda referencia a `--dev-only`.

(Motivo: Reemplazado por `--dev`)

## Criterios de Verificación

- [ ] Sin menciones a --dev-only
- [ ] --dev documentado
- [ ] --office documentado
- [ ] --all documentado
- [ ] --remove-snap documentado
- [ ] Ejemplos funcionales