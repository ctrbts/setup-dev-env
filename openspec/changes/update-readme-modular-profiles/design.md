# Diseño: Update README for Modular Profiles

## Enfoque Técnico

Editar el archivo `README.md` existente para actualizar la sección "Uso Avanzado" con las nuevas banderas de perfiles modulares, eliminando referencias obsoletas a `--dev-only`.

## Decisiones de Arquitectura

### Decisión: Estructura de la Sección Uso Avanzado

**Elección**: Mantener la estructura actual(addición de subsecciones para cada perfil) y actualizar ejemplos.

**Alternativas consideradas**: Crear una nueva tabla de perfiles, reorganizar completamente.
**Justificación**: Mantiene consistencia con el documento existente y no altera el tono.

### Decisión: Descripciones por Perfil

**Elección**: Documentar brevemente qué incluye cada perfil:
- **--dev**: Zsh, Docker, VSCode, DBeaver, runtimes interactivos
- **--office**: OnlyOffice, Zoom, Spotify, zero-touch, Bash estándar
- **--all**: Equivalente a --dev --office (default)

**Alternativas consideradas**: Detalle exhaustivo de paquetes.
**Justificación**: Conciso y suficiente para que el usuario entienda.

### Decisión: Formato de Ejemplos

**Elección**: Mantener el formato `GITHUB_USER="ctrbts" bash -c "$(curl -fsSL ...)" _ <flags>` en todos los ejemplos.

**Alternativas consideradas**: Simplificar a solo `bash post_install.sh`, variar formato.
**Justificación**: Mantiene compatibilidad con el flujo de bootstrap.sh existente.

## Cambios de Archivos

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `README.md` | Modificar | Actualizar sección Uso Avanzado con nuevos flags |

## Detalle de Cambios en README.md

| Sección | Cambio |
|---------|--------|
| Línea 27-28 (ejemplo --all --remove-snap) | Mantener (ya usa --all) |
| Línea 30-36 (ejemplo --dev-only) | **ELIMINAR** - substituir por ejemplo --office |
| Línea 38-41 (explicación) | Actualizar para mencionar --dev, --office, --all, --remove-snap |

## Estrategia de Testing

| Capa | Qué Testear | Enfoque |
|------|-------------|---------|
| Documentación | Flags documentados | Revisión visual |
| Documentación | Ejemplos sin errores de sintaxis | Verificar formato con grep |
| Documentación | Sin referencias a --dev-only | Búsqueda con grep |

## Migración

No se requiere migración. Es un cambio de documentación puro.

## Preguntas Abiertas

- [ ] Ninguna - el diseño es directo y sigue las specs