import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_widgets_app/models/product.dart';
import 'package:mobile_widgets_app/utils/themes.dart';
import 'package:mobile_widgets_app/widgets/product_card.dart';

const _product = Product(
  id: 't1',
  title: 'Тестовий товар',
  description: 'Опис',
  price: 10,
  category: 'Тест',
  emoji: '🎧',
  colorValue: 0xFF42A5F5,
);

Widget _wrap(Widget child) => MaterialApp(
      theme: AppThemes.light,
      home: Scaffold(
        body: SingleChildScrollView(child: SizedBox(width: 260, child: child)),
      ),
    );

void main() {
  group('ProductCard', () {
    testWidgets('renders title and formatted price', (tester) async {
      await tester.pumpWidget(_wrap(const ProductCard(product: _product)));

      expect(find.text('Тестовий товар'), findsOneWidget);
      expect(find.text('10.00 ₴'), findsOneWidget);
    });

    testWidgets('add to cart button calls callback', (tester) async {
      var added = 0;
      await tester.pumpWidget(
        _wrap(ProductCard(product: _product, onAddToCart: () => added++)),
      );

      await tester.tap(find.byKey(const Key('add_to_cart_t1')));
      await tester.pumpAndSettle();

      expect(added, 1);
    });

    testWidgets('favorite button calls callback', (tester) async {
      var toggled = 0;
      await tester.pumpWidget(
        _wrap(ProductCard(product: _product, onFavoriteToggle: () => toggled++)),
      );

      await tester.tap(find.byKey(const Key('favorite_t1')));
      await tester.pumpAndSettle();

      expect(toggled, 1);
    });

    testWidgets('swipe toggles favorite and keeps the card in the tree',
        (tester) async {
      var toggled = 0;
      await tester.pumpWidget(
        _wrap(ProductCard(product: _product, onFavoriteToggle: () => toggled++)),
      );

      await tester.drag(find.byType(Dismissible), const Offset(300, 0));
      await tester.pumpAndSettle();

      expect(toggled, 1);
      expect(find.text('Тестовий товар'), findsOneWidget);
    });

    testWidgets('heart icon reflects isFavorite', (tester) async {
      await tester.pumpWidget(_wrap(const ProductCard(product: _product)));
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.pumpWidget(
        _wrap(const ProductCard(product: _product, isFavorite: true)),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('tap on image opens zoom dialog', (tester) async {
      await tester.pumpWidget(_wrap(const ProductCard(product: _product)));

      await tester.tap(find.byType(ProductArt));
      await tester.pumpAndSettle();

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });
  });
}
