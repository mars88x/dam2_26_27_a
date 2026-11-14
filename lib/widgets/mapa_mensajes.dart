import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/mensaje.dart';
import '../services/cercania.dart';
import '../services/mensajes_service.dart';
import '../services/trabajo_isolate.dart';
import '../services/ubicacion_service.dart';
import '../theme/app_tema.dart';
import 'estado_pantalla.dart';

// Un mensaje con su distancia a mí (para la lista "Cerca de mí").
class _Cercano {
  final Mensaje mensaje;
  final double metros;
  const _Cercano(this.mensaje, this.metros);
}

// Pestaña Mapa: arriba se elige entre el mapa y la lista "Cerca de mí".
// Al abrirla se pide la posición del usuario (es para lo que sirve la pestaña)
// y el mapa se centra en él.
class MapaMensajes extends StatefulWidget {
  const MapaMensajes({super.key});

  @override
  State<MapaMensajes> createState() => _MapaMensajesState();
}

class _MapaMensajesState extends State<MapaMensajes> {
  final _servicio = MensajesService();
  final _ubicacion = UbicacionService();

  List<Mensaje>? _mensajes; // solo los que tienen posición
  Object? _error;
  bool _cargando = true;
  bool _verLista = false;

  // Mi posición (null si no se pudo leer) y por qué falló.
  LatLng? _miPosicion;
  FalloUbicacion? _fallo;

