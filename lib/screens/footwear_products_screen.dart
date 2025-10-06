import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class FootwearProductsScreen extends StatelessWidget {
  final List<Product> products = [
    Product(name: 'Sneakers', price: 2999.0, image: 'assets/images/sneakers.jpeg'),
    Product(name: 'Formal Shoes', price: 4599.0, image: 'assets/images/formal.jpg'),
    Product(name: 'High Heels', price: 1599.0, image: 'assets/images/heels.webp'),
    Product(name: 'Boots', price: 5499.0, image: 'assets/images/boots.webp'),
    Product(name: 'Flip-flops', price: 999.0, image: 'assets/images/flip.webp'),
    Product(name: 'Loafers', price: 3899.0, image: 'assets/images/loafers.webp'),
  ];

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: const Text("Footwear"), centerTitle: true),
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
