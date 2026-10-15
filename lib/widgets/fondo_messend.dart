import 'package:flutter/material.dart';
import '../theme/app_tema.dart';

// Fondo de las pantallas
class FondoMessend extends StatelessWidget {
  final Widget child;
  const FondoMessend({super.key, required this.child});

  Widget _burbuja(double tamano, Color color) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD6ECFA), Color(0xFFEAF6FD), Color(0xFFE3F5E4)],
            ),
          ),
        ),
        Positioned(
            top: -80,
            right: -60,
            child: _burbuja(280, Colors.white.withValues(alpha: 0.9))),
        Positioned(
            top: 220,
            left: -50,
            child: _burbuja(160, AppTema.principal.withValues(alpha: 0.15))),
        Positioned(
            bottom: 60,
            left: -90,
            child: _burbuja(300, AppTema.acento.withValues(alpha: 0.25))),
        child,
      ],
    );
  }
}