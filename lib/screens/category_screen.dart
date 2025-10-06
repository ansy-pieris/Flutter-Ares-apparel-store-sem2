import 'package:flutter/material.dart';
import 'package:apparel_store/screens/men_products_screen.dart';
import 'package:apparel_store/screens/women_products_screen.dart';
import 'package:apparel_store/screens/footwear_products_screen.dart';
import 'package:apparel_store/screens/accessories_products_screen.dart';

class CategoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Men',
      'image': 'assets/images/shirt.jpg',
      'screen': MenProductsScreen(),
    },
    {
      'name': 'Women',
      'image': 'assets/images/womens.jpg',
      'screen': WomenProductsScreen(),
    },
    {
      'name': 'Footwear',
      'image': 'assets/images/sneakers.jpeg',
      'screen': FootwearProductsScreen(),
    },
    {
      'name': 'Accessories',
      'image': 'assets/images/watch.jpg',
      'screen': AccessoriesProductsScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
           
            AspectRatio(
              aspectRatio: isLandscape ? 21 / 9 : 16 / 9,
              child: Image.asset(
                'assets/images/hero.jpg',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: categories.map((category) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => category['screen']),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        color: theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: Image.asset(
                                category['image'],
                                width: isLandscape
                                    ? screenWidth * 0.25
                                    : screenWidth * 0.3,
                                height: isLandscape ? 120 : 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  category['name'],
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: theme.iconTheme.color,
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
