# Propuesta: Refactor Workstation Scripts for Modular Profiles

## Intención

Refactorizar el script `post_install.sh` para soportar aprovisionamiento modular basado en perfiles combinables. El objetivo es que el mismo script pueda provisionar estaciones de trabajo pesadas para Ingenieros (Dev) o entornos limpios y estandarizados para Personal de Oficina (Office), evitando el bloatware y mejorando la automatización.

## Alcance

### Dentro del Alcance
- Reestructurar el parseo de argumentos en `main()` para activar variables booleanas (`INSTALL_DEV=false`, `INSTALL_OFFICE=false`, `REMOVE_SNAP=false`)
- Separar arrays de paquetes en tres grupos: Base (core), Dev, Office
- Aplicar condicionales `if [ "$INSTALL_DEV" = true ]; then` para envolver funciones específicas de desarrolladores (`setup_zsh`, `setup_runtimes`, `setup_dotfiles`)
- Eliminar pausas interactivas en `setup_runtimes` cuando solo esté `--office` activo (ejecución zero-touch)
- Mantener limpieza de repositorios y erradicación de Snap intactas

### Fuera del Alcance
- Nuevas funcionalidades de instalación (más allá de reorganizar las existentes)
- Testing automatizado del script refactorizado

## Enfoque

Refactorización del parseo de argumentos existente, reorganización de arrays de paquetes, aplicación de condicionales por perfil, y modificación de `setup_runtimes` para ejecución desatendida cuando solo esté `--office`.

## Áreas Afectadas

| Área                          | Impacto      | Descripción                                |
|-------------------------------|-------------|---------------------------------------------|
| `post_install.sh`             | Modificado  | Refactorización completa del script         |
| `configs/functions.sh`      | Potencial   | Puede requerir ajustes si es copiado condicionalmente |
| `configs/zshrc`              | Potencial   | Solo se copia si perfil Dev está activo   |

## Riesgos

| Riesgo                               | Probabilidad | Mitigación                          |
|--------------------------------------|-------------|-------------------------------------|
| Breaking changes en argumentos       | Baja        | Mantener backwards compatibility   |
| Errores en condicionales Bash        | Media       | Revisar lógica antes de ejecutar   |

## Plan de Rollback

Revertir los cambios en `post_install.sh` usando git checkout desde el último commit antes del cambio.

## Criterios de Éxito

- [ ] Script acepta `--dev`, `--office`, `--remove-snap` y los combina correctamente
- [ ] Si solo se usa `--office`, NO se instala Zsh ni funciones de dev
- [ ] `setup_runtimes` ejecuta sin interacción cuando solo está `--office`
- [ ] El flag `--all` o sin argumentos activa ambos perfiles (comportamiento por defecto)