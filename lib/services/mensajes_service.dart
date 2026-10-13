import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mensaje.dart';

class MensajesService {
  final CollectionReference<Mensaje> _coleccion =
  FirebaseFirestore.instance.collection('mensajes').withConverter<Mensaje>(
    fromFirestore: Mensaje.fromFirestore,
    toFirestore: (mensaje, _) => mensaje.toFirestore(),
  );

  // la pantalla se actualiza sola cuando cambian los datos
  Stream<List<Mensaje>> escuchar() {
    return _coleccion
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Future<void> anadir(Mensaje mensaje) async {
    await _coleccion.add(mensaje);
  }
}