import 'package:flutter/material.dart';

import '../utils/app_state.dart';
import '../utils/constants.dart';
import 'products_screen.dart';
import 'profile_screen.dart';
import 'showcase_screen.dart';

/// Головний екран: Scaffold + AppBar + адаптивна навігація.
/// Вузькі екрани — NavigationBar знизу, широкі (>= 720) — NavigationRail збоку.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = [
    'Бібліотека компонентів',
    'Каталог товарів',
    'Мій профіль',
  ];

  static const _destinations =
      <({IconData icon, IconData selectedIcon, String label})>[
    (icon: Icons.widgets_outlined, selectedIcon: Icons.widgets, label: 'Віджети'),
    (
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront,
      label: 'Товари'
    ),
    (icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Профіль'),
  ];

  static const _pages = <Widget>[
    ShowcaseScreen(),
    ProductsScreen(),
    ProfileScreen(),
  ];

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide =
        MediaQuery.sizeOf(context).width >= AppConstants.breakpointWide;

    // IndexedStack зберігає стан вкладок; TickerMode зупиняє анімації неактивних.
    final body = IndexedStack(
      index: _index,
      children: [
        for (var i = 0; i < _pages.length; i++)
          TickerMode(enabled: i == _index, child: _pages[i]),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Змінити тему',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => app.setThemeMode(
              isDark ? ThemeMode.light : ThemeMode.dark,
            ),
          ),
          IconButton(
            tooltip: 'Кошик',
            onPressed: () => _select(2),
            icon: Badge(
              key: const Key('cart_badge'),
              isLabelVisible: app.cartItemsCount > 0,
              label: Text('${app.cartItemsCount}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in _destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
    );
  }
}
