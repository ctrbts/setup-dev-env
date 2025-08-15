# Infraestructura como Código con Ansible

Estructura del Proyecto

 - **inventory.ini**: Le dice a Ansible dónde actuar, en este caso en la propia máquina local.
 - **playbook.yml**: Le dice a Ansible qué hacer.

## Prepara tu Entorno (Solo la primera vez)

En tu máquina (la que controlará la instalación), necesitas instalar Ansible.

### Actualiza tu sistema

    sudo apt update && sudo apt upgrade -y

### Instala Ansible y dependencias necesarias para los módulos que usaremos

    sudo apt install ansible python3-pip -y
    pip3 install --user community.general
    

## Ejecuta el Playbook

Abre una terminal en la carpeta mi-workstation-ansible y ejecuta:

    ansible-playbook -i inventory.ini playbook.yml

Ansible comenzará a ejecutar las tareas una por una. Verás una salida de texto que te indica qué está haciendo en cada momento.

 - **Verde (ok)**: La tarea se ejecutó y el sistema ya estaba en el estado deseado.
 - **Amarillo (changed)**: La tarea se ejecutó y realizó un cambio en el sistema.
 - **Rojo (failed)**: La tarea falló.

La primera vez que lo ejecutes, casi todo saldrá en amarillo. Si lo vuelves a ejecutar, casi todo saldrá en verde, porque Ansible es idempotente: solo aplica cambios si son necesarios.