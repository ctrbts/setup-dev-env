## 1. Generar una nueva clave SSH

Primero, necesitas crear un par de claves SSH (una pública y una privada) en tu computadora.

Abre una terminal o Git Bash en tu computadora.

Pega el siguiente comando, reemplazando "tu_email@ejemplo.com" con el correo electrónico asociado a tu cuenta de GitHub.

```Bash
ssh-keygen -t ed25519 -C "tu_email@ejemplo.com"
```

Cuando te pregunte "Enter a file in which to save the key," simplemente presiona Enter para aceptar la ubicación por defecto.

Luego, te pedirá que crees una contraseña (passphrase) para tu clave SSH. Esto es opcional pero altamente recomendado para mayor seguridad. Si la configuras, deberás ingresarla cada vez que uses la clave.

Esto generará dos archivos en una carpeta oculta .ssh dentro de tu directorio de usuario: id_ed25519 (tu clave privada, ¡no la compartas!) y id_ed25519.pub (tu clave pública).

## 2. Añadir tu clave SSH al ssh-agent
El ssh-agent es un programa que gestiona tus claves SSH y recuerda tu contraseña si estableciste una.

Inicia el ssh-agent en segundo plano con el siguiente comando:

```Bash
eval "$(ssh-agent -s)"
```

Añade tu clave SSH privada al ssh-agent.

```Bash
ssh-add ~/.ssh/id_ed25519
```

## 3. Añadir tu clave pública a GitHub

Ahora necesitas decirle a GitHub cuál es tu clave pública para que reconozca tu computadora.

Copia el contenido de tu clave pública. Puedes usar el siguiente comando para mostrarla en la terminal y copiarla fácilmente.

```Bash
cat ~/.ssh/id_ed25519.pub
```

Ve a tu cuenta de GitHub.

Haz clic en tu foto de perfil en la esquina superior derecha y selecciona Settings.

En el menú de la izquierda, haz clic en SSH and GPG keys.

Haz clic en el botón verde New SSH key.

Dale un título descriptivo a tu clave (por ejemplo, "Mi Laptop de Trabajo").

Pega tu clave pública (la que copiaste del terminal) en el campo Key.

Finalmente, haz clic en Add SSH key. Es posible que te pida tu contraseña de GitHub para confirmar.

## 4. Probar la conexión y clonar un repositorio
Para asegurarte de que todo funciona correctamente, puedes probar la conexión a GitHub.

Abre tu terminal y ejecuta:

```Bash
ssh -T git@github.com
```

Es posible que veas una advertencia sobre la autenticidad del host. Escribe yes y presiona Enter.

Si todo está correcto, verás un mensaje como: Hi tu-usuario! You've successfully authenticated, but GitHub does not provide shell access. ¡Esto significa que funcionó! 🎉

Ahora, para clonar un repositorio, asegúrate de usar la URL SSH en lugar de la HTTPS. En la página del repositorio de GitHub, haz clic en el botón verde Code y selecciona la opción SSH. La URL debería empezar con git@github.com:.

Usa esa URL para clonar:

```Bash
git clone git@github.com:nombre-de-usuario/nombre-del-repositorio.git
```

¡Y listo! Ya no te pedirá la contraseña de GitHub para clonar, hacer push o pull desde tus repositorios.