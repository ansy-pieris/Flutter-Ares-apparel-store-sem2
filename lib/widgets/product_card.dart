import 'package:flutter/material.dart';
import '../models/product.dart';
import 'cors_safe_image.dart';

/// Simple ProductCard with clean design matching your original layout
/// Shows product image, name, and price in rupees
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  Widget _buildProductImage() {
    if (product.image.isNotEmpty && product.image.startsWith('http')) {
      debugPrint('🖼️ Loading CORS-safe image: ${product.image}');

      // Use CORS-safe image widget for reliable loading
      return CorsSafeImage(imageUrl: product.image, fit: BoxFit.cover);
    } else {
      // Fallback for no image URL
      return Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 32, color: Colors.grey),
            const SizedBox(height: 4),
            Text(
              'No image',
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: _buildProductImage(),
                ),
              ),
            ),

            // Product Details - Fixed height to prevent overflow
            Container(
              height: 80, // Fixed height to prevent overflow
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product Name and Description section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Product Name
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 2),

                        // Product Description
                        if (product.description.isNotEmpty &&
                            product.description != 'No description available')
                          Expanded(
                            child: Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else if (product.description ==
                            'No description available')
                          Text(
                            'Tap for more details',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue[600],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Product Price in LKR format
                  Text(
                    'Rs. ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
