import 'package:flutter/material.dart';
import '../models/mensaje.dart';
import '../services/auth_service.dart';
import '../services/mensajes_service.dart';
import '../theme/app_tema.dart';
import 'estado_pantalla.dart';
import 'mensajes_lista.dart';

// Búsqueda con filtros: solo mis mensajes y/o un rango de fechas.
class BuscarMensajes extends StatefulWidget {
  const BuscarMensajes({super.key});

  @override
  State<BuscarMensajes> createState() => _BuscarMensajesState();
}

class _BuscarMensajesState extends State<BuscarMensajes> {
  final _servicio = MensajesService();
  final _auth = AuthService();
  bool _soloMios = false;
  DateTimeRange? _rango;
  List<Mensaje>? _resultados;
  Object? _error;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  Future<void> _buscar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await _servicio.buscar(
        autorUid: _soloMios ? _auth.uidActual : null,
        desde: _rango?.start,
        hasta: _rango?.end,
      );
      if (!mounted) return;
      setState(() {
        _resultados = lista;
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

  Future<void> _elegirFechas() async {
    final elegido = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: _rango,
    );
    if (elegido == null) return; // canceló: no se cambia nada
    setState(() => _rango = elegido);
    _buscar();
  }

  String _fecha(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Widget _filtros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Solo mis mensajes'),
              value: _soloMios,
              onChanged: (v) {
                setState(() => _soloMios = v);
                _buscar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range, color: AppTema.principal),
              title: Text(_rango == null
                  ? 'Cualquier fecha'
                  : '${_fecha(_rango!.start)} - ${_fecha(_rango!.end)}'),
              trailing: _rango == null
                  ? const Icon(Icons.chevron_right)
                  : IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Quitar fechas',
                onPressed: () {
                  setState(() => _rango = null);
                  _buscar();
                },
              ),
              onTap: _elegirFechas,
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultado() {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return EstadoPantalla(
        icono: Icons.cloud_off,
        titulo: 'La búsqueda ha fallado.',
        texto: 'Comprueba la conexión e inténtalo de nuevo.',
        alPulsar: _buscar,
      );
    }
    if (_resultados == null || _resultados!.isEmpty) {
      return const EstadoPantalla(
        icono: Icons.search_off,
        titulo: 'Sin resultados.',
        texto: 'Prueba a cambiar los filtros.',
      );
    }
    return MensajesLista(mensajes: _resultados!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _filtros(),
        Expanded(child: _resultado()),
      ],
    );
  }
}
