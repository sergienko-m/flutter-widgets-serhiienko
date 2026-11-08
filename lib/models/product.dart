import 'package:flutter/foundation.dart';

/// Незмінна модель товару. Рівність визначається за [id],
/// тому товар можна безпечно використовувати як ключ у Map.
@immutable
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.emoji,
    required this.colorValue,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String category;

  /// Емодзі й колір використовуються як офлайн-"зображення" товару.
  final String emoji;
  final int colorValue;

  /// Якщо задано — показується мережеве зображення (з shimmer під час завантаження).
  final String? imageUrl;

  String get formattedPrice => '${price.toStringAsFixed(2)} ₴';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
