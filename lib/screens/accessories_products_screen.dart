import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class AccessoriesProductsScreen extends StatelessWidget {
  final List<Product> products = [
    Product(name: 'Watch', price: 2499.0, image: 'assets/images/watch.jpg'),
    Product(name: 'Sunglasses', price: 1999.0, image: 'assets/images/sun.jpg'),
    Product(name: 'Wallets', price: 1599.0, image: 'assets/images/wallet.webp'),
    Product(name: 'Caps', price: 799.0, image: 'assets/images/cap.jpg'),
    Product(name: 'Stylish Bracelets', price: 1299.0, image: 'assets/images/brace.webp'),
    Product(name: 'Stylish Rings', price: 999.0, image: 'assets/images/ring.webp'),
  ];

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: const Text("Accessories"), centerTitle: true),
      body: GridView.builder(
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
                  builder: (_) => ProductDetailScreen(
                    name: product.name,
                    price: product.price,
                    image: product.image,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
