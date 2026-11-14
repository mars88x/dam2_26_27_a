import 'package:cloud_firestore/cloud_firestore.dart';

class Mensaje {
  final String? id;
  final String texto;
  final String autor;
  // uid de quien lo escribió: las reglas y las consultas por autor lo usan.
  // Los mensajes antiguos no lo tienen y se leen con ''.
  final String autorUid;
  final DateTime fecha;

  const Mensaje({
    this.id,
    required this.texto,
    required this.autor,
    this.autorUid = '',
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
      autorUid: datos['autorUid'] ?? '',
      fecha: (datos['fecha'] as Timestamp).toDate(),
    );
  }

  // Objeto Mensaje - Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'texto': texto,
      'autor': autor,
      'autorUid': autorUid,
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}
