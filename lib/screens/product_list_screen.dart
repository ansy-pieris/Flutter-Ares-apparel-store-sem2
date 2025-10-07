import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

import '../models/product.dart';
import 'product_detail_screen.dart';
import '../widgets/product_card.dart';

/// Master list screen showing all products with filtering and search capabilities
/// Implements master/detail pattern with navigation to product detail screen
class ProductListScreen extends StatefulWidget {
  final String? initialCategory;

  const ProductListScreen({super.key, this.initialCategory});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for smooth transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize products and set initial category if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.initializeProducts();

      if (widget.initialCategory != null) {
        productProvider.setCategory(widget.initialCategory!);
      }

      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Filter and sort actions
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'featured':
                      productProvider.toggleFeaturedFilter();
                      break;
                    case 'sale':
                      productProvider.toggleSaleFilter();
                      break;
                    case 'clear':
                      productProvider.clearFilters();
                      break;
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'featured',
                        child: Row(
                          children: [
                            Icon(
                              productProvider.showOnlyFeatured
                                  ? Icons.star
                                  : Icons.star_border,
                              color:
                                  productProvider.showOnlyFeatured
                                      ? Colors.amber
                                      : null,
                            ),
                            const SizedBox(width: 8),
                            const Text('Featured Only'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'sale',
                        child: Row(
                          children: [
                            Icon(
                              productProvider.showOnlySale
                                  ? Icons.local_offer
                                  : Icons.local_offer_outlined,
                              color:
                                  productProvider.showOnlySale
                                      ? Colors.red
                                      : null,
                            ),
                            const SizedBox(width: 8),
                            const Text('On Sale Only'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'clear',
                        child: Row(
                          children: [
                            Icon(Icons.clear),
                            SizedBox(width: 8),
                            Text('Clear Filters'),
                          ],
                        ),
                      ),
                    ],
                icon: Stack(
                  children: [
                    const Icon(Icons.filter_list),
                    if (productProvider.hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search and filter section
            _buildSearchAndFilters(),

            // Products count and sort
            _buildProductsHeader(),

            // Products grid
            Expanded(child: _buildProductsGrid()),
          ],
        ),
      ),
    );
  }

  /// Build simple category filters (removed search functionality)
  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Category and subcategory filters
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              return Row(
                children: [
                  // Category dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: productProvider.selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          productProvider
                              .getAvailableCategories()
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          productProvider.setCategory(value);
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Subcategory dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: productProvider.selectedSubcategory,
                      decoration: InputDecoration(
                        labelText: 'Subcategory',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          productProvider
                              .getAvailableSubcategories()
                              .map(
                                (subcategory) => DropdownMenuItem(
                                  value: subcategory,
                                  child: Text(subcategory),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          productProvider.setSubcategory(value);
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build products count header with sort options
  Widget _buildProductsHeader() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${productProvider.filteredProductsCount} of ${productProvider.totalProductsCount} products',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),

              // Sort dropdown
              DropdownButton<String>(
                value: productProvider.sortBy,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('Name')),
                  DropdownMenuItem(
                    value: 'price_low',
                    child: Text('Price: Low to High'),
                  ),
                  DropdownMenuItem(
                    value: 'price_high',
                    child: Text('Price: High to Low'),
                  ),
                  DropdownMenuItem(value: 'rating', child: Text('Rating')),
                  DropdownMenuItem(value: 'newest', child: Text('Newest')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    productProvider.setSortBy(value);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build products grid with animated cards
  Widget _buildProductsGrid() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = productProvider.filteredProducts;

        if (products.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutBack,
              child: GestureDetector(
                onTap: () => _navigateToProductDetail(product),
                child: Hero(
                  tag: 'product_${product.id}',
                  child: ProductCard(product: product),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Build empty state when no products found
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Provider.of<ProductProvider>(
                context,
                listen: false,
              ).clearFilters();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  /// Navigate to product detail screen with animation
  void _navigateToProductDetail(Product product) {
    // Update selected product in provider
    Provider.of<ProductProvider>(context, listen: false).selectProduct(product);

    // Navigate with custom page transition
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                ProductDetailScreen(product: product),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}
