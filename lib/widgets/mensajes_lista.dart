import 'package:flutter/material.dart';
import '../models/mensaje.dart';
import '../theme/app_tema.dart';

class MensajesLista extends StatelessWidget {
  final List<Mensaje> mensajes;
  const MensajesLista({super.key, required this.mensajes});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: mensajes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final m = mensajes[i];
        final f = m.fecha;
        return Card(
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: AppTema.pasteles[i % AppTema.pasteles.length],
              child: Text(
                m.autor.isEmpty ? '?' : m.autor[0].toUpperCase(),
                style: const TextStyle(
                    color: AppTema.texto, fontWeight: FontWeight.w800),
              ),
            ),
            title: Text(m.autor,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.texto, style: const TextStyle(color: AppTema.texto)),
                  const SizedBox(height: 4),
                  Text('${f.day}/${f.month}/${f.year}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTema.textoSuave)),
                ],
              ),
            ),
            trailing:
            const Icon(Icons.chevron_right, color: AppTema.textoSuave),
            onTap: () =>
                Navigator.pushNamed(context, '/detalle', arguments: m),
          ),
        );
      },
    );
  }
}