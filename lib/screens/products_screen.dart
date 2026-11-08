import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/app_state.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer.dart';

/// Каталог: CustomScrollView + SliverGrid / SliverList.
/// Імітує завантаження даних (shimmer-скелетон), підтримує фільтр за категорією
/// та перемикання "сітка / список".
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _loading = true;
  bool _grid = true;
  String? _category;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    // імітація мережевого запиту
    _loadingTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _addToCart(AppState app, Product product) {
    final ok = app.addToCart(product);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
          content: Text(
            ok
                ? '«${product.title}» додано до кошика'
                : app.lastError ?? 'Не вдалося додати товар',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final categories = kMockProducts.map((p) => p.category).toSet().toList();
    final products = _category == null
        ? kMockProducts
        : kMockProducts.where((p) => p.category == _category).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Знайдено: ${products.length}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.grid_view),
                          tooltip: 'Сітка',
                        ),
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.view_list),
                          tooltip: 'Список',
                        ),
                      ],
                      selected: {_grid},
                      onSelectionChanged: (s) => setState(() => _grid = s.first),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('Усі'),
                          selected: _category == null,
                          onSelected: (_) => setState(() => _category = null),
                        ),
                      ),
                      for (final c in categories)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(c),
                            selected: _category == c,
                            onSelected: (_) => setState(() => _category = c),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_loading)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            sliver: SliverGrid(
              gridDelegate: _gridDelegate,
              delegate: SliverChildBuilderDelegate(
                (context, index) => const _SkeletonCard(),
                childCount: 6,
              ),
            ),
          )
        else if (_grid)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            sliver: SliverGrid(
              gridDelegate: _gridDelegate,
              delegate: SliverChildBuilderDelegate(
                (context, index) => _card(app, products[index], compact: false),
                childCount: products.length,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _card(app, products[index], compact: true),
                  ),
                ),
                childCount: products.length,
              ),
            ),
          ),
      ],
    );
  }

  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 260,
    mainAxisExtent: 320,
    crossAxisSpacing: 4,
    mainAxisSpacing: 4,
  );

  Widget _card(AppState app, Product product, {required bool compact}) {
    return ProductCard(
      key: ValueKey(product.id),
      product: product,
      isFavorite: app.isFavorite(product),
      imageAspectRatio: compact ? 16 / 9 : 4 / 3,
      onFavoriteToggle: () => app.toggleFavorite(product),
      onAddToCart: () => _addToCart(app, product),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ShimmerBox(borderRadius: BorderRadius.zero)),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 16),
                SizedBox(height: 8),
                ShimmerBox(width: 80, height: 14),
                SizedBox(height: 12),
                ShimmerBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
