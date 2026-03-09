import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_cloudfit/main.dart'; // Ajusta según el nombre de tu proyecto

void main() {
  testWidgets('Cloudfit smoke test', (tester) async {
    // Carga la aplicación
    await tester.pumpWidget(const MainApp());

    // Verifica que el saludo inicial aparezca en pantalla
    expect(find.text('Hola, Daniel'), findsOneWidget);
    
    // Verifica que el título de la sección "Prepárate" esté presente
    expect(find.text('Prepárate'), findsOneWidget);
    
    // Verifica que no existan elementos del contador (el default de Flutter)
    expect(find.text('0'), findsNothing);
  });
}