import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class MenProductsScreen extends StatelessWidget {
  final List<Product> products = [
    Product(name: 'Men T-Shirt', price: 1999.0, image: 'assets/images/shirt.jpg'),
    Product(name: 'Mens Jeans', price: 2999.0, image: 'assets/images/jeans.jpg'),
    Product(name: 'Jacket', price: 3599.0, image: 'assets/images/jacket.jpg'),
    Product(name: 'Shirt', price: 2599.0, image: 'assets/images/shirts1.jpg'),
    Product(name: 'Shorts', price: 1599.0, image: 'assets/images/shorts.jpg'),
    Product(name: 'Blazer', price: 4999.0, image: 'assets/images/blazer.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: const Text("Men's Products"), centerTitle: true),
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
