import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';

class HomeScreen extends StatelessWidget {
  final List<Product> bestSellers = [
    Product(name: 'Sneakers', price: 14500.00, image: 'assets/images/sneakers.jpeg'),
    Product(name: 'Watch', price: 20000.00, image: 'assets/images/watch.jpg'),
    Product(name: 'T-Shirt', price: 6000.00, image: 'assets/images/shirt.jpg'),
    Product(name: 'Shirt-style collar', price: 7500.00, image: 'assets/images/womens.jpg'),
  ];

  final List<Product> featuredProducts = [
    Product(name: 'Jeans', price: 11500.00, image: 'assets/images/shirts.jpg'),
    Product(name: 'Shirts', price: 5750.00, image: 'assets/images/shirts1.jpg'),
    Product(name: 'T-shirts', price: 6000.00, image: 'assets/images/shirt.jpg'),
    Product(name: 'Shirt-style collar', price: 7500.00, image: 'assets/images/womens.jpg'),
    Product(name: 'Sneakers', price: 14500.00, image: 'assets/images/sneakers.jpeg'),
    Product(name: 'Watch', price: 20000.00, image: 'assets/images/watch.jpg'),
  ];

  final List<String> carouselImages = [
    'assets/images/Ares.jpg',
    'assets/images/hero.jpg',
    'assets/images/hero2.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
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
            const SizedBox(width: 8),
            const Text(
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
              items: carouselImages.map((imagePath) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            
            Text(
              "Best Sellers",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: isPortrait ? 260 : 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: bestSellers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: isPortrait ? 160 : 200,
                    child: ProductCard(product: bestSellers[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            
            Text(
              "Featured Products",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isPortrait ? 2 : 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isPortrait ? 0.65 : 0.8,
              children: featuredProducts.map((product) {
                return ProductCard(product: product);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
