import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/perfil.dart';

class PerfilesService {
  final CollectionReference<Perfil> _coleccion =
  FirebaseFirestore.instance.collection('perfiles').withConverter<Perfil>(
    fromFirestore: Perfil.fromFirestore,
    toFirestore: (perfil, _) => perfil.toFirestore(),
  );

  // El ID del documento es el uid del usuario, así cada usuario tiene su perfil.
  Future<void> guardar(String uid, Perfil perfil) async {
    await _coleccion.doc(uid).set(perfil);
  }

  Future<Perfil?> obtener(String uid) async {
    final doc = await _coleccion.doc(uid).get();
    return doc.data();
  }
}