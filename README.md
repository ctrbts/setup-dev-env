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

Puedes enviar opciones adicionales al comando pasando parámetros al final de este.

### Instalación completa eliminando Snap

> **ADVERTENCIA:** Solo usa esta opción si entiendes las implicaciones de eliminar `snapd` de tu sistema.

```bash
GITHUB_USER="ctrbts" bash -c "$(curl -fsSL https://raw.githubusercontent.com/ctrbts/setup-dev-env/main/bootstrap.sh)" _ --all --remove-snap
```

### Instalar solo herramientas de desarrollo

Sin instalar flatpaks de escritorio y manteniendo Snap

```bash
GITHUB_USER="ctrbts" bash -c "$(curl -fsSL https://raw.githubusercontent.com/ctrbts/setup-dev-env/main/bootstrap.sh)" _ --dev-only
```

> **Explicación del comando:**
>
> - `GITHUB_USER="ctrbts"`: Define la variable de entorno de tu usuario para clonar el repositorio automáticamente sin hacer pausas e instalar en ese directorio de trabajo (`~/workspace/github.com/<usuario>/`).
> - `bash -c "..." _`: El `_` es un placeholder necesario para que `bash -c` asigne correctamente los sufijos o argumentos (`--all`, `--dev-only`, etc.) a `$@` del script descargado en subshell.

## Scripts

- [Aquí hay varios scripts](/scripts) que están diseñados para automatizar la instalación y configuración de herramientas y entornos necesarios para el desarrollo de software.

## Configuración para diferentes plataformas

- [Ubuntu](/markdown/setup-ubuntu.md)
- [Windows](/markdown/setup-win.md)

---
## 🧪 Pruebas (Testing)

El proyecto incluye una suite de pruebas automatizadas para verificar la integridad de los scripts.

### Ejecutar pruebas

Para ejecutar todas las pruebas, utiliza el script `run_tests.sh` en la raíz del repositorio:

```bash
./run_tests.sh
```

### Estructura de pruebas

- `tests/test_helper.sh`: Utilidades y aserciones para las pruebas.
- `tests/test_*.sh`: Archivos de prueba individuales para diferentes componentes.
- `run_tests.sh`: Ejecutor principal que descubre y ejecuta todas las pruebas.

---
Este repositorio es una referencia personal y la actualizo a medida de mis necesidades (es probable que no incluya algunos stack de desarrollo).
