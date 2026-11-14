import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'MiApp.dart';

// Se activa al compilar, nunca a mano:
//   flutter run --dart-define=USAR_EMULADORES=true
// Sin la bandera, la app habla con el Firebase real.
const bool usarEmuladores = bool.fromEnvironment('USAR_EMULADORES');

// Solo hace falta si pruebas en un móvil físico (la IP de tu PC).
const String _hostManual = String.fromEnvironment('HOST_EMULADORES');

// El emulador de Android ve el PC en 10.0.2.2; Chrome y el resto, en localhost.
String _hostEmuladores() {
  if (_hostManual.isNotEmpty) return _hostManual;
  if (kIsWeb) return 'localhost';
  return defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : 'localhost';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (usarEmuladores) {
    final host = _hostEmuladores();
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    debugPrint('Messend usa los emuladores de Firebase en $host');
  }
  runApp(const MiApp());
}
