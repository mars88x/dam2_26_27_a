import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

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