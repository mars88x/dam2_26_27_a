import 'package:flutter_test/flutter_test.dart';

import 'package:dam2_26_27_a/MiApp.dart';

void main() {
  testWidgets('La app arranca en el splash y pasa al login', (WidgetTester tester) async {
    await tester.pumpWidget(const MiApp());
    expect(find.text('Mi App'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Registrarse'), findsOneWidget);
  });
}