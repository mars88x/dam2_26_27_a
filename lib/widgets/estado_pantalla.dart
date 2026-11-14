import 'package:flutter/material.dart';
import '../theme/app_tema.dart';

// Pantalla de estado (error, vacío...) con icono, título, texto y,
// si se quiere, un botón. La usan Home, la cuadrícula y Buscar.
class EstadoPantalla extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String texto;
  final String? etiquetaBoton;
  final VoidCallback? alPulsar;

  const EstadoPantalla({
    super.key,
    required this.icono,
    required this.titulo,
    required this.texto,
    this.etiquetaBoton,
    this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTema.lavanda,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icono, size: 48, color: AppTema.principal),
            ),
            const SizedBox(height: 24),
            Text(titulo,
                textAlign: TextAlign.center,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(texto,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTema.textoSuave)),
            if (alPulsar != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: alPulsar,
                child: Text(etiquetaBoton ?? 'Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
