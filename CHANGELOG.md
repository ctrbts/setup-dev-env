
0.2
- Añadida la erradicación completa de Snap y la instalación de
- Firefox desde el PPA de Mozilla para un sistema base limpio.

0.3
- Corregido para ser compatible con ramas de desarrollo de Ubuntu (ej. 25.10).
- Ancla los repositorios de Docker, Chrome y VSCode a la última LTS ("noble").
- Método de gestión de claves GPG mejorado para máxima compatibilidad.

0.4
- Se elimina el PPA de Mozilla para Firefox.
- Firefox y todas las aplicaciones GUI se instalan ahora vía Flatpak para máxima compatibilidad y consistencia.

0.4.1
- Corregido el parámetro 'location' a 'flatpakrepo_url' para compatibilidad con versiones recientes del módulo community.general.flatpak_remote.

0.4.3
- Añadida limpieza de configuraciones previas de VS Code para evitar conflictos de llaves GPG y hacer el playbook más robusto.

0.4.4
- CORREGIDO: Reordenadas las tareas para ejecutar la limpieza de configuraciones previas ANTES de cualquier operación de APT.
- MEJORADO: Añadida limpieza para repositorios de Chrome y Docker.

0.4.5
- CORREGIDO: Se reestructura la gestión de APT para añadir todos los repositorios primero y ejecutar una única actualización de caché al final, evitando errores de "Failed to update apt cache".

0.4.6
- CORREGIDO: Añadida una tarea de limpieza para el archivo /etc/apt/sources.list para eliminar de forma robusta cualquier configuración de repositorio conflictiva.

0.5.0
- MODIFICADO: Ahora utiliza la versión del sistema operativo detectada automáticamente (ansible_distribution_release) en lugar de una LTS fija. Ideal para versiones intermedias estables.
