import 'package:flutter/material.dart';
import '../widgets/cart_item_tile.dart';
import 'checkout_screen.dart'; 

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems = [
    {'name': 'Sneakers', 'price': 14500.00, 'image': 'assets/images/sneakers.jpeg', 'quantity': 1},
    {'name': 'T-Shirt', 'price': 6000.00, 'image': 'assets/images/shirt.jpg', 'quantity': 2},
    {'name': 'Jacket', 'price': 12500.00, 'image': 'assets/images/jacket.jpg', 'quantity': 1},
    {'name': 'Cargo Pants', 'price': 8000.00, 'image': 'assets/images/cargo.webp', 'quantity': 2},
    {'name': 'Hoodie', 'price': 9500.00, 'image': 'assets/images/hoodie.webp', 'quantity': 2},
    {'name': 'Jeans', 'price': 15000.00, 'image': 'assets/images/shirts.jpg', 'quantity': 2},
  ];

  double get total => cartItems.fold(0, (sum, item) => sum + item['price'] * item['quantity']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) => CartItemTile(
                  name: cartItems[index]['name'],
                  price: cartItems[index]['price'],
                  image: cartItems[index]['image'],
                  quantity: cartItems[index]['quantity'],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Total: \LKR ${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
