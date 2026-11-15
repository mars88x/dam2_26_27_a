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

## Registro - Fase 1b: emuladores, datos de prueba y consultas
* **Herramienta:** Claude
* **Parte de la tarea:** `main.dart` con `USAR_EMULADORES`, `firebase.proyecto.json`, `firestore.rules`, `firestore.indexes.json`, `tools/seed.mjs`, el campo `autorUid` en `Mensaje`, las cuatro consultas de `MensajesService` y los widgets `CuadriculaPaginada`, `BuscarMensajes` y `EstadoPantalla`.
* **Instrucción dada:** Le pasé el enunciado de la Fase 1b y el código de mi proyecto y pedí empezar por los emuladores y las consultas de Firestore.
* **Respuesta recibida:** Los ficheros de configuración de los emuladores, un script que crea 3 usuarios y 22 mensajes, y el código de la lista (snapshots con `limit`), la cuadrícula paginada con `startAfterDocument` y la búsqueda por autor y fechas con el índice compuesto.
* **Cambios realizados y motivo:** Lo probé con los emuladores en Chrome. Como el emulador de Firestore necesita Java y no lo tenía en el PATH, usé el de Android Studio (`JAVA_HOME`). Exporté los datos a `emulator-data` para poder importarlos con un comando. Revisé que la lista usa snapshots y la cuadrícula y la búsqueda usan `get`, y por qué.

## Registro - Fase 1b: editar y borrar
* **Herramienta:** Claude
* **Parte de la tarea:** `detalle_screen.dart` (editar y borrar), `actualizarTexto` y `borrar` en `MensajesService`, y `tools/probar_reglas.mjs`.
* **Instrucción dada:** Pedí editar y borrar mis propios mensajes con confirmación y estado de error, y comprobar que las reglas impiden tocar los ajenos.
* **Respuesta recibida:** Botones que solo salen en mensajes propios, un cuadro de edición que muestra el error dentro, una confirmación antes de borrar y un script que intenta editar y borrar un mensaje de otro usuario.
* **Cambios realizados y motivo:** Ejecuté el script y salieron las tres comprobaciones bien (200 al editar lo propio y 403 al editar y borrar lo ajeno). Probé en la app que en un mensaje de otra persona no salen los botones.

## Registro - Fase 1b: posición con geolocator
* **Herramienta:** Claude
* **Parte de la tarea:** `ubicacion_service.dart`, `nuevo_mensaje_screen.dart`, permisos de localización en `AndroidManifest.xml` y `ubicacion`/`fechaUbicacion` en `Mensaje`.
* **Instrucción dada:** Pedí leer la posición con `geolocator` tratando permiso denegado, GPS apagado y tiempo agotado, y guardarla como `GeoPoint` con un `Timestamp`.
* **Respuesta recibida:** Un servicio que nunca lanza excepciones y devuelve la posición o el motivo del fallo, una pantalla para escribir un mensaje con el botón de ubicación y los datos de prueba con posiciones.
* **Cambios realizados y motivo:** Probé en Chrome con el permiso concedido y bloqueado (desde el candado del navegador) y comprobé que no se queda cargando. Cada comprobación en Android la hago en el emulador.

## Registro - Fase 1b: mapa y lista cerca de mí
* **Herramienta:** Claude
* **Parte de la tarea:** `mapa_mensajes.dart`, `cercania.dart` y `trabajo_isolate.dart`.
* **Instrucción dada:** Pedí un mapa con `flutter_map` y OpenStreetMap con un marcador por mensaje, y una lista "cerca de mí" calculada en un isolate con progreso.
* **Respuesta recibida:** El mapa con marcadores, atribución y `userAgentPackageName`, y una función que calcula distancias con Haversine que se lanza con `Isolate.run` y avisa del progreso. Al releer yo el enunciado vimos que faltaba centrar el mapa en el usuario y comunicar el progreso, y se corrigió.
* **Cambios realizados y motivo:** Lo probé en Chrome y en el emulador. Entendí que en la web no hay isolates y que ordenar tan pocos documentos no lo necesita; lo dejé documentado en el README.

## Registro - Fase 1b: foto desde cámara o galería
* **Herramienta:** Claude
* **Parte de la tarea:** `foto_service.dart`, la tarjeta de foto de `nuevo_mensaje_screen.dart`, el permiso de cámara y la miniatura en lista y detalle.
* **Instrucción dada:** Pedí elegir una foto de la cámara o la galería, comprimirla en un isolate con una barra de progreso y guardarla en base64 en el documento.
* **Respuesta recibida:** `image_picker` con el permiso denegado tratado, una función que reduce la foto a 800 px y baja la calidad hasta que pesa menos de 200 KB, y el guardado como texto.
* **Cambios realizados y motivo:** Instalé `image_picker` e `image`, probé a elegir una foto y comprobé que la miniatura sale en la lista y en el detalle. Entendí por qué se comprime (límite de 1 MiB por documento) y que en la web el isolate no existe.

## Registro - Fase 1b: acceso con Google
* **Herramienta:** Claude
* **Parte de la tarea:** `auth_service.dart` (`entrarConGoogle`), el botón en `login_screen.dart` y la configuración en Firebase.
* **Instrucción dada:** Pedí entrar con Google en Android y en la web, con la cancelación y el error tratados, y crear el perfil de Firestore si la persona es nueva.
* **Respuesta recibida:** El código para web (`signInWithPopup`) y Android (`google_sign_in` y `signInWithCredential`) y los pasos para activar Google, registrar las huellas SHA y descargar `google-services.json`.
* **Cambios realizados y motivo:** Activé Google en Authentication, registré las huellas SHA-1 y SHA-256 y sustituí `google-services.json` (que no se sube al repositorio). `keytool` falló con Java en español y lo resolví poniéndolo en inglés. Probé en Chrome entrar y cancelar. En Android solo comprobé el selector de cuentas y la cancelación, porque no quise usar mi cuenta personal en el emulador.

## Registro - Fase 1b: hosting y README
* **Herramienta:** Claude
* **Parte de la tarea:** Publicación en Firebase Hosting y el README de la Fase 1b.
* **Instrucción dada:** Pedí los pasos para publicar la web con el plan gratuito y ayuda para redactar el README con los apartados que pide el enunciado.
* **Respuesta recibida:** Los comandos `flutter build web` y `firebase deploy`, y un borrador del README con las consultas, la foto, los isolates, la posición y las pruebas.
* **Cambios realizados y motivo:** Publiqué la web y comprobé que se puede registrar y usar. Revisé el README contra mi código y dejé como "Por probar" lo que aún no había comprobado.  