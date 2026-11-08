import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Власні токени дизайн-системи, доступні через `Theme.of(context)`.
/// Дозволяє віджетам (CustomButton, ProfileWidget, ...) стилізуватись через Theme.
@immutable
class AppStyle extends ThemeExtension<AppStyle> {
  const AppStyle({
    required this.danger,
    required this.onDanger,
    required this.success,
    required this.radius,
  });

  final Color danger;
  final Color onDanger;
  final Color success;
  final double radius;

  static const AppStyle light = AppStyle(
    danger: Color(0xFFC62828),
    onDanger: Colors.white,
    success: Color(0xFF2E7D32),
    radius: 16,
  );

  static const AppStyle dark = AppStyle(
    danger: Color(0xFFEF5350),
    onDanger: Color(0xFF2B0000),
    success: Color(0xFF66BB6A),
    radius: 16,
  );

  /// Безпечний доступ: якщо розширення не додано до теми — береться light.
  static AppStyle of(BuildContext context) =>
      Theme.of(context).extension<AppStyle>() ?? light;

  @override
  AppStyle copyWith({
    Color? danger,
    Color? onDanger,
    Color? success,
    double? radius,
  }) {
    return AppStyle(
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      success: success ?? this.success,
      radius: radius ?? this.radius,
    );
  }

  @override
  AppStyle lerp(ThemeExtension<AppStyle>? other, double t) {
    if (other is! AppStyle) return this;
    return AppStyle(
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      success: Color.lerp(success, other.success, t)!,
      radius: lerpDouble(radius, other.radius, t)!,
    );
  }
}

class AppThemes {
  AppThemes._();

  static const Color seed = Color(0xFF3F51B5);

  static ThemeData get light => _build(Brightness.light, AppStyle.light);

  static ThemeData get dark => _build(Brightness.dark, AppStyle.dark);

  static ThemeData _build(Brightness brightness, AppStyle style) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
      extensions: <ThemeExtension<dynamic>>[style],
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }
}
