import 'dart:async';
import 'package:flutter/material.dart';
import '../models/mensaje.dart';
import '../services/auth_service.dart';
import '../services/mensajes_service.dart';
import '../widgets/mensajes_lista.dart';
import '../widgets/mensajes_cuadricula.dart';
import '../theme/app_tema.dart';
import '../widgets/fondo_messend.dart';

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
  String get _iniciales {
    final correo = _auth.correoActual ?? '?';
    return correo.substring(0, correo.length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _estado(IconData icono, String titulo, String texto) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTema.lavanda,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icono, size: 48, color: AppTema.principal),
            ),
            const SizedBox(height: 24),
            Text(titulo,
                textAlign: TextAlign.center,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(texto,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTema.textoSuave)),
          ],
        ),
      ),
    );
  }

  // Gestiona los estados de error, carga y vacío para lista y cuadrícula.
  Widget _conEstados(Widget Function(List<Mensaje>) construir) {
    if (_error != null) {
      return _estado(
        Icons.cloud_off,
        'No se pudieron cargar los mensajes.',
        'Parece que la conexión se ha tomado una pausa. Vuelve a intentarlo más tarde.',
      );
    }
    if (_mensajes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_mensajes!.isEmpty) {
      return _estado(
        Icons.forum_outlined,
        'Todavía no hay mensajes.',
        'Cada conversación tiene un comienzo. Tus mensajes aparecerán aquí.',
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text('Tus mensajes',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTema.lavanda,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${_mensajes!.length} mensajes',
                    style: const TextStyle(
                        color: AppTema.principal,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        Expanded(child: construir(_mensajes!)),
      ],
    );
  }

  Widget _perfil() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Mi perfil',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTema.lavanda,
                    child: Text(_iniciales,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTema.principal)),
                  ),
                  const SizedBox(height: 16),
                  Text(_auth.correoActual ?? 'Sin sesión',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secciones = [
      _conEstados((m) => MensajesLista(mensajes: m)),
      _conEstados((m) => MensajesCuadricula(mensajes: m)),
      _perfil(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.chat_bubble_rounded, color: AppTema.principal),
            SizedBox(width: 8),
            Text('Messend'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTema.lavanda,
              child: Text(_iniciales,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTema.principal)),
            ),
          ),
        ],
      ),
      body: FondoMessend(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: secciones[_seccion],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seccion,
        onDestinationSelected: (i) => setState(() => _seccion = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'Lista'),
          NavigationDestination(
              icon: Icon(Icons.grid_view), label: 'Cuadrícula'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}