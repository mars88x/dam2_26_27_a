import 'dart:async';
import 'package:flutter/material.dart';
import '../models/mensaje.dart';
import '../services/auth_service.dart';
import '../services/mensajes_service.dart';
import '../widgets/mensajes_lista.dart';
import '../widgets/mensajes_cuadricula.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _mensajesService = MensajesService();
  final _auth = AuthService();
  StreamSubscription<List<Mensaje>>? _suscripcion;
  List<Mensaje>? _mensajes;
  Object? _error;
  int _seccion = 0;

  @override
  void initState() {
    super.initState();
    _suscripcion = _mensajesService.escuchar().listen(
          (datos) => setState(() {
        _mensajes = datos;
        _error = null;
      }),
      onError: (e) => setState(() => _error = e),
    );
  }

  @override
  void dispose() {
    _suscripcion?.cancel(); // se cierra la suscripción al destruir la pantalla
    super.dispose();
  }

  Future<void> _cerrarSesion() async {
    await _suscripcion?.cancel();
    await _auth.cerrarSesion();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Gestiona los estados de error, carga y vacío para lista y cuadrícula.
  Widget _conEstados(Widget Function(List<Mensaje>) construir) {
    if (_error != null) {
      return const Center(child: Text('No se pudieron cargar los mensajes.'));
    }
    if (_mensajes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_mensajes!.isEmpty) {
      return const Center(child: Text('Todavía no hay mensajes.'));
    }
    return construir(_mensajes!);
  }

  @override
  Widget build(BuildContext context) {
    final secciones = [
      _conEstados((m) => MensajesLista(mensajes: m)),
      _conEstados((m) => MensajesCuadricula(mensajes: m)),
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, size: 80),
            Text(_auth.correoActual ?? 'Sin sesión'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cerrarSesion,
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Messend')),
      body: secciones[_seccion],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _seccion,
        onTap: (i) => setState(() => _seccion = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lista'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Cuadrícula'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}