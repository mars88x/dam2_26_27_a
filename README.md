# Messend

App de mensajería hecha con Flutter y Firebase para 2.º de DAM. La Fase 1 fue el arranque de la aplicación; la **Fase 1b** (este README) añade acceso con Google, consultas de Firestore, editar y borrar, foto, posición, mapa, emuladores y hosting. Funciona en Android y en Chrome.

**Versión publicada:** https://prueba1-22fe9.web.app

## 1. Estructura del proyecto

```
lib/
├── main.dart                 # Inicializa Firebase (y los emuladores si se pide)
├── MiApp.dart                # MaterialApp: tema y tabla de rutas
├── theme/
│   └── app_tema.dart         # Colores y estilos de toda la app
├── models/                   # Clases de datos con conversores de Firestore
│   ├── mensaje.dart
│   └── perfil.dart
├── services/                 # Todo lo que habla con Firebase o con el dispositivo
│   ├── auth_service.dart         # Correo/contraseña y Google
│   ├── mensajes_service.dart     # Las consultas de Firestore
│   ├── perfiles_service.dart
│   ├── ubicacion_service.dart    # geolocator con sus fallos tratados
│   ├── foto_service.dart         # image_picker y la compresión
│   ├── cercania.dart             # Distancias (se ejecuta en un isolate)
│   └── trabajo_isolate.dart      # Lanza una tarea en un isolate y reenvía el progreso
├── screens/                  # Pantallas completas
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── detalle_screen.dart
│   └── nuevo_mensaje_screen.dart
└── widgets/                  # Piezas reutilizables
    ├── fondo_messend.dart
    ├── estado_pantalla.dart
    ├── mensajes_lista.dart
    ├── mensajes_cuadricula.dart
    ├── cuadricula_paginada.dart
    ├── buscar_mensajes.dart
    └── mapa_mensajes.dart
tools/
├── seed.mjs                  # Carga los datos de prueba en los emuladores
└── probar_reglas.mjs         # Comprueba que las reglas niegan lo ajeno
emulator-data/                # Datos de prueba exportados de los emuladores
firebase.proyecto.json        # Emuladores, reglas, índices y hosting
firestore.rules
firestore.indexes.json
```

## 2. Por qué esta estructura

Separé el código en `screens`, `models` y `services` para que cada carpeta tenga una sola responsabilidad:

- **`screens`** solo se ocupa de lo que ve el usuario: formularios, botones, listas y navegación. Ninguna pantalla importa Firebase directamente; pide los datos a un servicio. Así, si cambia la forma de guardar datos, no hay que tocar la interfaz.
- **`services`** es la única capa que habla con Firebase o con el dispositivo (ubicación, cámara). Tener las consultas en un solo sitio evita repetir código y hace fácil cambiar una consulta sin buscarla por las pantallas. También traducen los errores a mensajes que entiende el usuario.
- **`models`** define los datos (`Mensaje`, `Perfil`) y sabe convertirse desde y hacia Firestore con `fromFirestore` y `toFirestore`. Así el resto de la app trabaja con objetos tipados y no con mapas sueltos.
- **`widgets`** guarda las piezas reutilizables, para que `HomeScreen` no se llene de código de dibujo.
- **`theme`** reúne los colores y los estilos en un solo archivo.

Las tareas pesadas (`comprimirFoto` y `ordenarPorDistancia`) son funciones sueltas, sin pantalla ni Firebase dentro, porque eso es lo que permite mandarlas a un isolate (apartado 9).

## 3. Splash y onboarding

- **Splash:** muestra el nombre y una imagen de red (`picsum.photos`) con indicador de carga y un icono de error si la imagen falla. A los 3 segundos decide a qué pantalla ir.
- **Onboarding:** 3 páginas con botón **Saltar** y botones Siguiente/Empezar. Solo se muestra la primera vez.
- **Dónde se guarda que ya se vio:** en `shared_preferences`, con la clave `onboarding_visto`. En Chrome depende del puerto de `localhost`, por eso si el puerto cambia el onboarding puede salir otra vez.

## 4. Firebase y acceso con Google

**Qué hay que activar en un proyecto de Firebase propio:**

1. **Authentication:** métodos de acceso *Correo electrónico/contraseña* y *Google*.
2. **Cloud Firestore:** crear la base de datos. Las reglas y el índice se suben con `firebase deploy --only firestore --config firebase.proyecto.json`.
3. **Hosting:** solo si se quiere publicar la web (apartado 11).

**Acceso con Google** (`AuthService.entrarConGoogle`):

