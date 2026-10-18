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

## Registro - Onboarding con SharedPreferences
* **Herramienta:** Claude
* **Parte de la tarea:** `screens/onboarding_screen.dart` y lógica del splash para mostrarlo solo la primera vez.
* **Instrucción dada:** Le pedí un onboarding de 3 pantallas deslizables, con opción de saltarlo, que solo aparezca la primera vez.
* **Respuesta recibida:** Una pantalla con `PageView`, botones Saltar y Siguiente/Empezar, y el uso de `shared_preferences` para guardar la clave `onboarding_visto`.
* **Cambios realizados y motivo:** Añadí `shared_preferences`, creé la pantalla, registré la ruta `/onboarding` en `MiApp.dart` y modifiqué el splash para decidir si va al onboarding o al login. Corregí un error al pegar la ruta en la zona de imports.

## Registro - AuthService con Firebase Authentication
* **Herramienta:** Claude
* **Parte de la tarea:** Servicio de autenticación en `services/auth_service.dart` (registro, inicio de sesión y cierre de sesión).
* **Instrucción dada:** Pedí ayuda para conectar el registro y el login con Firebase Authentication y para controlar los errores de correo ya en uso, contraseña débil y credenciales incorrectas.
* **Respuesta recibida:** Código de la clase `AuthService` con `registrar`, `iniciarSesion` y `cerrarSesion`, y una función que traduce los códigos de `FirebaseAuthException` a mensajes en español.
* **Cambios realizados y motivo:** Copié la clase y la revisé línea por línea. Cada método devuelve `null` si todo va bien o el texto del error, para que la pantalla solo lo muestre. Añadí `correoActual` y `uidActual` porque los necesito en Home y al crear el perfil.

## Registro - Login conectado a Firebase
* **Herramienta:** Claude
* **Parte de la tarea:** Adaptar `screens/login_screen.dart` para usar `AuthService` y mostrar los errores en pantalla.
* **Instrucción dada:** Pedí cómo llamar al servicio desde los botones Login y Registrarse sin tener código de Firebase dentro de la pantalla.
* **Respuesta recibida:** Un método `_enviar` que llama al servicio, muestra el error si lo hay y navega a `/home` si todo sale bien, con la comprobación `if (!mounted) return;` tras cada `await`.
* **Cambios realizados y motivo:** Lo integré en mi pantalla. Usé `TextEditingController` y los liberé en `dispose()` para evitar fugas de memoria. Probé a mano los tres errores pedidos.

## Registro - Firestore, colecciones y modelo Perfil
* **Herramienta:** Claude
* **Parte de la tarea:** Colecciones `perfiles` y `mensajes` en Firestore, modelo `Perfil` y `PerfilesService`.
* **Instrucción dada:** Pedí cómo estructurar las colecciones y cómo usar `withConverter` con `fromFirestore` y `toFirestore` para que los servicios devuelvan objetos tipados.
* **Respuesta recibida:** Estructura de los documentos, el modelo `Perfil` con sus conversores y `PerfilesService` con `guardar(uid, perfil)` y `obtener(uid)`.
* **Cambios realizados y motivo:** Creé a mano en la consola los documentos de prueba. Hice que el documento del perfil use el `uid` del usuario como id y que se cree al registrarse. Entendí que `edad` se lee como `num` y se convierte a `int` porque Firestore guarda los números de forma genérica.

## Registro - Lista, cuadrícula, detalle y barra inferior
* **Herramienta:** Claude
* **Parte de la tarea:** `home_screen.dart` con barra inferior de 3 secciones, `widgets/mensajes_lista.dart`, `widgets/mensajes_cuadricula.dart` y `detalle_screen.dart`.
* **Instrucción dada:** Pedí cómo mostrar los mensajes de Firestore en lista y cuadrícula con estados de carga, vacío y error, y cómo pasar un mensaje a otra pantalla por ruta con parámetros.
* **Respuesta recibida:** Código de Home con `BottomNavigationBar`, una suscripción al stream de mensajes, widgets de lista y cuadrícula, y el paso del `Mensaje` con `Navigator.pushNamed(..., arguments:)`.
* **Cambios realizados y motivo:** Cancelé la suscripción en `dispose()` y antes de cerrar sesión. Separé lista y cuadrícula en widgets propios para no llenar Home de código. Añadí la ruta `/detalle` en `MiApp.dart`.

## Registro - Cambio de nombre a Messend
* **Herramienta:** Claude
* **Parte de la tarea:** Renombrar la app en `AndroidManifest.xml`, `web/index.html` y `web/manifest.json`.
* **Instrucción dada:** Pedí qué archivos cambiar para que la app se llame Messend en Android y en el navegador.
* **Respuesta recibida:** Lista de archivos y líneas con el nombre.
* **Cambios realizados y motivo:** Cambié el texto en esos archivos y comprobé en el commit que solo cambiaba el nombre. Los avisos del análisis en esos archivos eran falsos positivos de las plantillas de Flutter.

## Registro - README y configuración de Firebase en otro equipo
* **Herramienta:** Claude
* **Parte de la tarea:** `README.md` y guía de arranque (`flutterfire configure`).
* **Instrucción dada:** Pedí ayuda para redactar el README con la estructura, la explicación del por qué, Firebase, las pruebas y los pasos para arrancar el proyecto, y para regenerar los archivos de Firebase que no están en el repositorio.
* **Respuesta recibida:** Un borrador del README, incluido el apartado "Por qué esta estructura", y los comandos de `flutterfire configure`.
* **Cambios realizados y motivo:** Revisé el texto contra mi código y lo ajusté. Lo del apartado 2 lo he leído y sé explicarlo. Probé la guía de arranque en un segundo equipo clonando el repositorio y regenerando los archivos de configuración, que están en `.gitignore`.

## Registro - Rediseño visual de la app
* **Herramienta:** Claude
* **Parte de la tarea:** Tema de la app (`theme/app_tema.dart`), `widgets/fondo_messend.dart` y el aspecto de splash, onboarding, login, Home y detalle.
* **Instrucción dada:** Mandé mi diseño de Figma y unas imágenes de referencia y pedí un estilo luminoso en azul y verde, con un fondo para las pantallas.
* **Respuesta recibida:** Un tema con la paleta, un fondo con degradado y círculos difuminados, y el código rediseñado de cada pantalla.
* **Cambios realizados y motivo:** Rechacé la primera propuesta porque no me gustaba y pedí otra con más azul y verde. Moví una línea `theme:` que había quedado fuera de `MaterialApp` y apilé los botones del login porque se desbordaban. Revisé que la lógica de las pantallas no cambiara, solo el aspecto.