import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import 'cors_safe_image.dart';
import '../providers/cart_provider.dart';

/// Enhanced ProductCard with animations, micro-interactions, and detailed information
/// Features hover effects, animated buttons, sale badges, and smooth transitions
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showQuickActions;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showQuickActions = true,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _buttonController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _buttonScaleAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Initialize hover animation controller
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Initialize button animation controller
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Scale animation for hover effect
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    // Elevation animation for hover effect
    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    // Button scale animation
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([_hoverController, _buttonController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => _onTapDown(),
            onTapUp: (_) => _onTapUp(),
            onTapCancel: () => _onTapUp(),
            child: MouseRegion(
              onEnter: (_) => _onHover(true),
              onExit: (_) => _onHover(false),
              child: Card(
                elevation: _elevationAnimation.value,
                shadowColor: colorScheme.shadow.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(),
                      _buildContentSection(),
                      if (widget.showQuickActions) _buildQuickActions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build image section with badges and overlay
  Widget _buildImageSection() {
    return Expanded(
      flex: 3,
      child: Stack(
        children: [
          // Product image
          Container(
            width: double.infinity,
            child: Hero(
              tag: 'product_image_${widget.product.id}',
              child:
                  widget.product.image.isNotEmpty &&
                          widget.product.image.startsWith('http')
                      ? CorsSafeImage(
                        imageUrl: widget.product.image,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        color: Colors.grey[200],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'No image',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ),

          // Sale badge
          if (widget.product.isOnSale)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${widget.product.discountPercentage.toInt()}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),

          // Featured badge
          if (widget.product.isFeatured)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 12),
              ),
            ),

          // Stock status overlay
          if (!widget.product.inStock)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: const Center(
                  child: Text(
                    'OUT OF STOCK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

          // Hover overlay with quick view
          if (_isHovered)
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isHovered ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build content section with product details
  Widget _buildContentSection() {
    final theme = Theme.of(context);

    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand name
            Text(
              widget.product.brand,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Product name
            Text(
              widget.product.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Rating
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < widget.product.rating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 12,
                  );
                }),
                const SizedBox(width: 4),
                Text(
                  '(${widget.product.reviewCount})',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),

            const Spacer(),

            // Price section
            Row(
              children: [
                Text(
                  widget.product.formattedPrice,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),

                if (widget.product.hasDiscount) ...[
                  const SizedBox(width: 6),
                  Text(
                    widget.product.formattedOriginalPrice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick actions section
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ScaleTransition(
              scale: _buttonScaleAnimation,
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  final isInCart = cartProvider.isInCart(widget.product.id);

                  return ElevatedButton.icon(
                    onPressed:
                        widget.product.inStock
                            ? () => _addToCart(cartProvider)
                            : null,
                    icon: Icon(
                      isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                      size: 16,
                    ),
                    label: Text(
                      isInCart ? 'In Cart' : 'Add',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor:
                          isInCart
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Favorite button
          IconButton(
            onPressed: _toggleFavorite,
            icon: const Icon(Icons.favorite_border),
            iconSize: 20,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Handle hover state changes
  void _onHover(bool isHovered) {
    if (mounted) {
      setState(() {
        _isHovered = isHovered;
      });

      if (isHovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }

  /// Handle tap down with animation
  void _onTapDown() {
    if (mounted) {
      _buttonController.forward();
    }
  }

  /// Handle tap up with animation
  void _onTapUp() {
    if (mounted) {
      _buttonController.reverse();
    }
  }

  /// Add product to cart with animation feedback
  void _addToCart(CartProvider cartProvider) {
    cartProvider.addItem(widget.product);

    // Show feedback with haptic
    HapticFeedback.selectionClick();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            cartProvider.removeItem(widget.product.id);
          },
        ),
      ),
    );
  }

  /// Toggle favorite status (placeholder)
  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to favorites'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
