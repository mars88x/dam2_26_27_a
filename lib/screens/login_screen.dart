import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/perfil.dart';
import '../services/perfiles_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _auth = AuthService();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

   Future<void> _enviar(
      Future<String?> Function(String, String) accion, {
        bool esRegistro = false,
      }) async {
    final correo = _correoController.text.trim();
    final contrasena = _contrasenaController.text;

    if (correo.isEmpty || contrasena.isEmpty) {
      setState(() => _error = 'Rellena el correo y la contraseña.');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    final error = await accion(correo, contrasena);
    if (!mounted) return;

    if (error == null) {
      if (esRegistro) {
        await PerfilesService().guardar(
          _auth.uidActual!,
          Perfil(nombre: correo.split('@').first, edad: 0),
        );
        if (!mounted) return;
      }
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _cargando = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Messend")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "LOGIN",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "Correo electrónico",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contrasenaController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Contraseña",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            if (_cargando)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _enviar(_auth.iniciarSesion),
                    child: const Text("Login"),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => _enviar(_auth.registrar, esRegistro: true),
                    child: const Text("Registrarse"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}