# Setup Dev Env

Automatización para la configuración de entornos de desarrollo en máquinas nuevas Ubuntu.

Este repositorio está diseñado para ejecutarse como un **one-shot**. Con solo copiar y pegar un comando en la terminal, se descargará el script de inicialización (`bootstrap.sh`), se solicitarán permisos de administrador (te pedirá ingresar tu contraseña temporalmente para `sudo`), se clonará el repositorio localmente y se ejecutará la configuración completa sin depender de pasos manuales.

## Instalación Estándar (Recomendado)

Para iniciar la instalación, abre tu terminal y ejecuta el siguiente comando.
*(Si hiciste un fork de este repositorio, cambia `ctrbts` por tu usuario de GitHub)*:

```bash
GITHUB_USER="ctrbts" bash -c "$(curl -fsSL https://raw.githubusercontent.com/ctrbts/setup-dev-env/main/bootstrap.sh)"
```

Este comando ejecuta la configuración completa pero **mantiene Snap** predeterminado para máxima compatibilidad con versiones recientes de Ubuntu.

## Uso Avanzado

Puedes enviar opciones adicionales al comando pasando parámetros al final de este. Las banderas pueden combinarse.

### Instalación completa eliminando Snap

> **ADVERTENCIA:** Solo usa esta opción si entiendes las implicaciones de eliminar `snapd` de tu sistema.

```bash
GITHUB_USER="ctrbts" bash -c "$(curl -fsSL https://raw.githubusercontent.com/ctrbts/setup-dev-env/main/bootstrap.sh)" _ --all --remove-snap
```

### Instalación solo para oficina (Zero-Touch)

Entorno limpio y estandarizado sin herramientas de desarrollo. 100% desatendido.

```bash
GITHUB_USER="ctrbts" bash -c "$(curl -fsSL https://raw.githubusercontent.com/ctrbts/setup-dev-env/main/bootstrap.sh)" _ --office
```

### Instalación de desarrollo sin Snap

Stack de ingeniería completo (Zsh, Docker, VSCode, DBeaver, runtimes)

```bash
GITHUB_USER="ctrbts" bash -c "$(curl -fsSL https://raw.githubusercontent.com/ctrbts/setup-dev-env/main/bootstrap.sh)" _ --dev --remove-snap
```

> **Explicación del comando:**
>
> - `GITHUB_USER="ctrbts"`: Define la variable de entorno de tu usuario para clonar el repositorio automáticamente sin hacer pausas e instalar en ese directorio de trabajo (`~/workspace/github.com/<usuario>/`).
> - `bash -c "..." _`: El `_` es un placeholder necesario para que `bash -c` asigne correctamente los sufijos o argumentos (`--dev`, `--office`, `--all`, `--remove-snap`) a `$@` del script descargado en subshell.
>
> **Banderas disponibles:**
> - `--dev`: Stack de ingeniería (Zsh, Docker, VSCode, DBeaver, runtimes interactivos)
> - `--office`: Stack de oficina (OnlyOffice, Zoom, Spotify) - 100% zero-touch, Bash estándar
> - `--all`: Ambos perfiles (equivalente a `--dev --office`, es el default)
> - `--remove-snap`: Erradica Snapd del sistema

## Scripts

- [Aquí hay varios scripts](/scripts) que están diseñados para automatizar la instalación y configuración de herramientas y entornos necesarios para el desarrollo de software.

## Configuración para diferentes plataformas

- [Ubuntu](/markdown/setup-ubuntu.md)
- [Windows](/markdown/setup-win.md)
