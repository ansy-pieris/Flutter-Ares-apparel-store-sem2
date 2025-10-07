import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as material;
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

/// FootwearProductsScreen displays footwear category products
///
/// This screen demonstrates:
/// - Category-specific product filtering using ProductProvider API
/// - Responsive grid layout for different orientations
/// - Integration with enhanced ProductCard and ProductDetailScreen
/// - Material 3 theming with proper navigation
class FootwearProductsScreen extends StatefulWidget {
  const FootwearProductsScreen({Key? key}) : super(key: key);

  @override
  State<FootwearProductsScreen> createState() => _FootwearProductsScreenState();
}

class _FootwearProductsScreenState extends State<FootwearProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.setCategory('Footwear');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: const material.Text("Footwear"), centerTitle: true),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading &&
              productProvider.filteredProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  material.Text(productProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productProvider.refreshProducts(),
                    child: const material.Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final products = productProvider.filteredProducts;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLandscape ? 3 : 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
