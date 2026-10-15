import 'package:flutter/material.dart';
import '../models/mensaje.dart';
import '../theme/app_tema.dart';

class MensajesCuadricula extends StatelessWidget {
  final List<Mensaje> mensajes;
  const MensajesCuadricula({super.key, required this.mensajes});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      // Cada ficha mide como máximo 190 px de ancho: en el móvil salen 2
      // columnas y en la web se reparten en más columnas.
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 190,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: mensajes.length,
      itemBuilder: (context, i) {
        final m = mensajes[i];
        final f = m.fecha;
        return Card(
          color: AppTema.pasteles[i % AppTema.pasteles.length],
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTema.radio),
            onTap: () =>
                Navigator.pushNamed(context, '/detalle', arguments: m),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.white,
                        child: Text(
                          m.autor.isEmpty ? '?' : m.autor[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTema.texto,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(m.autor,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Text(m.texto,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, color: AppTema.texto)),
                  ),
                  Text('${f.day}/${f.month}/${f.year}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTema.textoSuave)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}