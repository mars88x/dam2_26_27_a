import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/mensaje.dart';
import '../services/mensajes_service.dart';
import '../theme/app_tema.dart';
import 'estado_pantalla.dart';
import 'mensajes_cuadricula.dart';

// Cuadrícula que carga los mensajes de 8 en 8 con startAfterDocument.
class CuadriculaPaginada extends StatefulWidget {
  const CuadriculaPaginada({super.key});

  @override
  State<CuadriculaPaginada> createState() => _CuadriculaPaginadaState();
}

class _CuadriculaPaginadaState extends State<CuadriculaPaginada> {
  final _servicio = MensajesService();
  final List<Mensaje> _mensajes = [];
  DocumentSnapshot<Mensaje>? _ultimo;
  bool _hayMas = true;
  bool _cargando = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _cargarPagina();
  }

  Future<void> _cargarPagina() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final pagina = await _servicio.pagina(despuesDe: _ultimo);
      if (!mounted) return; // la pantalla pudo cerrarse mientras se esperaba
      setState(() {
        _mensajes.addAll(pagina.mensajes);
        _ultimo = pagina.ultimo;
        _hayMas = pagina.hayMas;
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

  // Vuelve a pedir desde la primera página (tras editar o borrar).
  void _recargar() {
    _mensajes.clear();
    _ultimo = null;
    _hayMas = true;
    _cargarPagina();
  }

  @override
  Widget build(BuildContext context) {
    if (_mensajes.isEmpty) {
      if (_cargando) return const Center(child: CircularProgressIndicator());
      if (_error != null) {
        return EstadoPantalla(
          icono: Icons.cloud_off,
          titulo: 'No se pudieron cargar los mensajes.',
          texto: 'Comprueba la conexión e inténtalo de nuevo.',
          alPulsar: _cargarPagina,
        );
      }
      return const EstadoPantalla(
        icono: Icons.forum_outlined,
        titulo: 'Todavía no hay mensajes.',
        texto: 'Cada conversación tiene un comienzo. Tus mensajes aparecerán aquí.',
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text('Todos los mensajes',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              Text('${_mensajes.length} cargados',
                  style: const TextStyle(
                      color: AppTema.textoSuave, fontSize: 12)),
            ],
          ),
        ),
        Expanded(
            child: MensajesCuadricula(
                mensajes: _mensajes, alVolver: _recargar)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: _pie(),
        ),
      ],
    );
  }

  // Parte de abajo: botón, spinner, error o aviso de que no hay más.
  Widget _pie() {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return OutlinedButton.icon(
        onPressed: _cargarPagina,
        icon: const Icon(Icons.refresh),
        label: const Text('No se pudo cargar. Reintentar'),
      );
    }
    if (_hayMas) {
      return OutlinedButton.icon(
        onPressed: _cargarPagina,
        icon: const Icon(Icons.expand_more),
        label: const Text('Cargar más'),
      );
    }
    return const Center(
      child: Text('No hay más mensajes',
          style: TextStyle(color: AppTema.textoSuave)),
    );
  }
}
