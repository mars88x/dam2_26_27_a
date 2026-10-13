import 'package:flutter/material.dart';
import '../models/mensaje.dart';

class MensajesLista extends StatelessWidget {
  final List<Mensaje> mensajes;
  const MensajesLista({super.key, required this.mensajes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mensajes.length,
      itemBuilder: (context, i) {
        final m = mensajes[i];
        return ListTile(
          leading: CircleAvatar(
            child: Text(m.autor.isEmpty ? '?' : m.autor[0].toUpperCase()),
          ),
          title: Text(m.texto),
          subtitle: Text(m.autor),
          onTap: () => Navigator.pushNamed(context, '/detalle', arguments: m),
        );
      },
    );
  }
}