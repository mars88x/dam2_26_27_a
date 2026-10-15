import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_tema.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _urlImagen = 'https://picsum.photos/300';
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    _temporizador = Timer(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final visto = prefs.getBool('onboarding_visto') ?? false;
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, visto ? '/login' : '/onboarding');
    });
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppTema.degradadoSplash,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 170,
                height: 170,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.35),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(
                  child: Image.network(
                    _urlImagen,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progreso) {
                      if (progreso == null) return child;
                      return const SizedBox(
                        width: 150,
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 150,
                        height: 150,
                        color: Colors.white24,
                        child: const Icon(Icons.broken_image,
                            size: 64, color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Messend',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Más cerca, en cada mensaje.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}