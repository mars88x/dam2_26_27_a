import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controlador = PageController();
  int _pagina = 0;

  static const _paginas = [
    ('Bienvenido', 'Esta app te permite enviar y leer mensajes.', Icons.waving_hand),
    ('Tu perfil', 'Crea tu cuenta y guarda tus datos.', Icons.person),
    ('Tus mensajes', 'Consulta tus mensajes en tiempo real.', Icons.chat),
  ];

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _terminar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_visto', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final esUltima = _pagina == _paginas.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _terminar,
                child: const Text('Saltar'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controlador,
                itemCount: _paginas.length,
                onPageChanged: (i) => setState(() => _pagina = i),
                itemBuilder: (context, i) {
                  final (titulo, texto, icono) = _paginas[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icono, size: 100),
                        const SizedBox(height: 24),
                        Text(titulo,
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(texto, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: esUltima
                    ? _terminar
                    : () => _controlador.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: Text(esUltima ? 'Empezar' : 'Siguiente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}