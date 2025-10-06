import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final String name;
  final double price;
  final String image;

  const ProductDetailScreen({
    super.key,
    required this.name,
    required this.price,
    required this.image,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  void increment() {
    setState(() => quantity++);
  }

  void decrement() {
    if (quantity > 1) setState(() => quantity--);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.name), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.image,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            
            Text(
              widget.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            
            Text(
              "LKR ${widget.price.toStringAsFixed(2)}",
              style: theme.textTheme.titleMedium,
            ),

            const SizedBox(height: 16),

            
            const Text(
              "This is a stylish and high-quality product, ideal for everyday use. "
              "Made from premium materials, offering both comfort and durability.",
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 20),

            
            Row(
              children: [
                const Text("Quantity:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: decrement,
                ),
                Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: increment,
                ),
              ],
            ),

            const SizedBox(height: 24),

            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${widget.name} added to cart (x$quantity)")),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text("Add to Cart", 
                style:TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
