## Registro - Creación de estructura modular y LoginScreen
* **Herramienta:** Gemini
* **Parte de la tarea:** Solución al problema de carpetas vacías en Git y modularización de la pantalla de Login en `screens/login_screen.dart`.
* **Instrucción dada:** Captura del panel de Commit indicando "Select files to commit" con las carpetas de `lib/` creadas.
* **Respuesta recibida:** Pasos para crear los archivos dentro de las carpetas para que Git detecte los cambios y código de `login_screen.dart` y `MiApp.dart`.
* **Cambios realizados y motivo:** Creación de`login_screen.dart` y actualización de `MiApp.dart` para registrar la estructura modular en Git.

## Registro - Limpieza de main.dart y test del login
* **Herramienta:** Claude
* **Parte de la tarea:** Dejar `main.dart` limpio y actualizar el test para que compruebe el login.
* **Instrucción dada:** Le pasé el contenido de `main.dart` y de `widget_test.dart` y le pregunté qué más tenía que cambiar antes de hacer el push.
* **Respuesta recibida:** Me dijo que `runApp( MiApp )` debía ser `runApp(const MiApp())` y que el test seguía usando `MyApp` y el contador, que ya no existían. Me dio el código de un test nuevo.
* **Cambios realizados y motivo:** Borré `MyApp` y `MyHomePage` de `main.dart`, corregí `runApp` y sustituí el test por uno que comprueba que aparecen los textos LOGIN y Registrarse.

## Registro - Modelo de datos
* **Herramienta:** Claude
* **Parte de la tarea:** Modelo de datos de la app.
* **Instrucción dada:** Pregunte por que crear en modulos.
* **Respuesta recibida:** Me propuso una clase `Mensaje` con texto, autor y fecha.
* **Cambios realizados y motivo:** Creé `mensaje.dart` con la clase `Mensaje`.

## Registro - Splash con imagen de red
* **Herramienta:** Claude
* **Parte de la tarea:** `screens/splash_screen.dart` y ruta `/splash` en `MiApp.dart`.
* **Instrucción dada:** Le pedí una pantalla de inicio con una imagen de una URL, con estado de carga y de error.
* **Respuesta recibida:** Un `Image.network` con `loadingBuilder` y `errorBuilder`, y un `Timer` que pasa al login a los 3 segundos.
* **Cambios realizados y motivo:** Creé la pantalla y cambié la imagen por `https://picsum.photos/300` porque la anterior era de Pinterest y podía dejar de funcionar. Actualicé el test para el flujo splash a login.