import 'dart:typed_data';
import 'package:flutter/services.dart' show PlatformException;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

// Por qué no se ha podido conseguir la foto. Cada caso tiene su mensaje.
enum FalloFoto { permisoDenegado, sinCamara, imagenNoValida, desconocido }

extension MensajeFalloFoto on FalloFoto {
  String get mensaje {
    switch (this) {
      case FalloFoto.permisoDenegado:
        return 'Has denegado el permiso. Actívalo en los ajustes de la app '
            '(Permisos > Cámara) o elige una foto de la galería.';
      case FalloFoto.sinCamara:
        return 'Este dispositivo no tiene cámara disponible. Elige una foto '
            'de la galería.';
      case FalloFoto.imagenNoValida:
        return 'Ese archivo no es una imagen que se pueda leer. Prueba con '
            'otra foto.';
      case FalloFoto.desconocido:
        return 'No se ha podido conseguir la foto. Inténtalo de nuevo.';
    }
  }
}

class ResultadoElegir {
  final Uint8List? bytes;
  final FalloFoto? fallo;
  final bool cancelado;
  const ResultadoElegir.ok(Uint8List this.bytes)
      : fallo = null,
        cancelado = false;
  const ResultadoElegir.fallo(FalloFoto this.fallo)
      : bytes = null,
        cancelado = false;
  const ResultadoElegir.cancelado()
      : bytes = null,
        fallo = null,
        cancelado = true;
}

class FotoService {
  final _picker = ImagePicker();

  // Abre la cámara o la galería. No lanza nunca: devuelve la foto, que se
  // canceló o el motivo del fallo. En el navegador abre la cámara que haya
  // o el selector de archivos.
  Future<ResultadoElegir> elegir(ImageSource origen) async {
    try {
      // Sin maxWidth ni calidad: la reducción la hace comprimirFoto en un
      // isolate, que es lo que se quiere demostrar.
      final archivo = await _picker.pickImage(source: origen);
      if (archivo == null) return const ResultadoElegir.cancelado();
      return ResultadoElegir.ok(await archivo.readAsBytes());
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        return const ResultadoElegir.fallo(FalloFoto.permisoDenegado);
      }
      if (e.code == 'no_available_camera') {
        return const ResultadoElegir.fallo(FalloFoto.sinCamara);
      }
      return const ResultadoElegir.fallo(FalloFoto.desconocido);
    } catch (_) {
      return const ResultadoElegir.fallo(FalloFoto.desconocido);
    }
  }
}

// Tamaño máximo de la miniatura. 200 KB en bytes son unos 267 KB en base64:
// por debajo de los 300 KB pedidos y muy lejos del límite de 1 MB de Firestore.
const int limiteMiniaturaBytes = 200 * 1024;
const int _ladoMaximo = 800;

// Reduce la foto a una miniatura JPEG. Se ejecuta en un isolate (ver
// trabajo_isolate.dart): decodificar una foto de cámara de 12 megapíxeles es
// lo que congelaría la pantalla. "avisar" informa del progreso de 0 a 1.
// Lanza FormatException si los bytes no son una imagen.
Uint8List comprimirFoto(Uint8List original, void Function(double) avisar) {
  avisar(0.05);
  final decodificada = img.decodeImage(original);
  if (decodificada == null) throw const FormatException('No es una imagen');
  avisar(0.4);

  // Las fotos de móvil guardan el giro en los metadatos: se aplica al pintar.
  var imagen = img.bakeOrientation(decodificada);
  if (imagen.width >= imagen.height) {
    if (imagen.width > _ladoMaximo) imagen = img.copyResize(imagen, width: _ladoMaximo);
  } else if (imagen.height > _ladoMaximo) {
    imagen = img.copyResize(imagen, height: _ladoMaximo);
  }
  avisar(0.6);

  // Se baja la calidad poco a poco hasta que entre en el límite.
  var calidad = 80;
  var resultado = img.encodeJpg(imagen, quality: calidad);
  while (resultado.length > limiteMiniaturaBytes && calidad > 30) {
    calidad -= 10;
    resultado = img.encodeJpg(imagen, quality: calidad);
    avisar(0.6 + (80 - calidad) / 50 * 0.35);
  }
  // Si aun así pesa demasiado, se reduce el tamaño a la mitad.
  while (resultado.length > limiteMiniaturaBytes && imagen.width > 100) {
    imagen = img.copyResize(imagen, width: imagen.width ~/ 2);
    resultado = img.encodeJpg(imagen, quality: calidad);
  }
  avisar(1);
  return Uint8List.fromList(resultado);
}