- **Web:** `signInWithPopup(GoogleAuthProvider())`, sin ningún paquete extra.
- **Android:** el paquete `google_sign_in` enseña las cuentas del dispositivo y devuelve un token que `signInWithCredential` cambia por una sesión de Firebase.
- **Cancelar:** si el usuario cierra la ventana o el selector, la app muestra "Has cancelado el acceso con Google." y se queda en el login. No se trata como un error.
- **Errores:** ventana bloqueada, falta de conexión y cualquier otro fallo tienen su mensaje.
- **Perfil:** tras entrar se busca el documento `perfiles/{uid}`; si no existe (persona nueva) se crea con el nombre de la cuenta de Google, y si ya existía se deja como estaba.

**Huellas SHA y cliente OAuth:**

- Para Google en Android, Firebase necesita las huellas **SHA-1 y SHA-256** del certificado con el que se firma la app. En desarrollo es el certificado de depuración de cada ordenador, así que **hay que registrar las huellas del equipo en el que se ejecuta**: yo registré las de mi PC en Firebase (Configuración del proyecto > Tus apps > Android > Añadir huella digital). Las huellas no son secretas.
- Para sacarlas en Windows: `& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" '-J-Duser.language=en' '-J-Duser.country=US' -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android` (con Java en español `keytool` falla al imprimir el certificado; la opción lo pone en inglés).
- Al activar Google, Firebase crea un **cliente OAuth web** y un cliente OAuth de Android por cada huella. Tras registrar las huellas hay que **descargar de nuevo `google-services.json`**, que es donde viajan esos clientes. El plugin lee de ahí el identificador del cliente web, por eso no hay ningún identificador escrito en el código.
- Archivos de configuración que **no están en el repositorio** (están en `.gitignore`, líneas `/lib/firebase_options.dart`, `/firebase.json` y `/android/app/google-services.json`):
  - `lib/firebase_options.dart`
  - `firebase.json`
  - `android/app/google-services.json`

  Se regeneran con `flutterfire configure` (apartado 12). Una clave subida a GitHub es una clave quemada, por eso no se suben.

## 5. Firestore

| Colección | Contenido | Documentos |
|-----------|-----------|------------|
| `perfiles` | Un documento por usuario (id = uid): `nombre`, `edad` | 3 de prueba en los emuladores; se crea uno al registrarse o al entrar con Google |
| `mensajes` | `texto`, `autor`, `autorUid`, `fecha` y, si los tiene, `ubicacion` (GeoPoint), `fechaUbicacion` (Timestamp) y `foto` (texto base64) | 22 de prueba, 16 con posición |

Los modelos usan `withConverter` con `fromFirestore` y `toFirestore`. Los campos nuevos son opcionales, así que los mensajes antiguos (sin `autorUid`, sin posición, sin foto) se leen igual.

**Reglas** (`firestore.rules`):

- Leer `mensajes` y `perfiles`: cualquiera con sesión.
- Crear un mensaje: solo con tu propio `autorUid`.
- Editar o borrar un mensaje: solo su autor, y nadie puede cambiar de quién es.
- Cada usuario solo escribe su propio perfil.

## 6. Consultas: cuál usa snapshots y cuál `get`, y por qué

| Pantalla | Consulta | Tipo | Por qué |
|----------|----------|------|---------|
| Lista | `orderBy('fecha', descending)` + `limit(10)` | **snapshots** | Son los últimos mensajes: es lo que más cambia y lo que el usuario espera ver aparecer solo. |
| Cuadrícula | `orderBy` + `limit(8)` + `startAfterDocument` (paginación con botón "Cargar más") | **get** | Cada página es una petición única. Escuchar varias páginas a la vez mantendría varias suscripciones abiertas y cobrando lecturas cada vez que algo cambia en páginas que ni se están viendo. |
| Buscar (mis mensajes) | `where('autorUid' ==)` + `where('fecha' >=)` + `where('fecha' <)` | **get** | Es una pregunta puntual con filtros; si el resultado cambia, el usuario vuelve a buscar. |
| Buscar (solo fechas) | rango sobre `fecha` | **get** | Igual que la anterior. |
| Mapa | los 100 últimos y se filtran los que tienen posición | **get** | Se pinta una vez y se recarga al volver del detalle. |

Escucharlo todo siempre no es una decisión, es no haberla tomado: solo la lista tiene sentido en tiempo real.

El **índice compuesto** que necesita la búsqueda por autor y fecha (`autorUid` ascendente + `fecha` descendente) está declarado en `firestore.indexes.json`, no creado a mano en la consola. La consulta por solo fechas no necesita índice propio.

