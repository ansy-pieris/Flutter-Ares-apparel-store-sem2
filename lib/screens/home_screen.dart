import 'package:flutter/material.dart' hide Text, SizedBox;
import 'package:flutter/material.dart' as material;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

/// HomeScreen serves as the main dashboard for the ARES Apparel Store app.
///
/// This screen demonstrates several key Flutter concepts:
/// - Image carousel with auto-play functionality using CarouselSlider
/// - Horizontal scrollable product lists with ProductCard widgets
/// - Responsive layout that adapts to different screen sizes
/// - Integration with ProductProvider for live API data
/// - Material Design 3 styling with consistent theming
///
/// Features displayed:
/// - Hero banner carousel showcasing brand imagery
/// - "Best Sellers" section with horizontally scrollable product cards
/// - "Featured Products" section with product grid layout
/// - Smooth animations and transitions throughout the interface
/// - Uses enhanced Product model with comprehensive product data from Laravel API
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Get best selling products from ProductProvider
  List<Product> getBestSellers(ProductProvider productProvider) {
    // Return products with high ratings as best sellers, or fallback to first products
    final highRated =
        productProvider.allProducts
            .where((product) => product.rating >= 4.5)
            .toList();

    if (highRated.isNotEmpty) {
      return highRated.take(4).toList();
    }

    // Fallback to first 4 products if no high-rated products
    return productProvider.allProducts.take(4).toList();
  }

  /// Get featured products from ProductProvider
  List<Product> getFeaturedProducts(ProductProvider productProvider) {
    // Return featured products from API, or fallback to first products
    final featured =
        productProvider.allProducts
            .where((product) => product.isFeatured)
            .toList();

    if (featured.isNotEmpty) {
      return featured.take(6).toList();
    }

    // Fallback to first 6 products if no featured products
    return productProvider.allProducts.take(6).toList();
  }

  final List<String> carouselImages = [
    'assets/images/Ares.jpg',
    'assets/images/hero.jpg',
    'assets/images/hero2.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset('assets/images/Logo2.png', width: 70, height: 70),
            const material.SizedBox(width: 8),
            const material.Text(
              'ARES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: isPortrait ? 240 : 180,
                aspectRatio: isPortrait ? 16 / 9 : 21 / 9,
                viewportFraction: 0.9,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
              items:
                  carouselImages.map((imagePath) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imagePath,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                material.Text(
                                  'Image not found',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
            ),
            const material.SizedBox(height: 20),

            material.Text(
              "Best Sellers",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const material.SizedBox(height: 10),
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final bestSellers = getBestSellers(productProvider);

                // Debug output
                debugPrint('=== HOME SCREEN DEBUG ===');
                debugPrint(
                  'All products count: ${productProvider.allProducts.length}',
                );
                debugPrint('Best sellers count: ${bestSellers.length}');
                debugPrint('Is loading: ${productProvider.isLoading}');
                debugPrint('Error: ${productProvider.errorMessage}');
                if (bestSellers.isNotEmpty) {
                  debugPrint('First product: ${bestSellers.first.name}');
                }

                if (productProvider.isLoading && bestSellers.isEmpty) {
                  return const material.SizedBox(
                    height: 260,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (bestSellers.isEmpty && !productProvider.isLoading) {
                  return const material.SizedBox(
                    height: 260,
                    child: Center(
                      child: material.Text(
                        'No products available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return material.SizedBox(
                  height: isPortrait ? 260 : 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: bestSellers.length,
                    separatorBuilder:
                        (_, __) => const material.SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return material.SizedBox(
                        width: isPortrait ? 160 : 200,
                        child: ProductCard(product: bestSellers[index]),
                      );
                    },
                  ),
                );
              },
            ),
            const material.SizedBox(height: 20),

            material.Text(
              "Featured Products",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const material.SizedBox(height: 10),
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final featuredProducts = getFeaturedProducts(productProvider);

                if (productProvider.isLoading && featuredProducts.isEmpty) {
                  return const material.SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isPortrait ? 2 : 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isPortrait ? 0.65 : 0.8,
                  children:
                      featuredProducts.map((product) {
                        return ProductCard(product: product);
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
