import 'dart:async';
import 'package:geolocator/geolocator.dart';

// Por qué no se ha podido leer la posición. Cada caso tiene su mensaje y su
// salida, así ninguno deja la pantalla colgada.
enum FalloUbicacion {
  gpsApagado,
  permisoDenegado,
  permisoBloqueado, // "no volver a preguntar": solo se arregla en los ajustes
  tiempoAgotado,
  desconocido,
}

extension MensajeFallo on FalloUbicacion {
  String get mensaje {
    switch (this) {
      case FalloUbicacion.gpsApagado:
        return 'La ubicación del dispositivo está apagada. Actívala para '
            'poder añadir tu posición.';
      case FalloUbicacion.permisoDenegado:
        return 'Has denegado el permiso de ubicación. Pulsa Reintentar y '
            'acepta para añadir tu posición.';
      case FalloUbicacion.permisoBloqueado:
        return 'El permiso de ubicación está bloqueado. Actívalo en los '
            'ajustes de la app (Permisos > Ubicación).';
      case FalloUbicacion.tiempoAgotado:
        return 'No se ha podido obtener tu posición a tiempo. Prueba en un '
            'sitio con mejor cobertura.';
      case FalloUbicacion.desconocido:
        return 'No se ha podido leer tu posición. Inténtalo de nuevo.';
    }
  }
}

class ResultadoUbicacion {
  final Position? posicion;
  final FalloUbicacion? fallo;
  const ResultadoUbicacion.ok(Position this.posicion) : fallo = null;
  const ResultadoUbicacion.fallo(FalloUbicacion this.fallo) : posicion = null;
}

class UbicacionService {
  static const _espera = Duration(seconds: 15);

  // Nunca lanza: devuelve la posición o el motivo por el que no hay.
  Future<ResultadoUbicacion> obtener() async {
    try {
      // 1. ¿Está encendida la ubicación del dispositivo?
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const ResultadoUbicacion.fallo(FalloUbicacion.gpsApagado);
      }

      // 2. El permiso se pide ahora, justo cuando el usuario lo ha pedido.
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.deniedForever) {
        return const ResultadoUbicacion.fallo(FalloUbicacion.permisoBloqueado);
      }
      if (permiso == LocationPermission.denied) {
        return const ResultadoUbicacion.fallo(FalloUbicacion.permisoDenegado);
      }

      // 3. La lectura, con un tiempo máximo para que no se quede esperando.
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: _espera,
        ),
      );
      return ResultadoUbicacion.ok(posicion);
    } on TimeoutException {
      return const ResultadoUbicacion.fallo(FalloUbicacion.tiempoAgotado);
    } catch (_) {
      return const ResultadoUbicacion.fallo(FalloUbicacion.desconocido);
    }
  }

  Future<void> abrirAjustesUbicacion() => Geolocator.openLocationSettings();
  Future<void> abrirAjustesApp() => Geolocator.openAppSettings();
}