  // Estado de "Cerca de mí"
  bool _calculando = false;
  double _progreso = 0;
  List<_Cercano>? _cercanos;
  int? _milisegundos; // lo que tardó el cálculo, para medirlo

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await _servicio.conUbicacion();
      if (!mounted) return;
      setState(() => _mensajes = lista);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _cargando = false;
      });
      return;
    }
    // La posición solo se pide la primera vez; al recargar se reutiliza.
    if (_miPosicion == null) await _leerPosicion();
    if (!mounted) return;
    setState(() => _cargando = false);
  }

  // Intenta leer mi posición. Si falla, el mapa se ve igual pero sin centrarse
  // en mí, y se explica el motivo.
  Future<void> _leerPosicion() async {
    final r = await _ubicacion.obtener();
    if (!mounted) return;
    setState(() {
      if (r.posicion != null) {
        _miPosicion = LatLng(r.posicion!.latitude, r.posicion!.longitude);
        _fallo = null;
      } else {
        _fallo = r.fallo;
      }
    });
  }

  Future<void> _reintentarPosicion() async {
    setState(() => _cargando = true);
    await _leerPosicion();
    if (!mounted) return;
    setState(() => _cargando = false);
  }

  Future<void> _abrirDetalle(Mensaje m) async {
    await Navigator.pushNamed(context, '/detalle', arguments: m);
    if (mounted) _cargar(); // por si se editó o se borró
  }

  // Ordena por distancia en un isolate, avisando del progreso.
  Future<void> _calcularCercanos() async {
    final mensajes = _mensajes;
    final yo = _miPosicion;
    if (mensajes == null || mensajes.isEmpty || yo == null) return;
    setState(() {
      _calculando = true;
      _progreso = 0;
    });
    final datos = <double>[yo.latitude, yo.longitude];
    for (final m in mensajes) {
      datos.add(m.ubicacion!.latitude);
      datos.add(m.ubicacion!.longitude);
    }
    final reloj = Stopwatch()..start();
    final orden = await correrConProgreso(
      ordenarPorDistancia,
      datos,
          (p) {
        if (mounted) setState(() => _progreso = p);
      },
    );
    reloj.stop();
    if (!mounted) return;
    setState(() {
      _cercanos = [for (final o in orden) _Cercano(mensajes[o[0].toInt()], o[1])];
      _milisegundos = reloj.elapsedMilliseconds;
      _calculando = false;
    });
  }

  String _distancia(double metros) => metros < 1000
      ? '${metros.round()} m'
      : '${(metros / 1000).toStringAsFixed(1)} km';

  Widget _selector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(
              value: false, icon: Icon(Icons.map_outlined), label: Text('Mapa')),
          ButtonSegment(
              value: true,
              icon: Icon(Icons.near_me_outlined),
              label: Text('Cerca de mí')),
        ],
        selected: {_verLista},
        onSelectionChanged: (s) {
          setState(() => _verLista = s.first);
          if (_verLista &&
              _cercanos == null &&
              !_calculando &&
              _miPosicion != null) {
            _calcularCercanos();
          }
        },
      ),
    );
  }

  // Aviso cuando no se pudo leer mi posición, con su salida.
  Widget _avisoSinPosicion() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        color: AppTema.errorSuave,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.location_off, color: AppTema.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_fallo!.mensaje,
                    style: const TextStyle(fontSize: 13)),
              ),
              TextButton(
                onPressed: _reintentarPosicion,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapa(List<Mensaje> mensajes) {
    final puntos = [
      for (final m in mensajes)
        LatLng(m.ubicacion!.latitude, m.ubicacion!.longitude)
    ];
    final yo = _miPosicion;
    return FlutterMap(
      // Si cambia mi posición se reconstruye el mapa para centrarlo en ella.
      key: ValueKey(yo),
      options: MapOptions(
        // Centrado en mí. Sin mi posición, se ajusta para ver todos los pines.
        initialCenter: yo ?? puntos.first,
        initialZoom: 13,
        initialCameraFit: yo == null && puntos.length > 1
            ? CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(puntos),
            padding: const EdgeInsets.all(48))
            : null,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // Identifica la app ante OpenStreetMap, que lo exige en sus normas.
          userAgentPackageName: 'com.example.DAM_26_27_A.dam2_26_27_a',
        ),
        MarkerLayer(
          markers: [
            for (var i = 0; i < mensajes.length; i++)
              Marker(
                point: puntos[i],
                width: 44,
                height: 44,
                // La punta del pin queda sobre el punto exacto.
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => _abrirDetalle(mensajes[i]),
                  child: const Icon(Icons.location_on,
                      size: 44, color: AppTema.principal),
                ),
              ),
            if (yo != null)
              Marker(
                point: yo,
                width: 28,
                height: 28,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTema.acento,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
          ],
        ),
        // Atribución siempre visible, como exige la licencia de OpenStreetMap.
        const SimpleAttributionWidget(
          source: Text('© OpenStreetMap contributors'),
        ),
      ],
    );
  }

  Widget _listaCercanos() {
    if (_miPosicion == null) {
      return EstadoPantalla(
        icono: Icons.location_off,
        titulo: 'No se pudo leer tu posición.',
        texto: _fallo?.mensaje ?? 'Inténtalo de nuevo.',
        etiquetaBoton: 'Reintentar',
        alPulsar: () async {
          await _reintentarPosicion();
          if (_miPosicion != null) _calcularCercanos();
        },
      );
    }
    if (_calculando) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Calculando distancias... ${(_progreso * 100).round()} %'),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _progreso),
            ],
          ),
        ),
      );
    }
    final lista = _cercanos;
    if (lista == null) return const SizedBox.shrink();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: lista.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Row(
            children: [
              Expanded(
                child: Text(
                    '${lista.length} mensajes ordenados en $_milisegundos ms',
                    style: const TextStyle(
                        fontSize: 12, color: AppTema.textoSuave)),
              ),
              TextButton.icon(
                onPressed: _calcularCercanos,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
              ),
            ],
          );
        }
        final c = lista[i - 1];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTema.lavanda,
              child: Text(_distancia(c.metros),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTema.principal)),
            ),
            title: Text(c.mensaje.autor,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(c.mensaje.texto,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrirDetalle(c.mensaje),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando el mapa y buscando tu posición...'),
          ],
        ),
      );
    }
    if (_error != null) {
      return EstadoPantalla(
        icono: Icons.cloud_off,
        titulo: 'No se pudo cargar el mapa.',
        texto: 'Comprueba la conexión e inténtalo de nuevo.',
        alPulsar: _cargar,
      );
    }
    final mensajes = _mensajes ?? const <Mensaje>[];
    if (mensajes.isEmpty) {
      return const EstadoPantalla(
        icono: Icons.location_off_outlined,
        titulo: 'Ningún mensaje tiene ubicación.',
        texto: 'Añade tu ubicación al escribir un mensaje y saldrá aquí.',
      );
    }
    return Column(
      children: [
        _selector(),
        if (_fallo != null && !_verLista) _avisoSinPosicion(),
        Expanded(
          child: _verLista
              ? _listaCercanos()
              : ClipRRect(
            borderRadius: BorderRadius.circular(AppTema.radio),
            child: _mapa(mensajes),
          ),
        ),
      ],
    );
  }
}
