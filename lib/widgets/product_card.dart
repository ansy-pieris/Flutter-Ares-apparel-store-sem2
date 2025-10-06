import 'package:flutter/material.dart';
import '../models/product.dart'; 
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  product.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "LKR ${product.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "View Details",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
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
