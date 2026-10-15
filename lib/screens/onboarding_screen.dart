import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_tema.dart';
import '../widgets/fondo_messend.dart';

// Datos de cada página: textos, color del panel y colores de las 4 fichas.
class _Pagina {
  final String titulo;
  final String texto;
  final Color panel;
  final List<Color> fichas;
  const _Pagina(this.titulo, this.texto, this.panel, this.fichas);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controlador = PageController();
  int _pagina = 0;

  static const _paginas = [
    _Pagina(
      'Tu gente, más cerca.',
      'Chatea con tus contactos y comparte esos pequeños grandes momentos.',
      Color(0xFFCDE9FA),
      [Colors.white, AppTema.principal, Color(0x99FFFFFF), Color(0xFFD5F0C8)],
    ),
    _Pagina(
      'Una conversación que no se detiene.',
      'Mensajes en tiempo real para sentirte cerca, estés donde estés.',
      Color(0xFFD5F0C8),
      [AppTema.acento, Colors.white, Color(0x99FFFFFF), AppTema.principal],
    ),
    _Pagina(
      'Tu perfil, siempre contigo.',
      'Un espacio que habla de ti. Tu identidad en cada conversación.',
      Color(0xFFFFD9B8),
      [Colors.white, Color(0xFFFF9F6B), Color(0xFFFFE9D6), Colors.white],
    ),
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

  // Una ficha redondeada del mosaico.
  Widget _ficha(Color color, double redondeo) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(redondeo),
        ),
      ),
    );
  }

  // Ilustración: panel de color con 4 fichas redondeadas.
  Widget _mosaico(_Pagina p) {
    return Container(
      height: 260,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(children: [
              _ficha(p.fichas[0], 24),
              _ficha(p.fichas[1], 60),
            ]),
          ),
          Expanded(
            child: Row(children: [
              _ficha(p.fichas[2], 24),
              _ficha(p.fichas[3], 24),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esUltima = _pagina == _paginas.length - 1;
    return Scaffold(
      body: FondoMessend(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
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
                        final p = _paginas[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _mosaico(p),
                              const SizedBox(height: 32),
                              Text(p.titulo,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppTema.texto)),
                              const SizedBox(height: 12),
                              Text(p.texto,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: AppTema.textoSuave)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _paginas.length,
                          (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _pagina ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _pagina
                              ? AppTema.principal
                              : AppTema.borde,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}