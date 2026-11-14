import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/mensaje.dart';
import '../services/auth_service.dart';
import '../services/mensajes_service.dart';
import '../theme/app_tema.dart';
import '../widgets/fondo_messend.dart';

// Mensaje de error entendible según lo que haya fallado.
String _textoError(Object e, String accion) {
  if (e is FirebaseException && e.code == 'permission-denied') {
    return 'No tienes permiso para $accion este mensaje.';
  }
  return 'No se pudo $accion el mensaje. Inténtalo de nuevo.';
}

class DetalleScreen extends StatefulWidget {
  const DetalleScreen({super.key});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  final _servicio = MensajesService();
  final _auth = AuthService();
  late Mensaje _mensaje;
  bool _iniciado = false;
  bool _ocupado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Los argumentos de la ruta solo se pueden leer aquí, y solo la primera vez.
    if (!_iniciado) {
      _mensaje = ModalRoute.of(context)!.settings.arguments as Mensaje;
      _iniciado = true;
    }
  }

  // Solo se ofrecen editar y borrar en los mensajes propios.
  bool get _esMio =>
      _mensaje.autorUid.isNotEmpty && _mensaje.autorUid == _auth.uidActual;

  Future<void> _editar() async {
    final nuevo = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoEditar(mensaje: _mensaje),
    );
    if (nuevo == null) return; // canceló
    setState(() => _mensaje = _mensaje.conTexto(nuevo));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Mensaje actualizado.')));
  }

  Future<void> _borrar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar este mensaje?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTema.error),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    // Se guarda antes de salir de la pantalla para poder avisar después.
    final mensajero = ScaffoldMessenger.of(context);
    setState(() => _ocupado = true);
    try {
      await _servicio.borrar(_mensaje.id!);
      if (!mounted) return;
      Navigator.pop(context);
      mensajero.showSnackBar(const SnackBar(content: Text('Mensaje borrado.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _ocupado = false);
      mensajero.showSnackBar(SnackBar(content: Text(_textoError(e, 'borrar'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = _mensaje.fecha;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: FondoMessend(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTema.pasteles[0],
                        child: Text(
                          _mensaje.autor.isEmpty
                              ? '?'
                              : _mensaje.autor[0].toUpperCase(),
                          style: const TextStyle(
                              color: AppTema.texto,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(_mensaje.autor,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.format_quote,
                              color: AppTema.principal),
                          const SizedBox(height: 8),
                          Text(_mensaje.texto,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Icon(Icons.person_outline,
                        size: 18, color: AppTema.textoSuave),
                    const SizedBox(width: 8),
                    Text('Autor: ${_mensaje.autor}'),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppTema.textoSuave),
                    const SizedBox(width: 8),
                    Text('Fecha: ${f.day}/${f.month}/${f.year}'),
                  ]),
                  if (_mensaje.ubicacion != null) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.place_outlined,
                          size: 18, color: AppTema.textoSuave),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            'Lugar: ${_mensaje.ubicacion!.latitude.toStringAsFixed(5)}, '
                            '${_mensaje.ubicacion!.longitude.toStringAsFixed(5)}'),
                      ),
                    ]),
                  ],
                  if (_esMio) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _ocupado ? null : _editar,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Editar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _ocupado ? null : _borrar,
                            style: OutlinedButton.styleFrom(
                                foregroundColor: AppTema.error),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Borrar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Diálogo para cambiar el texto. Si falla, el error se ve dentro y no se cierra.
class _DialogoEditar extends StatefulWidget {
  final Mensaje mensaje;
  const _DialogoEditar({required this.mensaje});

  @override
  State<_DialogoEditar> createState() => _DialogoEditarState();
}

class _DialogoEditarState extends State<_DialogoEditar> {
  final _servicio = MensajesService();
  late final TextEditingController _controlador;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controlador = TextEditingController(text: widget.mensaje.texto);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) {
      setState(() => _error = 'El mensaje no puede estar vacío.');
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await _servicio.actualizarTexto(widget.mensaje.id!, texto);
      if (!mounted) return;
      Navigator.pop(context, texto);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = _textoError(e, 'guardar');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar mensaje'),
      content: TextField(
        controller: _controlador,
        autofocus: true,
        maxLines: 4,
        minLines: 1,
        enabled: !_guardando,
        decoration: InputDecoration(errorText: _error),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
