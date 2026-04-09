# Diseño: Refactor Workstation Scripts for Modular Profiles

## Enfoque Técnico

Reestructurar `post_install.sh` para soportar aprovisionamiento modular mediante variables booleanas que controlan la instalación de perfiles combinables. El parseo de argumentos en `main()` se reescribirá para aceptar `--dev`, `--office`, `--remove-snap` y `--all`, activando booleanos que gated las llamadas a funciones específicas de cada perfil.

## Decisiones de Arquitectura

### Decisión: Estructura de Variables Booleanas

**Elección**: Usar variables globales `INSTALL_DEV`, `INSTALL_OFFICE`, `REMOVE_SNAP` inicializadas en `false` dentro de `main()` y modificadas por el parseo de argumentos.

**Alternativas consideradas**: Usar arrays asociativos o strings delimitados por comas.
**Justificación**: Más legible y permite condicionales directos estilo `[ "$INSTALL_DEV" = true ]`. El patrón booleano ya existe en el código actual (REMOVE_SNAP).

### Decisión: Separación de Arrays de Paquetes

**Elección**: Crear tres arrays independientes: `APT_BASE` (siempre instala), `APT_DEV` (solo con --dev), `APT_OFFICE` (solo con --office).

**Alternativas consideradas**: Un solo array con todas las apps y filtrar con case/switch, mantener los arrays existentes pero envueltos en condicionales.
**Justificación**: Separación clara de responsabilidades, facilita mantenimiento y extensión futura. Evita condicionales complejos dentro de las llamadas a apt.

### Decisión: Comportamiento por Defecto

**Elección**: Si `$#` (cantidad de argumentos) es 0, establecer `INSTALL_DEV=true` y `INSTALL_OFFICE=true`. Igual comportamiento con `--all`.

**Alternativas consideradas**: Default solo a Dev, default a Office, error si no hay argumentos.
**Justificación**: Mantiene backwards compatibility con comportamiento actual (todo instalado). El usuario puede usar `--office` solo si quiere un entorno limpio.

### Decisión: Zero-Touch para Office

**Elección**: `setup_runtimes` verificará `$INSTALL_DEV` al inicio y retornará inmediatamente si es `false`, sin ejecutar las pausas `read -p`.

**Alternativas consideradas**: Modificar cada llamada read para verificar el flag, pasar argumento a la función.
**Justificación**: Un solo punto de guard, más limpio y extensible.

### Decisión: Zsh Condicional

**Elección**: Envolver `setup_zsh` y `setup_dotfiles` en `if [ "$INSTALL_DEV" = true ]; then`.

**Alternativas consideradas**: Verificar dentro de cada función, crear función wrapper.
**Justificación**: El patrón ya existe en el código (setup de Snap). Gated temprano para evitar instalaciones innecesarias.

## Flujo de Datos

```
main("$@")
    │
    ├─→ Parsear args → INSTALL_DEV/OFFICE/SNAP = true/false
    │
    ├─→ cleanup_previous_configs
    │
    ├─→ remove_snap (solo si REMOVE_SNAP=true)
    │
    ├─→ setup_apt_repos
    │
    ├─→ install_apt_packages
    │       ├─→ APT_BASE (siempre)
    │       ├─→ APT_DEV (si INSTALL_DEV=true)
    │       └─→ APT_OFFICE (si INSTALL_OFFICE=true)
    │
    ├─→ setup_zsh (solo si INSTALL_DEV=true)
    │
    ├─→ setup_runtimes (solo si INSTALL_DEV=true)
    │
    ├─→ setup_dotfiles (solo si INSTALL_DEV=true)
    │
    ├─→ install_flatpaks (si INSTALL_OFFICE=true o --all)
    │
    └─→ cleanup final
```

## Cambios de Archivos

| Archivo                    | Acción    | Descripción                                           |
|--------------------------|-----------|-------------------------------------------------------|
| `post_install.sh`        | Modificar | Refactorización completa del script (líneas 336-406)    |
| `configs/functions.sh` | Sin cambio| Copiado solo si INSTALL_DEV=true                    |
| `configs/zshrc`        | Sin cambio| Copiado solo si INSTALL_DEV=true                    |

### Detalle de Cambios en post_install.sh

| Sección                            | Cambio                                  |
|------------------------------------|----------------------------------------|
| Variables Globales (líneas 15-21)   | Agregar booleanos al inicializar         |
| Arrays de Paquetes (líneas 22-62)    | Separar en APT_BASE, APT_DEV, APT_OFFICE |
| `main()` parseo (líneas 350-370)     | Reescribir loop para booleanos         |
| `main()` calls (líneas 372-390)      | Envolver en condicionales if             |
| `setup_runtimes()` (líneas 282-312)      | Agregar guard `$INSTALL_DEV`          |

## Interfaz de Línea de Comandos

```bash
# Ambos perfiles (default actual)
sudo ./post_install.sh
sudo ./post_install.sh --all

# Solo Dev
sudo ./post_install.sh --dev

# Solo Office (zero-touch)
sudo ./post_install.sh --office

# Combinados
sudo ./post_install.sh --dev --office
sudo ./post_install.sh --dev --remove-snap

# Oficina + limpieza Snap
sudo ./post_install.sh --office --remove-snap
```

## Estrategia de Testing

| Capa        | Qué Testear                    | Enfoque                    |
|-------------|-------------------------------|---------------------------|
| Manual      | Parseo de args y booleanos    | Inspect con echo/debug     |
| Manual      | Instalación perfiles        | Ejecutar en VM de prueba  |
| Manual      | Zero-touch para Office        | Verificar sin prompts     |

**Nota**: No hay infraestructura de testing automatizada en el proyecto. Testing será manual en VM.

## Migración

No se requiere migración. El cambio es backwards compatible: sin argumentos funciona igual que antes (`--all` implícito).

## Preguntas Abiertas

- [ ] Ninguna — todas las decisiones están tomadas basándose en el código existente y requisitos.