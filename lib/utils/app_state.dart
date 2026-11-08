import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/user.dart';
import 'constants.dart';

/// Єдине джерело правди (single source of truth) для застосунку.
///
/// Принципи:
///  * стан змінюється лише через методи класу;
///  * колекції оновлюються імутабельно (створюється нова колекція);
///  * публічні getters повертають незмінні копії;
///  * некоректні дії не кидають виняток у UI, а повертають `false`
///    і записують повідомлення в [lastError].
class AppState extends ChangeNotifier {
  AppState({User? user, ThemeMode themeMode = ThemeMode.system})
      : _currentUser = user,
        _themeMode = themeMode;

  List<Product> _favoriteProducts = const [];
  Map<Product, int> _cart = const {};
  User? _currentUser;
  ThemeMode _themeMode;
  String? _lastError;

  // ---- getters ----
  List<Product> get favoriteProducts => List.unmodifiable(_favoriteProducts);
  Map<Product, int> get cart => Map.unmodifiable(_cart);
  User? get currentUser => _currentUser;
  ThemeMode get themeMode => _themeMode;
  String? get lastError => _lastError;

  int get cartItemsCount => _cart.values.fold(0, (sum, qty) => sum + qty);

  double get cartTotal =>
      _cart.entries.fold(0.0, (sum, e) => sum + e.key.price * e.value);

  bool isFavorite(Product product) => _favoriteProducts.contains(product);

  // ---- favorites ----
  void toggleFavorite(Product product) {
    _favoriteProducts = isFavorite(product)
        ? _favoriteProducts.where((p) => p != product).toList()
        : [..._favoriteProducts, product];
    _lastError = null;
    notifyListeners();
  }

  // ---- cart ----
  /// Додає товар у кошик. Повертає `false`, якщо дію відхилено.
  bool addToCart(Product product, {int quantity = 1}) {
    if (quantity <= 0) {
      return _fail('Кількість має бути більшою за 0');
    }
    final current = _cart[product] ?? 0;
    if (current + quantity > AppConstants.maxCartQuantity) {
      return _fail(
        'Максимум ${AppConstants.maxCartQuantity} одиниць одного товару',
      );
    }
    _cart = {..._cart, product: current + quantity};
    _lastError = null;
    notifyListeners();
    return true;
  }

  void removeFromCart(Product product) {
    if (!_cart.containsKey(product)) return;
    _cart = Map.of(_cart)..remove(product);
    notifyListeners();
  }

  void clearCart() {
    if (_cart.isEmpty) return;
    _cart = const {};
    notifyListeners();
  }

  // ---- user ----
  /// Оновлює профіль після валідації. Повертає `false`, якщо дані некоректні.
  bool updateUser({required String name, required String email}) {
    if (!User.isValidName(name)) {
      return _fail("Ім'я має містити щонайменше 2 символи");
    }
    if (!User.isValidEmail(email)) {
      return _fail('Некоректний email');
    }
    final base = _currentUser ?? const User(id: 'local', name: '', email: '');
    _currentUser = base.copyWith(name: name.trim(), email: email.trim());
    _lastError = null;
    notifyListeners();
    return true;
  }

  // ---- theme ----
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  bool _fail(String message) {
    _lastError = message;
    notifyListeners();
    return false;
  }
}

/// Прокидає [AppState] вниз по дереву без сторонніх залежностей.
/// Віджети, що викликають [AppScope.of], автоматично перебудовуються при змінах.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope не знайдено над цим віджетом');
    return scope!.notifier!;
  }
}
