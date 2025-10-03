import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinema_frontend/app.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: CinemaApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CinemaApp), findsOneWidget);
  });
}
