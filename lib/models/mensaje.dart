import 'package:cloud_firestore/cloud_firestore.dart';

class Mensaje {
  final String? id;
  final String texto;
  final String autor;
  final DateTime fecha;

  const Mensaje({
    this.id,
    required this.texto,
    required this.autor,
    required this.fecha,
  });

  // Firestore - objeto Mensaje
  factory Mensaje.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final datos = snapshot.data()!;
    return Mensaje(
      id: snapshot.id,
      texto: datos['texto'] ?? '',
      autor: datos['autor'] ?? '',
      fecha: (datos['fecha'] as Timestamp).toDate(),
    );
  }

  // Objeto Mensaje - Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'texto': texto,
      'autor': autor,
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}