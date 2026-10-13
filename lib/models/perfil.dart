import 'package:cloud_firestore/cloud_firestore.dart';

class Perfil {
  final String? id;
  final String nombre;
  final int edad;

  const Perfil({this.id, required this.nombre, required this.edad});

  factory Perfil.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final datos = snapshot.data()!;
    return Perfil(
      id: snapshot.id,
      nombre: datos['nombre'] ?? '',
      // Firestore guarda los números como double; lo convertimos a int.
      edad: (datos['edad'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'nombre': nombre, 'edad': edad};
  }
}