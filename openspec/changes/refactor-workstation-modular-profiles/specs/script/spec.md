# Delta para Script de Instalación Modular

## Requisitos AGREGADOS

### Requisito: Parseo de Banderas Combinables

El sistema DEBE aceptar múltiples banderas combinables en la línea de comandos (`--dev`, `--office`, `--remove-snap`). Las banderas DEBEN poder combinarse en cualquier orden.

#### Escenario: Combinación básica de perfiles

- GIVEN el script se ejecuta con `--dev --office`
- WHEN se procesan los argumentos
- THEN las variables `INSTALL_DEV` y `INSTALL_OFFICE` DEBEN establecerse en `true`

#### Escenario: Perfil único con flag de limpieza

- GIVEN el script se ejecuta con `--office --remove-snap`
- WHEN se procesan los argumentos
- THEN `INSTALL_OFFICE` DEBE ser `true`, `INSTALL_DEV` DEBE ser `false`, y `REMOVE_SNAP` DEBE ser `true`

### Requisito: Comportamiento por Defecto

El sistema DEBE iniciar con ambos perfiles activos si no se especifican argumentos, o si se usa `--all`.

#### Escenario: Sin argumentos

- GIVEN el script se ejecuta sin argumentos
- WHEN se procesa `main "$@"` con `$#` igual a 0
- THEN `INSTALL_DEV` y `INSTALL_OFFICE` DEBEN ser ambos `true`

#### Escenario: Flag --all

- GIVEN el script se ejecuta con `--all`
- WHEN se procesa el argumento
- THEN `INSTALL_DEV` y `INSTALL_OFFICE` DEBEN establecerse en `true`

### Requisito: Topología de Paquetes Separados

El sistema DEBE mantener tres arrays de paquetes independientes: Base (siempre instalados), Dev (solo con `--dev`), Office (solo con `--office`).

#### Escenario: Instalación Base

- GIVEN el script se ejecuta con cualquier combinación de perfiles
- WHEN se ejecuta `install_apt_packages`
- THEN los paquetes en el array `APT_BASE` DEBEN instalarse siempre

#### Escenario: Instalación Dev

- GIVEN el script se ejecuta con `--dev` activo
- WHEN se evalúa el condicional para el perfil Dev
- THEN los paquetes en `APT_DEV` DEBEN instalarse

#### Escenario: Instalación Office

- GIVEN el script se ejecuta con `--office` activo
- WHEN se evalúa el condicional para el perfil Office
- THEN los paquetes en `APT_OFFICE` DEBEN instalarse

### Requisito: Ejecución Zero-Touch para Office

El sistema NO DEBE ejecutar pausas interactivas ni prompts cuando solo esté activo el perfil `--office`.

#### Escenario: Setup runtimes sin perfil Dev

- GIVEN el script se ejecuta solo con `--office`
- WHEN se llama a `setup_runtimes`
- THEN la función DEBE ejecutarse de forma desatendida sin `read -p`
- AND NO DEBE instalar uv, fnm, ni sdkman

### Requisito: Zsh Condicional al Perfil Dev

El sistema DEBE instalar y configurar Zsh, Oh My Zsh y los dotfiles SOLO si el perfil `--dev` está activo.

#### Escenario: Zsh con perfil Dev

- GIVEN el script se ejecuta con `--dev` o `--all`
- WHEN se llama a `setup_zsh`
- THEN la función DEBE ejecutarse completamente

#### Escenario: Zsh sin perfil Dev

- GIVEN el script se ejecuta solo con `--office`
- WHEN se llama a `setup_zsh`
- THEN la función DEBE ser omitida (no ejecutarse)
- AND el usuario DEBE permanecer con Bash estándar

### Requisito: Copia Condicional de Dotfiles

El sistema DEBE copiar el `functions.sh` y `.zshrc` personalized SOLO si el perfil Dev está activo.

#### Escenario: Dotfiles con perfil Dev

- GIVEN el script se ejecuta con `--dev` activo
- WHEN se llama a `setup_dotfiles`
- THEN los dotfiles DEBEN copiarse al home del usuario

#### Escenario: Dotfiles sin perfil Dev

- GIVEN el script se ejecuta solo con `--office`
- WHEN se ejecuta `setup_dotfiles`
- THEN los dotfiles NO DEBEN copiarse

## Requisitos MODIFICADOS

### Requisito: Parseo de Argumentos (Anteriormente: Solo --dev-only)

El sistema DEBE reestructurar el loop `for arg in "$@"` en `main()` para soportar múltiples flags mediante variables booleanas (`INSTALL_DEV=false`, `INSTALL_OFFICE=false`, `REMOVE_SNAP=false`).

(Anteriormente: Solo aceptaba `--dev-only` como string, sin booleanos)

#### Escenario: Múltiples argumentos unknowns

- GIVEN el script se ejecuta con `--dev --office --unknown-flag`
- WHEN el loop encuentra un argumento desconocido
- THEN el script DEBE ignorar el argumento desconocido sinerror
- AND continuar procesando los argumentos válidos

### Requisito: Arrays de Paquetes (Anteriormente: APT_ESSENTIALS y APT_APPS juntos)

El sistema DEBE separar los paquetes en tres grupos independientes: Base, Dev, Office.

(Anteriormente: Paquetes mezclados en `APT_ESSENTIALS` y `APT_APPS`, sin separación por perfil)

## Requisitos ELIMINADOS

### Requisito: Instalación interactiva de runtimes

El sistema NO DEBE solicitar confirmación al usuario para uv, fnm, sdkman cuando el perfil Dev no esté activo.

(Motivo: Requisito eliminado para habilitar zero-touch para Office)

### Requisito: Zsh siempre instalado

El sistema NO DEBE instalar Zsh como parte del perfil Office.

(Motivo: Para reduzir bloatware y mejorar experiencia de usuario de oficina)

## Criterios de Verificación

- [ ] Caminos felices: Los 4 perfiles/combinaciones principales están cubiertos
- [ ] Casos límite: Argumentos desconocidos, perfiles vacíos, condición sin argumentos
- [ ] Estados de error: Permisos insuficidos, elementos ya instalados