## 7. Editar y borrar

- En el detalle, los botones **Editar** y **Borrar** solo salen en los mensajes propios.
- Editar abre un cuadro con el texto: se guarda con `update`; si falla, el error se ve dentro del cuadro y no se cierra.
- Borrar pide confirmación y usa `delete`; si falla, se avisa y el mensaje sigue.
- Las **reglas** lo impiden aunque la interfaz no lo ofrezca: `tools/probar_reglas.mjs` entra como Ana e intenta editar y borrar un mensaje de Luis; las dos operaciones devuelven 403 (y editar uno propio, 200).

## 8. Foto y por qué se comprime

- En **Nuevo mensaje** hay dos botones: **Cámara** y **Galería** (`image_picker`). En el navegador abre la cámara que haya o el selector de archivos.
- **Permisos:** el permiso `CAMERA` está declarado en `AndroidManifest.xml` y se pide al hacer la foto. Si se deniega, sale un mensaje que dice qué hacer (activarlo en los ajustes o elegir de la galería) y un botón a los ajustes de la app.
- **Compresión:** la foto original (una cámara de móvil da varios megabytes) se reduce a un máximo de 800 píxeles de lado y se codifica como JPEG bajando la calidad hasta que pesa menos de 200 KB. Va en un **isolate** con una barra de progreso (apartado 9).
- **Guardado:** la miniatura se guarda como texto **base64** en el campo `foto` del propio documento y se ve en la lista y en el detalle.
- **Por qué se comprime antes:** un documento de Firestore no puede pasar de **1 MiB**, y el base64 ocupa un tercio más que la imagen. Una foto sin reducir no cabría, y aunque cupiera, cada vez que se leyera el mensaje se descargaría entera. Con 200 KB en bytes (unos 267 KB en base64) queda por debajo de los 300 KB pedidos y muy lejos del límite. Para fotos de verdad lo correcto sería Cloud Storage y guardar solo la dirección, pero eso necesita el plan Blaze y esta fase es con herramientas gratuitas.

## 9. Isolates: qué se hizo, qué no y por qué

`trabajo_isolate.dart` lanza una función en otro isolate con `Isolate.run` y reenvía su progreso a la pantalla por un `SendPort`.

**Qué va en un isolate:**

- **Comprimir la foto** (`comprimirFoto`): decodificar una foto de cámara y volver a codificarla es trabajo de procesador de varios segundos. Hecho en el hilo de la interfaz, la pantalla se congelaría. Con el isolate la barra de progreso sigue avanzando y se puede mover la pantalla mientras dura.
- **Ordenar por distancia** (`ordenarPorDistancia`): calcula la distancia de cada mensaje a mi posición (fórmula de Haversine) y los ordena.

**Qué no va:**

- Las lecturas de Firestore: son entrada/salida asíncrona y no bloquean el hilo, no ganan nada con un isolate.
- Filtrar los mensajes con posición y pintar el mapa: son pocos datos y el dibujo tiene que hacerse en el hilo de la interfaz.

**Por qué ordenar veinte documentos no lo necesita:** con 16 mensajes con posición el cálculo es mínimo, y arrancar un isolate cuesta más que el propio cálculo. Lo hice para medirlo y saberlo: la pantalla "Cerca de mí" enseña cuánto tarda cada ejecución. El patrón sirve cuando son miles de puntos; con estos datos no se nota.

**Limitación en la web:** los navegadores no tienen isolates como Android. En Chrome, `correrConProgreso` ejecuta la tarea en el mismo hilo, así que mientras comprime la pantalla se queda quieta. Para repartir el trabajo allí harían falta *web workers*, que quedan fuera de esta fase. La comprobación de "mover la pantalla durante la compresión" se hace en Android.

## 10. Posición y mapa

**Posición (`UbicacionService`):** se pide cuando el usuario pulsa **Añadir mi ubicación** (o al abrir la pestaña Mapa), no al arrancar la app. Los tres fallos están tratados y ninguno deja la pantalla colgada:

- **Permiso denegado:** mensaje que explica qué hacer y botón **Reintentar**. Si Android lo bloquea para siempre, botón a los ajustes de la app.
- **GPS apagado:** mensaje y botón que abre los ajustes de ubicación del dispositivo.
- **Tiempo agotado:** a los 15 segundos sin posición se corta y se avisa.

La posición se guarda como `GeoPoint` junto con un `Timestamp` de cuándo se leyó (`fechaUbicacion`), y se lee de vuelta tipada en el modelo.

