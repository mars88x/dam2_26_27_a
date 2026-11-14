import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

// Cómo terminó el acceso con Google: bien, cancelado por el usuario o con error.
class ResultadoGoogle {
  final bool cancelado;
  final String? error;
  const ResultadoGoogle.ok()
      : cancelado = false,
        error = null;
  const ResultadoGoogle.cancelado()
      : cancelado = true,
        error = null;
  const ResultadoGoogle.error(String this.error) : cancelado = false;
  bool get esOk => !cancelado && error == null;
}

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  String? get correoActual => FirebaseAuth.instance.currentUser?.email;
  String? get uidActual => FirebaseAuth.instance.currentUser?.uid;
  String? get nombreActual => FirebaseAuth.instance.currentUser?.displayName;
  // Devuelve null si todo va bien, o el mensaje de error para mostrar.
  Future<String?> registrar(String correo, String contrasena) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensajeDeError(e.code);
    }
  }

  Future<String?> iniciarSesion(String correo, String contrasena) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensajeDeError(e.code);
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
    // Para que la próxima vez deje elegir cuenta y no entre sola con la anterior.
    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Si nunca se entró con Google no hay nada que cerrar.
      }
    }
  }

  static bool _googleIniciado = false;

  // Entrar con Google. No lanza nunca: devuelve ok, cancelado o el error.
  //  - Web: Firebase abre una ventana emergente con las cuentas de Google.
  //  - Android: el plugin google_sign_in enseña las cuentas del dispositivo y
  //    entrega un token que Firebase cambia por una sesión. Necesita la huella
  //    SHA-1 de la app registrada en Firebase (ver README).
  Future<ResultadoGoogle> entrarConGoogle() async {
    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        if (!_googleIniciado) {
          // El cliente OAuth web se lee de google-services.json (que no está
          // en el repositorio), por eso no hay ningún id escrito aquí.
          await GoogleSignIn.instance.initialize();
          _googleIniciado = true;
        }
        final cuenta = await GoogleSignIn.instance.authenticate();
        final idToken = cuenta.authentication.idToken;
        if (idToken == null) {
          return const ResultadoGoogle.error(
              'Google no devolvió la credencial. Inténtalo de nuevo.');
        }
        await _auth.signInWithCredential(
            GoogleAuthProvider.credential(idToken: idToken));
      }
      return const ResultadoGoogle.ok();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const ResultadoGoogle.cancelado();
      }
      return const ResultadoGoogle.error(
          'No se pudo entrar con Google. Comprueba la conexión e inténtalo de nuevo.');
    } on FirebaseAuthException catch (e) {
      // En la web, cerrar la ventana emergente cuenta como cancelar.
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return const ResultadoGoogle.cancelado();
      }
      if (e.code == 'popup-blocked') {
        return const ResultadoGoogle.error(
            'El navegador ha bloqueado la ventana de Google. Permite las ventanas emergentes e inténtalo de nuevo.');
      }
      if (e.code == 'network-request-failed') {
        return const ResultadoGoogle.error(
            'Sin conexión. Comprueba tu red e inténtalo de nuevo.');
      }
      return const ResultadoGoogle.error(
          'No se pudo entrar con Google. Inténtalo de nuevo.');
    } catch (_) {
      return const ResultadoGoogle.error(
          'No se pudo entrar con Google. Inténtalo de nuevo.');
    }
  }

  String _mensajeDeError(String codigo) {
    switch (codigo) {
      case 'email-already-in-use':
        return 'Ese correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña es demasiado débil (mínimo 6 caracteres).';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Correo o contraseña incorrectos.';
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      default:
        return 'Ha ocurrido un error. Inténtalo de nuevo.';
    }
  }
}