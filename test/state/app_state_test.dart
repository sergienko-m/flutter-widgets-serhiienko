import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_widgets_app/models/product.dart';
import 'package:mobile_widgets_app/models/user.dart';
import 'package:mobile_widgets_app/utils/app_state.dart';
import 'package:mobile_widgets_app/utils/constants.dart';

const _p1 = Product(
  id: 'a',
  title: 'A',
  description: '',
  price: 100,
  category: 'c',
  emoji: '🅰️',
  colorValue: 0xFF000000,
);
const _p2 = Product(
  id: 'b',
  title: 'B',
  description: '',
  price: 50,
  category: 'c',
  emoji: '🅱️',
  colorValue: 0xFF000000,
);

void main() {
  group('AppState favorites', () {
    test('toggleFavorite adds and removes, notifying listeners', () {
      final state = AppState();
      var notifications = 0;
      state.addListener(() => notifications++);

      state.toggleFavorite(_p1);
      expect(state.isFavorite(_p1), isTrue);
      expect(state.favoriteProducts, [_p1]);

      state.toggleFavorite(_p1);
      expect(state.isFavorite(_p1), isFalse);
      expect(state.favoriteProducts, isEmpty);
      expect(notifications, 2);
    });

    test('exposed collections are unmodifiable', () {
      final state = AppState()..toggleFavorite(_p1);

      expect(() => state.favoriteProducts.add(_p2), throwsUnsupportedError);
      expect(() => state.cart[_p1] = 5, throwsUnsupportedError);
    });
  });

  group('AppState cart', () {
    test('addToCart accumulates quantity and total', () {
      final state = AppState();

      expect(state.addToCart(_p1), isTrue);
      expect(state.addToCart(_p1, quantity: 2), isTrue);
      expect(state.addToCart(_p2), isTrue);

      expect(state.cart[_p1], 3);
      expect(state.cartItemsCount, 4);
      expect(state.cartTotal, 350);
    });

    test('rejects non-positive quantity', () {
      final state = AppState();

      expect(state.addToCart(_p1, quantity: 0), isFalse);
      expect(state.lastError, isNotNull);
      expect(state.cartItemsCount, 0);
    });

    test('rejects exceeding the per-item limit', () {
      final state = AppState();

      expect(state.addToCart(_p1, quantity: AppConstants.maxCartQuantity), isTrue);
      expect(state.addToCart(_p1), isFalse);
      expect(state.cart[_p1], AppConstants.maxCartQuantity);
      expect(state.lastError, contains('Максимум'));
    });

    test('removeFromCart and clearCart', () {
      final state = AppState()
        ..addToCart(_p1)
        ..addToCart(_p2);

      state.removeFromCart(_p1);
      expect(state.cart.containsKey(_p1), isFalse);
      expect(state.cartItemsCount, 1);

      state.clearCart();
      expect(state.cart, isEmpty);
    });
  });

  group('AppState user', () {
    test('updateUser validates input', () {
      final state = AppState(
        user: const User(id: '1', name: 'Old Name', email: 'old@example.com'),
      );

      expect(state.updateUser(name: 'A', email: 'x@y.com'), isFalse);
      expect(state.updateUser(name: 'New Name', email: 'bad-email'), isFalse);
      expect(state.currentUser?.name, 'Old Name');

      expect(state.updateUser(name: ' New Name ', email: 'new@example.com'), isTrue);
      expect(state.currentUser?.name, 'New Name');
      expect(state.currentUser?.email, 'new@example.com');
      expect(state.currentUser?.id, '1');
      expect(state.lastError, isNull);
    });
  });

  group('AppState theme', () {
    test('setThemeMode notifies only on change', () {
      final state = AppState(themeMode: ThemeMode.light);
      var notifications = 0;
      state.addListener(() => notifications++);

      state.setThemeMode(ThemeMode.light);
      state.setThemeMode(ThemeMode.dark);

      expect(notifications, 1);
      expect(state.themeMode, ThemeMode.dark);
    });
  });

  group('User model', () {
    test('initials', () {
      expect(const User(id: '1', name: 'Іван Петренко', email: 'a@b.c').initials, 'ІП');
      expect(const User(id: '1', name: 'Марія', email: 'a@b.c').initials, 'М');
      expect(const User(id: '1', name: '  ', email: 'a@b.c').initials, '?');
    });

    test('email validation', () {
      expect(User.isValidEmail('a@b.co'), isTrue);
      expect(User.isValidEmail('a@b'), isFalse);
      expect(User.isValidEmail('a b@c.d'), isFalse);
    });
  });
}