**Mapa (`MapaMensajes`):** `flutter_map` sobre teselas de OpenStreetMap, centrado en el usuario, un marcador por cada mensaje con posición (al tocarlo se abre el detalle), la atribución "© OpenStreetMap contributors" siempre visible y `userAgentPackageName` puesto, como exige la política de uso de OpenStreetMap. Si no se pudo leer la posición, el mapa se ajusta para ver todos los pines y avisa del motivo. La pestaña también tiene la lista **Cerca de mí**, ordenada por distancia con el cálculo en un isolate (apartado 9).

**Comparación de las tecnologías de localización del dispositivo:**

- **GPS (satélites).** Es la más precisa: de 3 a 10 metros al aire libre. Pero tarda en obtener la primera posición (en frío, decenas de segundos), apenas funciona dentro de edificios y es la que más batería gasta. Conviene cuando la precisión importa y el usuario está fuera: navegación, rutas, deporte.
- **Red (antenas móviles y wifi).** Estima la posición por las antenas y los puntos wifi cercanos. Responde casi al instante, funciona dentro de edificios y gasta muy poca batería, pero la precisión es mala: de decenas de metros a varios kilómetros según la zona. Sirve para saber en qué ciudad o barrio está alguien: tiempo, tiendas cercanas.
- **Proveedor combinado (Fused).** Es la API de los servicios de Google Play: mezcla GPS, red y los sensores del móvil y decide sola cuál usar según la precisión pedida y la batería. Da una buena precisión con menos consumo que el GPS puro y es la opción recomendada en Android. Su pega es que depende de los servicios de Google Play, que no están en todos los dispositivos.

`geolocator` usa el proveedor combinado cuando está disponible y recurre a los servicios de ubicación del sistema si no. Yo pido precisión alta (`LocationAccuracy.high`) porque la posición se guarda con el mensaje y se dibuja en un mapa, donde un error de varios kilómetros se vería. Si solo hiciera falta saber la ciudad, bastaría la precisión baja, que gasta menos. En el navegador la posición viene de la API de geolocalización, que solo funciona en `https` o en `localhost`, y por eso la versión publicada va con https.

## 11. Emuladores, datos de prueba y hosting

**Emuladores de Auth y Firestore.** La app se conecta a ellos solo si se arranca con `--dart-define=USAR_EMULADORES=true`; sin esa opción habla con el Firebase real. En el emulador de Android se usa `10.0.2.2` para llegar al PC, en Chrome `localhost`. El manifiesto de debug permite tráfico `http` porque los emuladores no usan https.

Necesitan **Java** (el emulador de Firestore lo usa). En Windows, si no está en el PATH, se puede usar el de Android Studio:

```
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
```

```
firebase emulators:start --config firebase.proyecto.json --project prueba1-22fe9 --import=emulator-data
flutter run -d chrome --dart-define=USAR_EMULADORES=true
```

Con **un solo comando** se arrancan los emuladores con los datos de `emulator-data/` (22 mensajes y 3 usuarios). Usuarios de prueba: `ana@prueba.com`, `luis@prueba.com` y `marta@prueba.com`, contraseña `123456`. Para volver a generar los datos desde cero: arrancar los emuladores y, desde `tools`, `node seed.mjs prueba1-22fe9` (no hace falta `npm install`). Para exportar los cambios al cerrar, añadir `--export-on-exit=emulator-data`. La interfaz de los emuladores está en http://127.0.0.1:4000.

**Probar las reglas** (con los emuladores en marcha y los datos cargados): desde `tools`, `node probar_reglas.mjs prueba1-22fe9`. Debe dar tres líneas `OK`.

**Hosting** (plan gratuito, sin tarjeta):

```
flutter build web
firebase deploy --only hosting,firestore --config firebase.proyecto.json --project prueba1-22fe9
```

La web publicada usa el Firebase real, no los emuladores, así que los usuarios de prueba no existen allí: hay que registrarse o entrar con Google.

## 12. Pruebas de la Fase 1b

Probado en el emulador de Android (Pixel 8, API 37) y en Chrome. Las capturas están en el PDF de entrega.

