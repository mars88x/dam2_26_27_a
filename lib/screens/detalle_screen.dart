import 'package:flutter/material.dart';
import '../models/mensaje.dart';
import '../theme/app_tema.dart';
import '../widgets/fondo_messend.dart';

class DetalleScreen extends StatelessWidget {
  const DetalleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mensaje = ModalRoute.of(context)!.settings.arguments as Mensaje;
    final f = mensaje.fecha;
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
                          mensaje.autor.isEmpty
                              ? '?'
                              : mensaje.autor[0].toUpperCase(),
                          style: const TextStyle(
                              color: AppTema.texto,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(mensaje.autor,
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
                          Text(mensaje.texto,
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
                    Text('Autor: ${mensaje.autor}'),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppTema.textoSuave),
                    const SizedBox(width: 8),
                    Text('Fecha: ${f.day}/${f.month}/${f.year}'),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}