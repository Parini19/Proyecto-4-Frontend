import 'package:flutter_test/flutter_test.dart';
import 'package:cinema_frontend/app.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Renderiza la app principal
    await tester.pumpWidget(const CinemaApp());
    expect(find.byType(CinemaApp), findsOneWidget);
  });
}
