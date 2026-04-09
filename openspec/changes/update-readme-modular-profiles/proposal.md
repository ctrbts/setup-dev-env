# Propuesta: Update README for Modular Profiles

## Intención

Actualizar el archivo `README.md` para reflejar con exactitud la nueva arquitectura de perfiles modulares implementada en `post_install.sh`. La documentación debe actuar como el contrato oficial de cómo los usuarios interactúan con el script de aprovisionamiento.

## Alcance

### Dentro del Alcance
- Eliminar referencias obsoletas al flag `--dev-only`
- Documentar nuevas banderas combinables: `--dev`, `--office`, `--all`, `--remove-snap`
- Actualizar sección "Uso Avanzado" con ejemplos de bloques de código (`bash`)
- Mantener estructura general y tono directo
- Respetar prefijo `GITHUB_USER="ctrbts" bash -c "$(curl -fsSL ...)" _` en ejemplos

### Fuera del Alcance
- Modificar otras secciones del documento
- Alterar enlaces a otros markdowns
- Cambiar el tono general del documento

## Enfoque

Editar directamente el archivo README.md existente, actualizando solo las secciones de Uso Avanzado y eliminando referencias a --dev-only.

## Áreas Afectadas

| Área | Impacto | Descripción |
|------|--------|------------|
| `README.md` | Modificado | Actualización de documentación de flags |

## Riesgos

| Riesgo | Probabilidad | Mitigación |
|--------|-------------|------------|
| Documentación desactualizada | Baja | Verificar después del cambio |

## Plan de Rollback

Revertir cambios usando git checkout desde el commit anterior.

## Criterios de Éxito

- [ ] Sin referencias a --dev-only en el documento
- [ ] Documentación de --dev, --office, --all, --remove-snap visible
- [ ] Ejemplos de código funcionales
- [ ] Sintaxis verificada (el script funciona con los ejemplos)