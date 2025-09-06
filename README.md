Para configurar una máquina nueva ejecute uno de los comandos de abajo. Esto descargará un pequeño script que clonará el repositorio y ejecutará la instalación.

## Instalación Estándar (Recomendado)

Este comando ejecuta la configuración completa pero **mantiene Snap** para máxima compatibilidad con versiones recientes de Ubuntu.

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ctrbts/setup-dev-env/main/bootstrap.sh)"

### Uso Avanzado

Puedes pasar flags directamente al script de instalación para modificar su comportamiento.

**Ejemplo 1: Instalación completa eliminando Snap**

ADVERTENCIA: Solo usar si entiendes las implicaciones de eliminar `snapd` de tu sistema.

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ctrbts/setup-dev-env/main/bootstrap.sh)" _ --all --remove-snap

**Ejemplo 2: Instalación solo de herramientas de desarrollo (sin Apps de escritorio y sin eliminar Snap)**

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ctrbts/setup-dev-env/main/bootstrap.sh)" _ --dev-only

**Explicación del formato del comando:**
El `_` después del script es un placeholder necesario para que `sh -c` asigne correctamente los argumentos (`--all`, `--remove-snap`, etc.) al script descargado.

## Scripts

- [Aquí hay varios scripts](/scripts) que están diseñados para automatizar la instalación y configuración de herramientas y entornos necesarios para el desarrollo de software.


## Configuración para diferentes plataformas

- [Ubuntu](/markdown/setup-ubuntu.md)
- [Windows](/markdown/setup-win.md)

---
Este repositorio es una referencia personal y la actualizo a medida de mis necesidades (es probable que no incluya algunos stack de desarrollo).