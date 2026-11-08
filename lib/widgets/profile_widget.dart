import 'package:flutter/material.dart';

import '../models/user.dart';
import '../utils/themes.dart';
import 'custom_button.dart';

/// Профільна картка (StatelessWidget).
///
/// * [isCompact] — один рядок: аватар, ім'я, email та іконка редагування;
/// * розгорнутий режим адаптується до ширини: на широких екранах (>= 480)
///   аватар зліва, на вузьких — вертикальна компоновка.
/// Стилізація береться з Theme (ColorScheme, [AppStyle.radius]).
class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    super.key,
    required this.user,
    this.onEditPressed,
    this.isCompact = false,
  });

  final User user;
  final VoidCallback? onEditPressed;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final style = AppStyle.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(style.radius),
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12 : 20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isCompact) return _buildCompact(context);
            return constraints.maxWidth >= 480
                ? _buildWide(context)
                : _buildNarrow(context);
          },
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Row(
      children: [
        _avatar(context, 22),
        const SizedBox(width: 12),
        Expanded(child: _info(context, CrossAxisAlignment.start)),
        if (onEditPressed != null)
          IconButton(
            key: const Key('profile_edit_button'),
            tooltip: 'Редагувати профіль',
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEditPressed,
          ),
      ],
    );
  }

  Widget _buildWide(BuildContext context) {
    return Row(
      children: [
        _avatar(context, 44),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _info(context, CrossAxisAlignment.start),
              if (onEditPressed != null) ...[
                const SizedBox(height: 12),
                _editButton(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrow(BuildContext context) {
    return Column(
      children: [
        _avatar(context, 44),
        const SizedBox(height: 12),
        _info(context, CrossAxisAlignment.center),
        if (onEditPressed != null) ...[
          const SizedBox(height: 12),
          _editButton(),
        ],
      ],
    );
  }

  Widget _editButton() {
    return CustomButton(
      key: const Key('profile_edit_button'),
      text: 'Редагувати',
      style: CustomButtonStyle.outline,
      icon: const Icon(Icons.edit_outlined, size: 18),
      onPressed: onEditPressed,
    );
  }

  Widget _avatar(BuildContext context, double radius) {
    final scheme = Theme.of(context).colorScheme;
    final url = user.avatarUrl;
    return Semantics(
      label: 'Аватар ${user.name}',
      child: CircleAvatar(
        radius: radius,
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        foregroundImage: url != null ? NetworkImage(url) : null,
        onForegroundImageError: url != null ? (_, __) {} : null,
        child: Text(
          user.initials,
          style: TextStyle(fontSize: radius * 0.8, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _info(BuildContext context, CrossAxisAlignment alignment) {
    final theme = Theme.of(context);
    final textAlign =
        alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          user.name,
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          user.email,
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
