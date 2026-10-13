import 'package:flutter/material.dart';
import '../models/mensaje.dart';

class MensajesCuadricula extends StatelessWidget {
  final List<Mensaje> mensajes;
  const MensajesCuadricula({super.key, required this.mensajes});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: mensajes.length,
      itemBuilder: (context, i) {
        final m = mensajes[i];
        return Card(
          child: InkWell(
            onTap: () =>
                Navigator.pushNamed(context, '/detalle', arguments: m),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.autor,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(child: Text(m.texto, overflow: TextOverflow.fade)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}