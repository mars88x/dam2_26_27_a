# Messend

App de mensajería hecha con Flutter y Firebase para la Fase 1 de 2.º DAM (el arranque de la aplicación). Funciona en Android y en Chrome.

## 1. Estructura del proyecto

```
lib/
├── main.dart                 # Inicializa Firebase y arranca la app
├── MiApp.dart                # MaterialApp: tema y tabla de rutas
├── models/                   # Clases de datos con conversores de Firestore
│   ├── mensaje.dart
│   └── perfil.dart
├── services/                 # Acceso a Firebase (auth y Firestore)
│   ├── auth_service.dart
│   ├── mensajes_service.dart
│   └── perfiles_service.dart
├── screens/                  # Pantallas completas
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   └── detalle_screen.dart
└── widgets/                  # Piezas reutilizables
    ├── mensajes_lista.dart
    └── mensajes_cuadricula.dart
```

## 2. Por qué esta estructura

Separé el código en `screens`, `models` y `services` para que cada carpeta tenga una sola responsabilidad:

- **`screens`** solo se ocupa de lo que ve el usuario: formularios, botones, listas y navegación. Ninguna pantalla importa Firebase directamente; pide los datos a un servicio. Así, si cambia la forma de guardar datos, no hay que tocar la interfaz.
- **`services`** es la única capa que habla con Firebase (`AuthService` para el registro y el login, `MensajesService` y `PerfilesService` para Firestore). Tener las consultas en un solo sitio evita repetir código y hace fácil cambiar o probar una consulta sin buscarla por las pantallas. También traducen los errores de Firebase a mensajes que entiende el usuario.
- **`models`** define los datos (`Mensaje`, `Perfil`) y sabe convertirse desde y hacia Firestore con `fromFirestore` y `toFirestore`. Gracias a eso, el resto de la app trabaja con objetos tipados y no con mapas sueltos, y un error en un nombre de campo se ve al compilar, no al ejecutar.
- **`widgets`** guarda las piezas reutilizables (`MensajesLista` y `MensajesCuadricula`), para que `HomeScreen` no se llene de código de dibujo y los mismos datos se puedan mostrar de dos maneras.

Además, `MiApp.dart` concentra la tabla de rutas y `main.dart` solo inicializa Firebase y arranca la app, de modo que es fácil encontrar dónde empieza todo.

## 3. Splash y onboarding

- **Splash:** muestra el nombre y una imagen de red (`picsum.photos`) con indicador de carga y un icono de error si la imagen falla. A los 3 segundos decide a qué pantalla ir.
- **Onboarding:** 3 páginas con botón **Saltar** y botones Siguiente/Empezar. Solo se muestra la primera vez.
- **Dónde se guarda que ya se vio:** en `shared_preferences`, con la clave `onboarding_visto` (booleano). En Android queda en el almacenamiento de la app y en Chrome en el almacenamiento local del navegador, por eso en cada plataforma se ve una vez por separado.

## 4. Firebase

- Proyecto de Firebase con **Authentication** (correo y contraseña) y **Cloud Firestore**.
- **Registro e inicio de sesión** con errores controlados: correo ya en uso, contraseña débil, credenciales incorrectas y correo con formato inválido.
- Al registrarse se crea automáticamente el documento del usuario en la colección `perfiles`.
- **Cerrar sesión:** antes de salir se cancela la suscripción a Firestore (`StreamSubscription.cancel()`); también se cancela en `dispose()`.
- **Archivos de configuración que NO están en el repositorio** (están en `.gitignore`):
  - `lib/firebase_options.dart`
  - `firebase.json`
  - `android/app/google-services.json`

  Se regeneran con `flutterfire configure` (ver apartado 8).

## 5. Firestore

| Colección | Contenido | Documentos |
|-----------|-----------|------------|
| `perfiles` | Un documento por usuario (id = uid): `nombre`, `edad` | Se crea uno al registrarse; incluye usuarios de prueba |
| `mensajes` | Contenido de la app: `texto`, `autor`, `fecha` | [N] documentos de prueba |

Los modelos `Perfil` y `Mensaje` usan `withConverter` con `fromFirestore` y `toFirestore`, así los servicios devuelven objetos tipados y no mapas.

## 6. Navegación y pantallas

- Rutas con nombre en `MaterialApp`: `/splash` (inicial), `/onboarding`, `/login`, `/home`, `/detalle`.
- `/detalle` recibe el `Mensaje` como argumento con `Navigator.pushNamed(..., arguments: mensaje)` y lo lee con `ModalRoute.of(context)!.settings.arguments`.
- Barra inferior con 3 secciones: **Lista**, **Cuadrícula** y **Perfil**. Lista y cuadrícula leen `mensajes` de Firestore y muestran estados de carga, vacío ("Todavía no hay mensajes.") y error ("No se pudieron cargar los mensajes.").

## 7. Pruebas

Se probó en el emulador de Android y en Chrome. Las capturas están en el PDF de entrega.

| # | Prueba | Resultado esperado | Android | Chrome |
|---|--------|--------------------|---------|--------|
| 1 | Splash con red | Nombre, imagen de red e indicador de carga; a los 3 s pasa a la siguiente pantalla | | |
| 2 | Splash sin red | Icono de error en lugar de la imagen y la app sigue | | |
| 3 | Onboarding la primera vez | 3 páginas con opción de saltar | | |
| 4 | Onboarding la segunda vez | No vuelve a salir; va directo a Login | | |
| 5 | Registro con correo ya usado | "Ese correo ya está registrado." | | |
| 6 | Registro con contraseña débil | "La contraseña es demasiado débil (mínimo 6 caracteres)." | | |
| 7 | Login con datos incorrectos | "Correo o contraseña incorrectos." | | |
| 8 | Registro válido | Entra a Home y se crea el documento en `perfiles` | | |
| 9 | Login válido | Entra a Home y el correo aparece en Perfil | | |
| 10 | Lista de mensajes | Se ven los mensajes de Firestore | | |
| 11 | Cuadrícula de mensajes | Se ven los mismos mensajes en cuadrícula | | |
| 12 | Detalle | Al tocar un mensaje se abre `/detalle` con texto, autor y fecha | | |
| 13 | Cerrar sesión | Vuelve a Login y se cancela la suscripción | | |

**Diferencias entre Android y Chrome:** [anotar después de probar]

Test automático: `flutter test`.

## 8. Guía de arranque

Requisitos: Flutter 3.47 o superior, Android Studio o VS Code, Node.js y una cuenta de Firebase con acceso al proyecto.

```
git clone https://github.com/mars88x/dam2_26_27_a.git
cd dam2_26_27_a
flutter pub get
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure      # elige el proyecto, plataformas android y web
flutter run -d chrome      # o elige un emulador Android
```

`flutterfire configure` genera los tres archivos que no están en el repositorio.

## 9. Uso de IA

El registro de uso de IA está en [IA.md](IA.md).
