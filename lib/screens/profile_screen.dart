import 'package:flutter/material.dart';

import '../models/user.dart';
import '../utils/app_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/profile_widget.dart';

/// Профіль, статистика, обране та кошик (ListView).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final user = app.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return const Center(child: Text('Користувач не авторизований'));
    }

    final favorites = app.favoriteProducts;
    final cartEntries = app.cart.entries.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProfileWidget(
          user: user,
          onEditPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const _EditProfileDialog(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _StatTile(
              icon: Icons.favorite,
              value: '${favorites.length}',
              label: 'Обране',
            ),
            _StatTile(
              icon: Icons.shopping_cart,
              value: '${app.cartItemsCount}',
              label: 'У кошику',
            ),
            _StatTile(
              icon: Icons.payments_outlined,
              value: app.cartTotal.toStringAsFixed(0),
              label: 'Сума, ₴',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Обране', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        if (favorites.isEmpty)
          const Text('Порожньо. Свайпніть картку товару вбік або натисніть ♡.')
        else
          Card(
            child: Column(
              children: [
                for (final p in favorites)
                  ListTile(
                    key: ValueKey('fav_${p.id}'),
                    leading: CircleAvatar(child: Text(p.emoji)),
                    title: Text(p.title),
                    subtitle: Text(p.formattedPrice),
                    trailing: IconButton(
                      tooltip: 'Прибрати з обраного',
                      icon: const Icon(Icons.favorite, color: Colors.redAccent),
                      onPressed: () => app.toggleFavorite(p),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Text('Кошик', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        if (cartEntries.isEmpty)
          const Text('Кошик порожній. Додайте товари в каталозі.')
        else
          Card(
            child: Column(
              children: [
                for (final e in cartEntries)
                  ListTile(
                    key: ValueKey('cart_${e.key.id}'),
                    leading: CircleAvatar(child: Text(e.key.emoji)),
                    title: Text(e.key.title),
                    subtitle: Text('${e.value} × ${e.key.formattedPrice}'),
                    trailing: IconButton(
                      tooltip: 'Видалити з кошика',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => app.removeFromCart(e.key),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: CustomButton(
            text: 'Очистити кошик',
            style: CustomButtonStyle.danger,
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            onPressed: cartEntries.isEmpty ? null : app.clearCart,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Діалог редагування профілю з валідацією форми.
class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog();

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    // AppScope знаходиться над MaterialApp, тому доступний і в діалозі
    final user = context.getInheritedWidgetOfExactType<AppScope>()?.notifier?.currentUser;
    _name = TextEditingController(text: user?.name ?? '');
    _email = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final app = AppScope.of(context);
    if (app.updateUser(name: _name.text, email: _email.text)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редагувати профіль'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('edit_name_field'),
                controller: _name,
                decoration: const InputDecoration(
                  labelText: "Ім'я",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    User.isValidName(v ?? '') ? null : 'Мінімум 2 символи',
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('edit_email_field'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    User.isValidEmail(v ?? '') ? null : 'Введіть коректний email',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        FilledButton(onPressed: _save, child: const Text('Зберегти')),
      ],
    );
  }
}
