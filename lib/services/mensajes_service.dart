import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mensaje.dart';

// Una página de resultados y lo que hace falta para pedir la siguiente.
class PaginaMensajes {
  final List<Mensaje> mensajes;
  final DocumentSnapshot<Mensaje>? ultimo; // desde aquí empieza la siguiente
  final bool hayMas;

  const PaginaMensajes({
    required this.mensajes,
    required this.ultimo,
    required this.hayMas,
  });
}

class MensajesService {
  final CollectionReference<Mensaje> _coleccion =
  FirebaseFirestore.instance.collection('mensajes').withConverter<Mensaje>(
    fromFirestore: Mensaje.fromFirestore,
    toFirestore: (mensaje, _) => mensaje.toFirestore(),
  );

  // CONSULTA 1: orderBy + limit. Los últimos mensajes, escuchando cambios:
  // la pestaña Lista se actualiza sola cuando alguien escribe.
  Stream<List<Mensaje>> escuchar({int limite = 10}) {
    return _coleccion
        .orderBy('fecha', descending: true)
        .limit(limite)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  // CONSULTA 2: paginación con startAfterDocument. Se lee una vez (get):
  // cada página es una petición nueva cuando el usuario pulsa "Cargar más".
  Future<PaginaMensajes> pagina({
    DocumentSnapshot<Mensaje>? despuesDe,
    int tamano = 8,
  }) async {
    Query<Mensaje> consulta =
    _coleccion.orderBy('fecha', descending: true).limit(tamano);
    if (despuesDe != null) {
      consulta = consulta.startAfterDocument(despuesDe);
    }
    final resultado = await consulta.get();
    return PaginaMensajes(
      mensajes: resultado.docs.map((d) => d.data()).toList(),
      ultimo: resultado.docs.isEmpty ? despuesDe : resultado.docs.last,
      hayMas: resultado.docs.length == tamano,
    );
  }

  // CONSULTAS 3 y 4, según los filtros que se pasen. Se lee una vez (get).
  //  - autorUid + rango de fechas: where con dos condiciones. Necesita el
  //    índice compuesto (autorUid, fecha) de firestore.indexes.json.
  //  - solo rango de fechas: rango sobre un único campo, sin índice propio.
  // "hasta" incluye el día entero, por eso se suma un día y se usa isLessThan.
  Future<List<Mensaje>> buscar({
    String? autorUid,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    Query<Mensaje> consulta = _coleccion;
    if (autorUid != null) {
      consulta = consulta.where('autorUid', isEqualTo: autorUid);
    }
    if (desde != null) {
      consulta = consulta.where('fecha',
          isGreaterThanOrEqualTo: Timestamp.fromDate(desde));
    }
    if (hasta != null) {
      consulta = consulta.where('fecha',
          isLessThan: Timestamp.fromDate(hasta.add(const Duration(days: 1))));
    }
    final resultado =
    await consulta.orderBy('fecha', descending: true).limit(50).get();
    return resultado.docs.map((d) => d.data()).toList();
  }

  Future<void> anadir(Mensaje mensaje) async {
    await _coleccion.add(mensaje);
  }
}