| # | Prueba | Resultado esperado | Android | Chrome |
|---|--------|--------------------|---------|--------|
| 1 | Arrancar con los emuladores | Se ven los datos de `emulator-data` y el aviso "Running in emulator mode" | Por probar | Bien |
| 2 | Lista (snapshots + limit) | Salen los 10 últimos mensajes | Por probar | Bien |
| 3 | Cuadrícula paginada | 8 mensajes; "Cargar más" llega a 22 y aparece "No hay más mensajes" | Por probar | Bien |
| 4 | Buscar: solo mis mensajes y fechas | Salen solo los del autor y/o del rango; rango sin mensajes, "Sin resultados." | Por probar | Bien |
| 5 | Editar un mensaje propio | Cambia el texto y se ve al volver | Por probar | Bien |
| 6 | Borrar con confirmación | Pide confirmación; al aceptar desaparece | Por probar | Bien |
| 7 | Editar o borrar un mensaje ajeno | No salen los botones; las reglas devuelven 403 (`probar_reglas.mjs`) | Por probar | Bien |
| 8 | Añadir ubicación, permiso concedido | Salen las coordenadas y la precisión; el mensaje se guarda con `GeoPoint` | Bien | Bien |
| 9 | Añadir ubicación, permiso denegado | Mensaje que dice qué hacer y botón Reintentar; no se cuelga | Por probar | Bien |
| 10 | GPS apagado | Mensaje y botón de ajustes; no se cuelga | Por probar | No aplica |
| 11 | Foto desde la galería y comprimida | Barra de progreso; miniatura de menos de 200 KB; se ve en lista y detalle | Por probar | Por probar |
| 12 | Cámara con permiso denegado | Mensaje que dice qué hacer | Por probar | No aplica |
| 13 | Mover la pantalla durante la compresión | La interfaz no se congela | Por probar | No aplica (la web no tiene isolates) |
| 14 | Mapa centrado, marcadores y detalle | Marcadores de los mensajes con posición, atribución visible, tocar abre el detalle | Por probar | Bien |
| 15 | Cerca de mí | Lista ordenada por distancia con progreso y tiempo | Por probar | Bien |
| 16 | Google: entrar | Entra y se crea el perfil la primera vez | Solo se probó el selector | Bien |
| 17 | Google: cancelar | "Has cancelado el acceso con Google." | Bien | Bien |
| 18 | Sin conexión | La pantalla muestra el estado de error con botón Reintentar | Por probar | Por probar |
| 19 | Web publicada | Se puede registrar, entrar y usar la app en https://prueba1-22fe9.web.app | No aplica | Bien |

Las filas marcadas "Por probar" son las que aún no he comprobado en esa plataforma; las actualizo antes de entregar. La fila 16 en Android **no está verificada de principio a fin**: no quise iniciar sesión con mi cuenta personal en el emulador, así que solo comprobé que aparece el botón, que se abre el selector de cuentas y que cancelar funciona.

**Diferencias entre Android y Chrome:**

- **Isolates:** en Android la compresión no congela la pantalla; en Chrome no hay isolates y sí se queda quieta unos instantes.
- **Permisos:** en Android el permiso de ubicación y el de cámara salen como avisos del sistema; en Chrome los gestiona el navegador y Chrome los recuerda por origen, y como Flutter arranca la web en un puerto distinto cada vez, a veces vuelve a preguntar.
- **Cámara en Chrome:** abre la cámara que haya o el selector de archivos, según el navegador.

## 13. Guía de arranque

Requisitos: Flutter 3.47 o superior, Android Studio o VS Code, Node.js, Java 21 o superior (para los emuladores) y una cuenta de Firebase con acceso al proyecto.

```
git clone https://github.com/mars88x/dam2_26_27_a.git
cd dam2_26_27_a
flutter pub get
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure      # elige el proyecto, plataformas android y web
```

`flutterfire configure` genera `lib/firebase_options.dart` y `firebase.json`. El tercer archivo, `android/app/google-services.json`, se descarga de la consola de Firebase (Configuración del proyecto > Tus apps > Android), después de registrar las huellas SHA de tu equipo (apartado 4).

**Para probar sin tocar el Firebase real** (recomendado): arranca los emuladores con el comando del apartado 11 y, en otra terminal:

```
flutter run -d chrome --dart-define=USAR_EMULADORES=true
```

Para Android, la misma línea sin `-d chrome` y con el emulador abierto.

**Si falla en Android (Windows):** si el proyecto está en una unidad (por ejemplo `D:`) y la caché de Flutter en otra (`C:`), Gradle puede dar un error de Kotlin sobre las *incremental caches*. Se arregla añadiendo `kotlin.incremental=false` al archivo `%USERPROFILE%\.gradle\gradle.properties`, y después `flutter clean` y `flutter pub get`.

## 14. Uso de IA

El registro de uso de IA está en [IA.md](IA.md).
