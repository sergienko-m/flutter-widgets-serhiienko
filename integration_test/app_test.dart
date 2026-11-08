import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_widgets_app/main.dart' as app;
import 'package:mobile_widgets_app/utils/constants.dart';

/// Запуск: flutter test integration_test  (потрібен емулятор/пристрій/Chrome)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('catalog -> add to cart -> badge updates', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Товари'));
    await tester.pumpAndSettle();

    final add = find.byKey(Key('add_to_cart_${kMockProducts.first.id}'));
    await tester.ensureVisible(add);
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const Key('cart_badge')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });
}
