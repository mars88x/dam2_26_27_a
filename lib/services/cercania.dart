import 'dart:math';

// Cálculo de distancias que se ejecuta en un isolate (ver trabajo_isolate.dart),
// para que ordenar muchos mensajes no bloquee la interfaz.
//
// Entrada y salida son listas planas de números porque es lo más barato de
// copiar entre isolates y no depende de ningún paquete de Flutter:
//   entrada: [latMia, lngMia, lat0, lng0, lat1, lng1, ...]
//   salida:  [[indice, metros], ...] ordenada de más cerca a más lejos
// "avisar" recibe el progreso de 0 a 1.
List<List<double>> ordenarPorDistancia(
    List<double> datos,
    void Function(double) avisar,
    ) {
  final latMia = datos[0];
  final lngMia = datos[1];
  final total = (datos.length - 2) ~/ 2;
  final resultado = <List<double>>[];
  // Se avisa cada 5 % como mucho, para no inundar el puerto de mensajes.
  final salto = max(1, total ~/ 20);
  for (var n = 0; n < total; n++) {
    final i = 2 + n * 2;
    resultado.add([
      n.toDouble(),
      _haversine(latMia, lngMia, datos[i], datos[i + 1]),
    ]);
    if (n % salto == 0) avisar(n / total);
  }
  resultado.sort((a, b) => a[1].compareTo(b[1]));
  avisar(1);
  return resultado;
}

// Distancia en metros entre dos puntos de la Tierra (fórmula de Haversine).
double _haversine(double lat1, double lng1, double lat2, double lng2) {
  const radioTierra = 6371000.0;
  double rad(double grados) => grados * pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(rad(lat1)) * cos(rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  return 2 * radioTierra * asin(sqrt(a));
}
