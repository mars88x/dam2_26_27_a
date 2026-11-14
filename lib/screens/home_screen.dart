import 'dart:async';
import 'package:flutter/material.dart';
import '../models/mensaje.dart';
import '../services/auth_service.dart';
import '../services/mensajes_service.dart';
import '../widgets/mensajes_lista.dart';
import '../widgets/cuadricula_paginada.dart';
import '../widgets/buscar_mensajes.dart';
import '../widgets/mapa_mensajes.dart';
import '../widgets/estado_pantalla.dart';
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
  // Sube al volver de crear un mensaje: fuerza a recargar cuadrícula y Buscar.
  int _version = 0;

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

  Future<void> _nuevoMensaje() async {
    await Navigator.pushNamed(context, '/nuevo');
    if (!mounted) return;
    setState(() => _version++);
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
    return EstadoPantalla(icono: icono, titulo: titulo, texto: texto);
  }

  // Gestiona los estados de error, carga y vacío de la lista.
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
                child: Text('Últimos mensajes',
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
      CuadriculaPaginada(key: ValueKey('cuadricula$_version')),
      BuscarMensajes(key: ValueKey('buscar$_version')),
      MapaMensajes(key: ValueKey('mapa$_version')),
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
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'Nuevo mensaje',
            onPressed: _nuevoMensaje,
          ),
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
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}