import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/mensaje.dart';
import '../services/auth_service.dart';
import '../services/mensajes_service.dart';
import '../services/perfiles_service.dart';
import '../services/ubicacion_service.dart';
import '../theme/app_tema.dart';
import '../widgets/fondo_messend.dart';

enum _EstadoUbicacion { ninguna, buscando, lista, fallo }

class NuevoMensajeScreen extends StatefulWidget {
  const NuevoMensajeScreen({super.key});

  @override
  State<NuevoMensajeScreen> createState() => _NuevoMensajeScreenState();
}

class _NuevoMensajeScreenState extends State<NuevoMensajeScreen> {
  final _texto = TextEditingController();
  final _auth = AuthService();
  final _mensajes = MensajesService();
  final _perfiles = PerfilesService();
  final _ubicacionService = UbicacionService();

  _EstadoUbicacion _estadoUbicacion = _EstadoUbicacion.ninguna;
  Position? _posicion;
  DateTime? _momentoPosicion;
  FalloUbicacion? _fallo;

  bool _publicando = false;
  String? _errorPublicar;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _pedirUbicacion() async {
    setState(() => _estadoUbicacion = _EstadoUbicacion.buscando);
    final r = await _ubicacionService.obtener();
    if (!mounted) return; // se pudo salir de la pantalla mientras se esperaba
    setState(() {
      if (r.posicion != null) {
        _posicion = r.posicion;
        _momentoPosicion = DateTime.now();
        _estadoUbicacion = _EstadoUbicacion.lista;
      } else {
        _fallo = r.fallo;
        _estadoUbicacion = _EstadoUbicacion.fallo;
      }
    });
  }

  void _quitarUbicacion() {
    setState(() {
      _posicion = null;
      _momentoPosicion = null;
      _estadoUbicacion = _EstadoUbicacion.ninguna;
    });
  }

  Future<void> _publicar() async {
    final texto = _texto.text.trim();
    if (texto.isEmpty) {
      setState(() => _errorPublicar = 'Escribe algo antes de publicar.');
      return;
    }
    final uid = _auth.uidActual;
    if (uid == null) {
      setState(() => _errorPublicar = 'Tu sesión ha caducado. Vuelve a entrar.');
      return;
    }
    setState(() {
      _publicando = true;
      _errorPublicar = null;
    });
    try {
      // El nombre sale del perfil; si no se puede leer, del correo.
      String autor;
      try {
        autor = (await _perfiles.obtener(uid))?.nombre ?? '';
      } catch (_) {
        autor = '';
      }
      if (autor.isEmpty) autor = (_auth.correoActual ?? 'Anónimo').split('@').first;

      await _mensajes.anadir(Mensaje(
        texto: texto,
        autor: autor,
        autorUid: uid,
        fecha: DateTime.now(),
        ubicacion: _posicion == null
            ? null
            : GeoPoint(_posicion!.latitude, _posicion!.longitude),
        fechaUbicacion: _posicion == null ? null : _momentoPosicion,
      ));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _publicando = false;
        _errorPublicar = 'No se pudo publicar el mensaje. Inténtalo de nuevo.';
      });
    }
  }

  // Botón de salida según el fallo: ajustes si hace falta, o reintentar.
  Widget _botonFallo() {
    switch (_fallo) {
      case FalloUbicacion.gpsApagado:
        // En el navegador no hay ajustes del dispositivo que abrir.
        if (kIsWeb) return _botonReintentar();
        return Wrap(spacing: 8, children: [
          OutlinedButton(
            onPressed: _ubicacionService.abrirAjustesUbicacion,
            child: const Text('Abrir ajustes'),
          ),
          _botonReintentar(),
        ]);
      case FalloUbicacion.permisoBloqueado:
        if (kIsWeb) return _botonReintentar();
        return Wrap(spacing: 8, children: [
          OutlinedButton(
            onPressed: _ubicacionService.abrirAjustesApp,
            child: const Text('Ajustes de la app'),
          ),
          _botonReintentar(),
        ]);
      default:
        return _botonReintentar();
    }
  }

  Widget _botonReintentar() => OutlinedButton.icon(
    onPressed: _pedirUbicacion,
    icon: const Icon(Icons.refresh),
    label: const Text('Reintentar'),
  );

  Widget _tarjetaUbicacion() {
    final Widget contenido;
    switch (_estadoUbicacion) {
      case _EstadoUbicacion.ninguna:
        contenido = Row(
          children: [
            const Expanded(child: Text('Sin ubicación')),
            OutlinedButton.icon(
              onPressed: _pedirUbicacion,
              icon: const Icon(Icons.my_location),
              label: const Text('Añadir mi ubicación'),
            ),
          ],
        );
      case _EstadoUbicacion.buscando:
        contenido = const Row(
          children: [
            SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Expanded(child: Text('Buscando tu posición...')),
          ],
        );
      case _EstadoUbicacion.lista:
        contenido = Row(
          children: [
            const Icon(Icons.place, color: AppTema.acento),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                  '${_posicion!.latitude.toStringAsFixed(5)}, '
                      '${_posicion!.longitude.toStringAsFixed(5)}\n'
                      'Precisión: ${_posicion!.accuracy.round()} m'),
            ),
            IconButton(
              onPressed: _quitarUbicacion,
              icon: const Icon(Icons.close),
              tooltip: 'Quitar ubicación',
            ),
          ],
        );
      case _EstadoUbicacion.fallo:
        contenido = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_off, color: AppTema.error),
                const SizedBox(width: 8),
                Expanded(child: Text(_fallo!.mensaje)),
              ],
            ),
            const SizedBox(height: 12),
            _botonFallo(),
          ],
        );
    }
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: contenido),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo mensaje')),
      body: FondoMessend(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _texto,
                  enabled: !_publicando,
                  maxLines: 5,
                  minLines: 3,
                  maxLength: 280,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                _tarjetaUbicacion(),
                if (_errorPublicar != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorPublicar!,
                      style: const TextStyle(color: AppTema.error)),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _publicando ? null : _publicar,
                  icon: _publicando
                      ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  label: const Text('Publicar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
