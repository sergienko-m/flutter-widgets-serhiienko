import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_widgets_app/main.dart';
import 'package:mobile_widgets_app/utils/constants.dart';

/// Інтеграційний (на рівні віджетів) сценарій:
/// каталог -> додати в кошик -> обране -> профіль.
void main() {
  testWidgets('user can add a product to cart and see it in the profile',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Бібліотека компонентів'), findsOneWidget);

    // 1. перехід у каталог, чекаємо на завершення "завантаження"
    await tester.tap(find.text('Товари'));
    await tester.pumpAndSettle();
    expect(find.text('Каталог товарів'), findsOneWidget);

    // 2. додаємо перший товар у кошик
    final first = kMockProducts.first;
    final addButton = find.byKey(Key('add_to_cart_${first.id}'));
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const Key('cart_badge')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );

    // 3. додаємо в обране
    final favButton = find.byKey(Key('favorite_${first.id}'));
    await tester.ensureVisible(favButton);
    await tester.pumpAndSettle();
    await tester.tap(favButton);
    await tester.pumpAndSettle();

    // 4. профіль показує і кошик, і обране
    await tester.tap(find.text('Профіль'));
    await tester.pumpAndSettle();

    expect(find.text('Мій профіль'), findsOneWidget);
    expect(find.byKey(ValueKey('cart_${first.id}')), findsOneWidget);
    expect(find.byKey(ValueKey('fav_${first.id}')), findsOneWidget);
  });
}
