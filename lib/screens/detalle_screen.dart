import 'package:flutter/material.dart';
import '../models/mensaje.dart';

class DetalleScreen extends StatelessWidget {
  const DetalleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mensaje = ModalRoute.of(context)!.settings.arguments as Mensaje;
    final f = mensaje.fecha;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mensaje.texto, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 16),
            Text('Autor: ${mensaje.autor}'),
            Text('Fecha: ${f.day}/${f.month}/${f.year}'),
          ],
        ),
      ),
    );
  }
}