import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/themes.dart';
import 'bounce_tap.dart';
import 'shimmer.dart';

/// Інтерактивна картка товару (StatefulWidget).
///
///  * swipe в будь-який бік — додати/прибрати з обраного (Dismissible);
///  * tap по кнопках — пружинна анімація ([BounceTap]);
///  * tap по зображенню — збільшення (діалог з InteractiveViewer);
///  * shimmer — поки вантажиться мережеве зображення ([Product.imageUrl]);
///  * "пульс" сердечка при зміні [isFavorite] (didUpdateWidget + AnimationController).
///
/// Стан обраного належить [AppState], картка лише відображає [isFavorite]
/// і повідомляє про наміри через колбеки.
class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onAddToCart,
    this.imageAspectRatio = 4 / 3,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onAddToCart;
  final double imageAspectRatio;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _heartScale;
  bool _imagePressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70,
      ),
    ]).animate(_pulse);
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _pulse.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _setImagePressed(bool value) {
    if (_imagePressed != value) setState(() => _imagePressed = value);
  }

  void _openZoom() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: AspectRatio(
                aspectRatio: 1,
                child: ProductArt(product: widget.product),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton.filledTonal(
                tooltip: 'Закрити',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = AppStyle.of(context);
    final product = widget.product;
    final radius = BorderRadius.circular(style.radius);

    final card = Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTapDown: (_) => _setImagePressed(true),
                onTapUp: (_) => _setImagePressed(false),
                onTapCancel: () => _setImagePressed(false),
                onTap: _openZoom,
                child: AnimatedScale(
                  scale: _imagePressed ? 1.06 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: AspectRatio(
                    aspectRatio: widget.imageAspectRatio,
                    child: ProductArt(product: product),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: BounceTap(
                  child: IconButton.filledTonal(
                    key: Key('favorite_${product.id}'),
                    tooltip: widget.isFavorite
                        ? 'Прибрати з обраного'
                        : 'Додати в обране',
                    onPressed: widget.onFavoriteToggle,
                    icon: ScaleTransition(
                      scale: _heartScale,
                      child: Icon(
                        widget.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.isFavorite ? Colors.redAccent : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  product.formattedPrice,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: BounceTap(
                    child: FilledButton.tonalIcon(
                      key: Key('add_to_cart_${product.id}'),
                      onPressed: widget.onAddToCart,
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text('У кошик'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Dismissible(
      key: ValueKey('dismiss_${product.id}'),
      direction: DismissDirection.horizontal,
      // не видаляємо картку зі списку — лише перемикаємо "обране"
      confirmDismiss: (_) async {
        widget.onFavoriteToggle?.call();
        return false;
      },
      background: _swipeBackground(theme, radius, Alignment.centerLeft),
      secondaryBackground:
          _swipeBackground(theme, radius, Alignment.centerRight),
      child: card,
    );
  }

  Widget _swipeBackground(
    ThemeData theme,
    BorderRadius radius,
    Alignment alignment,
  ) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignment,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: radius,
      ),
      child: Icon(
        widget.isFavorite ? Icons.heart_broken : Icons.favorite,
        color: theme.colorScheme.onErrorContainer,
      ),
    );
  }
}

/// "Зображення" товару: мережеве (з shimmer) або градієнт з емодзі (офлайн).
class ProductArt extends StatelessWidget {
  const ProductArt({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final base = Color(product.colorValue);
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base.withAlpha(230), base.withAlpha(120)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = math.min(constraints.maxWidth, constraints.maxHeight);
          return Center(
            child: Text(
              product.emoji,
              style: TextStyle(fontSize: side * 0.45),
            ),
          );
        },
      ),
    );

    final url = product.imageUrl;
    if (url == null) return fallback;

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ShimmerBox(borderRadius: BorderRadius.zero);
      },
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
