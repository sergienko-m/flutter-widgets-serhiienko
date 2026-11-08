import 'package:flutter/material.dart';

import '../utils/themes.dart';

enum CustomButtonStyle { primary, secondary, danger, outline }

/// Універсальна кнопка (StatelessWidget).
///
/// Приклад:
/// ```dart
/// CustomButton(
///   text: 'Зберегти',
///   style: CustomButtonStyle.primary,
///   icon: Icon(Icons.save_outlined, size: 18),
///   isLoading: false,
///   onPressed: () {},
/// )
/// ```
/// Кольори беруться з `Theme` (ColorScheme + розширення [AppStyle]).
/// Якщо [onPressed] == null або [isLoading] == true — кнопка неактивна.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = CustomButtonStyle.primary,
    this.icon,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final CustomButtonStyle style;
  final Widget? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appStyle = AppStyle.of(context);

    final Color foreground = switch (style) {
      CustomButtonStyle.primary => scheme.onPrimary,
      CustomButtonStyle.secondary => scheme.onSecondaryContainer,
      CustomButtonStyle.danger => appStyle.onDanger,
      CustomButtonStyle.outline => scheme.primary,
    };
    final Color? background = switch (style) {
      CustomButtonStyle.primary => scheme.primary,
      CustomButtonStyle.secondary => scheme.secondaryContainer,
      CustomButtonStyle.danger => appStyle.danger,
      CustomButtonStyle.outline => null,
    };

    final VoidCallback? handler = isLoading ? null : onPressed;
    const minimumSize = Size(64, 48);

    final Widget content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
            ],
          );

    if (style == CustomButtonStyle.outline) {
      return OutlinedButton(
        onPressed: handler,
        style: OutlinedButton.styleFrom(
          minimumSize: minimumSize,
          foregroundColor: foreground,
          disabledForegroundColor: isLoading ? foreground : null,
        ),
        child: content,
      );
    }

    return FilledButton(
      onPressed: handler,
      style: FilledButton.styleFrom(
        minimumSize: minimumSize,
        backgroundColor: background,
        foregroundColor: foreground,
        // під час завантаження зберігаємо вигляд кнопки, а не "сірий" disabled
        disabledBackgroundColor: isLoading ? background : null,
        disabledForegroundColor: isLoading ? foreground : null,
      ),
      child: content,
    );
  }
}
