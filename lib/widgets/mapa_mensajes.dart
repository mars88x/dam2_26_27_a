import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/mensaje.dart';
import '../services/cercania.dart';
import '../services/mensajes_service.dart';
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

  // Estado de "Cerca de mí"
  bool _calculando = false;
  FalloUbicacion? _fallo;
  List<_Cercano>? _cercanos;
  LatLng? _miPosicion;

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
      setState(() {
        _mensajes = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _cargando = false;
      });
    }
  }

  Future<void> _abrirDetalle(Mensaje m) async {
    await Navigator.pushNamed(context, '/detalle', arguments: m);
    if (mounted) _cargar(); // por si se editó o se borró
  }

  // Lee mi posición y calcula las distancias en un isolate.
  Future<void> _calcularCercanos() async {
    final mensajes = _mensajes;
    if (mensajes == null || mensajes.isEmpty) return;
    setState(() {
      _calculando = true;
      _fallo = null;
    });
    final r = await _ubicacion.obtener();
    if (!mounted) return;
    if (r.posicion == null) {
      setState(() {
        _fallo = r.fallo;
        _calculando = false;
      });
      return;
    }
    final pos = r.posicion!;
    final datos = <double>[pos.latitude, pos.longitude];
    for (final m in mensajes) {
      datos.add(m.ubicacion!.latitude);
      datos.add(m.ubicacion!.longitude);
    }
    // compute lanza ordenarPorDistancia en otro isolate y espera el resultado.
    // En la web no hay isolates: Flutter lo ejecuta en el hilo principal.
    final orden = await compute(ordenarPorDistancia, datos);
    if (!mounted) return;
    setState(() {
      _miPosicion = LatLng(pos.latitude, pos.longitude);
      _cercanos = [for (final o in orden) _Cercano(mensajes[o[0].toInt()], o[1])];
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
          if (_verLista && _cercanos == null && !_calculando) _calcularCercanos();
        },
      ),
    );
  }

  Widget _mapa(List<Mensaje> mensajes) {
    final puntos = [
      for (final m in mensajes)
        LatLng(m.ubicacion!.latitude, m.ubicacion!.longitude)
    ];
    return FlutterMap(
      options: MapOptions(
        // Con 2 puntos o más, el mapa se ajusta para que se vean todos.
        initialCenter: puntos.first,
        initialZoom: 12,
        initialCameraFit: puntos.length > 1
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
            if (_miPosicion != null)
              Marker(
                point: _miPosicion!,
                width: 24,
                height: 24,
                child: const Icon(Icons.my_location, color: AppTema.acento),
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
    if (_calculando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando tu posición y calculando distancias...'),
          ],
        ),
      );
    }
    if (_fallo != null) {
      return EstadoPantalla(
        icono: Icons.location_off,
        titulo: 'No se pudo leer tu posición.',
        texto: _fallo!.mensaje,
        etiquetaBoton: 'Reintentar',
        alPulsar: _calcularCercanos,
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
          return Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _calcularCercanos,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
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
    if (_cargando) return const Center(child: CircularProgressIndicator());
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
