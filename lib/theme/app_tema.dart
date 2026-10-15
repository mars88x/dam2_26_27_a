import 'package:flutter/material.dart';

class AppTema {
  static const Color principal = Color(0xFF1E88D8); // azul agua
  static const Color acento = Color(0xFF6CC24A); // verde hoja
  static const Color fondo = Color(0xFFEAF6FD);
  static const Color superficie = Color(0xFFFFFFFF);
  static const Color texto = Color(0xFF0F3150);
  static const Color textoSuave = Color(0xFF5A7B93);
  static const Color borde = Color(0xFFD3E7F3);
  static const Color suave = Color(0xFFDCEFFB);
  static const Color lavanda = suave; // alias: así no hay que tocar otros archivos
  static const Color error = Color(0xFFD64550);
  static const Color errorSuave = Color(0xFFFDE8EA);

  // Colores pastel para avatares y tarjetas de la cuadrícula.
  static const List<Color> pasteles = [
    Color(0xFFFFD9B8), // melocotón
    Color(0xFFCDE9FA), // celeste
    Color(0xFFD5F0C8), // menta
    Color(0xFFFAD1E3), // rosa
    Color(0xFFFFF1B8), // limón
  ];

  // Degradado del splash.
  static const List<Color> degradadoSplash = [
    Color(0xFF1E88D8),
    Color(0xFF47B5E8),
    Color(0xFF7DD3A8),
  ];

  static const double radio = 16;

  static OutlineInputBorder _borde(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(radio),
    borderSide: BorderSide(color: color),
  );

  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(seedColor: principal).copyWith(
      primary: principal,
      onPrimary: Colors.white,
      secondary: acento,
      surface: superficie,
      onSurface: texto,
      error: error,
      outline: borde,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: fondo,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        foregroundColor: texto,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: texto,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radio),
          side: const BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        hintStyle: const TextStyle(color: textoSuave),
        border: _borde(borde),
        enabledBorder: _borde(borde),
        focusedBorder: _borde(principal),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: principal,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radio),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: principal,
          minimumSize: const Size(0, 54),
          side: const BorderSide(color: principal, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radio),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: textoSuave),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        indicatorColor: suave,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radio),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((estados) {
          final activo = estados.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
            color: activo ? principal : textoSuave,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((estados) {
          final activo = estados.contains(WidgetState.selected);
          return IconThemeData(color: activo ? principal : textoSuave);
        }),
      ),
    );
  }
}