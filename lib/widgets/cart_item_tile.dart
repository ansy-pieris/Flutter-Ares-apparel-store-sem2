import 'package:flutter/material.dart';
import 'cors_safe_image.dart';

class CartItemTile extends StatelessWidget {
  final String name;
  final double price;
  final String image;
  final int quantity;
  final VoidCallback? onRemove;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  const CartItemTile({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    this.onRemove,
    this.onDecrease,
    this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    image.isNotEmpty && image.startsWith('http')
                        ? CorsSafeImage(imageUrl: image, fit: BoxFit.cover)
                        : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.shopping_bag,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onDecrease,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 20,
                ),
                Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 20,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
