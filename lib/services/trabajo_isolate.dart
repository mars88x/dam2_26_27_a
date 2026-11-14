import 'dart:isolate';
import 'package:flutter/foundation.dart';

// Ejecuta una tarea pesada en un isolate y reenvía su progreso (de 0 a 1) a la
// pantalla. La tarea recibe un "avisar" con el que informa de cuánto lleva.
//
// Reglas de los isolates (por qué el código tiene esta forma):
//  - La tarea tiene que ser una función de primer nivel (no un método ni una
//    función que capture la pantalla), porque se copia al otro isolate.
//  - El otro isolate no comparte memoria: el progreso viaja por un SendPort.
//  - En la web no hay isolates, así que allí se ejecuta en el mismo hilo (la
//    pantalla se queda quieta mientras dura; el README lo explica).
Future<R> correrConProgreso<A, R>(
    R Function(A argumento, void Function(double) avisar) tarea,
    A argumento,
    void Function(double) alProgreso,
    ) async {
  if (kIsWeb) {
    // Un momento para que se pinte el indicador antes de empezar.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return tarea(argumento, alProgreso);
  }
  final puerto = ReceivePort();
  final suscripcion = puerto.listen((mensaje) {
    if (mensaje is double) alProgreso(mensaje);
  });
  try {
    return await _lanzar(tarea, argumento, puerto.sendPort);
  } finally {
    await suscripcion.cancel();
    puerto.close();
  }
}

// Función aparte a propósito: la función anónima que se manda al isolate solo
// debe capturar cosas que se puedan copiar (la tarea, el dato y el puerto).
// Si estuviera dentro de correrConProgreso podría arrastrar sin querer la
// función alProgreso, que depende de la pantalla y no se puede copiar.
Future<R> _lanzar<A, R>(
    R Function(A, void Function(double)) tarea,
    A argumento,
    SendPort puerto,
    ) {
  return Isolate.run(() => tarea(argumento, (f) => puerto.send(f)));
}
