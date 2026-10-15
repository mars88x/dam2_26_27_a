import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/perfil.dart';
import '../services/perfiles_service.dart';
import '../theme/app_tema.dart';
import '../widgets/fondo_messend.dart';

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
  bool _ocultar = true;
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

  Widget _formulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Row(
          children: [
            Icon(Icons.chat_bubble_rounded,
                color: AppTema.principal, size: 32),
            SizedBox(width: 8),
            Text('Messend',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 40),
        const Text('Qué bueno verte.',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text(
          'Entra y vuelve a conectar con quienes te importan.',
          style: TextStyle(color: AppTema.textoSuave),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _correoController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Correo electrónico',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _contrasenaController,
          obscureText: _ocultar,
          decoration: InputDecoration(
            hintText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_ocultar
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () => setState(() => _ocultar = !_ocultar),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTema.errorSuave,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_error!, style: const TextStyle(color: AppTema.error)),
          ),
        ],
        const SizedBox(height: 24),
        if (_cargando)
          const Center(child: CircularProgressIndicator())
        else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _enviar(_auth.iniciarSesion),
              child: const Text('Login'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _enviar(_auth.registrar, esRegistro: true),
              child: const Text('Registrarse'),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoMessend(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _formulario(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}